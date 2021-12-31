import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/base/logger.dart';


// Internal

class DbRepositorySupervisorImpl {

  late String databaseName;
  final List<AbstractDbRepository> repositories;

  DbRepositorySupervisorImpl(this.repositories);

  openDb(String databaseName) async {
    this.databaseName = databaseName;
    String _databaseFilePath = join(await getDatabasesPath(), databaseName);
    _db = await openDatabase(
        _databaseFilePath,
        version: 1,
        onCreate: (Database db, int version) async => await onDbCreate(db),
        onOpen: (Database db) async => onDbOpen(db)
    );
  }


  final Logger _logger = Logger("DbRepositorySupervisor");

  static const String _tableName = "repository_version_control";
  static const String _columnTableName = "table_name";
  static const String _columnColumnName = "column_name";
  static const String _columnColumnType = "column_type";
  static const String _columnIsIndexed = "is_indexed";
  static const String _columnIsUnique = "is_unique";
  static const String _columnId = 'id';

  late Database _db;

  // table_name -> column_name -> type
  final Map<String, Map<String, DbColumnInfo>> _columnsByTable = {};


  onDbCreate(Database db) async {
    _logger.info("onDbCreate");
    _db = db;
    await _createVersionControlTable();
  }

  onDbOpen(Database db) async {
    var logger = _logger.subModule("onDbOpen()");
    // logger.info("");
    _db = db;
    await _loadColumnInfo();
    await _updateDbSchema();
    _setRepDb(db);
  }

  _setRepDb(Database db) {
    for (var rep in repositories) {
      rep.db = db;
    }
  }

  _createVersionControlTable() async{
    await _execute("""
        CREATE TABLE IF NOT EXISTS $_tableName (
           $_columnId INTEGER PRIMARY KEY NOT NULL,
           $_columnTableName TEXT NOT NULL,
           $_columnColumnName TEXT NOT NULL,
           $_columnColumnType TEXT NOT NULL,
           $_columnIsIndexed BOOLEAN NOT NULL,
           $_columnIsUnique BOOLEAN NOT NULL
        );            
    """);
    await _execute("""
        CREATE UNIQUE INDEX IF NOT EXISTS 
          index_table_field ON $_tableName ($_columnTableName, $_columnColumnName)
        ;
    """);
  }

  _loadColumnInfo() async {
    var logger = _logger.subModule("_loadColumnInfo()");
    _columnsByTable.clear();
    List<Map<String, Object?>> rawFields = await _db.query(_tableName);
    for(var rawField in rawFields){
      DbColumnInfo columnInfo = _columnInfoFromDbMap(rawField);
      Map<String,DbColumnInfo> fields = _columnsByTable.putIfAbsent(
          columnInfo.tableName, () => <String,DbColumnInfo>{});
      if(fields.containsKey(columnInfo.columnName)){
        _logger.subModule("updateDbSchema()").error("Found duplicated column info ${columnInfo.tableColumnName}");
      }
      fields[columnInfo.columnName] = columnInfo;
    }
  }

  _updateDbSchema_3_35_0() async {
    //var logger = _logger.subModule("_updateDbSchema()");

    for (var repository in repositories) {
      var tableName = repository.tableName;
      var repFields = repository.fieldsByName;
      var dbColumns = _columnsByTable.putIfAbsent(tableName, () => {});

      if (dbColumns.isEmpty) {
        await _createTable(tableName, repFields);
      } else{
        await _updateFields(dbColumns,repFields);
      }

    }
  }

  _updateDbSchema() async {
    //var logger = _logger.subModule("_updateDbSchema()");

    for (var repository in repositories) {
      var tableName = repository.tableName;
      var repFields = repository.fieldsByName;
      var dbColumns = _columnsByTable.putIfAbsent(tableName, () => {});

      if (dbColumns.isEmpty) {
        await _createTable(tableName, repFields);
        dbColumns.addAll(repFields);
      } else {
        if (_isNeedDropTable(dbColumns, repFields)) {
          await _dropTable(tableName);
          await _createTable(tableName, repFields);
        } else {
          await _updateFields(dbColumns, repFields);
        }
      }
      dbColumns.clear();
      dbColumns.addAll(repFields);

    }
  }

  _isNeedDropTable(
      Map<String, DbColumnInfo> dbColumns,
      Map<String, DbColumnInfo> repFields) {
    for (var repField in repFields.values){
      var dbColumnInfo = dbColumns[repField.columnName];
      if (dbColumnInfo != null) {
        if(dbColumnInfo.sqlType != repField.sqlType) {
          return true;
        }
        if(!dbColumnInfo.isUnique && repField.isUnique){
          return true;
        }
      }
    }
    return false;
  }

