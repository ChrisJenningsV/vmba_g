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
      break;
    case 'FLIGHTSEARCH':
      return SizedBox(
        height: 30,
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
      break;
    case 'TAKEOFF':
      return Transform.rotate(
          angle: math.pi / 4,
          child: new Icon(
            Icons.airplanemode_active,
            color: color,
          ));
      break;
    return Icon( PhosphorIcons.airplane_takeoff_light, color: color,);
    case 'LANDING':
/*
    return Transform.rotate(
        angle: 3* math.pi / 4,
        child: new Icon(
          Icons.airplanemode_active,
          color: color,
        ));
*/
      return Icon( PhosphorIcons.airplane_landing_light, color: color,);
      break;
    case 'PEOPLE':
        return Icon(Icons.people);
        break;
    case 'ADULT':
      //return  Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.user));
      return Padding( padding: EdgeInsets.only(left: 0, right: 5), child: Icon(Icons.person));
      break;
    case 'YOUTH':
          return  Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.person));
          break;
    case 'CHILD':
      return Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.child));
      break;
    case 'INFANT':
      return Padding( padding: EdgeInsets.only(left: 5), child: FaIcon(FontAwesomeIcons.baby));
      //return Icon(Icons.baby)
      break;
    default:
    return Transform.rotate(
        angle: math.pi / 4,
        child: new Icon(
          Icons.airplanemode_active,
          color: color,
        ));
      break;
  }

}