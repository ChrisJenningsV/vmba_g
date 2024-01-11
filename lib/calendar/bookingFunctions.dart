import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../Helpers/networkHelper.dart';
import '../Helpers/stringHelpers.dart';
import '../components/trText.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../data/models/models.dart';
import '../data/models/pax.dart';
import '../data/models/pnr.dart';
import '../data/repository.dart';
import '../home/home_page.dart';
import '../utilities/helper.dart';

Future searchSaveBooking(NewBooking newBooking) async {
  gblPayable = '';
  PnrModel pnrModel;
  //String currencyCode;

  ParsedResponse rs = await Repository.get().getFareQuote(buildCmd(newBooking));

    if (rs.isOk()) {
      pnrModel = rs.body;
      //currencyCode = setCurrencyCode(pnrModel);
      if (gblRedeemingAirmiles == true) {
        int miles =
            int.tryParse(
                pnrModel.pNR.basket.outstandingairmiles.airmiles) ??
                0;
        if (gblFqtvBalance < miles) {
          /* setState(() {
              _loadingInProgress = false;
              _eVoucherNotValid = false;
              _tooManyUmnr = false;
              _hasError = true;*/
          gblError =
          'You do not have enough ${gblSettings
              .fQTVpointsName} to pay for this booking\n Balance = $gblFqtvBalance, ${gblSettings
              .fQTVpointsName} required = $miles';
          /* });*/
        }
      }
      // _dataLoaded();
      gblPnrModel = pnrModel;
      setAmountPayable( pnrModel);
      return pnrModel;
    } else if (rs.statusCode == 0) {
      gblError = rs.error;
      throw(gblError);
      /* _hasError = true;
        setState(() {
          _loadingInProgress = false;
        });*/
    } else {

      /*setState(() {
          _loadingInProgress = false;
          _noInternet = true;
        });*/
    }

  /*).catchError((resp) {
    logit(resp);
    if (resp is FormatException) {
      //String _error;
      FormatException ex = resp;
      print(ex.source.toString().trim());
      gblError = ex.source.toString().trim();
      *//*if (_error.contains('ERROR: E-VOUCHER ')) {
          setState(() {
            _loadingInProgress = false;
            _eVoucherNotValid = true;
          });
        } else if(_error.contains('TOO MANY UMNR ')) {
          setState(() {
            _tooManyUmnr = true;
            _eVoucherNotValid = true;
          });
        } else {
          setState(() {
            _loadingInProgress = false;
            _eVoucherNotValid = false;
            _hasError = true;
          });
        }*//*
    }
    else {
      gblError = resp;
    }
  });*/
}

String setCurrencyCode(PnrModel pnrModel) {
  String currencyCode;
  try {
    currencyCode =
    pnrModel
      .pNR
      .fareQuote
      .fareStore
      .where((fareStore) => fareStore.fSID == 'Total')
      .first
      .cur;
  } catch (ex) {
  currencyCode = '';
  print(ex.toString());
  }
  return currencyCode;
}

