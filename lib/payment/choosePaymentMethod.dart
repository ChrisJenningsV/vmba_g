import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/payment/paymentCmds.dart';
import 'package:vmba/payment/v2/CreditCardPage.dart';
import 'package:vmba/payment/webPaymentPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/buttons.dart';
import 'package:vmba/utilities/widgets/dataLoader.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/controllers/vrsCommands.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';

import '../Helpers/bookingHelper.dart';
import '../Helpers/stringHelpers.dart';
import '../components/bottomNav.dart';
import '../data/models/providers.dart';
import '../data/models/vrsRequest.dart';
import '../data/smartApi.dart';
import '../mmb/viewBookingPage.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import 'ProviderFieldsPage.dart';
import 'giftVoucher.dart';

bool _cancelTimer = false;

//ignore: must_be_immutable
class ChoosePaymenMethodWidget extends StatefulWidget {
  ChoosePaymenMethodWidget(
      {Key key= const Key("choosepaym_key"),
      this.newBooking,
      required this.pnrModel,
      this.isMmb =false,
      this.mmbCmd ='',
      this.mmbBooking,
      this.mmbAction ='',
      this.session})
      : super(key: key);
   NewBooking? newBooking;
  PnrModel pnrModel;
  final bool isMmb ;
  final String mmbCmd;
  final String mmbAction;
  MmbBooking? mmbBooking;
  final Session? session;

  _ChoosePaymenMethodWidgetState createState() =>
      _ChoosePaymenMethodWidgetState();
}

class _ChoosePaymenMethodWidgetState extends State<ChoosePaymenMethodWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();
  String currencyCode = '';
  bool _displayProcessingIndicator = false;
  bool tandCchecked = false;
  String _displayProcessingText = '';
 // PnrModel pnrModel;
  Stopwatch stopwatch = new Stopwatch();
  int timeout = 15;
  String _error = '';
  Passengers _passengers = new Passengers(1, 0, 0, 0,0, 0, 0);
  String nostop = '';
  bool isMmb = false;

  Session? session ;

  @override
  initState() {
    super.initState();
    if( gblLogPayment ) { logit('CPM initState');}
    if( widget.newBooking == null ) widget.newBooking = NewBooking();
    commonPageInit('CHOOSEPAY');

    gblPnrModel = widget.pnrModel;
    logit(gblCurPage);
    //widget.newBooking.paymentDetails = new PaymentDetails();
    session=widget.session;

    //gblPaymentMsg = '';
    gblStack = null;

    _displayProcessingText = 'Making your Booking...';
    _displayProcessingIndicator = false;
    //gblPaymentMsg = null;
    gblPayBtnDisabled = false;
    gblPaySuccess = false;
    gblPaymentState = PaymentState.start;
    if (widget.isMmb != null) {
      isMmb = widget.isMmb;
    }
    if( gblSettings.wantTandCCheckBox) {
      tandCchecked = false;
    }

    if( widget.pnrModel != null ) {
      _passengers = widget.pnrModel.pNR.names.getPassengerTypeCounts();
    }

    //pnrModel = widget.pnrModel;
    setCurrencyCode();
    if( widget.isMmb ) {
      if (session == null || session!.varsSessionId == "") {
      //  signin().then((_) => makeMmbBooking());
      } else {
        //     makeMmbBooking();
      }
    }
    if( gblProviders != null &&  gblSelectedCurrency == gblLastProviderCurrecy ) {
      startTimer();
    }
    stopwatch.start();
  }

  @override
  void dispose() {
    stopwatch.stop();
    super.dispose();
  }

  Future<void> signin() async {
    await login().then((result) {
      if( result == null)
        {
          _error = 'login failed';
          _dataLoaded();
          _showDialog();
        } else {
        session = Session(
          result.sessionId,
          result.varsSessionId,
          result.vrsServerNo,
        );
      }
    });
  }


  Future setCurrencyCode() async {
    try {
      currencyCode = widget
          .pnrModel
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
    //return currencyCode;
  }

  void _dataLoaded() {
    setState(() {
      endProgressMessage();
      _displayProcessingIndicator = false;
    });
  }

  Row amountOutstanding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
            formatPrice(widget.pnrModel.pNR.basket.outstanding.cur, double.parse(widget.pnrModel.pNR.basket.outstanding.amount)),
/*
                NumberFormat.simpleCurrency(
                    locale: gblSettings.locale,
                    name: this.pnrModel.pNR.basket.outstanding.cur)
                .format((double.parse(
                        this.pnrModel.pNR.basket.outstanding.amount) ??
                    0.0)),

 */
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)
            // Text(
            //  '£${(double.parse(this.pnrModel.pNR.basket.outstanding.amount) ?? 0.0).toStringAsFixed(2)}',
            // style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
      ],
    );
  }


  Widget taxTotal() {
    double tax = 0.0;
    double sepTax1 = 0.0;
    String desc1 = '';


    List <Row> rows = [];

    if (widget.pnrModel.pNR.fareQuote.fareTax != null) {
      widget.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        if(  paxTax.separate == 'true'){
          if( desc1 == '' || desc1 == paxTax.desc) {
            desc1 = paxTax.desc;
            sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
          }
          /*
          rows.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(paxTax.desc),
              Text(NumberFormat.simpleCurrency(
                  locale: gblSettings.locale,
                  name: currencyCode)
                  .format(double.tryParse(paxTax.amnt))),
            ],
          ));

           */

        } else {
          tax += (double.tryParse(paxTax.amnt) ?? 0.0);
        }
      });
    }
     rows.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TrText('Total Tax: '),
       Text(formatPrice(currencyCode, tax) ),
