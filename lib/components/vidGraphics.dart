



import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

Widget vidSeatIcon(String seatNo ){
  return             Stack(
    alignment: Alignment.center,
    children: [
      Icon(Icons.event_seat, color: Colors.grey.shade400, size: 35,),
      Text(seatNo, style: TextStyle(fontWeight: FontWeight.bold),),
    ],);
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