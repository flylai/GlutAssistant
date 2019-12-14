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
  Future<bool> fileExist(String filename) async {
    return await File(_dir + '/' + filename).exists();
  }

  String getDir() {
    return _dir;
  }

  Future init() async {
    if (_dir == null) _dir = (await getApplicationDocumentsDirectory()).path;
  }

  String readFile(String filename) {
    String content;
    try {
      File file = new File(_dir + '/' + filename);
      content = file.readAsStringSync();
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
