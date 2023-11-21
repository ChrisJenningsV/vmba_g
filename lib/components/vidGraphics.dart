



import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'dart:math' as math;

Widget vidSeatIcon(String seatNo ){
  return             Stack(
    alignment: Alignment.center,
    children: [
      Icon(Icons.event_seat, color: Colors.grey.shade400, size: 35,),
      Text(seatNo, style: TextStyle(fontWeight: FontWeight.bold),),
    ],);
}

Widget vidNoFlights( ){
  return             Stack(
    alignment: Alignment.center,
    children: [
      Transform.rotate(angle: math.pi/4,
          child: new Icon(
            Icons.airplanemode_active,
            size: 26.0,
          )),
      Icon(Icons.block_flipped , color: Colors.red, size: 39,),
    ],);
}

Widget vidtakeoffIcon( ){
  return
     Icon(
            Icons.flight_takeoff_outlined,
            size: 30.0,
          );
}


Widget vidProcessing( String text ){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TrText(text),
        )
      ],
    ),
  );

}