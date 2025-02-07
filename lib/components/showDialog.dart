import 'package:flutter/material.dart';
//import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/colourHelper.dart';

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
              style: ElevatedButton.styleFrom(backgroundColor: cancelButtonColor()),
              onPressed: () => Navigator.pop(context, false),
              child: TrText('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: gblSystemColors.primaryButtonColor),
              onPressed: () => Navigator.pop(context, true),
              child: TrText('Confirm')),
        ],
      );

    },
  );
  return result;

  }

Widget displayMessage(BuildContext context,String title, String msg ){
return AlertDialog(
actions: <Widget>[
new TextButton(
child: new TrText("OK"),
onPressed: () {
Navigator.of(context).pop();
},
),
],
title: new TrText(title),
content: SingleChildScrollView(
child: Text(msg),
));
}

enum DialogType{
  Error,
  Warning,
  Information,
  Custom,
  None
}

void showVidDialog(BuildContext context, String title, String msg,
    {void Function()? onComplete, DialogType type= DialogType.Information,
      Widget Function(void Function(void Function()))? getContent}) {
  // flutter defined function
  logit('showAlertDialog $msg');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState)
      {
        return getAlertDialog(context, title, msg, setState, onComplete: onComplete,
            type: type,
            getContent: getContent);
      }
      );
    }
  );
}

AlertDialog getAlertDialog(BuildContext context, String title, String msg, void Function(void Function()) setState2,
    {void Function()? onComplete, DialogType type= DialogType.Information, Widget Function(void Function(void Function()))? getContent}) {
  logit('getAlertDialog');

  //IconData icon = Icons.error_outline;
  Color titleTextClr=  gblSystemColors.headerTextColor!;
  Color? titleBackClr=  gblSystemColors.headerTextColor!;
  Widget icon = Icon(Icons.error_outline, color: titleTextClr);

  switch (type) {
    case DialogType.Information:
      titleTextClr = Colors.white;
      titleBackClr = Colors.cyan;
      icon = Icon(Icons.error_outline, color: titleTextClr);
      break;
    case DialogType.Error:
      titleTextClr = Colors.white;
      titleBackClr = Colors.red;
      icon = IconButton(onPressed: () => Navigator.pop(context),
        icon: Stack(
        children: [
        Icon(Icons.circle_outlined, color: Colors.white, size: 34,),
        Padding( padding: EdgeInsets.only(left: 5, top: 5), child: Icon(Icons.close, color: Colors.white,)),
        ],
        ));
      break;
    case DialogType.Warning:
      titleTextClr = Colors.white;
      titleBackClr = Colors.yellow;
      icon = Icon(Icons.warning_amber, color: titleTextClr);
      break;
    case DialogType.Custom:
      titleTextClr = Colors.black87;
      titleBackClr = Colors.black12;
      break;
    default:
      break;
  }

  Widget dlgTitleContent = Row(
      children: [
        icon,
        Padding(padding: EdgeInsets.all(3),),
        Text(title,  style: TextStyle(color: titleTextClr),)
      ]
  );
  if( icon == Icons.error_outline){
    dlgTitleContent = Text(title,  style: TextStyle(color: titleTextClr),);
  }


  Widget dlgTitle =  Container(
  alignment: Alignment.topLeft,
  decoration: BoxDecoration(
  color: titleBackClr, //titleBkClr,
      border: Border(
        bottom: BorderSide(width: 1, color: titleTextClr),
      ),
  borderRadius: BorderRadius.only(
  topLeft: Radius.circular(10.0),
  topRight: Radius.circular(10.0),)),
  padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
  child: dlgTitleContent);

  return AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))),
    contentPadding: EdgeInsets.only(top: 10.0),
    title: dlgTitle,
    titlePadding: const EdgeInsets.all(0),
    content: (getContent != null) ? getContent(setState2) : Container(
      width: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: msg,
                border: InputBorder.none,
              ),
              maxLines: 8,
            ),
          ),

       /*   onComplete != null ?
          InkWell(
            child: Container(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 50, right: 50),
                decoration: BoxDecoration(
                 // color: myColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: Colors.white),
                  child: new TrText("Close"),
                  onPressed: () {
                    if( onComplete != null ) {
                      onComplete();
                    }
                    Navigator.of(context).pop();
                  },
                )
            ),
          ): Container(),*/

        ],
      ),
    ),
      actions: [
        /*onComplete == null ?*/
      ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
onPressed: () {
if( onComplete != null ) {
onComplete();
} else {
  try {
    Navigator.of(context).pop();
  } catch(e) {
    logit(e.toString());
  }
}
},

child: TrText
('OK')) /*: Container()*/
],
);


}

Widget buildMessage(String title, String body, {void Function()? onComplete  }) {
  return Center( child: Container(

    //alignment: Alignment.topCenter,

      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.only(top: 20.0, left: 30, right: 30, bottom: 20),
      decoration: BoxDecoration(    border: Border.all(color: Colors.black),
          color: Colors.white,
          borderRadius: BorderRadius.all(
              Radius.circular(3.0))
      ),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [ Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TrText(title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                Padding(padding:  EdgeInsets.only(top: 10.0),),
                Text( body),
                Padding(padding:  EdgeInsets.only(top: 20.0),),
                ElevatedButton(
                  onPressed: () {
                    if( onComplete != null ) {
                      onComplete();

                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: gblSystemColors
                          .primaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30.0))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      TrText(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ]),])

  ));
}

  void updateAppDialog(BuildContext context) {
    var txt = '';
    if (gblSettings.optUpdateMsg != null &&
        gblSettings.optUpdateMsg.isNotEmpty) {
      txt = gblSettings.optUpdateMsg;
    }
    shownUpdate = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Update App'),
            content:
            Text(txt == '' ? 'A newer version of the app is available to download' : txt),
            actions: <Widget>[
              new TextButton(
                child: new Text(
                  'Close',
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text(
                  translate('Update Now'),
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: gblSystemColors.primaryButtonColor,
                    side: BorderSide(
                        color: gblSystemColors.textButtonTextColor, width: 1),
                    foregroundColor: gblSystemColors.primaryButtonTextColor),
                onPressed: () {

                  if( gblIsIos) {
                    launchUrl(Uri.parse('https://apps.apple.com/app/id${gblSettings.iOSAppId}'));
                  } else {
                    launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=' +gblSettings.androidAppId));
                  }
                },
              ),
            ]);
      },
    );
  }

  class ErrorParams {
    String msg = '';
    DialogType errorType = DialogType.None;
    bool isError = false;
    bool showDialog = false;

  }
