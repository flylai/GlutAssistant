import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';

const double _datePickerFontSize = 18.0;

const double _datePickerHeight = 210.0;
const double _datePickerItemHeight = 36.0;
const double _datePickerTitleHeight = 44.0;
const int _timeLength = 14;

typedef TimeChangedCallback(int weekday, int startTime, int endTime);

class TimePicker {
  ///
  /// Display date picker bottom sheet.
  ///
  /// cancel: Custom cancel button
  /// confirm: Custom confirm button
  ///
  static void showTimePicker(
    BuildContext context, {
    bool showTitleActions: true,
    int initialWeekday,
    int initialStartTime,
    int initialEndTime,
    Widget cancel,
    Widget confirm,
    TimeChangedCallback onChanged,
    TimeChangedCallback onConfirm,
  }) {
    Navigator.push(
      context,
      _TimePickerRoute(
        showTitleActions: showTitleActions,
        initialWeekday: initialWeekday,
        initialStartTime: initialStartTime,
        initialEndTime: initialEndTime,
        cancel: cancel,
        confirm: confirm,
        onChanged: onChanged,
        onConfirm: onConfirm,
        theme: Theme.of(context, shadowThemeOnly: true),
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  final double progress;

  final int itemCount;
  final bool showTitleActions;
  _BottomPickerLayout(this.progress, {this.itemCount, this.showTitleActions});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = _datePickerHeight;
    if (showTitleActions) {
      maxHeight += _datePickerTitleHeight;
    }

    return BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _TimePickerComponent extends StatefulWidget {
  final TimeChangedCallback onChanged;

  final int initialWeekday, initialStartTime, initialEndTime;
  final Widget cancel;

  final Widget confirm;
  final _TimePickerRoute route;

  _TimePickerComponent(
      {Key key,
      @required this.route,
      this.initialWeekday: 1,
      this.initialStartTime: 1,
      this.initialEndTime: 1,
      this.cancel,
      this.confirm,
      this.onChanged});

  @override
  State<StatefulWidget> createState() => _TimePickerState(
      this.initialWeekday, this.initialStartTime, this.initialEndTime);
}

class _TimePickerRoute<T> extends PopupRoute<T> {
  final bool showTitleActions;

  final int initialWeekday, initialStartTime, initialEndTime;
  final Widget cancel, confirm;
  final TimeChangedCallback onChanged;
  final TimeChangedCallback onConfirm;
  final ThemeData theme;
  @override
  final String barrierLabel;

  AnimationController _animationController;

  _TimePickerRoute({
    this.showTitleActions,
    this.initialWeekday,
    this.initialStartTime,
    this.initialEndTime,
    this.cancel,
    this.confirm,
    this.onChanged,
    this.onConfirm,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
  }) : super(settings: settings);

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _TimePickerComponent(
        initialWeekday: initialWeekday,
        initialStartTime: initialStartTime,
        initialEndTime: initialEndTime,
        cancel: cancel,
        confirm: confirm,
        onChanged: onChanged,
        route: this,
      ),
    );
    if (theme != null) {
      bottomSheet = Theme(data: theme, child: bottomSheet);
    }
    return bottomSheet;
  }

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }
}

class _TimePickerState extends State<_TimePickerComponent> {
  int _currentWeekday, _currentStartTime, _currentEndTime;
  FixedExtentScrollController weekDayScrollCtrl,
      startTimeScrollCtrl,
      endTimeScrollCtrl;

