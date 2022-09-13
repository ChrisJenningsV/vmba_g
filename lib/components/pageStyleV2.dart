


import 'package:flutter/material.dart';

Widget v2BorderBox(BuildContext context, String label, Widget child, {IconData icon}) {
  double w = MediaQuery.of(context).size.width -55;
  return Stack(
      children: <Widget>[
/*
        IntrinsicWidth(
  child:
*/
        Container(
          width: w,
          //margin: const EdgeInsets.all(15.0),
          margin: EdgeInsets.fromLTRB(0, 6, 20, 10),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //                 <--- border radius here
            ),
          ),
          child: child,
        ),
        Positioned(
            left: 15,
            top: 0,
            child: Container(
              padding: EdgeInsets.only(top: 0, bottom: 1, left: 0, right: 10),
              color: Colors.white,
              child: Text(
                label,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            )),
      ]
  );

}