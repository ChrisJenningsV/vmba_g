import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../helper.dart';

class CustomPageRoute extends CupertinoPageRoute {
  @override
  @protected
  bool get hasScopedWillPopCallback {
    return false;
  }
  CustomPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );
}
/////////////////////
class CustomWillPopScope extends StatelessWidget {
  const   CustomWillPopScope(
      {required this.child,
        this.onWillPop = false,
        Key? key,
        required this.action})
      : super(key: key);

  final Widget child;
  final bool onWillPop;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? GestureDetector(
        onPanEnd: (details) {
          print('on pan end');
          if (details.velocity.pixelsPerSecond.dx < 0 ||
              details.velocity.pixelsPerSecond.dx > 0) {
            if (onWillPop) {
              action();
            }
          }
        },
/*        onHorizontalDragEnd: (details){
          print('on drag end');
        },
        onHorizontalDragUpdate: (details){
          print('on h drag update');
        },*/
        child: WillPopScope(
          onWillPop: () async {
            print('on will pop iOS');
            return false;
          },
          child: child,
        ))
        : WillPopScope(
        child: child,
        onWillPop: () async {
          action();
          return onWillPop;
        });
  }
}

