import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/base/logger.dart';

class DbFieldInfo{
  String table;
  String name;
  String type;
  bool index;
  bool unique;

  String get indexName => "index_${table}_${name}";

  DbFieldInfo(this.table, this.name,this.type,this.index,this.unique);
}

class DbRepositoryVersionControl {

  final Logger _logger = Logger("DbRepositoryVersionControl");

  static const String _tableName = "repository_version_control";
  static const String _columnTableName = "table_name";
  static const String _columnFieldName = "field_name";
  static const String _columnFieldType = "field_type";
  static const String _columnFieldIndex = "field_index";
  static const String _columnFieldUnique = "field_unique";
  static const String _columnId = 'id';

  late Database _db;

  List<AbstractDbRepository> _repositories = [];

  // table_name -> field_name -> type
  final Map<String,Map<String,DbFieldInfo>> _fieldsByTable = {};

  init(Database db, List<AbstractDbRepository> repositories) {
    _db = db;
    _repositories = repositories;
  }

  createDdSchema() async{
    _db.execute("""
      CREATE TABLE IF NOT EXISTS $_tableName (
         $_columnId INTEGER PRIMARY KEY NOT NULL
         $_columnTableName TEXT NOT NULL,
         $_columnFieldName TEXT NOT NULL,
         $_columnFieldType TEXT NOT NULL,
         $_columnFieldIndex BOOLEAN NOT NULL,
         $_columnFieldUnique BOOLEAN NOT NULL
      );    
      
      CREATE UNIQUE INDEX IF NOT EXISTS 
        index_table_field ON $_tableName ($_columnTableName, $_columnFieldName);
      """
    );
    await _updateDbSchema();
  }

  updateDbSchema() async {
    List<Map<String, Object?>> raw_fields = await _db.query(_tableName);
    for(var raw_field in raw_fields){
      String tableName = raw_field[_columnTableName] as String;
      String fieldName = raw_field[_columnFieldName] as String;
      String fieldType = raw_field[_columnFieldType] as String;
      bool fieldIndex = raw_field[_columnFieldType] as bool;
      bool fieldUnique = raw_field[_columnFieldType] as bool;
      Map<String,DbFieldInfo> fields = _fieldsByTable.putIfAbsent(tableName, () => <String,DbFieldInfo>{});
      if(fields.containsKey(fieldName)){
        _logger.subModule("updateDbSchema()").error("Found duplicated field $tableName.$fieldName");
      }
      fields[fieldName] = DbFieldInfo(tableName, fieldName, fieldType, fieldIndex, fieldUnique);
    }
    await _updateDbSchema();
  }

  _updateDbSchema() async {
    var logger = _logger.subModule("_updateDbSchema()");
    List<String> executingLines = [];
    for(var repository in _repositories){
      var tableName = repository.tableName;
      var repFields = repository.fieldsByName.values;
      var tableFields = _fieldsByTable[tableName];

      if(tableFields == null){
        logger.warning("table $tableName does not exist");
        executingLines.add("""
          CREATE TABLE IF NOT EXISTS $tableName (
             $_columnId INTEGER PRIMARY KEY NOT NULL,
          )
        """);
        tableFields = {};
      }

      for(var repField in repFields){
        var dbFieldInfo = tableFields[repField.name];

        if(dbFieldInfo != null){
          if(dbFieldInfo.type != repField.sqlType){
            if(dbFieldInfo.index){
              executingLines.add("""
                DROP INDEX IF EXISTS ${dbFieldInfo.indexName};
              """);
            }
            executingLines.add("""
              ALTER TABLE $tableName DROP COLUMN ${dbFieldInfo.name};
            """);
          } else {
            if(
          }
        } else {

        }
      }
    }
  }


}
