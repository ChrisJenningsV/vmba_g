import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

import '../utilities/helper.dart';



void showError(String msg) {
  if( gblIsLive) return ;

  //showAlertDialog(NavigationService.navigatorKey.currentContext, 'Error', msg);

}
Future<bool> confirmDialog(BuildContext context, String title, String msg ) async {
  // flutter defined function

  bool result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.only(top: 0),
        content: Container(
          width: 300.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
              shape: RoundedRectangleBorder( borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0) )),
              tileColor: gblSystemColors.primaryHeaderColor ,
                leading: Icon(Icons.question_answer_outlined, size: 30.0, color: gblSystemColors.headerTextColor   ,),
                title: TrText(title, style: TextStyle(color: gblSystemColors.headerTextColor), textScaleFactor: 1.25,),
              ),
              Divider(
                color: Colors.grey,
                height: 4.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: msg,
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),

            ],

          ),
        ),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.grey),
              onPressed: () => Navigator.pop(context, false),
              child: TrText('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: gblSystemColors.primaryButtonColor),
              onPressed: () => Navigator.pop(context, true),
              child: TrText('Confirm')),
        ],
      );

    },
  );
  return result;

  }



void showAlertDialog(BuildContext context, String title, String msg, {void Function() onComplete  }) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
            return getAlertDialog(context, title, msg);
    },
  );
}

AlertDialog getAlertDialog(BuildContext context, String title, String msg, {void Function() onComplete}) {
  logit('getAlertDialog');

  return AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                translate(title),
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
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: msg,
                border: InputBorder.none,
              ),
              maxLines: 8,
            ),
          ),

/*
          InkWell(
            child: Container(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 50, right: 50),
                decoration: BoxDecoration(
                  color: myColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      primary: Colors.white),
                  child: new TrText("Close"),
                  onPressed: () {
                    if( onComplete != null ) {
                      onComplete();
                    }
                    Navigator.of(context).pop();
                  },
                )
            ),
          ),
*/
        ],
      ),
    ),
      actions: [
      ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.grey),
onPressed: () {
if( onComplete != null ) {
onComplete();
} else {
  Navigator.of(context).pop();
}
},

child: TrText
('OK')),
],
);


}
