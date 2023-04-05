import 'dart:convert';

import 'package:flutter/material.dart';

import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/pnr.dart';
import '../data/models/pnrs.dart';
import '../data/repository.dart';
import '../data/smartApi.dart';
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
          onPressed: () async {
            try {
              await callSmartApi('CANCELPAYMENT', "");
              //print(reply);
            } catch(e) {
            }

            if (pnrCompleted() ||  pnrHasTTL()) {
              resetPnrContent(gblPnrModel.pNR.rLOC).then((x) {
                // return to choose flights
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/HomePage', (Route<dynamic> route) => false);
              });
            } else {

              // delete PNR contents
              deletePnrContent().then((x) {
                // return to choose flights
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/FlightSearchPage', (Route<dynamic> route) => false);
              });
              //Navigator.of(context).pop(true);
            }
          },
          child: new TrText('Yes'),
        ),
      ],
    ),
  )) ?? false;
}

bool pnrCompleted() {
  if( gblPnrModel != null && gblPnrModel.pNR.payments != null && gblPnrModel.pNR.payments.fOP.length >0 ){
    return true;
  }
  return false;
}
bool pnrHasTTL() {
  if( gblPnrModel != null && gblPnrModel.pNR.timeLimits != null && gblPnrModel.pNR.timeLimits.tTL != null ){
    return true;
  }
  return false;
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



Future<PnrDBCopy> resetPnrContent(String rloc) async {
  String data;
  try {
    logit('reset $rloc');
    data = await runVrsCommand('I^*$rloc~x');
  } catch(e) {
    logit('catch ${e.toString()}');
    throw (e);
  }
  if( ! data.startsWith('{')){
    PnrDBCopy pnr = PnrDBCopy(rloc: '', data: data, delete: 0);
    pnr.success = false;
    return pnr;

  }

  String pnrJson;
  //logit('RX: $data');

  pnrJson = data
      .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
      .replaceAll('<string xmlns="http://videcom.com/">', '')
      .replaceAll('</string>', '');
  Map map = json.decode(pnrJson);
  print('Fetch PNR');
  PnrModel pnrModel = new PnrModel.fromJson(map);

  // {"RLOC":

  PnrDBCopy pnrDBCopy = new PnrDBCopy(
      rloc: pnrModel.pNR.rLOC, //_rloc,
      data: pnrJson,
      success: true,
      delete: 0,
      nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());



  Repository.get().updatePnr(pnrDBCopy);

  return pnrDBCopy;
}


