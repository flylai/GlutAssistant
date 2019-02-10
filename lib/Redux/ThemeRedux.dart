import 'package:redux/redux.dart';
import 'package:flutter/material.dart';

final ColorReducer = combineReducers<Color>([
  TypedReducer<Color, RefreshColorAction>(_refresh),
]);

Color _refresh(Color color, action) {
  color = action.color;
  return color;
}

class RefreshColorAction {
  final Color color;
  RefreshColorAction(this.color);
}
