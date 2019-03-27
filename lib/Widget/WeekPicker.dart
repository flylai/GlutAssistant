import 'package:flutter/material.dart';

typedef WeekChangedCallback(int startWeek, int endWeek, int weekType);

class WeekPicker {
  static void showWeekPicker(
    BuildContext context, {
    bool showTitleActions: true,
    int startWeek,
    int endWeek,
    int weekType,
    Widget cancel,
    Widget confirm,
    WeekChangedCallback onChanged,
    WeekChangedCallback onConfirm,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return _WeekPickerComponent(
            startWeek: startWeek,
            endWeek: endWeek,
            weekType: weekType,
            onChanged: onChanged,
            onConfirm: onConfirm,
          );
        });
  }
}

class _WeekPickerComponent extends StatefulWidget {
  final int startWeek;
  final int endWeek;
  final int weekType;

  final WeekChangedCallback onChanged;
  final WeekChangedCallback onConfirm;

  _WeekPickerComponent(
      {Key key,
      this.startWeek,
      this.endWeek,
      this.weekType,
      this.onChanged,
      this.onConfirm})
      : super(key: key);

  _WeekPickerComponentState createState() =>
      _WeekPickerComponentState(this.startWeek, this.endWeek, this.weekType);
}

class _WeekPickerComponentState extends State<_WeekPickerComponent> {
  int _currentStartWeek, _currentEndWeek, _currentWeekType;//0全 1单 2双
  List<bool> _selected = new List(30);
  Set<int> _weeks = {};

  _WeekPickerComponentState(
      this._currentStartWeek, this._currentEndWeek, this._currentWeekType) {
    if (_currentStartWeek != 0 &&
        _currentStartWeek != null &&
        _currentEndWeek != 0 &&
        _currentEndWeek != null) {
      this._selected[_currentStartWeek] = true;
      this._selected[_currentEndWeek] = true;
      _weeks.add(_currentStartWeek);
      _weeks.add(_currentEndWeek);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      height: 405,
      width: 350,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
            child: Text(
              '选择上课周区间',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            height: 270,
            width: 300,
            child: GridView.count(
              crossAxisCount: 5,
              primary: false,
              children: _generateGridView(),
            ),
          ),
          _buildWeekTypePicker(),
          _buildSaveButton()
        ],
      ),
    ));
  }

  int max(int a, int b) {
    return a > b ? a : b;
  }

  int min(int a, int b) {
    return a > b ? b : a;
  }

  void setEndWeek(int index) {
    if (_currentEndWeek != index) {
      _currentEndWeek = index;
      _notifyChanged();
    }
  }

  void setStartWeek(int index) {
    if (_currentStartWeek != index) {
      _currentStartWeek = index;
      _notifyChanged();
    }
  }

  void setWeekType(int index) {
    if (_currentWeekType != index) {
      _currentWeekType = index;
      setState(() {});
      _notifyChanged();
    }
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: InkWell(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 7, 20, 7),
                child: Text(
                  '确定',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
              onTap: () {
                if (widget.onConfirm != null)
                  widget.onConfirm(
                      _currentStartWeek, _currentEndWeek, _currentWeekType);
                  Navigator.of(context).pop();
              },
            ))
      ],
    );
  }

  Widget _buildWeekTypePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FlatButton(
          child: Text('全周',
              style: TextStyle(
                  color: _currentWeekType == 0 ? Colors.white : Colors.black)),
          color: _currentWeekType == 0 ? Colors.cyan : null,
          onPressed: () {
            setWeekType(0);
          },
        ),
        FlatButton(
          child: Text('单周',
              style: TextStyle(
                  color: _currentWeekType == 1 ? Colors.white : Colors.black)),
          color: _currentWeekType == 1 ? Colors.cyan : null,
          onPressed: () {
            setWeekType(1);
          },
        ),
        FlatButton(
          child: Text('双周',
              style: TextStyle(
                  color: _currentWeekType == 2 ? Colors.white : Colors.black)),
          color: _currentWeekType == 2 ? Colors.cyan : null,
          onPressed: () {
            setWeekType(2);
          },
        ),
      ],
    );
  }

  List<Widget> _generateGridView() {
    List<Widget> chooser = [];
    for (int i = 0; i < 25; i++) {
      chooser.add(Container(
        margin: EdgeInsets.all(3),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.blue, width: 0.5)),
        child: InkWell(
          onTap: () {
            setState(() {
              if (_selected[i + 1] == true) {
                _selected[i + 1] = !_selected[i + 1];
                _weeks.remove(i + 1);
              } else {
                if (_weeks.length < 2) {
                  _selected[i + 1] = true;
                  _weeks.add(i + 1);
                }
              }
            });
            if (_weeks.length > 0) {
              int temp1 = _weeks.first;
              int temp2 = _weeks.last;
              setStartWeek(min(temp1, temp2));
              setEndWeek(max(temp1, temp2));
            } else {
              setStartWeek(0);
              setEndWeek(0);
            }
          },
          child: Container(
            color: _selected[i + 1] == true ? Color(0xFFFC0484) : null,
            alignment: Alignment.center,
            child: Text((i + 1).toString(),
                style: TextStyle(
                  color: _selected[i + 1] == true ? Colors.white : Colors.black,
                )),
          ),
        ),
      ));
    }
    return chooser;
  }

  void _notifyChanged() {
    if (widget.onChanged != null)
      widget.onChanged(_currentStartWeek, _currentEndWeek, _currentWeekType);
  }
}
