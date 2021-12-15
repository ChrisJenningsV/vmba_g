import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';



void showNotification(BuildContext context, String title,  String msg) {
  String time = DateFormat('kk:mm').format(DateTime.now());
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext cxt) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Material(
            color: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
            child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom:  20),
              child:
                  Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset("lib/assets/images/app.png", width: 20, height: 20,)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          gblSettings.airlineName.toUpperCase(),
                          //style: TextStyle(                            color: Colors.white,                          ),
                        ),
                      ),
                      Text(time)
                    ],
                  ),
                  SizedBox(height: 5.0,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold),)
                    ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                    Text(msg)
                  ]),
                ],
              ),
            ),
                  Positioned( // will be positioned in the top right of the container
                    top: -12,
                    right: -12,
                        child: new IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }), //
                      ),
              ]
            ),
          ),
        ),
      );
    },
  );
}