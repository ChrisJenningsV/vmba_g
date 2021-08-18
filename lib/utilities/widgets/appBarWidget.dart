import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

//class CustomWidget {
Widget appBar(BuildContext context, String title,
    {Widget leading, bool automaticallyImplyLeading, List<Widget> actions, Color backgroundColor, String imageName,  double elevalion, NetworkImage backgroundImage,
        Widget bottom, double toolbarHeight }) {
  if( automaticallyImplyLeading == null ) {automaticallyImplyLeading=true;}
  bool wantOutline = false;

  Widget flexibleSpace ;

  if( backgroundImage != null ) {
    flexibleSpace = Image(
      image:
        backgroundImage,
      fit: BoxFit.cover,);
    backgroundColor = Colors.transparent;
  }

  if( imageName != null && imageName.isNotEmpty) {
    // map page name to image name
    Map pageMap = json.decode(gblSettings.pageImageMap.toUpperCase());
    String pageImage = pageMap[imageName.toUpperCase()];

    switch (pageImage) {
      case '[DEST]':
        pageImage = gblDestination;
        break;
    }
    if( pageImage == null) {
      pageImage = 'blank';
    }


    backgroundImage = NetworkImage('${gblSettings.gblServerFiles}/pageImages/$pageImage.png');
    if( backgroundImage != null ) {
      flexibleSpace = Image(
        image:
        backgroundImage,
        fit: BoxFit.cover,);
      //backgroundColor = Colors.transparent;
      wantOutline = true;
      //toolbarHeight = 100;

      return PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child:  AppBar(
            leading: leading,
            bottom: bottom,
            //toolbarHeight: toolbarHeight,
            flexibleSpace: flexibleSpace,
            elevation: elevalion,
            automaticallyImplyLeading: automaticallyImplyLeading,
            centerTitle: gblCentreTitle,
            brightness: gblSystemColors.statusBar,
            backgroundColor: Colors.transparent,

            iconTheme: IconThemeData(
                color: Colors.white),
            title: getText(title),
            actionsIconTheme: IconThemeData( color: Colors.white),
            actions: actions,
          ));


    }

  }


  if( flexibleSpace != null ) {
    wantOutline = true;
  }

  if( gblSettings.wantLeftLogo && leading == null ) {
    return AppBar(
      flexibleSpace: flexibleSpace,
      centerTitle: gblCentreTitle,
      toolbarHeight: toolbarHeight,
      elevation: elevalion,
      leading: gblSettings.wantLeftLogo ? Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Image.asset(
              'lib/assets/$gblAppTitle/images/appBarLeft.png',
              color: Color.fromRGBO(255, 255, 255, 0.1),
              colorBlendMode: BlendMode.modulate)) :Text(''),
      brightness: gblSystemColors.statusBar,
      backgroundColor: (backgroundColor == null) ? gblSystemColors.primaryHeaderColor : backgroundColor,
      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      title: new TrText(title,
          style: TextStyle(
              color: gblSystemColors.headerTextColor),
          variety: 'title'),
      actions: actions,
      bottom: bottom,
    );

  } else {
    Widget ab = AppBar(
      leading: leading,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      flexibleSpace: flexibleSpace,
      elevation: elevalion,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: gblCentreTitle,
      brightness: gblSystemColors.statusBar,
      backgroundColor: (backgroundColor == null) ? gblSystemColors.primaryHeaderColor : backgroundColor,

      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      title: wantOutline ? getText(title) : new TrText(title,
          style: TextStyle(
              color: gblSystemColors.headerTextColor),
              variety: 'title',),
        actions: actions,
    );
    return ab;
  }

}
Widget getText(String txt) {
return Stack(
  children: <Widget>[
    // Stroked text as border.
    Text(
      translate(txt),
      textScaleFactor: 1.25,
      style: TextStyle(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.grey.shade800,
      ),
    ),
    // Solid text as fill.
    Text(
      translate(txt),
      textScaleFactor: 1.25,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  ],
);

}

//}