/*
        Text(NumberFormat.simpleCurrency(
            locale: gblSettings.locale,
            name: currencyCode)
            .format(tax)),

 */
      ],
    ));

    if( sepTax1 > 0) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TrText('Additional Item(s) '),
        ],
      ));

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(desc1),
          Text(formatPrice(currencyCode, sepTax1) ),

          /*
          Text(NumberFormat.simpleCurrency(
              locale: gblSettings.locale,
              name: currencyCode)
              .format(sepTax1)),

           */
        ],
      ));
    }


    return Column(
      children: rows,
    );
  }


  Row netFareTotal() {
    double total = 0.0;
    total = (double.tryParse(widget
            .pnrModel
            .pNR
            .fareQuote
            .fareStore
            .where((fareStore) => fareStore.fSID == 'Total')
            .first
            .total) ??
        0.0);
    double tax = 0.0;

    if (widget.pnrModel.pNR.fareQuote.fareTax != null) {
      widget.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        tax += (double.tryParse(paxTax.amnt) ?? 0.0);
      });
    }
    double netFareTotal = total - tax;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TrText('Net Fare:'),
        Text(formatPrice(currencyCode, netFareTotal) ),

      ],
    );
  }

  Row grandTotal() {
    double total = 0.0;

    widget.pnrModel.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          if( d.fare != '') total += double.tryParse(d.fare )!;
          if( d.tax1 != '') total += double.tryParse(d.tax1 )!;
          if( d.tax2 != '') total += double.tryParse(d.tax2 )!;
          if( d.tax3 != '') total += double.tryParse(d.tax3 )!;
          if( d.disc != null && d.disc != '') {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc)!);
            //total += double.tryParse(d.disc ?? 0.0);
          }
        });
      }
    });

    // FareStore fareStore = this
    //     .pnrModel
    //     .pNR
    //     .fareQuote
    //     .fareStore
    //     .where((fareStore) => fareStore.fSID == 'Total')
    //     .first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TrText('Flights Total: '),
        Text(formatPrice(currencyCode, total) ),
/*
        Text(NumberFormat.simpleCurrency(
                locale: gblSettings.locale,
                name: currencyCode)
            .format(total))

 */
        // (double.tryParse(fareStore.total) ?? 0.0))),
      ],
    );
  }

  Row discountTotal() {
    double total = 0.0;

    widget.pnrModel.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          if( d.disc != null && d.disc != '') {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc)!);
            //total += double.tryParse(d.disc ?? 0.0);
          }
        });
      }
    });

    if (total == 0.0) {
      return Row(
        children: <Widget>[],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TrText('Discount: '),
          Text(formatPrice(currencyCode, total) ),
/*
          Text(NumberFormat.simpleCurrency(
                  locale: gblSettings.locale,
                  name: currencyCode)
              .format(total)),

 */
        ],
      );
    }
  }

  Widget nonSegProductSummary() {
    List<Widget> widgets = [];

    if( gblSettings.wantProducts ) {
      if( widget.pnrModel.pNR.mPS != null && widget.pnrModel.pNR.mPS.mP != null ){
        widget.pnrModel.pNR.mPS.mP.forEach((element) {
          // this seg ?
          if( element.seg == null || element.seg == ''){
            if( element.mPSAmt != null && element.mPSAmt != '') {
              widgets.add(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TrText(element.text),
                      Text(formatPrice(
                          element.mPSCur, double.parse(element.mPSAmt)))
                    ],
                  ));
            }
          }
        });
      }
    }
    if( widgets.length > 0 ) {
      widgets.add(Divider());
    }


    return Column(
      children: widgets,
    );

  }


  Widget flightSegementSummary() {
    List<Widget> widgets = [];
    // new List<Widget>();
    for (var i = 0; i <= widget.pnrModel.pNR.itinerary.itin.length - 1; i++) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(cityCodetoAirport(widget.pnrModel.pNR.itinerary.itin[i].depart),
                style:  TextStyle(fontWeight: FontWeight.w700)),

            /*FutureBuilder(
              future: cityCodeToName(
                widget.pnrModel.pNR.itinerary.itin[i].depart,
              ),
              initialData: widget.pnrModel.pNR.itinerary.itin[i].depart.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return new Text(text.data!,
                    style: TextStyle(fontWeight: FontWeight.w700));
              },
            ),*/
            TrText(
              ' to ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
  /*          FutureBuilder(
              future: cityCodeToName(
                widget.pnrModel.pNR.itinerary.itin[i].arrive,
              ),
              initialData: widget.pnrModel.pNR.itinerary.itin[i].arrive.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return new Text(
                  text.data!,
                  style: TextStyle(fontWeight: FontWeight.w700),
                );
              },
            ),*/
            Text(cityCodetoAirport(widget.pnrModel.pNR.itinerary.itin[i].arrive),
                style:  TextStyle(fontWeight: FontWeight.w700)),

          ],
        ),
      );
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TrText('Flight No:'),
            Text(
                '${widget.pnrModel.pNR.itinerary.itin[i].airID}${widget.pnrModel.pNR.itinerary.itin[i].fltNo}')
          ],
        ),
      );
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TrText('Departure Time:'),
            Text(_getDateFormatted(i))
          ],
        ),
      );
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TrText('Fare Type:'),
            Text(widget.pnrModel.pNR.itinerary.itin[i].classBandDisplayName ==
                    'Fly Flex Plus'
                ? 'Fly Flex +'
                : widget.pnrModel.pNR.itinerary.itin[i].classBandDisplayName)
          ],
        ),
      );
      double taxTotal = 0.0;

      if (widget.pnrModel.pNR.fareQuote.fareTax != null) {
        widget.pnrModel
            .pNR
            .fareQuote
            .fareTax[0]
            .paxTax
            .where((paxTax) => paxTax.seg == (i + 1).toString())
            .forEach((paxTax) {
          if( paxTax.separate == 'false' ) {
            taxTotal += (double.tryParse(paxTax.amnt) ?? 0.0);
          }

        });
      }
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TrText('Tax:'),
            Text(formatPrice(currencyCode, taxTotal) ),
