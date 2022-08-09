


import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

import '../data/globals.dart';

Widget vidExpanderCard(BuildContext context, String caption, bool expanded, IconData icon,  List<Widget> body) {
  return vidExpanderCardExt(context,
      Row( children: [
        Icon(
          icon,
          size: 30.0,
          color: gblSystemColors.primaryHeaderColor,
        ),
        Padding(padding: EdgeInsets.all(2)),
        Text(translate(caption), textScaleFactor: 1.25),
      ],), true,body  );

/*    vidCard( caption, Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(

        initiallyExpanded: expanded ,
        title:
        Row( children: [
          Icon(
            icon,
            size: 30.0,
            color: gblSystemColors.primaryHeaderColor,
          ),
          Padding(padding: EdgeInsets.all(2)),
          Text(translate(caption), textScaleFactor: 1.25),
        ],),

        children: body,)
  ));*/
}

Widget vidExpanderCardExt(BuildContext context, Widget title, bool expanded,  List<Widget> body) {
  return vidCard( '', Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(

        initiallyExpanded: expanded ,
        title:
        title,

        children: body,)
  ));
}

Widget vidCard( String caption,  Widget body) {
  return Padding(padding: EdgeInsets.only(top: 5, left: 3, right: 3, bottom: 3),
      child: Card(
        elevation: 3,
        child: ClipPath(
          child: Container(
 //           height: 100,
            width: double.infinity,
            child: body,
            decoration: BoxDecoration(
                border: Border(top: BorderSide(
                    color: gblSystemColors.primaryHeaderColor, width: 5))),
          ),
          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3))),
        ),
      ));
}