import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistant/Pages/Home.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:glutassistant/Redux/State.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:redux/redux.dart';

void main() {
  runApp(GlutAssistant());
  SystemUiOverlayStyle systemUiOverlayStyle =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

class GlutAssistant extends StatelessWidget {
  final store = Store<GlobalState>(appReducer,
      initialState: GlobalState(
        color: Constant.THEME_LIST_COLOR[0][1],
      ));

  GlutAssistant({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: StoreBuilder<GlobalState>(builder: (context, store) {
        return MaterialApp(
          title: '桂工助手',
          theme: ThemeData(primaryColor: store.state.color),
          home: Home(),
        );
      }),
    );
  }
}
