import 'package:flutter/foundation.dart';
import 'package:glutassistant/Model/CourseManage/Course.dart';
import 'package:glutassistant/Model/CourseManage/CourseModel.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';

class CoursePool with ChangeNotifier {
  List<SingleCourse> _courses = [];
  bool _isFirst = true;

  List<SingleCourse> get courses => _courses;

  Future<void> deleteCourse(int idx, int courseNo) async {
    SQLiteUtil su = await SQLiteUtil.getInstance();
    await su.deleteCourse(courseNo); // 数据库删
    _courses.removeAt(idx); // 列表删
    notifyListeners(); // 通知更新
  }

  Future<void> init() async {
    if (!_isFirst) return;
    await queryCoursePool();
    _isFirst = false;
  }

  Future<void> queryCoursePool() async {
    _courses.clear();
    List<Course> result = [];
    SQLiteUtil su = await SQLiteUtil.getInstance();
    result = await su.queryCourseList();
    for (var course in result) {
      _courses.add(SingleCourse.fromJson(course.toJson()));
    }
    notifyListeners();
  }
}
