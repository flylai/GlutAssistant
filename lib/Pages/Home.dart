import 'package:flutter/material.dart';

import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Pages/Timetable.dart';
import 'package:glutassistant/Pages/Login.dart';
import 'package:glutassistant/Pages/ImportTimetable.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //全局脚手架key
  var _selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: getDrawer(),
      appBar: AppBar(
        title: Text(Constant.DRAWER_LIST_TITLE[_selectIndex]),
      ),
      body: getBodyView(),
    );
  }

  Widget getDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
              accountEmail: Text('XX'),
              accountName: Text('XX'),
              margin: EdgeInsets.zero,
              currentAccountPicture: (CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://upload.jianshu.io/users/upload_avatars/7700793/dbcf94ba-9e63-4fcf-aa77-361644dd5a87?imageMogr2/auto-orient/strip|imageView2/1/w/240/h/240'),
              ))),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
                child: ListView.builder(
              itemCount: Constant.DRAWER_LIST_TITLE.length,
              itemBuilder: (context, index) => drawListItem(context, index),
            )),
          ),
        ],
      ),
    );
  }

  Widget drawListItem(context, index) {
    if (index != 0 && index != 7) {
      return ListTile(
          leading: Icon(Constant.DRAWER_LIST_ICON[index]),
          title: Text(Constant.DRAWER_LIST_TITLE[index]),
          dense: true,
          onTap: () {
            print(index);
            Navigator.pop(context);
            setState(() {
              _selectIndex = index;
            });
          });
    }
    return ListTile(
      title: Text(Constant.DRAWER_LIST_TITLE[index],
          style: TextStyle(color: Colors.blue, fontSize: 12.0)),
    );
  }

  Widget getBodyView() {
    switch (_selectIndex) {
      case 0:
        break;
      case 2:
        return new Timetable();
        break;
      case 5:
        return new ImportTimetable();
      case 6:
        return new Login();
        break;
      default:
        break;
    }
  }
}