String buildCmd(NewBooking newBooking) {
  String cmd;
  cmd = buildDummyAddPaxCmd(newBooking);
  cmd += buildADSCmd(newBooking);
  newBooking.outboundflight.forEach((flt) {
    int index = flt.indexOf('/');
    String bkFlt = flt.substring(0, index-3) + 'QQ' + flt.substring(index-1);
    print(bkFlt);
    cmd += bkFlt + '^';
    //print(flt.substring(0, 21) + 'QQ' + flt.substring(23));
    //cmd += flt.substring(0, 21) + 'QQ' + flt.substring(23) + '^';
  });

  newBooking.returningflight.forEach((flt) {
    int index = flt.indexOf('/');
    String bkFlt = flt.substring(0, index-3) + 'QQ' + flt.substring(index-1);
    print(bkFlt);
    cmd += bkFlt + '^';
    //   print(flt.substring(0, 21) + 'QQ' + flt.substring(23));
    //   cmd += flt.substring(0, 21) + 'QQ' + flt.substring(23) + '^';
  });

  //Add connecting indicators for outbound and return flights
  if (newBooking.outboundflight.length > 1) {
    for (var i = 1; i < newBooking.outboundflight.length; i++) {
      print('.${i}x^');
      cmd += '.${i}x^';
    }
  }

  if (newBooking.returningflight.length > 1) {
    for (var i = newBooking.outboundflight.length + 1;
    i <
        newBooking.outboundflight.length +
            newBooking.returningflight.length;
    i++) {
      print('.${i}x^');
      cmd += '.${i}x^';
    }
  }

  //Add voucher code
  if (newBooking.eVoucherCode != null &&
      newBooking.eVoucherCode.trim() != '') {
    cmd += '4-1FDISC${newBooking.eVoucherCode.trim()}^';
  }
  cmd += addFg(newBooking.currency, true);
  cmd += addFareStore(true);
  cmd += '*r~x';
//    cmd += 'fg^fs1^*r~x';
  logit('getFareQuote1: ' + cmd);
  return cmd;
}
String buildDummyAddPaxCmd(NewBooking newBooking) {
  StringBuffer sb = new StringBuffer();

  if( gblSettings.useWebApiforVrs) {
    sb.write('I^');
  }

  for (var adults = 1;
  adults < newBooking.passengers.adults + 1;
  adults++) {
    sb.write("-TTTT${convertNumberIntoWord(adults)}/AdultMr^");
  }
  for (var youths = 1;
  youths < newBooking.passengers.youths + 1;
  youths++) {
    sb.write("-TTTT${convertNumberIntoWord(youths)}/YouthMr.TH15^");
  }
  for (var seniors = 1;
  seniors < newBooking.passengers.seniors + 1;
  seniors++) {
    sb.write("-TTTT${convertNumberIntoWord(seniors)}/SeniorMr.CD^");
  }
  for (var students = 1;
  students < newBooking.passengers.students + 1;
  students++) {
    sb.write("-TTTT${convertNumberIntoWord(students)}/StudentMr.SD^");
  }
  for (var child = 1;
  child < newBooking.passengers.children + 1;
  child++) {
    sb.write("-TTTT${convertNumberIntoWord(child)}/ChildMr.CH10^");
  }
  for (var infant = 1;
  infant < newBooking.passengers.infants + 1;
  infant++) {
    sb.write("-TTTT${convertNumberIntoWord(infant)}/infantMr.IN09^");
  }

  return sb.toString();
}

String buildADSCmd(NewBooking newBooking) {
  StringBuffer sb = new StringBuffer();
  String paxNo = '1';
  if (newBooking.ads.pin != null && newBooking.ads.pin != '' &&
      newBooking.ads.number != null && newBooking.ads.number != '') {
    sb.write(
        '4-${paxNo}FADSU/${newBooking.ads.number}/${newBooking.ads.pin}^');
  }
  return sb.toString();
}

setAmountPayable(PnrModel pnrModel) {
  if( pnrModel == null || pnrModel.pNR == null ) {
    gblPayable = '';
    return;
  }
  FareStore fareStore = pnrModel
      .pNR
      .fareQuote
      .fareStore
      .where((fareStore) => fareStore.fSID == 'Total')
      .first;

  var amount = fareStore.total;
  if (double.parse(amount) <= 0) {
    amount = "0";
  }
  gblPayable = formatPrice(currencyCode(pnrModel), double.tryParse(amount) ?? 0.0);
}
String currencyCode(PnrModel pnrModel) {
  try {
    return  pnrModel
        .pNR
        .fareQuote
        .fareStore
        .where((fareStore) => fareStore.fSID == 'Total')
        .first
        .cur;
  } catch (ex) {

    print(ex.toString());
    return'';
  }
}