/*
            Text(NumberFormat.simpleCurrency(
                    locale: gblSettings.locale,
                    name: currencyCode)
                .format(taxTotal))

 */
          ],
        ),
      );
      double sepTax1 = 0.0;
      String desc1 = '';

      if (widget.pnrModel.pNR.fareQuote.fareTax != null) {
        widget.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
          if(  paxTax.separate == 'true' && paxTax.seg == (i + 1).toString()){ //
            if( desc1 == '' || desc1 == paxTax.desc) {
              desc1 = paxTax.desc;
              sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
            }
          }
        });
      }
      if (sepTax1 != 0.0) {
        widgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(desc1),
              Text(formatPrice(currencyCode, sepTax1) ),
/*
              Text(NumberFormat.simpleCurrency(
                  locale: gblSettings.locale,
                  name: currencyCode)
                  .format(sepTax1)),

 */
            ],
          ),
        );
      }




      String cityPair =
          '${widget.pnrModel.pNR.itinerary.itin[i].depart}${widget.pnrModel.pNR.itinerary.itin[i].arrive}';
      if (widget.pnrModel.pNR.aPFAX != null &&
          widget.pnrModel.pNR.aPFAX.aFX
                  .where((aFX) =>
                      aFX.aFXID == "SEAT" &&
                      aFX.text.split(' ')[1] ==
                          widget.pnrModel.pNR.itinerary.itin[i].cityPair.toString())
                  .length >
              0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TrText('Allocated Seats',
                    style: TextStyle(fontWeight: FontWeight.w700))
              ],
            ),
          ),
        );

        widget.pnrModel.pNR.aPFAX.aFX
            .where((aFX) =>
                aFX.aFXID == "SEAT" && aFX.text.split(' ')[1] == cityPair)
            .forEach((seat) {
          widgets.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TrText('Passenger ${seat.pax} - ${seat.seat}  ${seat.name}'),
                Text(formatPrice(seat.cur != '' ? seat.cur : currencyCode, double.parse(seat.amt)) ),
              ],
            ),
          );
        });
      }

      if( gblSettings.wantProducts ) {
        if( widget.pnrModel.pNR.mPS != null && widget.pnrModel.pNR.mPS.mP != null ){
          widget.pnrModel.pNR.mPS.mP.forEach((element) {
            // this seg ?
            if( element.seg != null && element.seg.isNotEmpty &&  int.parse(element.seg) == (i+1)){
              widgets.add(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TrText(element.text),
                      Text(formatPrice(element.mPSCur,double.parse(element.mPSAmt)))
                    ],
                  ));
            }
          });
        }
      }


      widgets.add(Divider());
    }
    return Column(
      children: widgets,
    );
  }

  String _getDateFormatted(int i) {

    if( widget.pnrModel.pNR.itinerary.itin[i].depDate == '' || widget.pnrModel.pNR.itinerary.itin[i].depTime == ''){
      return '';
    }

    return DateFormat('dd MMM kk:mm').format(DateTime.parse(
        widget.pnrModel.pNR.itinerary.itin[i].depDate +
            ' ' +
            widget.pnrModel.pNR.itinerary.itin[i].depTime));
  }

  bool validate() {
    final form = formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //final _snackbar = snackbar(message);
    //_key.currentState.showSnackBar(_snackbar);
  }
