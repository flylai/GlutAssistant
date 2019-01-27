import 'package:path_provider/path_provider.dart';

import 'dart:io';

class FileUtil {
  static String _dir;
  static Future<String> getFileDir() async {
    _dir = (await getApplicationDocumentsDirectory()).path;
    return _dir;
  }

  static Future<bool> fileExist(String filename) async {
    return await File(_dir + '/' + filename).exists();
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
      print(e);
      return false;
    }
  }
}
