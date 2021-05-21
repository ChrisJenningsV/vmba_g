import 'package:flutter/material.dart';
import 'package:vmba/resources/app_config.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/settings.dart';

//class CustomWidget {
AppBar appBar(BuildContext context, String title) {
  if( gbl_isLive == false ) {
    title = 'Test Mode: ' + title;
  }
  if( gbl_settings.wantLeftLogo) {
    return AppBar(
      leading: Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Image.asset(
              'lib/assets/${gblAppTitle}/images/appBarLeft.png',
              color: Color.fromRGBO(255, 255, 255, 0.1),
              colorBlendMode: BlendMode.modulate)),
      brightness: gbl_SystemColors.statusBar,
      backgroundColor: gbl_SystemColors.primaryHeaderColor,
      iconTheme: IconThemeData(
          color: gbl_SystemColors.headerTextColor),
      title: new Text(title,
          style: TextStyle(
              color: gbl_SystemColors.headerTextColor)),
    );

  } else {
    return AppBar(
      brightness: gbl_SystemColors.statusBar,
      backgroundColor: gbl_SystemColors.primaryHeaderColor,
      iconTheme: IconThemeData(
          color: gbl_SystemColors.headerTextColor),
      title: new Text(title,
          style: TextStyle(
              color: gbl_SystemColors.headerTextColor)),
    );
  }
}

//}
