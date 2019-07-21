import 'package:flutter/foundation.dart';
import 'package:glutassistant/Model/CourseManage/CourseModel.dart';
import 'package:glutassistant/Utility/SQLiteUtil2.dart';

class CoursePool with ChangeNotifier {
  List<SingleCourse> _courses = [];
  bool _isFirst = true;

  List<SingleCourse> get courses => _courses;

  Future<void> queryCoursePool() async {
    _courses.clear();
    List<Map<String, dynamic>> result = [];
    SQLiteUtil su = await SQLiteUtil.getInstance();
    result = await su.queryCourseList();
    for (var course in result) {
      SingleCourse singleCourse = SingleCourse();
      singleCourse.fromMap(course);
      _courses.add(singleCourse);
    }
    notifyListeners();
  }

  Future<void> init() async {
    if (!_isFirst) return;
    await queryCoursePool();
    _isFirst = false;
  }
}
