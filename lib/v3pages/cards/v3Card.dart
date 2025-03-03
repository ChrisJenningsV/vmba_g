



import 'package:flutter/material.dart';

import '../../components/trText.dart';
import '../../data/globals.dart';
import '../Templates.dart';

Widget v3ExpanderCard(BuildContext context, CardTemplate card,  Widget body,
    { bool wantIcon = true,  TextStyle ts= const TextStyle(color: Colors.grey, fontSize: 22) }) {

  Color titleColor = Colors.grey.shade200;
  if( card.title != null ) {
    if( card.title!.backgroundColor != null ) {
      titleColor = card.title!.backgroundColor!;
    }
  }
    if( card.backgroundClr != null){
      titleColor = card.backgroundClr as Color;
    }
  String sTitle = 'No Title';
  if( card.title != null ) {
    sTitle = card.title!.text;
  }
  if( gblPassengerDetail != null ){
    sTitle = sTitle.replaceAll('[[firstname]]', gblPassengerDetail!.firstName);
  }

  Widget title =       Container(
    color: titleColor,
      child: Row( children: [
        card.icon!= null ? Icon(
           card.icon,
          size: 30.0,
          color: ts.color,
        ) : Container(),
        Padding(padding: EdgeInsets.all(2)),
        Text(translate(sTitle),  style: ts,)
      ],));


  return Padding(padding: EdgeInsets.only(top:2, left: 3, right: 3, bottom: 0),
      child: Card(
        color:  titleColor ,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all( Radius.circular( card.cornerRadius))
        ),
        child: ClipPath(
          child: Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(
                    color: Colors.grey.shade200, width: 0))),
            //           height: 100,
            width: double.infinity,
            child:

            ExpansionTile(
              //backgroundColor: Colors.grey.shade200,
              //tilePadding: EdgeInsets.all(0),
              childrenPadding: EdgeInsets.all(0),
//        backgroundColor:  Colors.blue,
              initiallyExpanded: card.expanded ,
                trailing: wantIcon ? null : const SizedBox(),
              title: title,
              children: [ Container(
                color: Colors.grey.shade200,
                  child: body)]
            ),
          ),
          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(card.cornerRadius))),
        ),

          ),
  );

}