/*

  Future<String> buildCmd() async {
    //Cancel journey
    //String nostop = '';
    String cmd = '';
    cmd = '*${widget.mmbBooking.rloc}^';
    widget.mmbBooking.journeys.journey[widget.mmbBooking.journeyToChange - 1]
        .itin.reversed
        .forEach((f) {
      cmd += 'X${f.line}^';
      if (f.nostop == 'X') {
        nostop += ".${f.line}X^";
      }
    });

    widget.mmbBooking.newFlights.forEach((flt) {
      print(flt);
      cmd += flt + '^';
    });
    // cmd += nostop;
    cmd += addFg(widget.newBooking.currency, true);
    cmd += addFareStore(true);

    cmd += 'e';
    //cmd += 'fg^fs1^e';
    return cmd;
  }
*/
  Future completeBookingNothingtoPayVRS() async {
    String msg = '';

    if( gblPayAction != 'CHANGEFLT') {
      if (isMmb) {
        msg = '*${widget.mmbBooking!.rloc}';
      }
      widget.mmbBooking!.journeys.journey[widget.mmbBooking!.journeyToChange -
          1]
          .itin.reversed
          .forEach((f) {
        msg += '^X${f.line}';
      });

      widget.mmbBooking!.newFlights.forEach((flt) {
        print(flt);
        msg += '^' + flt;
      });
      int flightLineNumber = -1;
      if (gblBookingState == BookingState.changeFlt) {
        if (widget.mmbBooking!.newFlights.length > 1) {
          if (widget.mmbBooking!.journeyToChange == 1) {
            // make first line connection
            flightLineNumber = 1;
          } else {
            // count lines and add 1
            flightLineNumber =
                widget.mmbBooking!.journeys.journey[0].itin.length + 1;
          }
        }
      } else {
        flightLineNumber = getConnectingFlightLineIdentifier(
            widget.mmbBooking!.journeys.journey[widget.mmbBooking!
                .journeyToChange - 1]);
      }
      if (flightLineNumber >= 0) {
        logit("Journey has a connecting flight on itin($flightLineNumber)");
        msg += '^*r^.${flightLineNumber}x';
      }
      msg += '^';
      msg += addFg(widget.mmbBooking!.currency, true);
      msg += addFareStore(true);
    }
    msg += 'e*r~x';
    logit('CMP msg:$msg');
    try {
      await runVrsCommand(msg);
    } catch(e,stack) {
      _error = e.toString();
      gblStack = stack ;

      _dataLoaded();
      _showDialog();
      return null;
    }

    try {
      if (widget.pnrModel.pNR.tickets != null) {
        await pullTicketControl(widget.pnrModel.pNR.tickets);
      }
      logit('ticket booking 1');
      ticketBooking();

    } catch(e ) {

    }
   // _dataLoaded();
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
  Future completeBookingNothingtoPay() async {
    setState(() {
      _displayProcessingText = 'Processing your changes...';
      _displayProcessingIndicator = true;
    });

    if( gblSettings.useWebApiforVrs && isMmb) {
      return completeBookingNothingtoPayVRS();
    } else {
      //New code
      String msg = '';
      String data;
      if (this.isMmb) {
        msg = '*${widget.mmbBooking!.rloc}';

        widget.mmbBooking!.newFlights.forEach((flt) {
          print(flt);
          msg += '^' + flt;
        });
        msg += '^';
      }

      msg += 'e*r~x';

      logit('CMP msg:$msg');
      try {
        data = await runVrsCommand(msg);

        bool flightsConfirmed = true;
        if (data.contains('ERROR - ')) {
          _error = data
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '')
              .replaceAll('ERROR - ', '')
              .trim();

          print('completeBookingNothingtoPay: ' + _error);

          _error =
          'Unnable to change booking'; //response.body; // 'Please check your details';
          _dataLoaded();
          _showDialog();
          return null;
        } else if (data.contains('ERROR:')) {
          _error = data
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '')
              .replaceAll('ERROR: ', '')
              .trim();

          print('completeBookingNothingtoPay: ' + _error);

          _dataLoaded();
          _showDialog();
          return null;
        } else {
          logit('save OK step 1');
          String pnrJson = data
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '');
          Map<String, dynamic> map = json.decode(pnrJson);

          widget.pnrModel = new PnrModel.fromJson(map);
          print(widget.pnrModel.pNR.rLOC);
          if (widget.pnrModel.hasNonHostedFlights() &&
              widget.pnrModel.hasPendingCodeShareOrInterlineFlights()) {
            int noFLts = widget.pnrModel
                .flightCount(); //if external flights aren't confirmed they get removed from the PNR
            // which makes it look like the flights are confirmed

            flightsConfirmed = false;
            for (var i = 0; i < 4; i++) {
              msg = '*' + widget.pnrModel.pNR.rLOC + '~x';
              logit('save cmd $msg');
              String data = await runVrsCommand(msg);
              if (data.contains('ERROR - ')) {
                _error = data
                    .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                    .replaceAll('<string xmlns="http://videcom.com/">', '')
                    .replaceAll('</string>', '')
                    .replaceAll('ERROR - ', '')
                    .trim(); // 'Please check your details';
                logit(_error);
                _dataLoaded();
                return null;
              } else {
                String pnrJson = data
                    .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                    .replaceAll('<string xmlns="http://videcom.com/">', '')
                    .replaceAll('</string>', '');
                Map<String, dynamic> map = json.decode(pnrJson);
                logit('OK step 2');
                widget.pnrModel = new PnrModel.fromJson(map);
              }

              if (!widget.pnrModel.hasPendingCodeShareOrInterlineFlights()) {
                if (noFLts == widget.pnrModel.flightCount()) {
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
          showSnackBar(
              translate('Unable to confirm partner airlines flights.'));

          //Cnx new flights
          msg = '*${widget.mmbBooking!.rloc}';
          widget.mmbBooking!.newFlights.forEach((flt) {
            print('x' + flt.split('NN1')[0].substring(2));
            msg += '^' + 'x' + flt.split('NN1')[0].substring(2);
          });
          logit('Send msg $msg');
          await runVrsCommand(msg);
          return null;
        } else if(isMmb) {
          msg = '*${widget.mmbBooking!.rloc}^';
          //update to use full cancel segment command
          for (var i = 0;
          i <
              widget.mmbBooking!.journeys
                  .journey[widget.mmbBooking!.journeyToChange - 1].itin.length;
          i++) {
            Itin f = widget.mmbBooking!.journeys
                .journey[widget.mmbBooking!.journeyToChange - 1].itin[i];
            String _depDate =
            DateFormat('ddMMM').format(DateTime.parse(f.depDate)).toString();
            msg +=
            'X${f.airID}${f.fltNo}${f.xclass}$_depDate${f.depart}${f.arrive}^';
            if (f.nostop == 'X') {
              nostop += ".${f.line}X^";
            }
          }
          msg += addFg(widget.mmbBooking!.currency, true);
          msg += addFareStore(true);

          msg += 'e*r~x';
          //msg += 'fg^fs1^e*r~x';
        } else {
          msg='';
          msg += addFg(gblSelectedCurrency, true);
          msg += addFareStore(true);

          msg += 'e*r~x';
        }
        logit('sending msg: $msg');
        data = await runVrsCommand(msg);

        String result = data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');

        if (result.contains("ERROR -")) {
          logit(result);
          _error = 'Changes not completed';
          _dataLoaded();
          _showDialog();
        } else {
          Map<String, dynamic> map = json.decode(result);
          widget.pnrModel = new PnrModel.fromJson(map);

          setState(() {
            _displayProcessingText = 'Completing your booking...';
            _displayProcessingIndicator = true;
          });

          if (widget.pnrModel.pNR.tickets != null) {
            await pullTicketControl(widget.pnrModel.pNR.tickets);
          }
          logit('ticket booking 2');
          ticketBooking();
        }
      } catch (e, stack) {
        _error = e.toString();
        gblStack = stack ;

        logit('e871:$_error');
        _dataLoaded();
        _showDialog();
        return null;
      }
    }
  }

  Future<void> pullTicketControl(Tickets tickets) async {
    String msg = '';
    for (var i = 0; i < widget.pnrModel.pNR.tickets.tKT.length; i++) {
      if (widget.pnrModel.pNR.tickets.tKT[i].status == 'A') {
        msg = '*${widget.mmbBooking!.rloc}^';
        msg += '*t-' +
            widget.pnrModel.pNR.tickets.tKT[i].tktNo.replaceAll(' ', '') +
            '/' +
            widget.pnrModel.pNR.tickets.tKT[i].coupon +
            '=o';
/*
        await http.get(Uri.parse(
                "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
            .catchError((resp) {});
*/
        await runVrsCommand(msg);
      }
    }

    // return tickets.tKT.forEach((tkt) async {
    //   if (tkt.status == 'A') {
    //     msg = '*${widget.mmbBooking.rloc}^';
    //     msg += '*t-' + tkt.tktNo.replaceAll(' ', '') + '/' + tkt.coupon + '=o';
    //     http.Response reponse = await http
    //         .get(
    //             "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg'")
    //         .catchError((resp) {});
    //   }
    // });
  }
  /*bool hasValidTkt(int journeyToChange){
    bool bFound = false;
    widget.pnrModel.pNR.tickets.tKT.forEach((t) {
      if( t.segNo == journeyToChange && t.tktFor!= 'MPD' ) {
        bFound = true;
      }
    });
    return bFound;
  }*/

  Future ticketBooking() async {
    if(gblLogPayment) { logit('CPM:ticketBooking');}
    String msg = '';
    if( widget.mmbBooking != null) {
      msg = '*${widget.mmbBooking!.rloc}^';
      gblCurrentRloc = widget.mmbBooking!.rloc;
    } else {
      msg='*R^';
      gblCurrentRloc = widget.pnrModel.pNR.rLOC;
    }
    msg += nostop;

    // validate and ignore result
    String? onValue = await runVrsCommand('EZV*[E][ZWEB]^E*R');
/*

    if (hasValidTkt(widget.mmbBooking!.journeyToChange)) {
      msg += 'EZV*[E][ZWEB]^EZT*R~x';
    } else {
*/
      msg += 'EZT*R~x';
/*
    }
*/


    try {
      String data = await runVrsCommand(msg);
      String pnrJson = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      if( pnrJson.contains('ERROR:')){
        _error = pnrJson; // 'Please check your details';
        gblStack =null ;

        _dataLoaded();
        _showDialog();
        return;
      }

      Map<String, dynamic> map = json.decode(pnrJson);


      PnrModel pnrModel = new PnrModel.fromJson(map);

      PnrDBCopy pnrDBCopy = new PnrDBCopy(
          rloc: pnrModel.pNR.rLOC, //_rloc,
          data: pnrJson,
          delete: 0,
          nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
      Repository.get().updatePnr(pnrDBCopy);
      Repository.get()
          .fetchApisStatus(widget.pnrModel.pNR.rLOC)
          .then((_) => sendEmailConfirmation(pnrModel))
          .then((_) => getArgs())
          .then((args) => Navigator.of(context).pushNamedAndRemoveUntil(
              '/CompletedPage', (Route<dynamic> route) => false,
              arguments: args
              //[pnrModel.pNR.rLOC, result.toString()]
              ));
      //sendEmailConfirmation();

    } catch (e, stack) {
      _error = e.toString(); // 'Please check your details';
      gblStack = stack ;

      _dataLoaded();
      _showDialog();
    }
  }

  getArgs() {
    List<String> args = [];
    // List<String>();
    args.add(widget.pnrModel.pNR.rLOC);
    if (widget.pnrModel.pNR.itinerary.itin
            .where((itin) =>
                // itin.classBand.toLowerCase() != 'fly' &&
                itin.openSeating != 'True')
            .length >
        0) {
      args.add('true');
    } else {
      args.add('false');
    }
    return args;
  }


  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String er = _error;
        if( gblStack != null && gblIsLive == false){
          er += gblStack.toString();
        }
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: er != null && er != ''
              ? new Text(er)
              : new Text("Please try again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                _error = '';
                if(gblLogPayment) { logit('Close dialog');}
                if( gblSettings.wantNewEditPax ){
                  // double pop
                  var nav = Navigator.of(context);
                  nav.pop();
                  nav.pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Future<bool> _onBackPressed() {
  //   return true;
  //   //Navigator.pop(context, true);
  // }

  @override
  Widget build(BuildContext context) {

    if( gblPaymentState == PaymentState.needCheck){

    }

    if (_displayProcessingIndicator && gblInRefreshing == false) {
      if(gblLogPayment) { logit('CPM Build processing');}
      if( gblSettings.wantCustomProgress) {
        progressMessagePage(context, _displayProcessingText, title: 'Payment');
        return Container();
      } else {
        return Scaffold(
          key: _key,
          appBar: appBar(context, 'Payment',
            newBooking: widget.newBooking,
            curStep: 5,
            imageName: gblSettings.wantPageImages ? 'paymentPage' : '',),
          endDrawer: DrawerMenu(),
          body: new Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TrText(_displayProcessingText),
                ),
              ],
            ),
          ),
         // bottomNavigationBar: getBottomNav(context, helpText: 'Click "videcard" to proceed in demo mode.'),
        );
      }
    } else if (gblPaymentMsg != null  && gblPaymentMsg.isNotEmpty) {
      if(gblLogPayment) { logit('CPM Build error');}

      bool wantButtons = true;
      if( gblPaymentMsg.contains('urrency not support')) {
        wantButtons = true;
      }
      return
        CustomWillPopScope(
            action: () {

              print('pop');
 /*             if( gblSettings.canGoBackFromOptionsPage) {
                Navigator.pop(context);
                setState(() {
                  //product.is_favorite = isFavorite;
                });
              } else {*/
                onWillPop(context);
              //}
            },
            onWillPop: true,
          child:  Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('Payment',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          //endDrawer: DrawerMenu(),
          backgroundColor: Colors.grey.shade500,
          body:  criticalErrorWidget(context, gblPaymentMsg, title: 'Payment Error', onComplete: onComplete,wantButtons: wantButtons),
          bottomNavigationBar: getBottomNav(context),
      ));

    } else {
      if(gblLogPayment) { logit('CPM Build normal');}
      print('CPM norm build');
      return WillPopScope(
        onWillPop: _onWillPop,
     /* return
        CustomWillPopScope(
          action: () {

            print('pop');
            onWillPop(context);
          },
          onWillPop: true,*/
          child:  Platform.isIOS ?
              GestureDetector(
                onHorizontalDragEnd: (details){
                  print('gesture');
                  _onWillPop();
                },
                child: _body(),
              )
 : _body()
      );
    }
  }
Widget _body() {
    return Scaffold(
      key: _key,
      appBar: appBar(context, 'Payment',
        newBooking: widget.newBooking,
        curStep: 5,
        imageName: gblSettings.wantPageImages ? 'paymentpage' : '',) ,
      endDrawer: DrawerMenu(),
      //           body: SafeArea(
      body:
      Container(
        child: Column(
          children: <Widget>[
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
                            TimerText(
                              stopwatch: stopwatch,
                              onComplete:() {
                                setState(() {

                                });
                              }
                              ,
                            )
                          ],
                        ),
                      ),
                    )),
              )
            ]),
            // FQTV Here
            _getMiles(),
            _getTotals(),
          ],
        ),
      ),
