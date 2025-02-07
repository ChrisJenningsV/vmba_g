import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

Widget getnamedIcon(String name, {Color? color}){

  // icon for flight status
  if( name.toUpperCase() == 'FLIGHTSTATUS') {
    return SizedBox(
      height: 24,
      width: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Transform.rotate(
                  angle: math.pi / 4,
                  child: new Icon(
                    Icons.airplanemode_active,
                  )),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: Icon(
                Icons.access_time_outlined,
                size: 12,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  } else if (name.toUpperCase() == 'TAKEOFF') {
/*
    return Transform.rotate(
        angle: math.pi / 4,
        child: new Icon(
          Icons.airplanemode_active,
          color: color,
        ));
*/
    return Icon( PhosphorIcons.airplane_takeoff_light, color: color,);
  } else if (name.toUpperCase() == 'LANDING') {
/*
    return Transform.rotate(
        angle: 3* math.pi / 4,
        child: new Icon(
          Icons.airplanemode_active,
          color: color,
        ));
*/
      return Icon( PhosphorIcons.airplane_landing_light, color: color,);
  } else {
    return Transform.rotate(
        angle: math.pi / 4,
        child: new Icon(
          Icons.airplanemode_active,
        ));
  }

}