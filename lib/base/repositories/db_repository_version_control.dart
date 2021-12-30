import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/base/logger.dart';


class DbRepositoryVersionControl {

  final Logger _logger = Logger("DbRepositoryVersionControl");

  static const String _tableName = "repository_version_control";
  static const String _columnTableName = "table_name";
  static const String _columnColumnName = "column_name";
  static const String _columnColumnType = "column_type";
  static const String _columnIsIndexed = "is_indexed";
  static const String _columnIsUnique = "is_unique";
  static const String _columnId = 'id';

  late Database _db;

  final List<AbstractDbRepository> _repositories;

  // table_name -> column_name -> type
  final Map<String, Map<String, DbColumnInfo>> _columnsByTable = {};

  DbRepositoryVersionControl(List<AbstractDbRepository> repositories) :
        _repositories = repositories;

  createDdSchema(Database db) async{
    _db = db;
    await _createVersionControlTable();
    await _updateDbSchema();
  }

  updateDbSchema(Database db) async {
    _db = db;
    await _loadColumnInfo();
    await _updateDbSchema();
  }

  setRepDb(Database db){
    for(var rep in _repositories){
      rep.db = db;
    }
  }

  _createVersionControlTable() async{
    await _db.execute("""
      CREATE TABLE IF NOT EXISTS $_tableName (
         $_columnId INTEGER PRIMARY KEY NOT NULL
         $_columnTableName TEXT NOT NULL,
         $_columnColumnName TEXT NOT NULL,
         $_columnColumnType TEXT NOT NULL,
         $_columnIsIndexed BOOLEAN NOT NULL,
         $_columnIsUnique BOOLEAN NOT NULL
      );            
      CREATE UNIQUE INDEX IF NOT EXISTS 
        index_table_field ON $_tableName ($_columnTableName, $_columnColumnName);
      """
    );
  }

  _loadColumnInfo() async {
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

  _updateDbSchema() async {
    var logger = _logger.subModule("_updateDbSchema()");
    List<String> executingLines = [];

    for(var repository in _repositories){
      var tableName = repository.tableName;
      var repFields = repository.fieldsByName.values;
      var dbColumns = _columnsByTable.putIfAbsent(tableName, () => {});

      if(dbColumns.isEmpty){
        logger.warning("table $tableName does not exist");
        executingLines.add(_createTable(tableName));            //!
      }

      for(var repField in repFields){
        var dbColumnInfo = dbColumns[repField.columnName];
        bool dropColumn = false;
        bool dropIndex = false;
        bool addColumn = false;
        bool addIndex = false;

        if(dbColumnInfo != null){
          if(dbColumnInfo.sqlType != repField.sqlType){
            dropColumn = true;
            dropIndex = dbColumnInfo.isIndexed;
          } else if(dbColumnInfo.isIndexed != repField.isIndexed
              || dbColumnInfo.isUnique != repField.isUnique){
            dropIndex = dbColumnInfo.isIndexed;
            addIndex = repField.isIndexed;
          }
        } else {
          addColumn = true;
          addIndex = repField.isIndexed;
        }

        if(dropIndex){
          executingLines.add(_dropIndex(dbColumnInfo!));
        }
        if(dropColumn){
          executingLines.add(_dropColumn(dbColumnInfo!));
        }
        if(addColumn){
          executingLines.add(_addColumn(repField));
        }
        if(addIndex){
          executingLines.add(_addIndex(repField));
        }
        if(dropIndex || dropColumn || addColumn || addIndex){
          executingLines.add(_updateColumnInfo(repField));
        }
        dbColumns[repField.columnName] = repField;
      }
    }
  }

  String _createTable(String tableName){
    return """
     CREATE TABLE IF NOT EXISTS $tableName (
             $_columnId INTEGER PRIMARY KEY NOT NULL,
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
        VALUES(${info.tableName}, ${info.columnName}, ${info.sqlType}, ${info.isIndexed}, ${info.isUnique})
        ON CONFLICT($_columnTableName, $_columnColumnName)
        DO UPDATE SET 
        $_columnColumnType = ${info.sqlType},
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
    result.isIndexed = dbRawObj[_columnColumnType] as bool;
    result.isUnique = dbRawObj[_columnColumnType] as bool;
    return result;
  }


}