List<Pax> getPaxlist(PnrModel pnr, int  journey) {
  List<Pax> paxlist = [];

  for (var pax = 0; pax <= pnr.pNR.names.pAX.length - 1; pax++) {
    if (pnr.pNR.names.pAX[pax].paxType != 'IN') {
      paxlist.add(Pax(
          pnr.pNR.names.pAX[pax].firstName +
              ' ' +
              pnr.pNR.names.pAX[pax].surname,
          pnr.pNR.aPFAX != null
              ? pnr.pNR.aPFAX.aFX
              .firstWhere(
                  (aFX) =>
              aFX.aFXID == "SEAT" &&
                  aFX.pax == pnr.pNR.names.pAX[pax].paxNo &&
                  aFX.seg == (journey + 1).toString(),
              orElse: () => new AFX())
              .seat
              : '',
          pax == 0 ? true : false,
          pax + 1,
          pnr.pNR.aPFAX != null
              ? pnr.pNR.aPFAX.aFX
              .firstWhere(
                  (aFX) =>
              aFX.aFXID == "SEAT" &&
                  aFX.pax == pnr.pNR.names.pAX[pax].paxNo &&
                  aFX.seg == (journey + 1).toString(),
              orElse: () => new AFX())
              .seat
              : '',
          pnr.pNR.names.pAX[pax].paxType));
    }
  }
  return paxlist;
}



