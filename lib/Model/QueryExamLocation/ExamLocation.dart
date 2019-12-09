class ExamLocation {
  final String courseName;
  final String type;
  final String location;
  final String timeStr;
  final int timestamps;
  String leftTime;

  ExamLocation(
      this.courseName, this.type, this.location, this.timeStr, this.timestamps);

  ExamLocation.fromJson(Map<String, dynamic> json)
      : courseName = json['courseName'],
        type = json['type'],
        location = json['location'],
        timeStr = json['timeStr'],
        timestamps = json['timestamps'];

  Map<String, dynamic> toJson() => {
        'courseName': courseName,
        'type': type,
        'location': location,
        'timeStr': timeStr,
        'timestamps': timestamps
      };
}
