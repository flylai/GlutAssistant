import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Utility/HttpUtil.dart' as http;
import 'package:glutassistant/Common/Constant.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseFunctionUtil {
  static String getDuration(DateTime t1, DateTime t2) {
    int diff =
        t1.millisecondsSinceEpoch ~/ 1000 - t2.millisecondsSinceEpoch ~/ 1000;
    int day = diff ~/ 86400;
    int hour = day == 0 ? diff ~/ 3600 : (diff - 86400 * day) ~/ 3600;
    int minute;
    if (day == 0 && hour == 0)
      minute = diff ~/ 60;
    else if (day != 0 && hour == 0)
      minute = (diff - 86400 * day) ~/ 60;
    else if (day != 0 && hour != 0)
      minute = (diff - day * 86400 - hour * 3600) ~/ 60;
    else if (day == 0 && hour != 0) minute = (diff - 3600 * hour) ~/ 60;

    String duration = '';
    if (day != 0) duration += '$day天';
    if (hour != 0) duration += '$hour小时';
    duration += '$minute分钟';
    return duration;
  }

  static int getNumByWeekday(String weekday) {
    switch (weekday) {
      case '星期一':
        return 1;
      case '星期二':
        return 2;
      case '星期三':
        return 3;
      case '星期四':
        return 4;
      case '星期五':
        return 5;
      case '星期六':
        return 6;
      case '星期天':
        return 7;
      case '星期日':
        return 7;
    }
    return 0;
  }

  static Color getRandomColor() {
    return Color(
        Constant.VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
  }

  static String getTimeByNum(int i) {
    String _i;
    if (i > 4 && i < 7)
      _i = '中午${i - 4}';
    else if (i > 6)
      _i = (i - 2).toString();
    else
      _i = i.toString();
    return _i;
  }

  static String getWeekdayByNum(int weekday) {
    switch (weekday) {
      case 1:
        return '一';
      case 2:
        return '二';
      case 3:
        return '三';
      case 4:
        return '四';
      case 5:
        return '五';
      case 6:
        return '六';
      case 7:
        return '日';
    }
    return '未知';
  }

  /// 每次启动看心情检查更新
  static checkUpdate(BuildContext context) async {
    // 随机个数看心情检查更新
    if (Random.secure().nextInt(4) != 2 || Constant.VAR_UPDATE_CHECKED != 0)
      return;
    Constant.VAR_UPDATE_CHECKED = 1;
    var result;
    try {
      result = await http.get(Constant.URL_CHECK_UPDDATE, '');
    } catch (e) {
      return;
    }
    var json = jsonDecode(result.body);
    if (json['version'] == Constant.VAR_VERSION) return;
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('检查更新'),
            content: Text(json['msg']),
            actions: <Widget>[
              FlatButton(
                child: Text('下次再说'),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('前往下载'),
                onPressed: () async {
                  if (await canLaunch(Constant.LIST_ABOUT_ITEM[0][2])) {
                    await launch(Constant.LIST_ABOUT_ITEM[0][2]);
                  }
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
