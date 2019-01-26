class BaseFunctionUtil {
  static int getNumByWeekDay(String weekday) {
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
}
