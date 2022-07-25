import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

import '../data/globals.dart';

Widget vidWideTextButton(BuildContext context, String caption, void Function() onPressed, {IconData icon, int iconRotation, } ) {

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


  return Expanded(
    child: TextButton(
      onPressed: () => onPressed() ,
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
    ),
  );

}

/*
  NEXT button at the bottom of most pages
 */
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