//          bottomNavigationBar: getBottomNav(context, helpText: 'Click "videcard" to proceed in demo mode.'),
    );
}
  Future<bool> _onWillPop() async {
    print('onwillpop');
    return onWillPop(context);
  }

  void onComplete(dynamic p){
    gblPaymentMsg = '';
//    Navigator.of(context).pop();
    setState(() {
    });
  }

  Widget _getMiles() {
    Column col = new Column();
    if( gblRedeemingAirmiles == true && widget.pnrModel.pNR != null) {
      var miles = widget.pnrModel.pNR.basket.outstandingairmiles.airmiles;
      return Padding(
          padding: const EdgeInsets.only(top: 8, left: 16.0),
          child: Row(
           children: <Widget>[
          TrText( "${gblSettings.fqtvName} required ", style: TextStyle(fontWeight: FontWeight.w700) ),
          Text(miles, style: TextStyle(fontSize: 16.0))]));
    }
    return col;
  }


  Widget _getTotals() {
   String cur = widget.pnrModel.pNR.basket.outstanding.cur;
    String amount =   widget.pnrModel.pNR.basket.outstanding.amount;
    if( amount == '') amount = '0';
   var dAmount =double.parse(amount);
   if( dAmount <= 0 ) {
     dAmount = 0.0;
     amount = '0';
   }
    if( gblRedeemingAirmiles) {
      // get tax amount
      cur = widget.pnrModel.pNR.basket.outstandingairmiles.cur;
      amount =   widget.pnrModel.pNR.basket.outstandingairmiles.amount;
    }


     return Expanded(
      child: new SingleChildScrollView(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: Container(
           // color: Colors.black12,
            child: new Form(
              key: formKey,
              child: new Column(children: getPayOptions(amount, cur),))
      )),
    );
  }
