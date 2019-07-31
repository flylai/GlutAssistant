import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/View/Home/Home.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  SystemUiOverlayStyle systemUiOverlayStyle =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  GlobalData globalData = GlobalData();
  await globalData.refreshGlobal();

  runApp(ChangeNotifierProvider<GlobalData>.value(
      value: globalData, child: GlutAssistant()));
}

class GlutAssistant extends StatelessWidget {
  GlutAssistant({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalData>(builder: (context, globaldata, _) {
      return MaterialApp(
        home: Home(),
        theme: ThemeData(
            primaryColor: Constant.THEME_LIST_COLOR[globaldata.themeColorIndex]
                [1]),
      );
    });
  }
}
