import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

import '../data/globals.dart';

Widget vidWideTextButton(BuildContext context, String caption, void Function({int p1}) onPressed, {IconData icon, int iconRotation,int p1 } ) {
  return Expanded( child: vidTextButton(context, caption, onPressed, icon: icon, iconRotation: iconRotation, p1: p1 ));
}

Widget vidTextButton(BuildContext context, String caption, void Function({int p1}) onPressed, {IconData icon, int iconRotation,int p1 } ) {
  Widget iconWidget = Container();
  if( icon != null) {
    if( iconRotation != null && iconRotation > 0 ) {
      iconWidget = RotatedBox(
          quarterTurns: iconRotation,
          child: Icon(
            icon,
            size: 20.0,
            color: Colors.grey,
          ));
    } else {
      iconWidget = Icon(
        icon,
        size: 20.0,
        color: Colors.grey,
      );
    }
  }


  return
     TextButton(
      onPressed: () => onPressed(p1: p1) ,
      style: TextButton.styleFrom(
          side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
          primary: gblSystemColors.textButtonTextColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TrText(
            caption,
            style: TextStyle(
                color: gblSystemColors
                    .textButtonTextColor),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
          ),
          iconWidget,
        ],
      ),
  );

}

/*
  NEXT button at the bottom of most pages
 */
Widget vidWideActionButton(BuildContext context, String caption, void Function(BuildContext, dynamic) onPressed, {IconData icon, int iconRotation, var param1} ) {
  return ElevatedButton(
    onPressed: () {
      onPressed(context, param1);
    },
    style: ElevatedButton.styleFrom(
        primary: gblSystemColors
            .primaryButtonColor, //Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0))),
    child: Row(
      //mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.check,
          color: Colors.white,
        ),
        TrText(
          caption,
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
//  return Expanded( child: vidActionButton( context, caption, onPressed,icon: icon, iconRotation: iconRotation ));
}

Widget vidActionButton(BuildContext context, String caption, void Function(BuildContext) onPressed, {IconData icon, int iconRotation, } ) {
  return Padding(
      padding: EdgeInsets.only(left: 35.0),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FloatingActionButton.extended(
            elevation: 0.0,
            isExtended: true,
            label: TrText(
              caption,
              style: TextStyle(color: gblSystemColors.primaryButtonTextColor),
            ),
            icon: Icon(Icons.check,
                color: gblSystemColors.primaryButtonTextColor),
            backgroundColor: gblSystemColors.primaryButtonColor,
            onPressed: () => onPressed(context))
      ]));
}

Widget vidInfoButton(BuildContext context, {void Function(BuildContext) onPressed}){
  return vidRoundButton(context, Icons.info_outline, onPressed);
}

Widget vidAddButton(BuildContext context, {void Function(BuildContext) onPressed,   bool disabled}){
  Color clr = gblSystemColors.primaryButtonColor;
  if( disabled != null && disabled) {
    clr = Colors.grey;
  }
  return IconButton(
    icon: Icon(
      Icons.add_circle,
      color: clr,
    ),
    onPressed: () {
         onPressed(context);
    },
  );
  //return vidRoundButton(context, Icons.add_circle_outline, onPressed, btnClr: Colors.white);
}

Widget vidRemoveButton(BuildContext context, {void Function(BuildContext, int, int) onPressed, int paxNo, int segNo, bool disabled}){
  Color clr = gblSystemColors.primaryButtonColor;
      if( disabled != null && disabled) {
        clr = Colors.grey;
      }
  return IconButton(
    icon: Icon(
      Icons.remove_circle,
      color: clr,
    ),
    onPressed: () {
      if( disabled == null || disabled == false) {
        onPressed(context, paxNo, segNo,);
      }
    },
  ); // return vidRoundButton(context, Icons.remove_circle_outline, onPressed, btnClr: Colors.white);
}

Widget vidRightButton(BuildContext context, {void Function(BuildContext) onPressed}){
  return IconButton(
    icon: Icon(
      Icons.chevron_right,
      color: gblSystemColors.primaryButtonColor,
    ),
    onPressed: () {
      onPressed(context);
    },
  ); // return vidRoundButton(context, Icons.remove_circle_outline, onPressed, btnClr: Colors.white);
}


Widget vidRoundButton(BuildContext context,IconData icon,  void Function(BuildContext) onPressed,{Color btnClr}){
  if( btnClr == null ) {
    btnClr = gblSystemColors.primaryButtonColor;
  }

  return IconButton(
    icon: Icon(
      icon,
      //color: gblSystemColors.primaryButtonColor,
    ),
    onPressed: () {
      onPressed(context);
    },
  ); // retur


  /*return ElevatedButton(
    onPressed:() => onPressed(context),
    style: ElevatedButton.styleFrom(
      primary: btnClr,
      shape: CircleBorder(),),
    child:
    Icon(icon, color: Colors.white,
    ),
  );*/
}

Widget vidLineButton(BuildContext context, Widget body, int index, void Function(BuildContext, int) onPressed) {
  return InkWell(
    splashColor: Colors.green,
    onTap:() => onPressed(context, index),
    child: body,
  );
}

