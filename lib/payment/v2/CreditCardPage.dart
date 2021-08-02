import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/menu/menu.dart';
import 'package:intl/intl.dart';
import 'package:vmba/payment/v2/countDownTimer/CardInputWidget.dart';
import 'package:vmba/payment/v2/countDownTimer/CountDownTimer.dart';
import 'package:vmba/payment/v2/countDownTimer/timerWidget.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';

import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/controllers/vrsCommands.dart';
import 'package:vmba/components/showDialog.dart';

class CreditCardPage extends StatefulWidget {
  CreditCardPage({    Key key,
    this.newBooking,
    this.pnrModel,
    this.stopwatch,
    this.isMmb=false,
    this.mmbBooking,
    this.mmbAction,
    this.session,
  }) : super(key: key);

  final NewBooking newBooking;
  final PnrModel pnrModel;
  final Stopwatch stopwatch;
  final bool isMmb;
  final MmbBooking mmbBooking;
  final mmbAction;
  final Session session;

  @override
  _CreditCardPageState createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  // bool _displayProcessingIndicator;
  //String _displayProcessingText = 'Making your Booking...';
  PaymentDetails paymentDetails = new PaymentDetails();
  String nostop = '';

  //bool _displayProcessingIndicator;
 // String _displayProcessingText;
  PnrModel pnrModel;
  String _error;
  String rLOC = '';
  Session session;

  @override
  initState() {
    super.initState();
      double am = double.parse(widget.pnrModel.pNR.basket.outstanding.amount);
      gblError = '';
      if( am <= 0 ) {
        signin().then((_) => completeBooking() );
      }
    }
/*
    if( widget.pnrModel.pNR.basket.outstanding.amount == '0') {
      signin().then((_) => completeBooking() );
    }
 */



