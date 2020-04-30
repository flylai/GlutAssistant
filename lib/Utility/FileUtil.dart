import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtil {
  static String _dir = '/data/data/com.lkm.glutassistant/app_flutter';
  static FileUtil _instance;
  static Future<FileUtil> get instance async {
    return await getInstance();
  }

  FileUtil._();
  bool fileExist(String filename) {
    return File(_dir + '/' + filename).existsSync();
  }

  String getDir() {
    return _dir;
  }

  Future init() async {
    String tmpDir = (await getApplicationDocumentsDirectory()).path;
    if (tmpDir == null) _dir = tmpDir;
  }

  String readFile(String filename) {
    String content = 'ERROR';
    try {
      File file = new File(_dir + '/' + filename);
      if (fileExist(filename)) content = file.readAsStringSync();
    } catch (e) {
      print(e);
      content = 'ERROR';
    }
    return content;
  }

  bool writeFile(String contents, String filename) {
    try {
      File file = new File(_dir + '/' + filename);
      file.writeAsStringSync(contents);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<FileUtil> getInstance() async {
    if (_instance == null) {
      _instance = new FileUtil._();
      await _instance.init();
    }
    return _instance;
  }
}
