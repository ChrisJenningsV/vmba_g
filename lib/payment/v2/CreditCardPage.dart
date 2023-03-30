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
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/controllers/vrsCommands.dart';
import 'package:vmba/components/showDialog.dart';

import '../../Helpers/bookingHelper.dart';
import '../../Helpers/networkHelper.dart';
import 'package:vmba/data/models/vrsRequest.dart';

import '../../Helpers/pageHelper.dart';
import '../../components/bottomNav.dart';
import '../../components/vidButtons.dart';

GlobalKey<CardInputWidgetState> ccInputGlobalKeyOptions = new GlobalKey<CardInputWidgetState>();


class CreditCardPage extends StatefulWidget {
  CreditCardPage({
    Key key,
    this.newBooking,
    this.pnrModel,
    this.stopwatch,
    this.isMmb = false,
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
    gblCurPage = 'CREDITCARDPAGE';
    logit(gblCurPage);
    double am = double.parse(widget.pnrModel.pNR.basket.outstanding.amount);
    gblError = '';
    if (am <= 0) {
      signin().then((_) => completeBooking());
    }
  }
/*
    if( widget.pnrModel.pNR.basket.outstanding.amount == '0') {
      signin().then((_) => completeBooking() );
    }
 */

  @override
  Widget build(BuildContext context) {
    if (gblError != null && gblError.isNotEmpty) {
      return Scaffold(
        key: _key,
        appBar: appBar(
          context,
          'Payment',
          newBooking: widget.newBooking,
          curStep: 5,
          imageName: gblSettings.wantPageImages ? 'paymentPage' : null,
        ),
        endDrawer: DrawerMenu(),

        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText('Payment Error',
                    style: TextStyle(fontSize: 16.0)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText(
                  gblError,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      );

      // showAlertDialog(context, 'Error making payment', gblError);
      // return null;
    }
    Widget popButton;
    void Function() customAction;
    if( gblSettings.creditCardProvider != null && gblSettings.creditCardProvider.toLowerCase() == 'videcard' ) {
      //bool gotVideCard = false;
      customAction =_populateCC;

      popButton= vidDemoButton((context), 'Use Test CC', (p0) {
        _populateCC();

      });
    }
    return WillPopScope(
        onWillPop: _onWillPop,
        child:  Scaffold(
      key: _key,
      appBar: appBar(
        context,
        'Payment',
        newBooking: widget.newBooking,
        curStep: 5,
        imageName: gblSettings.wantPageImages ? 'paymentPage' : null,
      ),
      endDrawer: DrawerMenu(),
      bottomNavigationBar: getBottomNav(context, popButton: popButton, helpText: 'The test CC will popular field with working test card values.', custom: customAction),
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
                                logit('expired 1');
                              })),
                        ],
                      ),
                    ),
                  )),
            )
          ]),
          widget.pnrModel.pNR.basket.outstanding.amount == '0'
              ? TrText('Completing booking...')
              : new CardInputWidget(
                  key: ccInputGlobalKeyOptions,
                  payCallback: () {
                    logit('payCallBack');
                    hasDataConnection().then((result) async {
                      if (result == true) {
                        if( gblSettings.useWebApiforVrs) {
                          logit('CCP MakePaymentVars');
                          makePaymentVars();
                        } else {
                          logit('CCP MakePayment');
                          makePayment();
                        }
                        //  signin().then((_) => makePayment());
                      } else {
                        logit('No Internet');
                        setState(() {
                          // _displayProcessingIndicator = false;
                        });
                        //showSnackBar(translate('Please, check your internet connection'));
                        noInternetSnackBar(context);
                      }
                    }).catchError((e) {
                      logit('pay error ${e.toString()}');
                      return null;
                    });
                  },
                  paymentDetails: paymentDetails,
                ),
        ]),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ));
  }
  void _populateCC(){
    // populate test card
    this.paymentDetails.cardNumber = '4242424242424242';
    this.paymentDetails.expiryDate = '1234';
    this.paymentDetails.cVV = '1234';

    paymentDetails.addressLine1 = 'Windsor Castle' ;
    paymentDetails.addressLine2 = 'Castle Hill' ;
    paymentDetails.town = 'Windsor';
    paymentDetails.state = 'Berkshire';
    paymentDetails.postCode = 'SL4 1PD' ;
    paymentDetails.country  = 'UK' ;


    if(widget.pnrModel != null && widget.pnrModel.pNR != null && widget.pnrModel.pNR.names != null ) {
      this.paymentDetails.cardHolderName =
          widget.pnrModel.pNR.names.pAX[0].firstName + ' ' +
              widget.pnrModel.pNR.names.pAX[0].surname;
    }
    ccInputGlobalKeyOptions.currentState.initPayDetails(paymentDetails);
  }

  Future<bool> _onWillPop() async {
    return onWillPop(context);
  }
  void _dataLoaded() {
    setState(() {
      gblPayBtnDisabled = false;
      //_displayProcessingIndicator = false;
    });
  }

  Future _sendVRSCommand(msg) async {
    logit('_sendVRSCommand $msg');

    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/RunVRSCommand"),
        headers: getApiHeaders(),
        body: msg);

    if (response.statusCode == 200) {
      return response.body.trim();
    }
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
    logit('CCP:CompleteBooking');
    var msg = "*${widget.pnrModel.pNR.rLOC}^EZT*R~x";
    gblCurrentRloc = widget.pnrModel.pNR.rLOC;
    gblTimerExpired = true;
    _sendVRSCommand(json.encode(RunVRSCommand(session, msg).toJson()))
        .then((result) {
      try {
        if (!result.toString().startsWith('{')) {
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
      } catch (e) {
        logit(e);
      }
    });
  }


  Future makePaymentVars() async {
    String msg = '';
    bool oldCancelled = false;
    http.Response response;
    gblCurrentRloc = widget.pnrModel.pNR.rLOC;
    setState(() {
      //_displayProcessingText = 'Processing your payment...';
      //_displayProcessingIndicator = true;
    });
    if (widget.isMmb) {
      if( widget.session != null ) {
        session = widget.session;
      } else {
        logit('set ses to gs');
        session = gblSession;
      }
    }
    logit('bs = ${gblBookingState.toString()}');
    logit('gs = ${gblSession.toString()}');
    if (gblBookingState != BookingState.changeFlt &&
        gblSession != null &&
        (session == null ||
            session.varsSessionId == null ||
            session.varsSessionId.isEmpty)) {
      logit('set session');
      session = gblSession;
    }
    if (rLOC.isEmpty) {
      if (widget.pnrModel != null) {
        rLOC = widget.pnrModel.pNR.rLOC;
      }
    }
    logit('CCP RLOC=$rLOC');
    if (session != null) {
      logit('CCP Sess not null');

      if (gblBookingState != BookingState.changeSeat &&
          gblBookingState != BookingState.bookSeat) {
        msg = '*$rLOC^';
      }
      msg += getPaymentCmd(false);
      logit(msg);
      String result = await sendVarsCommand(msg) ;

    if( result != null){
      logit('MakePaymentVars: ' + result);


        if (result.contains('Payment Complete') ||
            result.contains('Receipt e-mailed to:') ||
            result == 'Payment not accepted, no more to pay for this passenger') {
          gblTimerExpired = true;
          gblUndoCommand = '';
         // need to re - ticket
          // MMGBP25^
          // is it a change flight action ?

          //  EZV*[E][ZWEB]^EZT*R^EMT*R^E*R^EZRE/en^*r~xMMGBP25^EZV*[E][ZWEB]^EZT*R^EMT*R^E*R^EZRE/en^*r~x
          // _sendVRSCommand(json.encode(RunVRSCommand(session, "EMT*R~x")))
          //var cmd = "EMT*R~x";
          var cmd = "EZT*R~x";
          if (widget.mmbAction == 'CHANGEFLT') {
            // get tickets
            cmd = "EZV*[E][ZWEB]^EZT*R^EMT*R^E*R~x"; // server exception
            //cmd = "EZV*[E][ZWEB]^E*R~x"; // good, no tickets
            //cmd = "EZV*[E][ZWEB]^EZT*R~x"; // good
            //cmd = "EZV*[E][ZWEB]^EZT^EMT*R~x"; //
          }
          if (widget.mmbAction == 'SEAT') {
            cmd = "EMT*R^E*R~x";
          } else if (widget.mmbAction == 'PAYOUTSTANDING') {
            if( widget.pnrModel.hasTickets(widget.pnrModel.pNR.tickets) ) {
              cmd = "EMT*R~x";
            } else {
              // issue tickets and MPD's
              cmd = "EZT*R~x";
            }
          }

          String onValue = await sendVarsCommand(cmd) ;
/*
          _sendVRSCommand(json.encode(RunVRSCommand(session, cmd).toJson()))
              .then((onValue) {
*/
          if( onValue != null )
          {

            if (onValue.toString().contains('error')) {
              _error = onValue;
              _dataLoaded();
              //_showDialog();
              showAlertDialog(context, 'Error', _error);
              return;
            }
            if (onValue.toString().contains('Exception:')) {
              _error = onValue.toString().split('Exception:')[1];
              if (_error.contains(' at ')) {
                _error = onValue.toString().split(' at ')[0];
              }
              _dataLoaded();
              //_showDialog();
              showAlertDialog(context, 'Error', _error);
              return;
            }
            // Server Exception ?
            Map map = json.decode(onValue);
            PnrModel pnrModel = new PnrModel.fromJson(map);
            PnrDBCopy pnrDBCopy = new PnrDBCopy(
                rloc: pnrModel.pNR.rLOC, //_rloc,
                data: onValue,
                delete: 0,
                nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
            Repository.get().updatePnr(pnrDBCopy);
            Repository.get()
                .fetchApisStatus(pnrModel.pNR.rLOC)
                .then((_) => sendEmailConfirmation(pnrModel))
                .then((_) => getArgs(pnrModel.pNR))
                .then((args) => Navigator.of(context).pushNamedAndRemoveUntil(
                '/CompletedPage', (Route<dynamic> route) => false,
                arguments: args
              //[pnrModel.pNR.rLOC, result.toString()]
            ));

/*
            Repository.get()
                .updatePnr(pnrDBCopy)
                .then((_) => sendEmailConfirmation(pnrModel))
                .then((n) => getArgs(pnrModel.pNR))
                .then((arg) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/CompletedPage', (Route<dynamic> route) => false,
                  arguments: arg);
            });
*/
          };
        } else {
          _error = result; // translate('Declined');
          _dataLoaded();
          if( result.contains('PaymentDeclined')) {
            _error = 'Declined';
          }
            //_showDialog();
            showAlertDialog(context, 'Error', _error);

        }
      };
    } else {
      logit('CCP Sess null');
      if (widget.isMmb) {
        logit('CCP MMB');
        msg = '*$rLOC';
        bool deleteDone = false;
        widget.mmbBooking.newFlights.reversed.forEach((flt) {
          // remove old flight
          //XLM0032Q15FebABZKOI

          if( deleteDone == false ) {
            if( widget.mmbBooking.journeys.journey[widget.mmbBooking.journeyToChange - 1].itin.length ==1 ){
              msg += '^X${widget.mmbBooking.journeyToChange}';
            } else {
              widget.mmbBooking.journeys
                  .journey[widget.mmbBooking.journeyToChange - 1].itin.forEach((
                  j) {
                DateTime fltDate = DateTime.parse(j.ddaygmt);
                msg +=
                '^X${j.airID}${j.fltNo}${j.xclass}${DateFormat('ddMMM').format(
                    fltDate)}${j.depart}${j.arrive}';
              });
            }
            deleteDone = true;
          }

          oldCancelled = true;

          logit(flt);
          msg += '^' + flt;
        });

        int flightLineNumber=-1;
        if(  gblBookingState == BookingState.changeFlt ) {
          /*int connectedLine = -1;
          if( widget.mmbBooking.newFlights.length > 1) flightLineNumber= 0;*/
          if( widget.mmbBooking.newFlights.length > 1) {
            if (widget.mmbBooking.journeyToChange == 1) {
              // make first line connection
              flightLineNumber =1;
            } else {
              // count lines and add 1
              flightLineNumber = widget.mmbBooking.journeys.journey[0].itin.length +1;
            }
            //flightLineNumber =            GetConnectingFlightLine(widget.mmbBooking.newFlights);
          }

        } else {
          flightLineNumber = getConnectingFlightLineIdentifier(
              widget.mmbBooking.journeys.journey[widget.mmbBooking
                  .journeyToChange - 1]);
        }
        if (flightLineNumber >= 0) {
          logit("Journey has a connecting flight.");
          msg += '^*r^.${flightLineNumber}x';
        }

        msg += '^e*r~x';
      } else {
        logit('CCP not MMB');
        if (rLOC.isEmpty) {
          if (widget.pnrModel != null) {
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
      logit(msg);

      String data = await runVrsCommand(msg);
      bool flightsConfirmed = true;
      String _response = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      logit('CCPR $data');
      if (data.contains('ERROR - ') || !_response.trim().startsWith('{')) {
        _error = _response.replaceAll('ERROR - ', '').trim();
        _dataLoaded();
        logit(_error);
        showAlertDialog(context, 'Error', _error);
        //showSnackBar(_error);
        return null;
      } else {
        Map map = json.decode(_response);
        pnrModel = new PnrModel.fromJson(map);
        logit(pnrModel.pNR.rLOC);
        if (pnrModel.hasNonHostedFlights() &&
            pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          logit('has pending or interline');
          int noFLts = pnrModel
              .flightCount(); //if external flights aren't confirmed they get removed from the PNR
          // which makes it look like the flights are confirmed

          flightsConfirmed = false;
          for (var i = 0; i < 10; i++) {
            msg = '*' + pnrModel.pNR.rLOC + '~x';

            String data = await runVrsCommand(msg);
            if (data.contains('ERROR - ')) {
              _error = response.body
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '')
                  .replaceAll('ERROR - ', '')
                  .trim(); // 'Please check your details';
              _dataLoaded();
              logit(_error);
              return null;
            } else {
              String pnrJson = data
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '');
              Map map = json.decode(pnrJson);

              pnrModel = new PnrModel.fromJson(map);
              logit('ccp got PNR');
            }

            if (!pnrModel.hasPendingCodeShareOrInterlineFlights()) {
              logit('no pending');
              if (noFLts == pnrModel.flightCount()) {
                flightsConfirmed = true;
              } else {
                flightsConfirmed = false;
              }
              _dataLoaded();
              break;
            }
            await new Future.delayed(const Duration(seconds: 2));
          }
        }
      }
      if (!flightsConfirmed) {
        logit('flights not confirmed');
        setState(() {
          //_displayProcessingIndicator = false;
        });
        showSnackBar(translate('Unable to confirm partner airlines flights.'));
        //Cnx new flights
        msg = '*${widget.mmbBooking.rloc}';
        widget.mmbBooking.newFlights.forEach((flt) {
          logit('x' + flt.split('NN1')[0].substring(2));
          msg += '^' + 'x' + flt.split('NN1')[0].substring(2);
        });
        logit(msg);
        await runVrsCommand(msg);
        return null;
      }

      msg = '*$rLOC^';
      //update to use full cancel segment command
      if (widget.isMmb) {
        //msg += '^';
        if (!oldCancelled) {
          for (var i = 0;
          i <
              widget
                  .mmbBooking
                  .journeys
                  .journey[widget.mmbBooking.journeyToChange - 1]
                  .itin
                  .length;
          i++) {
            Itin f = widget.mmbBooking.journeys
                .journey[widget.mmbBooking.journeyToChange - 1].itin[i];
            String _depDate = DateFormat('ddMMM')
                .format(DateTime.parse(f.depDate))
                .toString();
            msg +=
            'X${f.airID}${f.fltNo}${f.xclass}$_depDate${f.depart}${f.arrive}^';
            if (f.nostop == 'X') {
              nostop += ".${f.line}X^";
            }
          }
        }

        msg += addFg(widget.mmbBooking.currency, true);
        msg += addFareStore(true);

        msg += 'e*r^';
        //msg += 'fg^fs1^e*r^';
      }

      //msg = '*$rLOC^';
      logit('send $msg');
      msg += getPaymentCmd(true);

      try {
        logit("Payment sent $msg");
      } catch (e) {
        logit(e);
      }

      if( gblSettings.useSmartPay){

      }
      logit('ccp %msg');
      data = await runVrsCommand(msg);

      String result = '';
      try {
        result = data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');

        if (result.trim() == 'Payment Complete') {
          gblTimerExpired = true;
          logit('Payment success');
          gblUndoCommand = '';
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
        } else if (result.contains('VrsServerResponse')) {
          _error = json.decode(result)['VrsServerResponse']['PaymentResult']
          ['Description'];
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
          logit(result);
          _error = translate('Declined') + ': ' + result;
          _dataLoaded();
          //_showDialog();
          showAlertDialog(context, 'Error', _error);
        }
      } catch (e) {
        gblTimerExpired = true;
        if (result.isNotEmpty) {
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
  }

  Future<String> sendVarsCommand(String msg) async {

      String req = json.encode(
          VrsApiRequest(
              gblSession, Uri.encodeComponent( msg),
              gblSettings.xmlToken.replaceFirst('token=', ''),
              vrsGuid: gblSettings.vrsGuid,
              notifyToken: gblNotifyToken,
              rloc: gblCurrentRloc,
              phoneId: gblDeviceId,
              language: gblLanguage
          )
      );
      String xmsg = "${gblSettings.xmlUrl}VarsSessionID=${gblSession.varsSessionId}&req=$req";
      final response = await http.get(Uri.parse(xmsg),headers: getXmlHeaders());
      if( response == null ) {

      } else {
        Map map = jsonDecode(response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', ''));

        String result = map['data'];
        return result;
      }
  }





  Future makePayment() async {
    String msg = '';
    bool oldCancelled = false;
    http.Response response;
    gblCurrentRloc = widget.pnrModel.pNR.rLOC;
    setState(() {
      //_displayProcessingText = 'Processing your payment...';
      //_displayProcessingIndicator = true;
    });
    if (widget.isMmb) {
      session = widget.session;
    }
    if (gblBookingState != BookingState.changeFlt &&
        gblSession != null &&
        (session == null ||
            session.varsSessionId == null ||
            session.varsSessionId.isEmpty)) {
      session = gblSession;
    }
    if (rLOC.isEmpty) {
      if (widget.pnrModel != null) {
        rLOC = widget.pnrModel.pNR.rLOC;
      }
    }
    if (session != null) {
      if (gblBookingState != BookingState.changeSeat &&
          gblBookingState != BookingState.bookSeat) {
        msg = '*$rLOC^';
      }
      msg += getPaymentCmd(false);
      logit(msg);

      _sendVRSCommand(json.encode(RunVRSCommand(session, msg).toJson()))
          .then((result) {
      {
        logit(result);


        if (result == 'Payment Complete' ||
            result.contains('Receipt e-mailed to:') ||
            result == 'Payment not accepted, no more to pay for this passenger') {
          gblTimerExpired = true;
/*          if (pnrModel.pNR.tickets != null) {
            await pullTicketControl(pnrModel.pNR.tickets);
          }
         ticketBooking ();

 */ // need to re - ticket
          // MMGBP25^
          // is it a change flight action ?

          //  EZV*[E][ZWEB]^EZT*R^EMT*R^E*R^EZRE/en^*r~xMMGBP25^EZV*[E][ZWEB]^EZT*R^EMT*R^E*R^EZRE/en^*r~x
          // _sendVRSCommand(json.encode(RunVRSCommand(session, "EMT*R~x")))
          //var cmd = "EMT*R~x";
          gblUndoCommand = '';
          var cmd = "EZT*R~x";
          if (widget.mmbAction == 'CHANGEFLT') {
            // get tickets
            cmd = "EZV*[E][ZWEB]^EZT*R^EMT*R^E*R~x"; // server exception
            //cmd = "EZV*[E][ZWEB]^E*R~x"; // good, no tickets
            //cmd = "EZV*[E][ZWEB]^EZT*R~x"; // good
            //cmd = "EZV*[E][ZWEB]^EZT^EMT*R~x"; //
          }
          if (widget.mmbAction == 'SEAT') {
            cmd = "EMT*R^E*R~x";
          } else if (widget.mmbAction == 'PAYOUTSTANDING') {
            cmd = "EMT*R~x";
          }
          _sendVRSCommand(json.encode(RunVRSCommand(session, cmd).toJson()))
              .then((onValue) {
            if (onValue.toString().contains('error')) {
              _error = onValue;
              _dataLoaded();
              //_showDialog();
              showAlertDialog(context, 'Error', _error);
              return;
            }
            if (onValue.toString().contains('Exception:')) {
              _error = onValue.toString().split('Exception:')[1];
              if (_error.contains(' at ')) {
                _error = onValue.toString().split(' at ')[0];
              }
              _dataLoaded();
              //_showDialog();
              showAlertDialog(context, 'Error', _error);
              return;
            }
            // Server Exception ?
            Map map = json.decode(onValue);
            PnrModel pnrModel = new PnrModel.fromJson(map);
            PnrDBCopy pnrDBCopy = new PnrDBCopy(
                rloc: pnrModel.pNR.rLOC, //_rloc,
                data: onValue,
                delete: 0,
                nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
            Repository.get().updatePnr(pnrDBCopy);
            Repository.get()
                .fetchApisStatus(pnrModel.pNR.rLOC)
                .then((_) => sendEmailConfirmation(pnrModel))
                .then((_) => getArgs(pnrModel.pNR))
                .then((args) => Navigator.of(context).pushNamedAndRemoveUntil(
                '/CompletedPage', (Route<dynamic> route) => false,
                arguments: args
              //[pnrModel.pNR.rLOC, result.toString()]
            ));

/*
            Repository.get()
                .updatePnr(pnrDBCopy)
                .then((_) => sendEmailConfirmation(pnrModel))
                .then((n) => getArgs(pnrModel.pNR))
                .then((arg) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/CompletedPage', (Route<dynamic> route) => false,
                  arguments: arg);
            });
*/
          });
        } else {
          _error = result; // translate('Declined');
          _dataLoaded();
          //_showDialog();
          showAlertDialog(context, 'Error', _error);
        }
      }});
    } else {
      if (widget.isMmb) {
        msg = '*$rLOC';
        bool deleteDone = false;
//        int i = widget.mmbBooking.newFlights.length - 1;
        widget.mmbBooking.newFlights.reversed.forEach((flt) {
          // remove old flight
          //XLM0032Q15FebABZKOI

          if( deleteDone == false ) {
            widget.mmbBooking.journeys
                .journey[widget.mmbBooking.journeyToChange - 1].itin.forEach((
                j) {
              DateTime fltDate = DateTime.parse(j.ddaygmt);
              msg +=
              '^X${j.airID}${j.fltNo}${j.xclass}${DateFormat('ddMMM').format(
                  fltDate)}${j.depart}${j.arrive}';
            });
            deleteDone = true;
          }
/*
          Itin j = widget.mmbBooking.journeys
              .journey[widget.mmbBooking.journeyToChange - 1].itin[i];
          i--;
          DateTime fltDate = DateTime.parse(j.ddaygmt);
          msg +=
              '^X${j.airID}${j.fltNo}${j.xclass}${DateFormat('ddMMM').format(fltDate)}${j.depart}${j.arrive}';
*/



          oldCancelled = true;
          //String org = flt.substring(15, 18);
          //String dest = flt.substring(19, 22);

         /* widget.mmbBooking.journeys.journey.forEach((j) {
            if (j.itin[0].depart == org) {
              //      msg += '^X${j.itin[0].line}';
            }
          });*/
          logit(flt);
          msg += '^' + flt;
        });

        int flightLineNumber=-1;
        if(  gblBookingState == BookingState.changeFlt ) {
          /*int connectedLine = -1;
          if( widget.mmbBooking.newFlights.length > 1) flightLineNumber= 0;*/
          if( widget.mmbBooking.newFlights.length > 1) {
            if (widget.mmbBooking.journeyToChange == 1) {
              // make first line connection
              flightLineNumber =1;
            } else {
              // count lines and add 1
              flightLineNumber = widget.mmbBooking.journeys.journey[0].itin.length +1;
            }
            //flightLineNumber =            GetConnectingFlightLine(widget.mmbBooking.newFlights);
          }

        } else {
            flightLineNumber = getConnectingFlightLineIdentifier(
              widget.mmbBooking.journeys.journey[widget.mmbBooking
                  .journeyToChange - 1]);
        }
        if (flightLineNumber >= 0) {
          logit("Journey has a connecting flight.");
          msg += '^*r^.${flightLineNumber}x';
        }

        msg += '^e*r~x';
      } else {
        if (rLOC.isEmpty) {
          if (widget.pnrModel != null) {
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
      logit(msg);

      String data = await runVrsCommand(msg);

      bool flightsConfirmed = true;
      String _response = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      if (data.contains('ERROR - ') || !_response.trim().startsWith('{')) {
        _error = _response.replaceAll('ERROR - ', '').trim();
        _dataLoaded();
        showAlertDialog(context, 'Error', _error);
        //showSnackBar(_error);
        return null;
      } else {
        Map map = json.decode(_response);
        pnrModel = new PnrModel.fromJson(map);
        logit(pnrModel.pNR.rLOC);
        if (pnrModel.hasNonHostedFlights() &&
            pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          int noFLts = pnrModel
              .flightCount(); //if external flights aren't confirmed they get removed from the PNR
          // which makes it look like the flights are confirmed

          flightsConfirmed = false;
          for (var i = 0; i < 10; i++) {
            msg = '*' + pnrModel.pNR.rLOC + '~x';

            String data = await runVrsCommand(msg);
            if (data.contains('ERROR - ')) {
              _error = response.body
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '')
                  .replaceAll('ERROR - ', '')
                  .trim(); // 'Please check your details';
              _dataLoaded();
              return null;
            } else {
              String pnrJson = data
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
          logit('x' + flt.split('NN1')[0].substring(2));
          msg += '^' + 'x' + flt.split('NN1')[0].substring(2);
        });
        /*response = await http
            .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
            .catchError((resp) {});*/
        await runVrsCommand(msg);
        return null;
      }

      msg = '*$rLOC^';
      //update to use full cancel segment command
      if (widget.isMmb) {
        //msg += '^';
        if (!oldCancelled) {
          for (var i = 0;
              i <
                  widget
                      .mmbBooking
                      .journeys
                      .journey[widget.mmbBooking.journeyToChange - 1]
                      .itin
                      .length;
              i++) {
            Itin f = widget.mmbBooking.journeys
                .journey[widget.mmbBooking.journeyToChange - 1].itin[i];
            String _depDate = DateFormat('ddMMM')
                .format(DateTime.parse(f.depDate))
                .toString();
            msg +=
                'X${f.airID}${f.fltNo}${f.xclass}$_depDate${f.depart}${f.arrive}^';
            if (f.nostop == 'X') {
              nostop += ".${f.line}X^";
            }
          }
        }

        msg += addFg(widget.mmbBooking.currency, true);
        msg += addFareStore(true);

        msg += 'e*r^';
        //msg += 'fg^fs1^e*r^';
      }

      //msg = '*$rLOC^';
      msg += getPaymentCmd(true);

      try {
        logit("Payment sent $msg");
      } catch (e) {
        logit(e);
      }

      if( gblSettings.useSmartPay){

      }
      data = await runVrsCommand(msg);

      String result = '';
      try {
        result = data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');

        if (result.trim() == 'Payment Complete') {
          gblTimerExpired = true;
          logit('Payment success');
          gblUndoCommand = '';
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
        } else if (result.contains('VrsServerResponse')) {
          _error = json.decode(result)['VrsServerResponse']['PaymentResult']
              ['Description'];
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
          logit(result);
          _error = translate('Declined') + ': ' + result;
          _dataLoaded();
          //_showDialog();
          showAlertDialog(context, 'Error', _error);
        }
      } catch (e) {
        gblTimerExpired = true;
        if (result.isNotEmpty) {
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
  }

  int getConnectingFlightLineIdentifier(Journey journey) {
    int connectedLine = -1;
    journey.itin.forEach((itn) {
      if (itn.nostop == "X") {
        connectedLine = int.parse(itn.line);
      }
    });
    return connectedLine;
  }

  String getPaymentCmd(bool makeHtmlSafe) {
    var buffer = new StringBuffer();
    //if (isLive) {
    //buffer.write('MK($creditCardProviderProduction)');
    double am = 0.0;
    String currency;
    if (gblRedeemingAirmiles) {
      if (gblPassengerDetail != null &&
          gblPassengerDetail.fqtv != null &&
          gblPassengerDetail.fqtv.isNotEmpty) {
        buffer.write('MF-${gblPassengerDetail.fqtv}^');
      } else if (gblFqtvNumber != null && gblFqtvNumber.isNotEmpty) {
        buffer.write('MF-$gblFqtvNumber^');
      }
      am = double.parse(widget.pnrModel.pNR.basket.outstandingairmiles.amount);
      currency = widget.pnrModel.pNR.basket.outstandingairmiles.cur;
    } else {
      //if(widget.pnrModel != null &&  widget.pnrModel.pNR.basket.outstanding.amount == '0')
      if (widget.pnrModel != null &&
          widget.pnrModel.pNR.basket.outstanding.amount != null) {
        am = double.parse(widget.pnrModel.pNR.basket.outstanding.amount);
        currency = widget.pnrModel.pNR.basket.outstanding.cur;
        if (am <= 0) {
          return '';
        }
      } else if (pnrModel != null &&
          pnrModel.pNR.basket.outstanding.amount != null) {
        am = double.parse(pnrModel.pNR.basket.outstanding.amount);
        currency = pnrModel.pNR.basket.outstanding.cur;
        if (am <= 0) {
          return '';
        }
      }
    }

    buffer.write(addCreditCard(currency, am, gblSettings.creditCardProvider));
    //buffer.write('MK(${gblSettings.creditCardProvider})');

    //creditCardProviderStaging
    //buffer.write('MK(${gbl_settings.creditCardProvider})');
    if (gblRedeemingAirmiles) {
      // sb.AppendFormat("MK({0}){1}{2}", pSession.Payment.PaymentSchemeName, pSession.Payment.CurrentTransaction.PaymentCurrency, CDbl(pSession.Payment.CurrentTransaction.PaymentTotalAmount).ToString("#0.00"))
      // sb.AppendFormat("/{0}", .CardNumber.Trim)
      if (pnrModel != null) {
        buffer.write('${pnrModel.pNR.basket.outstandingairmiles.cur}');
        buffer.write('${pnrModel.pNR.basket.outstandingairmiles.amount}');
      } else if (widget.pnrModel != null) {
        buffer.write('${widget.pnrModel.pNR.basket.outstandingairmiles.cur}');
        buffer
            .write('${widget.pnrModel.pNR.basket.outstandingairmiles.amount}');
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
/*
        await http.get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
            .catchError((resp) {});*/
      }

      await runVrsCommand(msg);
    }
  }

  Future ticketBooking() async {
    logit('CCP:ticketBooking');
    String msg = '';
    http.Response response;
    msg = '*$rLOC^';
    msg += getTicketingCmd();

    logit('ticketBooking: $msg');

    String data = await runVrsCommand(msg);
    String pnrJson = '';
    try {
      pnrJson = data
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
      if (pnrJson.isNotEmpty) {
        _error = pnrJson;
      } else {
        _error = response.body; // 'Please check your details';
      }
      logit(_error);
      _dataLoaded();
      //_showDialog();
      showAlertDialog(context, 'Error', _error);
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