List<Widget> getPayOptions(String amount, String cur) {
    List<Widget> list = [];
    if(gblLogPayment) { logit('get pay opts'); }

     list.add( ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          translate('Total') + ' ' +
              formatPrice(cur, double.parse(amount)) ,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        children: [
          _passengers.adults != 0
              ? Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(translate('No of ') + translate('Adults') + ': '),
              Text(_passengers.adults.toString()),
            ],
          )
              : Padding(
            padding: EdgeInsets.zero,
          ),
          _passengers.youths != 0
              ? Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(translate('No of ') + translate('Youths') + ': '),
              Text(_passengers.youths.toString()),
            ],
          )
              : Padding(
            padding: EdgeInsets.zero,
          ),
          _passengers.children != 0
              ? Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(translate('No of ') + translate('Children') + ': '),
              Text(_passengers.children
                  .toString()),
            ],
          )
              : Padding(
            padding: EdgeInsets.zero,
          ),
          _passengers.infants != 0
              ? Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(translate('No of ') + translate('Infants') + ': '),
              Text(
                  _passengers.infants.toString()),
            ],
          )
              : Padding(
            padding: EdgeInsets.zero,
          ),
          Divider(),
          flightSegementSummary(),
          nonSegProductSummary(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TrText(
                'Summary',
                style: TextStyle(
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          netFareTotal(),
          taxTotal(),
          grandTotal(),
          discountTotal(),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TrText(
                'Amount outstanding',
                style: TextStyle(
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[amountOutstanding()],
          ),
          Padding(
            padding: EdgeInsets.only(top: 5),
          )
        ],
      ));
    if( gblSettings.termsAndConditionsUrl != null &&  gblSettings.termsAndConditionsUrl.isNotEmpty  ) {
      String url = gblSettings.termsAndConditionsUrl;
      if( url.startsWith('{')){
        Map urls = json.decode(url);
        if( urls.length > 0 && urls[gblLanguage ] != null){
          url = urls[gblLanguage ];
        }
      }
      list.add(Divider());
      list.add(Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TrText('Terms & Conditions'),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              if( gblNoNetwork == false ) {
                Navigator.push(
                    context,
                    SlideTopRoute(
                        page: VidWebViewWidget(
                            title: 'Terms & Conditions',
                            url: url)));
              }
            }
          )
        ],
      ));
    }
    if( gblSettings.privacyPolicyUrl != null && gblSettings.privacyPolicyUrl.isNotEmpty ) {
      String url = gblSettings.privacyPolicyUrl;
      if( url.startsWith('{')){
        Map urls = json.decode(url);
        if( urls.length > 0 && urls[gblLanguage ] != null){
          url = urls[gblLanguage ];
        }
      }

      list.add(Divider());
      list.add(Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TrText('Privacy Policy'),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              if(gblNoNetwork == false ) {
                Navigator.push(
                    context,
                    SlideTopRoute(
                        page: VidWebViewWidget(
                            title: translate('Privacy Policy'),
                            url: url)));
              }
            }
          )
        ],
      ));
    }
    list.add(Divider());
    if( gblSettings.wantGiftVouchers){
      list.add(GiftVoucherCard());
      list.add(Divider());
    }

    if( gblSettings.wantTandCCheckBox){
      list.add(CheckboxListTile(
        title: TrText("I have read and agree with the Terms and Conditions, and the Privacy Policy."),
        value: tandCchecked,
        onChanged: (newValue) {
          setState(() {
            tandCchecked = newValue!;
            setState(() {

            });
          });
        },
        controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
      ));
    }

      if(  amount == '0' || (amount != '' && double.parse(amount)==0) ) { // this.isMmb &&
      list.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: gblSystemColors.primaryButtonColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
        onPressed: () {
          if(_displayProcessingIndicator == false && gblNoNetwork == false ) {
            if( gblTimer != null){
              gblTimer?.cancel();
              gblTimer = null;
            }
            completeBookingNothingtoPay();
          }
        },
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ( _displayProcessingIndicator == true) ? CircularProgressIndicator() : Container(),
                Text(
                  this.isMmb
                      ? translate('AGREE AND MAKE CHANGES')
                      : translate('COMPLETE BOOKING'),

                ),
              ],
            ),
          ],
        ),
      ));
    } else {
        if(gblLogPayment) { logit('render pay buttons');}
        if( gblSettings.wantNewPayment) {
          list.add(  renderNewPaymentButtons(amount));
        } else {
          list.add(  renderPaymentButtons(amount));
        }
    }


    return list;
}

  Widget renderNewPaymentButtons(String amount) {
    List<Widget> paymentButtons = [];
    if( gblProviders != null &&  gblSelectedCurrency == gblLastProviderCurrecy ) {
      paymentButtons.add(Padding(
        padding: EdgeInsets.only(top: 8.0),
      ));

      gblProviders!.providers.forEach((provider) {
        logit('provider: ${provider.paymentSchemeName} name: ${provider.paymentSchemeDisplayName} type: ${provider.paymentType.toString()}');
        bool bShow = false;

        switch (provider.paymentType) {
          case 'ExternalPayment':
            bShow = true;
            break;
          case 'CreditCard':
            bShow = true;
            break;
          case 'FundTransferPayment':
              if( ! isMmb) {
                bShow = true;
            }
            break;
          case 'BuyNowPayLater':
              if( ! isMmb) {
                bShow = true;
            }
            break;

        }

        if( bShow){
        String btnText = '';
        Color btnBack = Colors.white;
        if(gblNoNetwork ==  true || ( gblSettings.wantTandCCheckBox == true && tandCchecked== false )   ) btnBack = Colors.grey.shade400;


        btnText = provider.paymentSchemeDisplayName;
        paymentButtons.add(ElevatedButton(
          style: ElevatedButton.styleFrom(


              backgroundColor: btnBack,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
          onPressed: () async {
            if ( gblPayBtnDisabled == false && gblNoNetwork ==  false && ( gblSettings.wantTandCCheckBox == false || tandCchecked )) {
              if(gblLogPayment) { logit('pay pressed');}
              gblPayBtnDisabled = true;
              if( gblTimer != null){
                gblTimer?.cancel();
                gblTimer = null;
              }
              setState(() {

              });
              gblSettings.creditCardProvider = provider.paymentSchemeName;
              if (provider.paymentType == 'ExternalPayment') {
                gblCurrentRloc = widget.pnrModel.pNR.rLOC;
                gblPaymentMsg = '';
                if (provider.fields == null ||
                    provider.fields.paymentFields == null ||
                    provider.fields.paymentFields.length == 0) {
                  if (widget.mmbAction == 'CHANGEFLT') {
                    await changeFlt(
                        widget.pnrModel, widget.mmbBooking!, context);
                  }
                  _cancelTimer = true;
                  await Navigator.push(
                      context,
                      //SlideTopRoute(page:
                      CustomPageRoute(
                          builder: (context) => WebPayPage(
                    provider.paymentSchemeName,
                            newBooking: widget.newBooking!,
                    mmbBooking: widget.mmbBooking,
                    pnrModel: widget.pnrModel,
                    isMmb: widget.isMmb,)));
                  setState(() {});

                } else {
                  if( widget.mmbBooking == null ) widget.mmbBooking = MmbBooking();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>
                      ProviderFieldsPage(pnrModel: widget.pnrModel,
                        provider: provider,
                        isMmb: isMmb,
                        mmbBooking: widget.mmbBooking!,
                        mmbAction: widget.mmbAction,)));
                }
              } else if ( provider.paymentType == 'FundTransferPayment') {
                endProgressMessage();
                _displayProcessingIndicator = false;
                doDelayedPayment(provider);
              } else if ( provider.paymentType == 'BuyNowPayLater') {
                endProgressMessage();
                _displayProcessingIndicator = false;
                doDelayedPayment(provider);

              } else {
                if( session == null){
                  logit('choosePay ses null');
                  if(gblSession != null){
                    session = gblSession;
                  } else {
                    session = Session('', '', '');
                  }
                }
                Navigator.push(
                    context,
                    //MaterialPageRoute(
                    CustomPageRoute(
                        builder: (context) =>
                    CreditCardPage(pnrModel: widget.pnrModel,
                      stopwatch: stopwatch,
                      session: session!,
                      isMmb: isMmb,
                      mmbBooking: widget.mmbBooking,
                      mmbAction: widget.mmbAction,)));
              }
            }
            else if( gblSettings.wantTandCCheckBox == true && tandCchecked == false ) {
              // check box
              showDialog(
                context: context,
                builder: (BuildContext context)
              {
                return msgDialog(context, translate('Warning'),
                    Container(
                      padding: EdgeInsets.all(10),
                        child: TrText('You must accept the terms and conditions before proceeding.')),
                    ipad: EdgeInsets.all(25)
                );
              });
            }
          },
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getPayButton(btnText, provider.paymentType, provider, amount)
              ),
            ],
          ),
        ));
      }
      });


      return Column(children: paymentButtons);
    } else {
      return DataLoaderWidget(dataType: LoadDataType.providers,
        newBooking: widget.newBooking!,
        pnrModel: widget.pnrModel,
        onComplete: (PnrModel pnrModel) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if(gblLogPayment) {logit('Load Providers onComplete');}
          widget.pnrModel = pnrModel;
          pnrModel = pnrModel;
          //setState(() {            });
          startTimer();
        },);
    }
  }
  Future<void> doDelayedPayment( Provider provider) async {
    progressMessagePage(context, 'Making payment', title:  'Payment');
    try {
      PaymentRequest pay = new PaymentRequest();
      pay.rloc = widget.pnrModel.pNR.rLOC;
      pay.paymentType = provider.paymentType;
      pay.paymentName = provider.paymentSchemeName;
      pay.amount = widget.pnrModel.pNR.basket.outstanding.amount;
      pay.currency = widget.pnrModel.pNR.basket.outstanding.cur;
      pay.confirmation = 'EMAIL';

      gblCurrentRloc = widget.pnrModel.pNR.rLOC;
      String data = json.encode(pay);
      try {
        String reply = await callSmartApi('MAKEPAYMENT', data);
        Map<String, dynamic> map = json.decode(reply);
        var objPnr = new PnrModel.fromJson(map);
//        PaymentReply payRs = new PaymentReply.fromJson(map);
        endProgressMessage();
        if (objPnr != null) {
          PnrDBCopy pnrDBCopy = new PnrDBCopy(
              rloc: objPnr.pNR.rLOC,
              data: reply,
              delete: 0,
              nextFlightSinceEpoch: objPnr.getnextFlightEpoch());
          Repository.get().updatePnr(pnrDBCopy).then((w) {
            String msg ;
            bool isHtml = false;
            if( objPnr.pNR.zpay != null && objPnr.pNR.zpay.info != null ) {

              msg= translate(parseHtmlString(objPnr.pNR.zpay.info));
              msg = msg.replaceAll('[[mbcurrency]]', objPnr.pNR.zpay.mbcurrency);
              msg = msg.replaceAll('[[mbamount]]', objPnr.pNR.zpay.mbamount);
              msg = msg.replaceAll('[[mbtotalfare]]', objPnr.pNR.zpay.mbtotalfare);
              msg = msg.replaceAll('[[mbtotaltax]]', objPnr.pNR.zpay.mbtotaltax);
              msg = msg.replaceAll('[[ttl]]', objPnr.pNR.zpay.ttl);
              msg = msg.replaceAll('[[reference]]', '<b>' + objPnr.pNR.zpay.reference + '</b>') ;
              isHtml = true;
            } else {
              msg = translate('Your booking is confirmed. Booking reference is') + ' ${objPnr.pNR.rLOC}'; 
            }
            List <Widget> actions = <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                smallButton(text: 'Show Booking',
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) =>
                        ViewBookingPage(
                        rloc: objPnr.pNR.rLOC,
                        )),
                        );
                    },
                 ),
              smallButton(text: 'Home',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/HomePage', (Route<dynamic> route) => false);
                },
              ),
            ])
            ];
            successMessagePage(context,msg, title: translate('Booking Complete-Payment Pending'), isHtml: isHtml, actions: actions );
          });
        } else {
          criticalErrorPage(context, gblError, title: 'Payment Error');
        }
      } catch (e, stack) {
        gblError = e.toString();
        gblStack = stack ;
        endProgressMessage();
        criticalErrorPage(context, gblError, title: 'Payment Error', wantButtons: true);
      }
    } catch(e, stack) {
      gblError = e.toString();
      gblStack = stack ;

      endProgressMessage();
      criticalErrorPage(context, gblError, title: 'Payment Error');

    }
  }



  Widget renderPaymentButtons(String amount) {
    List<Widget> paymentButtons = [];

      List<String> providers = gblSettings.creditCardProvider.split(',');
      //String provider = gblSettings.creditCardProvider;
      // List<Widget>();

      paymentButtons.add(Padding(
        padding: EdgeInsets.only(top: 8.0),
      ));

      providers.forEach((provider) {
        List<String> details = provider.split('|');
        String providerName = details[0];
        String btnText = '';
        if (details.length > 1) {
          btnText = details[1];
        }

        paymentButtons.add(ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
          onPressed: () {
            if (providerName.startsWith('3DS_')) {
              gblCurrentRloc = widget.pnrModel.pNR.rLOC;
              gblPaymentMsg = '';
              Navigator.push(
                  context,
                  //SlideTopRoute(page:
                  CustomPageRoute(
                      builder: (context) =>
                          WebPayPage(
                providerName, newBooking: widget.newBooking!,
                pnrModel: widget.pnrModel,
                isMmb: widget.isMmb,)));
            } else {
              if( session==null){
                if( gblSession != null) {
                  session = gblSession;
              } else{
                  session = new Session('', '', '');
                }
              }
              Navigator.push(
                  context,
                  //MaterialPageRoute(
                  CustomPageRoute(
                      builder: (context) =>
                  CreditCardPage(pnrModel: widget.pnrModel,
                    session: session!,
                    stopwatch: stopwatch,
                    isMmb: isMmb,
                    mmbBooking: widget.mmbBooking,
                    mmbAction: widget.mmbAction,)));
            }
          },
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getPayButton(btnText, 'ExternalPayment', null, amount)
              ),
            ],
          ),
        ));
      });

      return Column(children: paymentButtons);
  }

 // int _start = 10;

  void startTimer() {
    const oneSec = const Duration(milliseconds: 100);
    _cancelTimer = false;
    Timer.periodic(
      oneSec,
          (Timer timer) {
          setState(() {
            timer.cancel();
          });
        });
  }


  List<Widget> _getPayButton(String text, String providerType, Provider? provider, String amount) {
    List<Widget> list = [];
    if(text == null  ) {
      text = 'AGREE AND PAY';
    }
    if(text.isEmpty) {
    text = 'AGREE AND PAY';
    }

    if( amount == '0') {
      list.add(Text('COMPLETE BOOKING' ,
        style: new TextStyle(color: Colors.black),
      ));

    } else {
      if(gblPayBtnDisabled ) {
        text = "Completing Payment...";
       list.add( new Transform.scale(
          scale: 0.5,
          child: CircularProgressIndicator(),
        ));
      }
      list.add(TrText( text,
      style: new TextStyle(color: Colors.black),
      ));
      String action = '';
      if( provider != null && gblSettings.paySettings != null && gblSettings.paySettings!.payImageMap != null ) {
        Map pageMap = json.decode(            gblSettings.paySettings!.payImageMap.toUpperCase());
        if( pageMap[provider.paymentSchemeName.toUpperCase()] != null )          action = pageMap[provider.paymentSchemeName.toUpperCase()];
      }


      if( providerType == 'ExternalPayment' || providerType == 'CreditCard') {
          if( action == 'VISAMC' || action == '' ) {
            list.add(Image.asset(
              'lib/assets/images/payment/visa.png',
              height: 40,
            ));
            list.add(Padding(
              padding: EdgeInsets.all(6),
            ));
            list.add(Image.asset(
              'lib/assets/images/payment/mastercard.png',
              height: 40,
            ));
          } else if (action == 'IMAGE') {
            list.add(Padding(
              padding: EdgeInsets.all(6),
            ));
            list.add(Image.network('${gblSettings.gblServerFiles}/pageImages/${provider!.paymentSchemeName}.png', width: 30,));
          }
      } else if (providerType == 'FundTransferPayment') {
        if( action != 'NONE') {
          list.add(Icon(Icons.bookmark_border, color: Colors.grey,));
        }
        }
    }
    return list;

  }
}