Future makeBooking(NewBooking newBooking, PnrModel pnrModel) async {
  String msg = '';
  /*PnrModel pnrModel;*/
  // if using VRS sessions/AAA clear out temp booking

  print('gblSettings.useWebApiforVrs=${gblSettings.useWebApiforVrs}');
  if(gblSettings.useWebApiforVrs ) msg = 'I^';

  msg += buildAddPaxCmd(newBooking);
  msg += buildAddContactsCmd(newBooking);
  msg += buildADSCmd(newBooking);
  msg += buildFQTVCmd(newBooking);
  newBooking.outboundflight.forEach((flt) {
    msg += flt + '^';
  });
  newBooking.returningflight.forEach((flt) {
    msg += flt + '^';
  });
  //Add connecting indicators for outbound flights
  if (newBooking.outboundflight.length > 1) {
    for (var i = 1; i < newBooking.outboundflight.length; i++) {
      print('.${i}x^');
      msg += '.${i}x^';
    }
  }

  if (newBooking.returningflight.length > 1) {
    for (var i = newBooking.outboundflight.length + 1;
    i <
        newBooking.outboundflight.length +
            newBooking.returningflight.length;
    i++) {
      print('.${i}x^');
      msg += '.${i}x^';
    }
  }

  //Add voucher code
  if (newBooking.eVoucherCode != null &&
      newBooking.eVoucherCode.trim() != '') {
    msg += '4-1FDISC${newBooking.eVoucherCode.trim()}^';
  }
  if( gblSettings.brandID != null && gblSettings.brandID.isNotEmpty){
    msg += 'zbrandid=${gblSettings.brandID}^';
  }
  msg += addFg(newBooking.currency, true);
  msg += addFareStore(true);
  //msg += 'fg^fs1^8M/20^e*r~x';
  msg += '8M/20^e*r~x';

  logit('makeBooking: $msg');

  if( gblSettings.useWebApiforVrs) {
    print('Calling VRS with Cmd = $msg');
    String data = await runVrsCommand(msg).catchError((e) {
      //noInternetSnackBar(context);
      gblError = e.toString();
      return null;
    });
    if( data == null ){
      if( gblError == '') {
        gblError = 'Booking Failed';
      }
      return null;

    }

    try {
      bool flightsConfirmed = true;
      if (data.contains('ERROR - ') || data.contains('ERROR:')) {
        gblError = data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '')
            .replaceAll('ERROR - ', '')
            .trim(); // 'Please check your details';

       /* if (data.contains('TOO MANY UMNR')) {
        *//*  setState(() {
            _displayProcessingIndicator = false;
            _tooManyUmnr = true;
          });*//*
          return null;
        }*/
       // _dataLoaded();
        print('makeBooking $gblError');

        //_gotoPreviousPage();
        return;
      } else {
        String pnrJson =data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');
        Map<String, dynamic> map = json.decode(pnrJson);

        pnrModel = new PnrModel.fromJson(map);
        gblPnrModel = pnrModel;
        print(pnrModel.pNR.rLOC);
        //bool flightsConfirmed = true;
        if (pnrModel.hasNonHostedFlights() && pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          //if external flights aren't confirmed they get removed from the PNR which makes it look like the flights are confirmed
          int noFLts = pnrModel.flightCount();

          flightsConfirmed = false;
          for (var i = 0; i < 10; i++) { // was 4
            msg = '*' + pnrModel.pNR.rLOC + '~x';

/*
            http.Response response = await http.get(Uri.parse(
                "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"),
                headers: getXmlHeaders())
                .catchError((resp) {});
*/
            String data = await runVrsCommand(msg).catchError((e) {

//            if (response == null) {
              gblError = 'Network error';
              return null;
            });

            //If there was an error return an empty list
            if(data == null ) { // (response.statusCode < 200 || response.statusCode >= 300) {
/*
              setState(() {
                _displayProcessingIndicator = false;
              });
              noInternetSnackBar(context);
*/
              gblError = 'Network error';
              return null;
            //} else if (response.body.contains('ERROR - ') || response.body.contains('ERROR:')) {
            } else if (data.contains('ERROR - ') || data.contains('ERROR:')) {
              gblError = data
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '')
                  .replaceAll('ERROR - ', '')
                  .trim(); // 'Please check your details';
/*
              _dataLoaded();
              _gotoPreviousPage();
*/
              return;
            } else {
              String pnrJson = data
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '');
              Map<String, dynamic> map = json.decode(pnrJson);

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
            await new Future.delayed(const Duration(seconds: 4)); // was 2
            //sleep(const Duration(seconds: 2));
          }
        }
      }

      if (flightsConfirmed) {
        return pnrModel;
/*
        _dataLoaded();
        gotoChoosePaymentPage();
*/
      } else {
/*
        setState(() {
          _displayProcessingIndicator = false;
        });
*/
        gblError = translate('Unable to confirm partner airlines flights.');
        logit('Unable to confirm partner airlines flights.');
//        Navigator.pop(context, _error);
        return null;
      }
    } catch (e) {
      logit(e.toString());
      gblError = e.toString();
      if( data != null ) {
        gblError = data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');
        print(gblError);
      }
/*
      _dataLoaded();
      _showDialog();
*/
    }

  } else {
    print("Calling ${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg");

    http.Response response = await http.get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"),
        headers: getXmlHeaders())
        .catchError((resp) {});

    if (response == null) {
/*
      setState(() {
        _displayProcessingIndicator = false;
      });
      noInternetSnackBar(context);
*/
    gblError = 'Network error';
      return null;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
/*
      setState(() {
        _displayProcessingIndicator = false;
      });
      noInternetSnackBar(context);
*/
      gblError = 'Network error';
      return null;
      // return new ParsedResponse(response.statusCode, []);
    }

    try {
      bool flightsConfirmed = true;
      if (response.body.contains('ERROR - ') || response.body.contains('ERROR:')) {
        gblError = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '')
            .replaceAll('ERROR - ', '')
            .trim(); // 'Please check your details';

/*
        if (response.body.contains('TOO MANY UMNR')) {
          setState(() {
            _displayProcessingIndicator = false;
            _tooManyUmnr = true;
          });
          return null;
        }
*/
        //_dataLoaded();
        print('makeBooking $gblError');
        //_gotoPreviousPage();
        return null;
      } else {
        String pnrJson = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');
        Map<String, dynamic> map = json.decode(pnrJson);

        pnrModel = new PnrModel.fromJson(map);
        print(pnrModel.pNR.rLOC);
        //bool flightsConfirmed = true;
        if (pnrModel.hasNonHostedFlights() && pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          //if external flights aren't confirmed they get removed from the PNR which makes it look like the flights are confirmed
          int noFLts = pnrModel.flightCount();

          flightsConfirmed = false;
          for (var i = 0; i < 10; i++) { // was 4
            msg = '*' + pnrModel.pNR.rLOC + '~x';
            response = await http
                .get(Uri.parse(
                "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"),
                headers: getXmlHeaders())
                .catchError((resp) {});
            if (response == null) {
/*
              setState(() {
                _displayProcessingIndicator = false;
              });
              noInternetSnackBar(context);
*/
              gblError ='Network error';
              return null;
            }

            //If there was an error return an empty list
            if (response.statusCode < 200 || response.statusCode >= 300) {
              gblError ='Network error ${response.statusCode}';
             /* setState(() {
                _displayProcessingIndicator = false;
              });
              //showSnackBar(translate('Please, check your internet connection'));
              noInternetSnackBar(context); */
              return null;
            } else if (response.body.contains('ERROR - ') ||
                response.body.contains('ERROR:')) {
              gblError = response.body
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '')
                  .replaceAll('ERROR - ', '')
                  .trim(); // 'Please check your details';
/*
              _dataLoaded();
              _gotoPreviousPage();
*/
              return;
            } else {
              String pnrJson = response.body
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '');
              Map<String, dynamic> map = json.decode(pnrJson);

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
            await new Future.delayed(const Duration(seconds: 4)); // was 2
          }
        }
      }

      if (flightsConfirmed) {
        return pnrModel;
/*
        _dataLoaded();
        gotoChoosePaymentPage();
*/
      } else {
/*        setState(() {
          _displayProcessingIndicator = false;
        });*/
        gblError = translate('Unable to confirm partner airlines flights.');
        //showSnackBar();
        logit('Unable to confirm partner airlines flights.');
/*        Navigator.pop(context, _error);
        return null;*/
      }
    } catch (e) {
      gblError = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      print(gblError);
/*
      _dataLoaded();
      _showDialog();
*/
    }
  }
  return null;
}