    @override
  Widget build(BuildContext context) {
      if( gblError != null && gblError.isNotEmpty){
        return Scaffold(
          key: _key,
          appBar: new AppBar(
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new Text('Payment Selection',
                style: TextStyle(
                    color:
                    gblSystemColors.headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body: new Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TrText('Payment Error', style: TextStyle(fontSize: 16.0)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TrText(gblError, style: TextStyle(fontSize: 16.0),),
                ),
              ],
            ),
          ),
        );

        // showAlertDialog(context, 'Error making payment', gblError);
        // return null;
      }
    return Scaffold(
      key: _key,
      appBar: AppBar(
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new TrText('Payment',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
      endDrawer: DrawerMenu(),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TrText(
                            'Please complete your payment within ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                          ChangeNotifierProvider(
                              create: (context) => CountDownTimer(),
                              child: TimerWidget(timerExpired: () {
                                timerExpired();
                                print('expired');
                              })),
                        ],
                      ),
                    ),
                  )),
            )
          ]),
          widget.pnrModel.pNR.basket.outstanding
              .amount ==
              '0' ? TrText('Completing booking...') :
          CardInputWidget(
            payCallback: () {
              hasDataConnection().then((result) async {
                if (result == true) {

                  makePayment();
                //  signin().then((_) => makePayment());
                } else {
                  setState(() {
                    // _displayProcessingIndicator = false;
                  });
                  //showSnackBar(translate('Please, check your internet connection'));
                  noInternetSnackBar(context);
                }
              });
            },
            paymentDetails:  paymentDetails,
          ),
        ]),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _dataLoaded() {
    setState(() {
      gblPayBtnDisabled = false;
      //_displayProcessingIndicator = false;
    });
  }
  Future _sendVRSCommand(msg) async {
    print('_sendVRSCommand $msg');

    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/RunVRSCommand"),
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: msg);

    if (response.statusCode == 200) {
      return response.body.trim();
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: _error != null && _error != ''
              ? new Text(_error)
              : new Text("Please try again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                _error = '';

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signin() async {
    await login().then((result) {
      session = Session(
        result.sessionId,
        result.varsSessionId,
        result.vrsServerNo,
      );
      gblSession = session;
    });
  }

  Future completeBooking() async {
    var msg = "*${widget.pnrModel.pNR.rLOC}^EZT*R~x";
    gblTimerExpired = true;
    _sendVRSCommand(json.encode(
        RunVRSCommand(session, msg).toJson()))
        .then((result) {
          try{
            if(! result.toString().startsWith('{')){
              gblError = result;
              gblErrorTitle = 'Payment Error';
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/ErrorPage', (Route<dynamic> route) => false);
              return null;
            }
      Map map = json.decode(result);
      PnrModel pnrModel = new PnrModel.fromJson(map);
      PnrDBCopy pnrDBCopy = new PnrDBCopy(
          rloc: pnrModel.pNR.rLOC, //_rloc,
          data: result,
          delete: 0,
          nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());

      Repository.get().updatePnr(pnrDBCopy);
      Repository.get()
          .fetchApisStatus(pnrModel.pNR.rLOC)
          .then((_) => sendEmailConfirmation(pnrModel))
          .then((n) => getArgs(pnrModel.pNR))
          .then((arg) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/CompletedPage', (Route<dynamic> route) => false,
            arguments: arg);
      });
    } catch(e)
    {
      print(e);
    }

      });
    }



  Future makePayment() async {
    String msg = '';
    http.Response response;
    setState(() {
      //_displayProcessingText = 'Processing your payment...';
      //_displayProcessingIndicator = true;
    });
    if (widget.isMmb) {
      session = widget.session;
    }
    if (session != null) {
      _sendVRSCommand(json.encode(
          RunVRSCommand(session, getPaymentCmd(false)).toJson()))
          .then((result) {
            print(result);
        if (result == 'Payment Complete') {
          gblTimerExpired = true;
/*          if (pnrModel.pNR.tickets != null) {
            await pullTicketControl(pnrModel.pNR.tickets);
          }
         ticketBooking ();

 */   // need to re - ticket
          // MMGBP25^
          // is it a change flight action ?

          //  EZV*[E][ZWEB]^EZT*R^EMT*R^E*R^EZRE/en^*r~xMMGBP25^EZV*[E][ZWEB]^EZT*R^EMT*R^E*R^EZRE/en^*r~x
          // _sendVRSCommand(json.encode(RunVRSCommand(session, "EMT*R~x")))
          var cmd = "EMT*R~x";
          if( widget.mmbAction == 'CHANGEFLT') {
            // get tickets
            cmd = "EZV*[E][ZWEB]^EZT*R^EMT*R^E*R~x"; // server exception
            //cmd = "EZV*[E][ZWEB]^E*R~x"; // good, no tickets
            //cmd = "EZV*[E][ZWEB]^EZT*R~x"; // good
            //cmd = "EZV*[E][ZWEB]^EZT^EMT*R~x"; //
          }
          _sendVRSCommand(json.encode(RunVRSCommand(session, cmd).toJson()))
              .then((onValue) {
                // Server Exception ?
            Map map = json.decode(onValue);
            PnrModel pnrModel = new PnrModel.fromJson(map);
            PnrDBCopy pnrDBCopy = new PnrDBCopy(
                rloc: pnrModel.pNR.rLOC, //_rloc,
                data: onValue,
                delete: 0,
                nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
            Repository.get()
                .updatePnr(pnrDBCopy)
                .then((n) => getArgs(pnrModel.pNR))
                .then((arg) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/CompletedPage', (Route<dynamic> route) => false,
                  arguments: arg);
            });
          });


        } else {
          _error = 'Declined';
          _dataLoaded();
          _showDialog();
        }
      });
    } else {
      if (widget.isMmb) {
        msg = '*$rLOC';
        widget.mmbBooking.newFlights.forEach((flt) {
          print(flt);
          msg += '^' + flt;
        });
        msg += '^e*r~x';
      } else {
        if( rLOC.isEmpty) {
          if( widget.pnrModel != null ) {
            rLOC = widget.pnrModel.pNR.rLOC;
            msg = '*$rLOC~x';
          } else {
            msg = '*R~x';
          }
        } else {
          msg = '*$rLOC~x';
        }
      }
      //msg += '~x';
      print(msg);
      response = await http
          .get(Uri.parse(
          "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
          .catchError((resp) {});
      if (response == null) {
        setState(() {
          //_displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
        return null;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          //_displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
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
        showSnackBar(_error);
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
              setState(() {
                //_displayProcessingIndicator = false;
              });
              //showSnackBar(translate('Please, check your internet connection'));
              noInternetSnackBar(context);
              return null;
            }

            //If there was an error return an empty list
            if (response.statusCode < 200 || response.statusCode >= 300) {
              setState(() {
                //_displayProcessingIndicator = false;
              });
              //showSnackBar(translate('Please, check your internet connection'));
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
        setState(() {
          //_displayProcessingIndicator = false;
        });
        showSnackBar(translate('Unable to confirm partner airlines flights.'));
        //Cnx new flights
        msg = '*${widget.mmbBooking.rloc}';
        widget.mmbBooking.newFlights.forEach((flt) {
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
      if (widget.isMmb) {
        //msg += '^';

        for (var i = 0;
        i <
            widget.mmbBooking.journeys
                .journey[widget.mmbBooking.journeyToChange - 1].itin.length;
        i++) {
          Itin f = widget.mmbBooking.journeys
              .journey[widget.mmbBooking.journeyToChange - 1].itin[i];
          String _depDate =
          DateFormat('ddMMM').format(DateTime.parse(f.depDate)).toString();
          msg +=
          'X${f.airID}${f.fltNo}${f.xclass}$_depDate${f.depart}${f.arrive}^';
          if (f.nostop == 'X') {
            nostop += ".${f.line}X^";
          }
        }

        // widget.mmbBooking.journeys
        //     .journey[widget.mmbBooking.journeyToChange - 1].itin.reversed
        //     .forEach((f) {
        //   //msg += 'X${f.line}^';

        //   String _depDate =
        //       DateFormat('ddMMM').format(DateTime.parse(f.depDate)).toString();
        //   msg +=
        //       'X${f.airID}${f.fltNo}${f.cabin}$_depDate${f.depDate}${f.arrive}^';
        //   if (f.nostop == 'X') {
        //     nostop += ".${f.line}X^";
        //   }
        // });

        // widget.mmbBooking.newFlights.forEach((flt) {
        //   print(flt);
        //   msg += flt + '^';
        // });
        msg += addFg(widget.mmbBooking.currency, true);
        msg += addFareStore(true);

        msg += 'e*r^';
        //msg += 'fg^fs1^e*r^';
      }

      //msg = '*$rLOC^';
      msg += getPaymentCmd(true);

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
        setState(() {
          //_displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
        return null;
      }

      //If there was an error return an empty list
      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          //_displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
        return null;
      }

      try {
        String result = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');

        if (result.trim() == 'Payment Complete') {
          gblTimerExpired = true;
          print('Payment success');
          // kill timer
 //         try {
 //         Provider.of<CountDownTimer>(context, listen: false)
   //           .stop();
     //     } catch(e) {
       //     print(e.toString());
         // }

          setState(() {
            //_displayProcessingText = 'Completing your booking...';
            //_displayProcessingIndicator = true;
          });
          if (pnrModel.pNR.tickets != null) {
            await pullTicketControl(pnrModel.pNR.tickets);
          }
          ticketBooking();
        } else if (result.contains('ERROR')) {
          gblTimerExpired = true;
          _error = result;
          _dataLoaded();
          _showDialog();
        } else if (result.contains('Payment not')) {
          gblTimerExpired = true;
          _error = result;
          _dataLoaded();
          _showDialog();
        } else {
          gblTimerExpired = true;
          print(result);
          _error = 'Declined: ' + result;
          _dataLoaded();
          _showDialog();
        }
      } catch (e) {
        gblTimerExpired = true;
        _error = response.body; // 'Please check your details';
        _dataLoaded();
        _showDialog();
      }
    }
  }


  String getPaymentCmd(bool makeHtmlSafe) {
    var buffer = new StringBuffer();
    //if (isLive) {
      //buffer.write('MK($creditCardProviderProduction)');
    double am = 0.0;
    String currency;
    if( gblRedeemingAirmiles) {
      if( gblPassengerDetail != null && gblPassengerDetail.fqtv != null && gblPassengerDetail.fqtv.isNotEmpty) {
        buffer.write('MF-${gblPassengerDetail.fqtv}^');
      } else if (gblFqtvNumber != null && gblFqtvNumber.isNotEmpty) {
        buffer.write('MF-$gblFqtvNumber^');
      }
      am = double.parse(widget.pnrModel.pNR.basket.outstandingairmiles.amount );
      currency = widget.pnrModel.pNR.basket.outstandingairmiles.cur;
    } else {
      //if(widget.pnrModel != null &&  widget.pnrModel.pNR.basket.outstanding.amount == '0')
      if(widget.pnrModel != null && widget.pnrModel.pNR.basket.outstanding.amount != null )
        {
          am = double.parse(widget.pnrModel.pNR.basket.outstanding.amount);
          currency = widget.pnrModel.pNR.basket.outstanding.cur;
          if( am <= 0 ) {
            return '';
          }
        }
      if(pnrModel != null && pnrModel.pNR.basket.outstanding.amount != null) {
        am = double.parse(pnrModel.pNR.basket.outstanding.amount);
        currency = pnrModel.pNR.basket.outstanding.cur;
        if( am <= 0 ) {
          return '';
        }
      }
    }

      buffer.write( addCreditCard( currency, am, gblSettings.creditCardProvider));
    //buffer.write('MK(${gblSettings.creditCardProvider})');

    //creditCardProviderStaging
    //buffer.write('MK(${gbl_settings.creditCardProvider})');
    if( gblRedeemingAirmiles) {
      // sb.AppendFormat("MK({0}){1}{2}", pSession.Payment.PaymentSchemeName, pSession.Payment.CurrentTransaction.PaymentCurrency, CDbl(pSession.Payment.CurrentTransaction.PaymentTotalAmount).ToString("#0.00"))
      // sb.AppendFormat("/{0}", .CardNumber.Trim)
      if( pnrModel != null ) {
        buffer.write('${pnrModel.pNR.basket.outstandingairmiles.cur}');
        buffer.write('${pnrModel.pNR.basket.outstandingairmiles.amount}');
      } else if (widget.pnrModel != null ) {
        buffer.write('${widget.pnrModel.pNR.basket.outstandingairmiles.cur}');
        buffer.write('${widget.pnrModel.pNR.basket.outstandingairmiles.amount}');

      }
    }
    buffer.write('/${this.paymentDetails.cardNumber.trim()}');

    buffer.write(
        '**${this.paymentDetails.expiryDate.substring(0, 2)}${this.paymentDetails.expiryDate.substring(2, 4)}');
    buffer.write(
        ':${this.paymentDetails.cardHolderName.replaceAll(',', ' ').replaceAll('/', ' ').replaceAll('-', ' ').trim()}');
    buffer.write('&${this.paymentDetails.cVV.trim()}');
    buffer.write(
        '/${this.paymentDetails.addressLine1.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.addressLine2.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.town.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.state.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.postCode.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.country.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');

    if (makeHtmlSafe) {
      return buffer
          .toString()
          .replaceAll('=', '%3D')
          .replaceAll(',', '%2C')
          .replaceAll('/', '%2F')
          .replaceAll(':', '%3A')
          .replaceAll('[', '%5B')
          .replaceAll(']', '%5D')
          .replaceAll('&', '%26');
    } else {
      return buffer.toString();
    }
  }

  Future<void> timerExpired() async {
    await new Future.delayed(const Duration(
        seconds:
            2)); // this is required to stop the navigator triggering before the provider has triggered the last notification
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
  }


  String getTicketingCmd() {
    var buffer = new StringBuffer();
    if (widget.isMmb) {
      buffer.write(nostop);
      buffer.write('EZV*[E][ZWEB]^');
    }
    buffer.write('EZT*R^*R~x');
    return buffer.toString();
  }
  Future<void> pullTicketControl(Tickets tickets) async {
    String msg = '';
    for (var i = 0; i < pnrModel.pNR.tickets.tKT.length; i++) {
      if (pnrModel.pNR.tickets.tKT[i].status == 'A') {
        msg = '*${widget.mmbBooking.rloc}^';
        msg += '*t-' +
            pnrModel.pNR.tickets.tKT[i].tktNo.replaceAll(' ', '') +
            '/' +
            pnrModel.pNR.tickets.tKT[i].coupon +
            '=o';
//        http.Response reponse = await http
        await http.get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
            .catchError((resp) {});
      }
    }
  }

  Future ticketBooking() async {
    String msg = '';
    http.Response response;
    msg = '*$rLOC^';
    msg += getTicketingCmd();

    response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
        .catchError((resp) {});

    if (response == null) {
      setState(() {
        //_displayProcessingIndicator = false;
      });
      //showSnackBar(translate('Please, check your internet connection'));
      noInternetSnackBar(context);
      return null;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        //_displayProcessingIndicator = false;
      });
      //showSnackBar(translate('Please, check your internet connection'));
      noInternetSnackBar(context);
      return null;
    }

    try {
      String pnrJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      Map map = json.decode(pnrJson);

      PnrModel pnrModel = new PnrModel.fromJson(map);

      PnrDBCopy pnrDBCopy = new PnrDBCopy(
          rloc: pnrModel.pNR.rLOC, //_rloc,
          data: pnrJson,
          delete: 0,
          nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
      Repository.get().updatePnr(pnrDBCopy);
      Repository.get()
          .fetchApisStatus(this.pnrModel.pNR.rLOC)
          .then((_) => sendEmailConfirmation(pnrModel))
          .then((_) => getArgs(this.pnrModel.pNR))
          .then((args) => Navigator.of(context).pushNamedAndRemoveUntil(
          '/CompletedPage', (Route<dynamic> route) => false,
          arguments: args
        //[pnrModel.pNR.rLOC, result.toString()]
      ));
      //sendEmailConfirmation();

    } catch (e) {
      _error = response.body; // 'Please check your details';
      _dataLoaded();
      _showDialog();
    }
  }

  getArgs(PNR pNR) {
    List<String> args = [];
    // List<String>();
    args.add(pNR.rLOC);
    if (pNR.itinerary.itin
        .where((itin) =>
    itin.classBand.toLowerCase() != 'fly' &&
        itin.openSeating != 'True')
        .length >
        0) {
      args.add('true');
    } else {
      args.add('false');
    }
    return args;
  }


  /*
  sendEmailConfirmation() async {
    try {
      String msg = '*${pnrModel.pNR.rLOC}^EZRE';
      http.Response response = await http
          .get(Uri.parse(
          "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
          .catchError((resp) {});

      if (response == null) {
        //return new ParsedResponse(NO_INTERNET, []);
      }

      //If there was an error return an empty list
      if (response.statusCode < 200 || response.statusCode >= 300) {
        //return new ParsedResponse(response.statusCode, []);
      }
      print(response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));
    } catch (e) {
      print('sendEmailConfirmation: ' + e.toString());
    }
  }
     */

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    // final _snackbar = snackbar(message);
    // _key.currentState.showSnackBar(_snackbar);
  }
}
