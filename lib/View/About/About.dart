import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final list = [
    [Icons.update, '检查更新', 'https://www.coolapk.com/apk/com.lkm.glutassistant'],
    [Icons.code, 'GitHub', 'https://github.com/flylai/GlutAssistant']
  ];

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
                for (var item in list) _buildItem(item[0], item[1], item[2])
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String url) {
    return ListTile(
      leading: Icon(icon),
      onTap: () => _launchUrl(url),
      title: Text(title),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
