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

  static String getWeekdayByNum(int weekday) {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
    }
    return '未知';
  }
}
