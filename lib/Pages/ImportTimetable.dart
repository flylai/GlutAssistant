import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';
import 'package:glutassistant/Widget/ProgressDialog.dart';
import 'package:glutassistant/Widget/SnackBar.dart';

class ImportTimetable extends StatefulWidget {
  _ImportTimetableState createState() => _ImportTimetableState();
}

class _ImportTimetableState extends State<ImportTimetable> {
  int _selectYearValue = DateTime.now().year;
  int _selectTermValue = 2;
  bool _isLoading = false;
  String _cookie;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 50), child: _buildBody());
  }

  @override
  void initState() {
    super.initState();
    FileUtil.getFileDir();
    SQLiteUtil.init();
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: new ProgressDialog());
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _buildYearDropdown(),
            ),
            Expanded(
              child: _buildTermDropdown(),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildImportButton(),
            )
          ],
        )
      ],
    );
  }

  Widget _buildImportButton() {
    return RaisedButton(
      onPressed: () {
        _cookie = FileUtil.readFile(Constant.FILE_SESSION);
        setState(() {
          _isLoading = true;
        });
        HttpUtil.importTimetable(
            _selectYearValue.toString(), _selectTermValue.toString(), _cookie,
            (callback) async {
          if (callback['success'] && callback['data'].length > 0) {
            await SQLiteUtil.dropTable();
            await SQLiteUtil.createTable();
            for (var item in callback['data'])
              await SQLiteUtil.insertTimetable(item);
            CommonSnackBar.buildSnackBar(context, '课表导入成功了，请前往课程表界面查看');
          } else {
            CommonSnackBar.buildSnackBar(
                context, '获取得到的课表为空，请检查是否选对学年学期或者重新登录教务');
          }
          setState(() {
            _isLoading = false;
          });
        });
      },
      color: Colors.blue,
      child: Text(
        '导入课表',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTermDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selectTermValue,
        items: _generateTermList(),
        onChanged: (value) {
          setState(() {
            _selectTermValue = value;
            print(value);
          });
        },
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selectYearValue,
        items: _generateYearList(),
        onChanged: (value) {
          setState(() {
            _selectYearValue = value;
          });
        },
      ),
    );
  }

  List<DropdownMenuItem> _generateTermList() {
    List<DropdownMenuItem> items = List();
    DropdownMenuItem item = DropdownMenuItem(value: 1, child: Text('春'));
    items.add(item);
    DropdownMenuItem item2 = DropdownMenuItem(value: 2, child: Text('秋'));
    items.add(item2);
    return items;
  }

  List<DropdownMenuItem> _generateYearList() {
    List<DropdownMenuItem> items = List();
    int year = DateTime.now().year;
    for (var i = 0; i < 5; i++) {
      int _year = year - i;
      DropdownMenuItem item =
          DropdownMenuItem(value: _year, child: Text(_year.toString()));
      items.add(item);
    }
    return items;
  }
}
