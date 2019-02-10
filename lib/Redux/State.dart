import 'package:flutter/material.dart';
import 'package:glutassistant/Redux/ThemeRedux.dart';

class GlobalState {
  Color color;
  GlobalState({this.color});
}

GlobalState appReducer(GlobalState state, action) {
  return GlobalState(
    color: ColorReducer(state.color, action),
  );
}
