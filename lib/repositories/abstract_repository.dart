


abstract class AbstractRepository<ObjT> {
  final String _myType = "AbstractRepository<${ObjT.toString()}>";

  Future<List<ObjT>> getAll() async {
    _printAbstractMethodError("getAll()");
    return [];
  }

  Future<void> update(ObjT obj) async {
    _printAbstractMethodError("update()");
  }

  Future<int> insert(ObjT obj) async {
    _printAbstractMethodError("insert()");
    return 0;
  }

  Future<int> delete(ObjT obj) async {
    _printAbstractMethodError("delete()");
    return 0;
  }

  void _printAbstractMethodError(String place){
    print("Error: $_myType::$place: abstract method is called");
  }
}
