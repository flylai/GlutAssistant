class FitnessDetail {
  /// 项目名称
  final String name;

  /// 记录
  final String record;

  /// 分数
  final String score;

  /// 结论
  final String result;

  FitnessDetail(this.name, this.record, this.score, this.result);

  FitnessDetail.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        record = json['record'],
        score = json['score'],
        result = json['result'];
}

class FitnessResult {
  /// 加分
  final String add;

  /// 减分
  final String sub;

  /// 总分
  final String total;

  /// 结论
  final String conclusion;

  FitnessResult(this.add, this.sub, this.total, this.conclusion);

  FitnessResult.fromJson(Map<String, dynamic> json)
      : add = json['add'],
        sub = json['sub'],
        total = json['total'],
        conclusion = json['conclusion'];
}
