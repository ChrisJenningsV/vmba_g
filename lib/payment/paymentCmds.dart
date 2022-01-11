import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/controllers/vrsCommands.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/utilities/helper.dart';



Future changeFlt(PnrModel pnrModel, MmbBooking mmbBooking, BuildContext context) async {
  //Cancel journey
  Intl.defaultLocale = 'en';
  String cmd = '';
  cmd = '*${mmbBooking.rloc}^';
  mmbBooking.journeys.journey[mmbBooking.journeyToChange - 1]
      .itin.reversed
      .forEach((f) => cmd += 'X${f.line}^');

  mmbBooking.newFlights.forEach((flt) {
    print(flt.substring(0, 21) + 'NN' + flt.substring(23));
    cmd += flt.substring(0, 21) + 'NN' + flt.substring(23) + '^';
  });
  // cmd += removeVoucher();

  cmd += addFg(mmbBooking.currency, true);
  cmd += addFareStore(true);

  cmd += 'E*r~x';
  http.Response response;
  response = await http
      .get(Uri.parse(
      "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$cmd'"))
      .catchError((resp) {});

  if (response == null) {
/*
    setState(() {
      //_displayProcessingIndicator = false;
    });
*/
    noInternetSnackBar(context);
    return null;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
/*
    setState(() {
      //_displayProcessingIndicator = false;
    });
*/
    noInternetSnackBar(context);
    return null;
  }
}


