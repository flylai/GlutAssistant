import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Redux/State.dart';
import 'package:glutassistant/Redux/ThemeRedux.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redux/redux.dart';

class Settings extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  File _image;
  String _subtitleStudentid = '';
  String _subtitlePasswordJW = '';
  String _subtitleCurrentWeek = '1';
  String _subtitleBackgroundImage = '';
  double _subtitleOpacity = Constant.VAR_DEFAULT_OPACITY;
  bool _usingBackgroundImage = false;
  TextEditingController _studentidController = TextEditingController();
  TextEditingController _passwordJWController = TextEditingController();
  TextEditingController _currentWeekController = TextEditingController();
  TextEditingController _opacityController = TextEditingController();

  Store<GlobalState> _store;

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      _store = store;
      return _buildSettingsList();
    });
  }

  void initState() {
    super.initState();
    _init();
  }

  Widget _buildBackgroundImage() {
    return Container(
        color: Colors.white.withOpacity(_subtitleOpacity),
        child: ListTile(
          title: Text('启用背景图'),
          subtitle: Text(_subtitleBackgroundImage),
          trailing: Switch(
            value: _usingBackgroundImage,
            onChanged: (value) {
              setState(() {
                _usingBackgroundImage = value;
                SharedPreferenceUtil.setBool('background_enable', value);
              });
            },
          ),
          onTap: () {
            setState(() {
              _usingBackgroundImage = !_usingBackgroundImage;
              SharedPreferenceUtil.setBool(
                  'background_enable', _usingBackgroundImage);
              CommonSnackBar.buildSnackBar(context, '背景图与主题的互相切换可能需要重启APP才能生效');
            });
          },
        ));
  }

  Widget _buildCurrentWeek() {
    return Container(
        color: Colors.white.withOpacity(_subtitleOpacity),
        child: ListTile(
            title: Text('当前周'),
            subtitle: Text(_subtitleCurrentWeek),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text('当前周修改'),
                      content: TextField(
                        decoration: InputDecoration(labelText: '当前是第几周'),
                        controller: _currentWeekController,
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('确定'),
                          onPressed: () {
                            setState(() {
                              _subtitleCurrentWeek =
                                  _currentWeekController.text.trim();
                            });
                            SharedPreferenceUtil.setString(
                                'first_week', _subtitleCurrentWeek);
                            SharedPreferenceUtil.setString(
                                'first_week_timestamp',
                                (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                                    .toString());
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });
            }));
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
        leading: Icon(
          Icons.lens,
          color: Constant.THEME_LIST_COLOR[index][1],
        ),
        title: Text(Constant.THEME_LIST_COLOR[index][0]),
        dense: true,
        onTap: () {
          SharedPreferenceUtil.setInt('theme_color', index);
          _store.dispatch(
              RefreshColorAction(Constant.THEME_LIST_COLOR[index][1]));
          Navigator.pop(context);
        });
  }

  Widget _buildOpacitySetting() {
    return Container(
        color: Colors.white.withOpacity(_subtitleOpacity),
        child: ListTile(
            title: Text('控件透明度'),
            subtitle: Text(_subtitleOpacity.toString()),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text('透明度修改修改'),
                      content: TextField(
                        decoration: InputDecoration(labelText: '透明度(0.0-1.0)'),
                        controller: _opacityController,
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('确定'),
                          onPressed: () {
                            setState(() {
                              _subtitleOpacity =
                                  double.parse(_opacityController.text.trim());
                            });
                            SharedPreferenceUtil.setDouble(
                                'opacity', _subtitleOpacity);
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });
            }));
  }

  Widget _buildPickImage() {
    return Container(
        color: Colors.white.withOpacity(_subtitleOpacity),
        child: ListTile(
          title: Text('选择背景图'),
          enabled: _usingBackgroundImage,
          onTap: () => _getImage(),
        ));
  }

  Widget _buildPwdJW() {
    return Container(
      color: Colors.white.withOpacity(_subtitleOpacity),
      child: ListTile(
          title: Text('教务处密码'),
          subtitle: Text('密码就不告诉你啦'),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: Text('教务密码修改'),
                    content: TextField(
                      decoration: InputDecoration(labelText: '教务密码'),
                      controller: _passwordJWController,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('确定'),
                        onPressed: () {
                          setState(() {
                            _subtitlePasswordJW =
                                _passwordJWController.text.trim();
                          });
                          if (_subtitlePasswordJW != '' ||
                              _subtitlePasswordJW != null)
                            SharedPreferenceUtil.setBool('remember_pwd', true);
                          else
                            SharedPreferenceUtil.setBool('remember_pwd', false);
                          SharedPreferenceUtil.setString(
                              'password_JW', _subtitlePasswordJW);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          }),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      children: <Widget>[
        _buildStudentId(),
        _buildPwdJW(),
        _buildCurrentWeek(),
        _buildBackgroundImage(),
        _buildPickImage(),
        _buildThemeSetting(),
        _buildOpacitySetting()
      ],
    );
  }

  Widget _buildStudentId() {
    return Container(
        color: Colors.white.withOpacity(_subtitleOpacity),
        child: ListTile(
            title: Text('学号'),
            subtitle: Text(_subtitleStudentid),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text('学号修改'),
                      content: TextField(
                        decoration: InputDecoration(labelText: "学号"),
                        controller: _studentidController,
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('确定'),
                          onPressed: () {
                            setState(() {
                              _subtitleStudentid =
                                  _studentidController.text.trim();
                            });
                            SharedPreferenceUtil.setString(
                                'student_id', _subtitleStudentid);
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });
            }));
  }

  Widget _buildThemeSetting() {
    return Container(
        color: Colors.white.withOpacity(_subtitleOpacity),
        child: ListTile(
          title: Text('选择主题样式'),
          subtitle: Text('主题样式背景图是白色，与背景图冲突'),
          enabled: !_usingBackgroundImage,
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return Dialog(
                    child: Container(
                      height: 500,
                      width: 100,
                      child: ListView.builder(
                        itemCount: Constant.THEME_LIST_COLOR.length,
                        itemBuilder: (context, index) =>
                            _buildListItem(context, index),
                      ),
                    ),
                  );
                });
          },
        ));
  }

  Future _getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        _image.copy(FileUtil.getDir() + '/' + Constant.FILE_BACKGROUND_IMG);
      });
      CommonSnackBar.buildSnackBar(context, '你可能需要重新启动本APP使得背景图修改生效');
    } else
      CommonSnackBar.buildSnackBar(context, '读取照片失败啦，未知原因');
  }

  _init() async {
    String _firstWeekTimestamp =
        await SharedPreferenceUtil.getString('first_week_timestamp');
    await SharedPreferenceUtil.init();
    _subtitleStudentid = await SharedPreferenceUtil.getString('student_id');
    _subtitleStudentid ??= '';

    _firstWeekTimestamp ??= '1';
    _subtitleCurrentWeek = await SharedPreferenceUtil.getString('first_week');
    _subtitleCurrentWeek ??= '1';
    DateTime _now = DateTime.now();
    DateTime _startWeek = DateTime(_now.year, _now.month, _now.day)
        .subtract(Duration(days: _now.weekday - 1));
    _subtitleCurrentWeek = (((_startWeek.millisecondsSinceEpoch / 1000 -
                        int.parse(_firstWeekTimestamp)) ~/
                    25200 /
                    24)
                .ceil() +
            int.parse(_subtitleCurrentWeek))
        .toString();
    _subtitleOpacity = await SharedPreferenceUtil.getDouble('opacity');
    _subtitleOpacity ??= Constant.VAR_DEFAULT_OPACITY;
    _usingBackgroundImage =
        await SharedPreferenceUtil.getBool('background_enable');
    _usingBackgroundImage ??= false;
    await FileUtil.init();
    setState(() {
      _subtitleStudentid;
      _usingBackgroundImage;
      _subtitleCurrentWeek;
      _subtitleOpacity;
    });
    _studentidController.text = _subtitleStudentid;
    _currentWeekController.text = _subtitleCurrentWeek;
    _opacityController.text = _subtitleOpacity.toString();
  }
}