class TimerText extends StatefulWidget {
  TimerText({required this.stopwatch, this.onComplete });
  final Stopwatch stopwatch;
  void Function()? onComplete;
  final double timerStart = 600000;

  TimerTextState createState() => new TimerTextState(stopwatch: stopwatch);
}

class TimerTextState extends State<TimerText> {
  //late Timer timer;
  final Stopwatch stopwatch;
  void Function()? onComplete;

  TimerTextState({required this.stopwatch, this.onComplete}) {
    gblTimer = new Timer.periodic(new Duration(seconds: 1), callback);
  }
  void callback(Timer timer) {
    if(_cancelTimer) {
      timer.cancel();
      //timer = null;
      return;
    }
    if (widget.timerStart < stopwatch.elapsedMilliseconds) {
      gblPayBtnDisabled = false;
      gblPaymentMsg = 'Payment Timeout';
      print('expired 2');
      if( timer != null ) {
        timer.cancel();
        //timer = null;
      }
      //Navigator.of(context).pop();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
      if( onComplete != null ) {
        onComplete!();
      }
      return;
    }
    if (stopwatch.isRunning && timer != null ) {
       setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime;
    double timerStart = widget.timerStart; //600000;
    double timeRemaining = timerStart - stopwatch.elapsedMilliseconds;

    var timeRemainingMinutes = (timeRemaining / (1000 * 60)) % 60;
    var timeRemainingSeconds = (timeRemaining / (1000)) % 60;

    formattedTime = timeRemainingMinutes.toString().split('.')[0] +
        ':' +
        timeRemainingSeconds.toString().split('.')[0].padLeft(2, '0');

    return new Text(formattedTime,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300));
  }
}
