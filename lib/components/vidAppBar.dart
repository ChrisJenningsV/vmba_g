


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/components/showNotification.dart';

import '../data/globals.dart';
import '../data/repository.dart';
import '../main.dart';
import '../utilities/helper.dart';

class vidAppBar extends StatefulWidget implements PreferredSizeWidget {
  vidAppBar({this.elevation,this.centerTitle, this.backgroundColor,
    this.title, this.iconTheme,this.toolbarHeight,this.bottom,
    this.leading,this.flexibleSpace,this.actions,
    this.automaticallyImplyLeading = true,} ):
        preferredSize = _PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height);

  final Widget? title;
  final double? elevation;
  final Color? backgroundColor;
  final bool? centerTitle;
  final IconThemeData? iconTheme;
  final double? toolbarHeight;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final Widget? flexibleSpace;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;

  @override
  State<StatefulWidget> createState() => new vidAppBarState();

  @override
  final Size preferredSize;
}

class vidAppBarState extends State<vidAppBar>  with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        logit("a app in resumed");
        // ensure snack bar not removed when paused, as does not work
        if(gblNoNetwork == false){
          // check no snackbar
          hideSnackBarMessage();
        }

        gblNotifications = null;  // incase none found
        Repository.get().getAllNotifications().then((m) {
          gblNotifications = m;

          if( gblNotifications != null && gblNotifications!.list.length > 0 && gblNotifications!.list[0].background == 'true') {

            RemoteNotification n = RemoteNotification(title: gblNotifications!.list[0].notification!.title,
                body: gblNotifications!.list[0].notification!.body);

            // mark msg as seen
            Repository.get().updateNotification(convertMsg(gblNotifications!.list[0]) as RemoteMessage, false, true).then((value) {
              Repository.get().getAllNotifications().then((m) {
                gblNotifications = m;
              });
            });

            showNotification( NavigationService.navigatorKey.currentContext as BuildContext, n, gblNotifications!.list[0].data as Map<dynamic, dynamic>, 'background ');
          }
        });



        break;
      case AppLifecycleState.inactive:
        logit("a app in inactive");
        break;
      case AppLifecycleState.paused:
        logit("a app in paused");
        break;
      case AppLifecycleState.detached:
        logit("a app in detached");
        break;
      case AppLifecycleState.hidden:
        logit("a app in hidden");
        break;
    }


    }

  @override
  Widget build(BuildContext context) {
    return new AppBar(
      elevation: widget.elevation,
      centerTitle: gblCentreTitle,

      //brightness: gblSystemColors.statusBar,
      //leading: Image.asset("lib/assets/$gblAppTitle/images/appBar.png",),
      backgroundColor: widget.backgroundColor,
      title: widget.title ,
      iconTheme: widget.iconTheme,
      leading: widget.leading,
      flexibleSpace: widget.flexibleSpace,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      actions: widget.actions
      //iconTheme: IconThemeData(color:gblSystemColors.headerTextColor)
    );
  }

  }

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}
