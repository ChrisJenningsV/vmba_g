



import 'package:flutter/material.dart';

import '../../components/trText.dart';
import '../../data/globals.dart';
import '../homePageHelper.dart';

Widget v3ExpanderCard(BuildContext context, HomeCard card,  Widget body, {   TextStyle ts= const TextStyle(color: Colors.grey, fontSize: 22) }) {

  Color titleColor = Colors.grey.shade200;
  if( card.title != null ) {
    if( card.title!.backgroundColor != null ) {
      titleColor = card.title!.backgroundColor!;
    }
  }

  Widget title =       Container(
    color: titleColor,
      child: Row( children: [
        Icon(
          card.icon== null ? Icons.back_hand : card.icon,
          size: 30.0,
          color: ts.color,
        ),
        Padding(padding: EdgeInsets.all(2)),
        Text(translate(card.title!.text),  style: ts,)
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