  _TimePickerState(
      this._currentWeekday, this._currentStartTime, this._currentEndTime) {
    if (this._currentStartTime < 1) {
      this._currentStartTime = 1;
    }
    if (this._currentStartTime > _timeLength) {
      this._currentStartTime = _timeLength;
    }

    if (this._currentEndTime < 1) {
      this._currentEndTime = 1;
    }
    if (this._currentEndTime > _timeLength) {
      this._currentEndTime = _timeLength;
    }

    weekDayScrollCtrl =
        FixedExtentScrollController(initialItem: _currentWeekday - 1);
    startTimeScrollCtrl =
        FixedExtentScrollController(initialItem: _currentStartTime - 1);
    endTimeScrollCtrl =
        FixedExtentScrollController(initialItem: _currentEndTime - 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(widget.route.animation.value,
                  showTitleActions: widget.route.showTitleActions),
              child: GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: _renderPickerView(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      widget.onChanged(_currentWeekday, _currentStartTime, _currentEndTime);
    }
  }

  Widget _renderEndTimePickerComponent() {
    return Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _datePickerHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            scrollController: endTimeScrollCtrl,
            itemExtent: _datePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setEndTime(index);
            },
            children: List.generate(_timeLength, (int index) {
              return Container(
                height: _datePickerItemHeight,
                alignment: Alignment.center,
                child: Text(
                  '${BaseFunctionUtil.getTimeByNum(index + 1)}',
                  style: TextStyle(
                      color: Color(0xFF000046), fontSize: _datePickerFontSize),
                  textAlign: TextAlign.start,
                ),
              );
            }),
          )),
    );
  }

  Widget _renderItemView() {
    List<Widget> pickers = List<Widget>();
    pickers
      ..add(_renderWeekdayPickerComponent())
      ..add(_renderStartTimePickerComponent())
      ..add(_renderEndTimePickerComponent());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: pickers,
    );
  }

  Widget _renderPickerView() {
    Widget itemView = _renderItemView();
    if (widget.route.showTitleActions) {
      return Column(
        children: <Widget>[
          _renderTitleActionsView(),
          itemView,
        ],
      );
    }
    return itemView;
  }

  Widget _renderStartTimePickerComponent() {
    return Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _datePickerHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            scrollController: startTimeScrollCtrl,
            itemExtent: _datePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setStartTime(index);
            },
            children: List.generate(_timeLength, (int index) {
              return Container(
                height: _datePickerItemHeight,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      BaseFunctionUtil.getTimeByNum(index + 1),
                      style: TextStyle(
                          color: Color(0xFF000046),
                          fontSize: _datePickerFontSize),
                      textAlign: TextAlign.center,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ))
                  ],
                ),
              );
            }),
          )),
    );
  }

  Widget _renderTitleActionsView() {
    String done = 'done';
    String cancel = 'cancle';

    Widget cancelWidget = this.widget.cancel;
    if (cancelWidget == null) {
      cancelWidget = Text(
        '$cancel',
        style: TextStyle(
          color: Theme.of(context).unselectedWidgetColor,
          fontSize: 16.0,
        ),
      );
    }

    Widget confirmWidget = this.widget.confirm;
    if (confirmWidget == null) {
      confirmWidget = Text(
        '$done',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 16.0,
        ),
      );
    }

    return Container(
      height: _datePickerTitleHeight,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: _datePickerTitleHeight,
            child: FlatButton(
              child: cancelWidget,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            height: _datePickerTitleHeight,
            child: FlatButton(
              child: confirmWidget,
              onPressed: () {
                if (widget.route.onConfirm != null) {
                  widget.route.onConfirm(
                      _currentWeekday, _currentStartTime, _currentEndTime);
                }
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderWeekdayPickerComponent() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: _datePickerHeight,
        decoration: BoxDecoration(color: Colors.white),
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          scrollController: weekDayScrollCtrl,
          itemExtent: _datePickerItemHeight,
          onSelectedItemChanged: (int index) {
            _setWeekday(index);
          },
          children: List.generate(7, (int index) {
            return Container(
              height: _datePickerItemHeight,
              alignment: Alignment.center,
              child: Text(
                '星期${BaseFunctionUtil.getWeekdayByNum(index + 1)}',
                style: TextStyle(
                    color: Color(0xFF000046), fontSize: _datePickerFontSize),
                textAlign: TextAlign.start,
              ),
            );
          }),
        ),
      ),
    );
  }

  void _setEndTime(int index) {
    if (_currentEndTime != index + 1) {
      _currentEndTime = index + 1;
      if (_currentEndTime < _currentStartTime) {
        startTimeScrollCtrl.jumpToItem(_currentEndTime - 1);
      }
      _notifyDateChanged();
    }
  }

  void _setStartTime(int index) {
    if (_currentStartTime != index + 1) {
      _currentStartTime = index + 1;
      if (_currentEndTime < _currentStartTime) {
        endTimeScrollCtrl.jumpToItem(_currentStartTime - 1);
      }
      if (_currentEndTime > _timeLength) {
        _currentEndTime = _timeLength;
      }
      _notifyDateChanged();
    }
  }

  void _setWeekday(int index) {
    _currentWeekday = index + 1;
    _notifyDateChanged();
  }
}
