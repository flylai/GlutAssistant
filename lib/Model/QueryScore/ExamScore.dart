class ExamScore {
  final String courseName;
  final String teacher;
  final String subtitle;
  final String score;
  final String gpa;

  ExamScore(this.courseName, this.teacher, this.subtitle, this.score, this.gpa);

  ExamScore.fromJson(Map<String, dynamic> json)
      : courseName = json['courseName'],
        teacher = json['teacher'],
        subtitle = json['subtitle'],
        score = json['score'],
        gpa = json['gpa'];
}
