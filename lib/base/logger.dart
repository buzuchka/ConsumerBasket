


class Logger {
  String? module;
  int debugMarkerCouter = 0;

  Logger([this.module = null]);

  Logger subModule(String submodule){
    if(module != null){
      return Logger("$module::$submodule");
    }
    return Logger(submodule);
  }

  void error(String message){
    _log("Error", message);
  }

  void warning(String message){
    _log("Warning", message);
  }

  void info(String message){
    _log("Info", message);
  }

  void debug(String message){
    _log("DEBUG", message);
  }

  void abstractMethodError(String method){
    subModule(method).error("abstract method default implementation is called");
  }

  void debugMarker([Object? marker]){
    if(marker != null) {
      if(marker is int){
        debugMarkerCouter = marker + 1;
      }
    }else {
      marker = debugMarkerCouter;
      debugMarkerCouter++;
    }
    debug("Debug maker [$marker]");
  }

  void _log(String level, String message){
    if(module != null){
      _printLine("$level : $module : $message");
    } else {
      _printLine("$level : $message");
    }
  }

  void _printLine(String line){
    print(line);
  }
}