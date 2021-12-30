import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/base/logger.dart';


class DbRepositorySupervisor {

  DbRepositorySupervisor(List<AbstractDbRepository> repositories) :
        _impl = DbRepositorySupervisorImpl(repositories);

  // opens database and updates schemas in db if required
  openDatabase(String databaseName) async {
    await _impl.openDb(databaseName);
  }

  final DbRepositorySupervisorImpl _impl;
}


//----------------------------------------
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
    logger.debugMarker(1);
    await _loadColumnInfo();
    logger.debugMarker(2);
    await _updateDbSchema();
    logger.debugMarker(3);
    _setRepDb(db);
    logger.debugMarker(4);
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
    logger.debugMarker(1);
    List<Map<String, Object?>> rawFields = await _db.query(_tableName);
    for(var rawField in rawFields){
      logger.debugMarker(2);
      DbColumnInfo columnInfo = _columnInfoFromDbMap(rawField);
      logger.debugMarker(3);
      Map<String,DbColumnInfo> fields = _columnsByTable.putIfAbsent(
          columnInfo.tableName, () => <String,DbColumnInfo>{});
      logger.debugMarker(4);
      if(fields.containsKey(columnInfo.columnName)){
        _logger.subModule("updateDbSchema()").error("Found duplicated column info ${columnInfo.tableColumnName}");
      }
      logger.debugMarker(5);
      fields[columnInfo.columnName] = columnInfo;
      logger.debugMarker(6);
    }
  }

  _updateDbSchema() async {
    var logger = _logger.subModule("_updateDbSchema()");
    // List<String> executingLines = [];

    for (var repository in repositories) {
      var tableName = repository.tableName;
      var repFields = repository.fieldsByName.values;
      var dbColumns = _columnsByTable.putIfAbsent(tableName, () => {});

      if (dbColumns.isEmpty) {
        logger.warning("table $tableName does not exist");
        _execute(_createTable(tableName)); //!
      }

      for (var repField in repFields) {
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
          _execute(_dropIndex(dbColumnInfo!));
        }
        if (dropColumn) {
          _execute(_dropColumn(dbColumnInfo!));
        }
        if (addColumn) {
          _execute(_addColumn(repField));
        }
        if (addIndex) {
          _execute(_addIndex(repField));
        }
        if (dropIndex || dropColumn || addColumn || addIndex) {
          _execute(_updateColumnInfo(repField));
        }
        dbColumns[repField.columnName] = repField;
      }
    }
  }

  _execute(String toExecute) async {
    _logger.info("Db update: $toExecute");
    await _db.execute(toExecute);
  }

  String _createTable(String tableName){
    return """
     CREATE TABLE IF NOT EXISTS $tableName (
             $_columnId INTEGER PRIMARY KEY NOT NULL
     );
    """;
  }

  String _dropColumn(DbColumnInfo dbColumnInfo) {
    return """
      ALTER TABLE ${dbColumnInfo.tableName} 
        DROP COLUMN ${dbColumnInfo.columnName};
    """;
  }

  String _dropIndex(DbColumnInfo dbColumnInfo) {
    return "DROP INDEX IF EXISTS ${dbColumnInfo.indexName};";
  }

  String _addColumn(DbColumnInfo info) {
    return """
      ALTER TABLE ${info.tableName} ADD COLUMN ${info.sqlColumnDef};
    """;
  }

  String _addIndex(DbColumnInfo info) {
    String uniqueStr = "";
    if(info.isUnique){
      uniqueStr = "UNIQUE";
    }
    return """
      CREATE $uniqueStr INDEX IF NOT EXISTS 
        ${info.indexName} ON ${info.tableName} (${info.columnName});
     """;
  }

  String _updateColumnInfo(DbColumnInfo info) {
    return """
      INSERT INTO $_tableName 
        ($_columnTableName, $_columnColumnName, $_columnColumnType, $_columnIsIndexed, $_columnIsUnique)
        VALUES('${info.tableName}', '${info.columnName}', '${info.sqlType}', ${info.isIndexed}, ${info.isUnique})
        ON CONFLICT($_columnTableName, $_columnColumnName)
        DO UPDATE SET 
        $_columnColumnType = '${info.sqlType}',
        $_columnIsIndexed =  ${info.isIndexed},
        $_columnIsUnique = ${info.isUnique}
      ;
    """;
  }

  DbColumnInfo _columnInfoFromDbMap(Map<String, Object?> dbRawObj){
    var result = DbColumnInfo();
    result.tableName = dbRawObj[_columnTableName] as String;
    result.columnName = dbRawObj[_columnColumnName] as String;
    result.sqlType = dbRawObj[_columnColumnType] as String;
    result.isIndexed = dbRawObj[_columnIsIndexed] as bool;
    result.isUnique = dbRawObj[_columnIsUnique] as bool;
    return result;
  }


}
