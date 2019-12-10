class Course {
  final String courseName;
  final String teacher;
  final int startWeek;
  final int endWeek;
  final int weekday;
  final String weekType;
  final int startTime;
  final int endTime;
  final String location;

  int courseNo;

  Course(
    this.courseName,
    this.teacher,
    this.startWeek,
    this.endWeek,
    this.weekday,
    this.weekType,
    this.startTime,
    this.endTime,
    this.location,
  );

  Course.fromJson(Map<String, dynamic> json)
      : courseName = json['courseName'],
        teacher = json['teacher'],
        startWeek = json['startWeek'],
        endWeek = json['endWeek'],
        weekday = json['weekday'],
        weekType = json['weekType'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        location = json['location'];

  Map<String, dynamic> toJson() => {
        'courseNo': courseNo,
        'courseName': courseName,
        'teacher': teacher,
        'startWeek': startWeek,
        'endWeek': endWeek,
        'weekday': weekday,
        'weekType': weekType,
        'startTime': startTime,
        'endTime': endTime,
        'location': location
      };
}
