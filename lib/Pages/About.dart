import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: Image(
              alignment: Alignment.topCenter,
              image: AssetImage('assets/images/logo.png'),
              width: 90,
              height: 90,
            ),
          ),
          Text(
            '桂工助手 - ${Constant.VAR_VERSION}',
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '让你的桂工生活更为方便',
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.update),
                  onTap: () {
                    checkUpdateByCoolapk();
                  },
                  title: Text('检查更新'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: InkWell(
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationVersion: Constant.VAR_VERSION,
                );
              },
              child: Text('查看许可证'),
            ),
          )
        ],
      ),
    );
  }

  checkUpdateByCoolapk() async {
    const url = 'https://www.coolapk.com/apk/com.lkm.glutassistant';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
