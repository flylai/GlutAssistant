class BaseFunctionUtil {
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
}
