

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/globals.dart';

import '../../components/trText.dart';
import '../v3Theme.dart';
import 'V3Constants.dart';

class V3AppBar extends StatefulWidget implements PreferredSizeWidget {
  SystemUiOverlayStyle? systemOverlayStyle;
//  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final bool hasBackgroundImage;
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final IconThemeData? actionsIconTheme;
  IconThemeData? iconTheme;
  bool? centerTitle;
  final double? toolbarHeight;

  V3AppBar(
      PageEnum pageName,
      {
        this.title,
        this.titleText,
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
    if( widget.iconTheme == null ){
      widget.iconTheme = IconThemeData(color: gblSystemColors.headerTextColor);
    }

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
    Widget? title = widget.title;
    if(title == null ){
      if( gblSettings.wantMaterialFonts) {
        title = VHeadlineText(widget.titleText as String, size: TextSize.small,
          color: gblSystemColors.headerTextColor,);
      } else {
        title = Text( translate(widget.titleText as String),style: TextStyle(
                color: gblSystemColors.headerTextColor));
      }
    }

    return AppBar(title: title,
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