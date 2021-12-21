


class Logger {
  String? module;

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

  void _log(String level, String message){
    if(module != null){
      _print_line("$level : $module : $message");
    } else {
      _print_line("$level : $message");
    }
  }

  void _print_line(String line){
    print(line);
  }
}