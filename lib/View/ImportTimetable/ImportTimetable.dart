import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Model/ImportTimetable/ImportTimetableModel.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:provider/provider.dart';

class ImportTimetable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => ImportTimetableModel(),
        child: Container(
            padding: EdgeInsets.fromLTRB(30, 10, 30, 0), child: _buildBody()));
  }

  Widget _buildBody() {
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
        ),
        Expanded(
            child: Consumer<ImportTimetableModel>(
                builder: (context, importTimetableModel, _) => Center(
                      child: importTimetableModel.isLoading
                          ? CircularProgressIndicator()
                          : null,
                    )))
      ],
    );
  }

  Widget _buildImportButton() {
    return Consumer<ImportTimetableModel>(
        builder: (context, importTimetableModel, _) => RaisedButton(
              onPressed: () async {
                await importTimetableModel.importTimetable();
                CommonSnackBar.buildSnackBar(context, importTimetableModel.msg);
              },
              color: Colors.blue,
              child: Text(
                '导入课表',
                style: TextStyle(color: Colors.white),
              ),
            ));
  }

  Widget _buildTermDropdown() {
    return Consumer<ImportTimetableModel>(
        builder: (context, importTimetableModel, _) =>
            DropdownButtonHideUnderline(
              child: DropdownButton(
                value: importTimetableModel.term,
                items: _generateTermList(),
                onChanged: (value) {
                  importTimetableModel.term = value;
                },
              ),
            ));
  }

  Widget _buildYearDropdown() {
    return Consumer<ImportTimetableModel>(
      builder: (context, importTimetableModel, _) =>
          DropdownButtonHideUnderline(
              child: DropdownButton(
        value: importTimetableModel.year,
        items: _generateYearList(),
        onChanged: (value) {
          importTimetableModel.year = value;
        },
      )),
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