String buildAddContactsCmd(NewBooking newBooking) {
  StringBuffer sb = new StringBuffer();
  if( gblSettings.wantNewEditPax ) {
    if( newBooking.passengerDetails[0].phonenumber != null && newBooking.passengerDetails[0].phonenumber.isNotEmpty) {
      sb.write('9M*${newBooking.passengerDetails[0].phonenumber}^');
    }
    if(newBooking.passengerDetails[0].email!= null && newBooking.passengerDetails[0].email.isNotEmpty ) {
      sb.write('9E*${newBooking.passengerDetails[0].email}^');
    }

  } else {
    if( newBooking.contactInfomation.phonenumber != null && newBooking.contactInfomation.phonenumber.isNotEmpty) {
      sb.write('9M*${newBooking.contactInfomation.phonenumber}^');
    }
    if(newBooking.contactInfomation.email!= null && newBooking.contactInfomation.email.isNotEmpty ) {
      sb.write('9E*${newBooking.contactInfomation.email}^');
    }
  }

  return sb.toString();
}

String buildFQTVCmd(NewBooking newBooking) {
  StringBuffer sb = new StringBuffer();
  newBooking.passengerDetails.asMap().forEach((index, pax) {
    if (pax.fqtv != null && pax.fqtv != '') {
      sb.write('4-${index + 1}FFQTV${pax.fqtv}^');
    } else {
      if( gblFqtvNumber != null && gblFqtvNumber.isNotEmpty && index == 0) {
        sb.write('4-${index + 1}FFQTV$gblFqtvNumber^');

      }
    }
  });

  return sb.toString();
}

