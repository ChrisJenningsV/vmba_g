import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

//class CustomWidget {
AppBar appBar(BuildContext context, String title) {
  if( gblSettings.wantLeftLogo) {
    return AppBar(
      leading: Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Image.asset(
              'lib/assets/${gblAppTitle}/images/appBarLeft.png',
              color: Color.fromRGBO(255, 255, 255, 0.1),
              colorBlendMode: BlendMode.modulate)),
      brightness: gblSystemColors.statusBar,
      backgroundColor: gblSystemColors.primaryHeaderColor,
      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      title: new TrText(title,
          style: TextStyle(
              color: gblSystemColors.headerTextColor),
          variety: 'title'),
    );

  } else {
    return AppBar(
      brightness: gblSystemColors.statusBar,
      backgroundColor: gblSystemColors.primaryHeaderColor,
      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      title: new TrText(title,
          style: TextStyle(
              color: gblSystemColors.headerTextColor),
              variety: 'title',),
    );
  }
}

//}
