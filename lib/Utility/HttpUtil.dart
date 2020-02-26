import 'dart:core';

import 'package:glutassistant/Common/Constant.dart';
import 'package:http/http.dart' as http;

Future<http.Response> get(String url, String cookie) {
  var head = {'cookie': cookie};
  return http
      .get(url, headers: head)
      .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
}

Future<http.Response> post(String url, Map<String, dynamic> postData, {String cookie = ''}) {
  var head = {'cookie': cookie};
  return http
      .post(url, headers: head, body: postData)
      .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
}