String buildAddPaxCmd(NewBooking newBooking) {
  StringBuffer sb = new StringBuffer();
  int paxNo = 1;
  newBooking.passengerDetails.forEach((pax) {
    if (pax.lastName != '') {
      if( pax.middleName != null && pax.middleName.isNotEmpty && pax.middleName.toUpperCase() != 'NONE') {
        //sb.write('-${pax.paxNumber}${pax.lastName}/${pax.firstName}${pax.middleName}${pax.title}');
        sb.write('-${pax.lastName}/${pax.firstName}${pax.middleName}${pax.title}');
      } else {
        //sb.write('-${pax.paxNumber}${pax.lastName}/${pax.firstName}${pax.title}');
        sb.write('-${pax.lastName}/${pax.firstName}${pax.title}');
      }
      if (pax.dateOfBirth != null) {
        // get age in years
        Duration td = DateTime.now().difference(pax.dateOfBirth as DateTime);
        int ageYears = (td.inDays / 365).round();
        int ageMonths = (td.inDays / 30).round();
        if( ageMonths == 24) ageMonths = 23;
        String _dob = DateFormat('ddMMMyy').format(pax.dateOfBirth as DateTime).toString();

        bool wantDOB = false;
        if (pax.paxType == PaxType.child) {
          //sb.write('.CH${ageYears.toStringAsFixed(2)}');
          sb.write('.CH${ageYears}($_dob)');
          wantDOB = true;
        } else if (pax.paxType == PaxType.youth) {
          sb.write('.TH${ageYears}');
          wantDOB = true;
        } else if (pax.paxType == PaxType.senior) {
          sb.write('.CD');
          sb.write('($_dob)');
          wantDOB = true;
        } else if (pax.paxType == PaxType.infant) {
          // 2@jones/babyMstr.IN23^3-2FDOB 26Aug2
          //sb.write('.IN${ageMonths.toStringAsFixed(2)}');
          sb.write('.IN${ageMonths.toString()}($_dob)');
          wantDOB = true;
        }
        if( gblSettings.wantApis && wantDOB) {
          String _dob =
          DateFormat('ddMMMyy').format(pax.dateOfBirth as DateTime).toString();
          sb.write('^3-${pax.paxNumber}FDOB $_dob');
        }
      } else {
        if (pax.paxType == PaxType.student) {
          sb.write('.SD');
        } else if (pax.paxType == PaxType.senior) {
          sb.write('.CD');
        } else if (pax.paxType == PaxType.youth) {
          sb.write('.TH15');
        }
      }

    }
    sb.write('^');
    if( gblSettings.aircode == 'T6') {
      // phlippines specials
      if( pax.country != null && pax.country.toUpperCase() == 'PHILIPPINES'){
        sb.write('3-${pax.paxNumber}FCNTY${pax.country}^');
        // add disability
        if(  pax.disabilityID != null && pax.disabilityID.isNotEmpty ) {
          sb.write('ZDPWD-${pax.paxNumber}/${pax.disabilityID}^');
        }

        // add senior id
        if( pax.paxType == PaxType.senior && pax.seniorID != null && pax.seniorID.isNotEmpty ){
          sb.write('ZDSEN-${pax.paxNumber}/${pax.seniorID}^');
        }
      }

    }

    if( pax.dateOfBirth != null && (pax.paxType == PaxType.adult || pax.paxType == PaxType.senior)){
      String _dob =
      DateFormat('ddMMMyyyy').format(pax.dateOfBirth as DateTime).toString();
      sb.write('3-${paxNo}FDOB $_dob^');

    }
    if( pax.gender != null && pax.gender.isNotEmpty ){
      sb.write('3-${paxNo}FGNDR${pax.gender}^');
    }
    if( pax.redressNo != null && pax.redressNo.isNotEmpty ){
      sb.write('4-${paxNo}FDOCO//R/${pax.redressNo}///USA^');
    }
    if( pax.knowTravellerNo != null && pax.knowTravellerNo.isNotEmpty ){
      sb.write('4-${paxNo}FDOCO//K/${pax.knowTravellerNo}///USA^');
    }
    paxNo +=1 ;
  });
  return sb.toString();
}
void refreshMmbBooking() {
  try {
    if( mmbGlobalKeyBooking != null && mmbGlobalKeyBooking.currentState != null ) {
      mmbGlobalKeyBooking.currentState?.refresh();
    }
  } catch (e) {

  }
}
void reloadMmbBooking(String rloc) {
  try {
    if( mmbGlobalKeyBooking != null && mmbGlobalKeyBooking.currentState != null ) {
      mmbGlobalKeyBooking.currentState?.reload(rloc);
    }
  } catch (e) {

  }
}
void refreshStatusBar() {
  try {

  if( statusGlobalKeyOptions != null && statusGlobalKeyOptions.currentState != null ) {
    statusGlobalKeyOptions.currentState?.refresh();
  }
  } catch (e) {
    print(e.toString());
  }

  try{
  if( statusGlobalKeyPax != null && statusGlobalKeyPax.currentState != null ) {
    statusGlobalKeyPax.currentState?.refresh();
  }
} catch (e) {
print(e.toString());
}


}