Future xchangeFlt(PnrModel pnrModel, MmbBooking mmbBooking, BuildContext context) async {
  String msg = '';
  String _error = '';
  String nostop = '';
  http.Response response;
/*
  setState(() {
  });
*/

  String   rLOC = pnrModel.pNR.rLOC;

    msg = '*$rLOC';
    mmbBooking.newFlights.forEach((flt) {
      String org = flt.substring(15, 18);

      mmbBooking.journeys.journey.forEach((j) {
        if( j.itin[0].depart == org){
          //      msg += '^X${j.itin[0].line}';
        }
      });
      print(flt);
      msg += '^' + flt;
    });
    msg += '^e*r~x';

  print(msg);
  response = await http
      .get(Uri.parse(
      "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
      .catchError((resp) {});

  if (response == null) {
/*
    setState(() {
      //_displayProcessingIndicator = false;
    });
*/
    noInternetSnackBar(context);
    return null;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
/*
    setState(() {
      //_displayProcessingIndicator = false;
    });
*/
    noInternetSnackBar(context);
    return null;
  }

  bool flightsConfirmed = true;
  String _response = response.body
      .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
      .replaceAll('<string xmlns="http://videcom.com/">', '')
      .replaceAll('</string>', '');
  if (response.body.contains('ERROR - ') ||
      !_response.trim().startsWith('{')) {
    _error = _response.replaceAll('ERROR - ', '').trim();
    _dataLoaded();
    showSnackBar(_error, context);
    return null;
  } else {
    Map map = json.decode(_response);
    pnrModel = new PnrModel.fromJson(map);
    print(pnrModel.pNR.rLOC);
    if (pnrModel.hasNonHostedFlights() &&
        pnrModel.hasPendingCodeShareOrInterlineFlights()) {
      int noFLts = pnrModel
          .flightCount(); //if external flights aren't confirmed they get removed from the PNR
      // which makes it look like the flights are confirmed

      flightsConfirmed = false;
      for (var i = 0; i < 10; i++) {
        msg = '*' + pnrModel.pNR.rLOC + '~x';
        response = await http
            .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
            .catchError((resp) {});
        if (response == null) {
/*          setState(() {
            //_displayProcessingIndicator = false;
          });*/
          //showSnackBar(translate('Please, check your internet connection'));
          noInternetSnackBar(context);
          return null;
        }

        //If there was an error return an empty list
        if (response.statusCode < 200 || response.statusCode >= 300) {
 /*         setState(() {
            //_displayProcessingIndicator = false;
          });
*/          //showSnackBar(translate('Please, check your internet connection'));
          noInternetSnackBar(context);
          return null;
        }
        if (response.body.contains('ERROR - ')) {
          _error = response.body
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '')
              .replaceAll('ERROR - ', '')
              .trim(); // 'Please check your details';
          _dataLoaded();
          return null;
        } else {
          String pnrJson = response.body
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '');
          Map map = json.decode(pnrJson);

          pnrModel = new PnrModel.fromJson(map);
        }

        if (!pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          if (noFLts == pnrModel.flightCount()) {
            flightsConfirmed = true;
          } else {
            flightsConfirmed = false;
          }
          break;
        }
        await new Future.delayed(const Duration(seconds: 2));
      }
    }
  }
  if (!flightsConfirmed) {
/*
    setState(() {
      //_displayProcessingIndicator = false;
    });
*/
    showSnackBar(translate('Unable to confirm partner airlines flights.'), context);
    //Cnx new flights
    msg = '*${mmbBooking.rloc}';
    mmbBooking.newFlights.forEach((flt) {
      print('x' + flt.split('NN1')[0].substring(2));
      msg += '^' + 'x' + flt.split('NN1')[0].substring(2);
    });
    response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
        .catchError((resp) {});
    return null;
  }

  msg = '*$rLOC^';
  //update to use full cancel segment command
 // if (widget.isMmb) {
    //msg += '^';

    for (var i = 0;
    i <
        mmbBooking.journeys
            .journey[mmbBooking.journeyToChange - 1].itin.length;
    i++) {
      Itin f = mmbBooking.journeys
          .journey[mmbBooking.journeyToChange - 1].itin[i];
      String _depDate =
      DateFormat('ddMMM').format(DateTime.parse(f.depDate)).toString();
      msg +=
      'X${f.airID}${f.fltNo}${f.xclass}$_depDate${f.depart}${f.arrive}^';
      if (f.nostop == 'X') {
        nostop += ".${f.line}X^";
      }
    }

    msg += addFg(mmbBooking.currency, true);
    msg += addFareStore(true);

    msg += 'e*r';
 // }

  //msg += getPaymentCmd(true);

  try{
    print( "Payment sent $msg");
  } catch(e) {
    print(e);
  }
  response = await http
      .get(Uri.parse(
      "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
      .catchError((resp) {});

  if (response == null) {
/*    setState(() {
      //_displayProcessingIndicator = false;
    });*/
    //showSnackBar(translate('Please, check your internet connection'));
    noInternetSnackBar(context);
    return null;
  }

  //If there was an error return an empty list
  if (response.statusCode < 200 || response.statusCode >= 300) {
  /*  setState(() {
      //_displayProcessingIndicator = false;
    });*/
    //showSnackBar(translate('Please, check your internet connection'));
    noInternetSnackBar(context);
    return null;
  }

  String result = '';
  try {
    result = response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');

    if (result.trim() == 'Payment Complete') {
      gblTimerExpired = true;
      print('Payment success');

/*
      setState(() {
        //_displayProcessingText = 'Completing your booking...';
        //_displayProcessingIndicator = true;
      });
*/
      if (pnrModel.pNR.tickets != null) {
        //       await pullTicketControl(pnrModel.pNR.tickets);
      }
      //   ticketBooking();
    } else if (result.contains('VrsServerResponse')) {
      _error = json.decode(result)['VrsServerResponse']['PaymentResult']['Description'];
      gblTimerExpired = true;
      _dataLoaded();
      //_showDialog();
      logit(_error);
      showAlertDialog(context, 'Error', _error);

    } else if (result.contains('ERROR')) {
      gblTimerExpired = true;
      _error = result;
      logit(_error);
      _dataLoaded();
      //_showDialog();
      showAlertDialog(context, 'Error', _error);

    } else if (result.contains('Payment not')) {
      gblTimerExpired = true;
      _error = result;
      _dataLoaded();
      logit(_error);
      //_showDialog();
      showAlertDialog(context, 'Error', _error);

    } else {
      gblTimerExpired = true;
      print(result);
      _error = translate('Declined') + ': ' + result;
      _dataLoaded();
      //_showDialog();
      showAlertDialog(context, 'Error', _error);

    }
  } catch (e) {
    gblTimerExpired = true;
    if( result.isNotEmpty ){
      _error = result;
    } else {
      _error = response.body; // 'Please check your details';
    }
    logit(_error);
    _dataLoaded();
    //_showDialog();
    showAlertDialog(context, 'Error', _error);

  }
}
void _dataLoaded() {
/*  setState(() {
    gblPayBtnDisabled = false;
    //_displayProcessingIndicator = false;
  });*/
}

void saveChanges(BuildContext context)  async{
  http.Response response;
  String msg = 'e*r~x';

  print(msg);
  response = await http
      .get(Uri.parse(
      "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
      .catchError((resp) {});

  if (response == null) {
/*
    setState(() {
      //_displayProcessingIndicator = false;
    });
*/
    noInternetSnackBar(context);
    return null;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
/*
    setState(() {
      //_displayProcessingIndicator = false;
    });
*/
    noInternetSnackBar(context);
    return null;
  }

}