  _updateFields(
      Map<String, DbColumnInfo> dbColumns,
      Map<String, DbColumnInfo> repFields) async {
    for (var repField in repFields.values) {
      var dbColumnInfo = dbColumns[repField.columnName];
      bool dropColumn = false;
      bool dropIndex = false;
      bool addColumn = false;
      bool addIndex = false;

      if (dbColumnInfo != null) {
        if (dbColumnInfo.sqlType != repField.sqlType) {
          dropColumn = true;
          dropIndex = dbColumnInfo.isIndexed;
        } else if (dbColumnInfo.isIndexed != repField.isIndexed
            || dbColumnInfo.isUnique != repField.isUnique) {
          dropIndex = dbColumnInfo.isIndexed;
          addIndex = repField.isIndexed;
        }
      } else {
        addColumn = true;
        addIndex = repField.isIndexed;
      }

      if (dropIndex) {
        await _dropIndex(dbColumnInfo!);
      }
      if (dropColumn) {
        await _dropColumn(dbColumnInfo!);
      }
      if (addColumn) {
        await _addColumn(repField);
      }
      if (addIndex) {
        await _addIndex(repField);
      }
      if (dropIndex || dropColumn || addColumn || addIndex) {
        await _updateColumnInfo(repField);
      }
    }
  }

  _dropTable(String tableName) async{
    await _execute("""
      DROP TABLE IF EXISTS $tableName;
    """);

    await _execute("""
      DELETE FROM $_tableName WHERE $_columnTableName = '$tableName';
    """);
  }

  _execute(String toExecute) async {
    _logger.info("Db update: $toExecute");
    await _db.execute(toExecute);
  }

  _createTable(String tableName, Map<String, DbColumnInfo> repFields) async{
    await _execute( """
     CREATE TABLE IF NOT EXISTS $tableName (
             $_columnId INTEGER PRIMARY KEY NOT NULL
     );
    """);

    for(var repField in repFields.values){
      await _addColumn(repField);
      if(repField.isIndexed){
        await _addIndex(repField);
      }
      await _updateColumnInfo(repField);
    }
  }

  _dropColumn(DbColumnInfo dbColumnInfo) async {
    await _execute("""
      ALTER TABLE ${dbColumnInfo.tableName} 
        DROP COLUMN ${dbColumnInfo.columnName};
    """);
  }

  _dropIndex(DbColumnInfo dbColumnInfo) async {
    await _execute("DROP INDEX IF EXISTS ${dbColumnInfo.indexName};");
  }

  _addColumn(DbColumnInfo info) async{
    await _execute("""
      ALTER TABLE ${info.tableName} ADD COLUMN ${info.sqlColumnDef};
    """);
  }

  _addIndex(DbColumnInfo info) async {
    String uniqueStr = "";
    if(info.isUnique){
      uniqueStr = "UNIQUE";
    }
    await _execute("""
      CREATE $uniqueStr INDEX IF NOT EXISTS 
        ${info.indexName} ON ${info.tableName} (${info.columnName});
     """);
  }

  _updateColumnInfo(DbColumnInfo info) async {
    await _execute("""
      INSERT INTO $_tableName 
        ($_columnTableName, $_columnColumnName, $_columnColumnType, $_columnIsIndexed, $_columnIsUnique)
        VALUES('${info.tableName}', '${info.columnName}', '${info.sqlType}', ${info.isIndexed}, ${info.isUnique})
        ON CONFLICT($_columnTableName, $_columnColumnName)
        DO UPDATE SET 
        $_columnColumnType = '${info.sqlType}',
        $_columnIsIndexed =  ${info.isIndexed},
        $_columnIsUnique = ${info.isUnique}
      ;
    """);
  }

  DbColumnInfo _columnInfoFromDbMap(Map<String, Object?> dbRawObj){
    var result = DbColumnInfo();
    result.tableName = dbRawObj[_columnTableName] as String;
    result.columnName = dbRawObj[_columnColumnName] as String;
    result.sqlType = dbRawObj[_columnColumnType] as String;
    result.isIndexed = (dbRawObj[_columnIsIndexed] as int) != 0;
    result.isUnique = (dbRawObj[_columnIsUnique] as int) != 0;
    return result;
  }


}