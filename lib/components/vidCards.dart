


import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

import '../Helpers/settingsHelper.dart';
import '../data/globals.dart';

Widget vidExpanderCard(BuildContext context, String caption, bool expanded, IconData? icon,  List<Widget> body, { bool wantTop = true,
  TextStyle ts= const TextStyle(color: Colors.grey, fontSize: 22) }) {
  return vidExpanderCardExt(context,
      // title
      Container(
      child: Row( children: [
         Icon(
           icon== null ? Icons.back_hand : icon,
          size: 30.0,
          color: gblSystemColors.primaryHeaderColor.withOpacity(0.5),
        ),
        Padding(padding: EdgeInsets.all(2)),
        wantHomePageV3() ?
        Text(translate(caption),  style: ts,) :
        Text(translate(caption), textScaleFactor: 1.25),
      ],)),

      expanded,
      body, wantTop: wantTop  );
}

Widget vidExpanderCardExt(BuildContext context, Widget title, bool expanded,  List<Widget> body, {bool wantTop = true,}) {
  return vidCard( '', Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        //tilePadding: EdgeInsets.all(0),
      childrenPadding: EdgeInsets.all(0),
//        backgroundColor:  Colors.blue,
        initiallyExpanded: expanded ,
        title:
        title,

        children: body,)

  ), wantTop: wantTop
  );
}

Widget vidCard( String caption,  Widget body, {bool wantTop = true,}) {
  return Padding(padding: EdgeInsets.only(top:2, left: 3, right: 3, bottom: 0),
      child: Card(
        color: wantHomePageV3() ? Colors.grey.shade200 : null,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all( Radius.circular(wantHomePageV3() ? 10 : 3))
        ),
        child: ClipPath(
          child: Container(
 //           height: 100,
            width: double.infinity,
            child: body,
            decoration: BoxDecoration(

                border: Border(top: BorderSide(
                    color: (wantTop ) ? gblSystemColors.primaryHeaderColor: Colors.transparent, width: (wantTop ) ?5:0))),
          ),
          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(wantHomePageV3() ? 20 : 3))),
        ),
      ));
}