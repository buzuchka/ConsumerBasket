import 'package:flutter/foundation.dart';

class Logger {
  String? module;

  Logger([this.module]);

  Logger subModule(String submodule){
    if(module != null){
      return Logger("$module::$submodule");
    }
    return Logger(submodule);
  }

  void error(String message){
    _log("ERROR", message);
  }

  void warning(String message){
    _log("WARNING", message);
  }

  void info(String message){
    _log("INFO", message);
  }

  void debug(String message){
    _log("DEBUG", message);
  }

  void abstractMethodError(String method){
    subModule(method).error("abstract method default implementation is called");
  }

  void debugMarker([Object? marker]){
    debug("DEBUG MARKER [$marker]");
  }

  void _log(String level, String message){
    if(module != null){
      _printLine("$level : $module : $message");
    } else {
      _printLine("$level : $message");
    }
  }

  void _printLine(String line){
    if (kDebugMode) {
      print(line);
    }
  }
}