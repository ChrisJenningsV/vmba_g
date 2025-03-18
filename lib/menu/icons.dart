import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget getNamedIcon(String name, {Color? color}){

  // icon for flight status
  switch(name.toUpperCase()){

    case 'FLIGHTSTATUS':
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
                    size: 20,
                    color: color,
                  )),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: Icon(
                Icons.access_time_outlined,
                size: 15,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
    case 'FLIGHTSEARCH':
      return SizedBox(
        height: 25,
        width: 25,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                child: Transform.rotate(
                    angle: math.pi / 4,
                    child: new Icon(
                      Icons.airplanemode_active,
                      size: 20,
                      color: color,
                    )),
              ),
            ),
            Positioned(
              top: 11,
              left: 12,
              child: Container(
                child: Icon(
                  Icons.search,
                  size: 15,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    case 'TAKEOFF':
      return Transform.rotate(
          angle: math.pi / 4,
          child: new Icon(
            Icons.airplanemode_active,
            color: color,
          ));
//    return Icon( PhosphorIcons.airplane_takeoff_light, color: color,);
    case 'LANDING':
      return Icon( PhosphorIcons.airplane_landing_light, color: color,);
    case 'PEOPLE':
        return Icon(Icons.people);
    case 'ADULT':
      //return  Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.user));
      return Padding( padding: EdgeInsets.only(left: 0, right: 5), child: Icon(Icons.person));
    case 'SENIOR':
      return Padding( padding: EdgeInsets.only(left: 0, right: 5), child: Icon(Icons.person));
    case 'STUDENT':
      return Padding( padding: EdgeInsets.only(left: 0, right: 5), child: Icon(Icons.person));
    case 'YOUTH':
          return  Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.person));
    case 'CHILD':
      return Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.child));
    case 'INFANT':
      return Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.baby));
      //return Icon(Icons.baby)
    default:
    return Transform.rotate(
        angle: math.pi / 4,
        child: new Icon(
          Icons.airplanemode_active,
          color: color,
        ));
  }

}