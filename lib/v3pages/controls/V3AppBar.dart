

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/globals.dart';

import 'V3Constants.dart';

class V3AppBar extends StatefulWidget implements PreferredSizeWidget {
  SystemUiOverlayStyle? systemOverlayStyle;
//  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final bool hasBackgroundImage;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final IconThemeData? actionsIconTheme;
  final IconThemeData? iconTheme;
  bool? centerTitle;
  final double? toolbarHeight;

  V3AppBar(
      PageEnum pageName,
      {
        this.title,
        this.leading,
        this.flexibleSpace,
        this.bottom,
        this.elevation,
        this.centerTitle,
        this.iconTheme,
        this.actionsIconTheme,
        this.toolbarHeight,

        this.automaticallyImplyLeading = true,
        this.hasBackgroundImage = false,
        this.actions,
        this.systemOverlayStyle,
      }): preferredSize = Size.fromHeight(kToolbarHeight), super();
//  V3AppBar({Key key}) : preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _V3AppBarState createState() => _V3AppBarState();
}

class _V3AppBarState extends State<V3AppBar>{


  @override
  Widget build(BuildContext context) {
 //   bool wantShadow = true;
    if( gblV3Theme != null ) {
      if (widget.systemOverlayStyle == null) {
        if( gblV3Theme!.generic != null && gblV3Theme!.generic.setStatusBarColor) {
          widget.systemOverlayStyle = SystemUiOverlayStyle(
            statusBarColor: widget.hasBackgroundImage ? Colors.transparent : gblSystemColors.primaryHeaderColor,//widget.backgroundColor,
          );
        }
      }
      if( gblV3Theme!.generic != null && gblV3Theme!.generic.centerTitleText) {
        widget.centerTitle = gblV3Theme!.generic.centerTitleText;
      }
//      wantShadow = false;

    }
    return AppBar(title: widget.title, 
        backgroundColor: gblSystemColors.primaryHeaderColor,// widget.backgroundColor,
        //bottomOpacity: wantShadow ? null : 0.0 ,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        flexibleSpace: widget.flexibleSpace,
        actions: widget.actions,
        leading: widget.leading,
        bottom: widget.bottom,
        elevation: gblSettings.wantShadows ? widget.elevation : 0,
        actionsIconTheme: widget.actionsIconTheme,
        iconTheme: widget.iconTheme,
        centerTitle: widget.centerTitle,
        toolbarHeight: widget.toolbarHeight,
        systemOverlayStyle: widget.systemOverlayStyle,);
  }

}