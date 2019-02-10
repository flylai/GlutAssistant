import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtil {
  static String _dir;
  static Future<bool> fileExist(String filename) async {
    return await File(_dir + '/' + filename).exists();
  }

  static String getDir() {
    return _dir;
  }

  static Future init() async {
    if (_dir == null) _dir = (await getApplicationDocumentsDirectory()).path;
  }

  static String readFile(String filename) {
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

  static bool writeFile(String contents, String filename) {
    try {
      File file = new File(_dir + '/' + filename);
      file.writeAsStringSync(contents);
      return true;
    } catch (e) {
      return false;
    }
  }
}
