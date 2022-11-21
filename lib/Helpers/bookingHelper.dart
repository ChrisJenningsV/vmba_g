import 'package:flutter/material.dart';

import '../components/trText.dart';
import '../data/globals.dart';
import '../data/repository.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';

Future<bool> onWillPop(BuildContext context) async {
  return (await showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      shape: alertShape(),
      titlePadding: alertTitlePadding(),
      title: alertTitle(translate('Are you sure?'), gblSystemColors.headerTextColor, gblSystemColors.primaryHeaderColor),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            TrText('Do you want abandon your booking '),
      ]),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
              side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
              primary: gblSystemColors.textButtonTextColor),
          onPressed: () {
            gblPayBtnDisabled = false;
            Navigator.of(context).pop(false);
          } ,
          child: new TrText('No'),
        ),
        TextButton(
          style: TextButton.styleFrom(
              side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
              primary: gblSystemColors.textButtonTextColor),
          onPressed: ()  {
            // delete PNR contents
            deletePnrContent().then((x) {
              // return to choose flights
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/FlightSearchPage', (Route<dynamic> route) => false);
          });
            //Navigator.of(context).pop(true);
          },
          child: new TrText('Yes'),
        ),
      ],
    ),
  )) ?? false;
}

Future deletePnrContent() async {
  if( gblPnrModel != null &&  gblPnrModel.pNR.rLOC != null && gblPnrModel.pNR.rLOC.isNotEmpty){
    String msg = '';
    String data = '';
      gblPnrModel.pNR.itinerary.itin.reversed.forEach((flt) {
        if(msg.isNotEmpty){
          msg += '^';
        }
        msg += 'X${flt.line}';

    });
      if( msg.isNotEmpty){
        msg = '*${gblPnrModel.pNR.rLOC}^' + msg;
        msg += '^E';
        logit('deletePnrContent msg:$msg ');
        try {
          data = await runVrsCommand(msg);
          logit(data);
        } catch(e) {
          gblError = e.toString();
        }
      }
  }
}