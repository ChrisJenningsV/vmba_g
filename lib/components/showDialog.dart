import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';





void showAlertDialog(BuildContext context, String title, String msg ) {
  // flutter defined function
  Color myColor = Color(0xffc0c0c0);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              content: Container(
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(fontSize: 24.0),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: msg,
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 50, right: 50),
                        decoration: BoxDecoration(
                          color: myColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32.0),
                              bottomRight: Radius.circular(32.0)),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: gblSystemColors.primaryButtonColor ,
                              side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                              primary: gblSystemColors.primaryButtonTextColor),
                          child: new TrText("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ),
                    ),
                  ],
                ),
              ),
            );
      /*
      return AlertDialog(
        title: new Text(title),
        content: new Text(msg),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[ TextButton(
            style: TextButton.styleFrom(
                backgroundColor: gblSystemColors.primaryButtonColor ,
                side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                primary: gblSystemColors.primaryButtonTextColor),
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )]),
        ],
      );

       */
    },
  );
}
