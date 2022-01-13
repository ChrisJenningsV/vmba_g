import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/components/showDialog.dart';
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
import 'package:vmba/utilities/widgets/dataLoader.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/controllers/vrsCommands.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';

import 'ProviderFieldsPage.dart';

//ignore: must_be_immutable
class ChoosePaymenMethodWidget extends StatefulWidget {
  ChoosePaymenMethodWidget(
      {Key key,
      this.newBooking,
      this.pnrModel,
      this.isMmb ,
      this.mmbCmd,
      this.mmbBooking,
      this.mmbAction,
      this.session})
      : super(key: key);
  final NewBooking newBooking;
  PnrModel pnrModel;
  final bool isMmb ;
  final String mmbCmd;
  final String mmbAction;
  final MmbBooking mmbBooking;
  final Session session;

  _ChoosePaymenMethodWidgetState createState() =>
      _ChoosePaymenMethodWidgetState();
}

class _ChoosePaymenMethodWidgetState extends State<ChoosePaymenMethodWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();
  String currencyCode;
  bool _displayProcessingIndicator;
  String _displayProcessingText;
 // PnrModel pnrModel;
  Stopwatch stopwatch = new Stopwatch();
  int timeout = 15;
  String _error;
  Passengers _passengers = new Passengers(1, 0, 0, 0,0, 0, 0);
  String nostop = '';
  bool isMmb = false;

  Session session ;

  @override
  initState() {
    super.initState();
    //widget.newBooking.paymentDetails = new PaymentDetails();
    session=widget.session;

    _displayProcessingText = 'Making your Booking...';
    _displayProcessingIndicator = false;
    gblPaymentMsg = null;
    gblPayBtnDisabled = false;
    gblPaySuccess = false;
    if (widget.isMmb != null) {
      isMmb = widget.isMmb;
    }

    if( widget.pnrModel != null ) {
      _passengers = widget.pnrModel.pNR.names.getPassengerTypeCounts();
    }

    //pnrModel = widget.pnrModel;
    setCurrencyCode();
    if( widget.isMmb ) {
      if (session == null || session.varsSessionId == "") {
      //  signin().then((_) => makeMmbBooking());
      } else {
        //     makeMmbBooking();
      }
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

  void makeMmbBooking() async {
    String msg = "";
    if (widget.isMmb) {
  //    msg = '*${widget.mmbBooking.rloc}^';
      msg = '*${widget.mmbBooking.rloc}^';
      widget.mmbBooking.journeys.journey[widget.mmbBooking.journeyToChange - 1]
          .itin.reversed
          .forEach((f) {
        msg += 'X${f.line}^';
        if (f.nostop == 'X') {
          nostop += ".${f.line}X^";
        }
      });

      widget.mmbBooking.newFlights.forEach((flt) {
        print(flt);
        msg += flt + '^';
      });
      msg += addFg(widget.mmbBooking.currency, true);
      msg += addFareStore(false);
     // msg += '^E*R~X';
    }
    if(msg.isNotEmpty) {
//    String vrsCommandList =
//        json.encode(RunVRSCommandList(session, msg.split('^')).toJson());
    print(msg);
//    sendVRSCommandList(vrsCommandList);

      http.Response response = await http
          .get(Uri.parse(
          "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
          .catchError((resp) {});

      if (response == null) {
        //return new ParsedResponse(NO_INTERNET, []);
        setState(() {
          _displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
        return null;
      }

      //If there was an error return an empty list
      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
        return null;
        // return new ParsedResponse(response.statusCode, []);
      }
      try {
        if (response.body.contains('ERROR - ') ||
            response.body.contains('ERROR:')) {
          _error = response.body
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '')
              .replaceAll('ERROR - ', '')
              .trim(); // 'Please check your details';
        } else {
          String pnrJson = response.body
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '');
          logit(pnrJson);
          setState(() {
            _displayProcessingIndicator = false;
          });
        }

      } catch(e) {
        logit(e.toString());
      }


    }

    //sendVRSCommand(
    //  json.encode(JsonEncoder().convert(new RunVRSCommand(session, msg))));
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
      _displayProcessingIndicator = false;
    });
  }

  Row amountOutstanding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
            formatPrice(widget.pnrModel.pNR.basket.outstanding.cur, double.parse(widget.pnrModel.pNR.basket.outstanding.amount) ?? 0.0),
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
          total += double.tryParse(d.fare ?? 0.0);
          total += double.tryParse(d.tax1 ?? 0.0);
          total += double.tryParse(d.tax2 ?? 0.0);
          total += double.tryParse(d.tax3 ?? 0.0);
          if( d.disc != null ) {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc ?? 0.0));
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
          if( d.disc != null ) {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc ?? 0.0));
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
            FutureBuilder(
              future: cityCodeToName(
                widget.pnrModel.pNR.itinerary.itin[i].depart,
              ),
              initialData: widget.pnrModel.pNR.itinerary.itin[i].depart.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return new Text(text.data,
                    style: TextStyle(fontWeight: FontWeight.w700));
              },
            ),
            TrText(
              ' to ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            FutureBuilder(
              future: cityCodeToName(
                widget.pnrModel.pNR.itinerary.itin[i].arrive,
              ),
              initialData: widget.pnrModel.pNR.itinerary.itin[i].arrive.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return new Text(
                  text.data,
                  style: TextStyle(fontWeight: FontWeight.w700),
                );
              },
            ),
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
            Text(DateFormat('dd MMM kk:mm').format(DateTime.parse(
                widget.pnrModel.pNR.itinerary.itin[i].depDate +
                    ' ' +
                    widget.pnrModel.pNR.itinerary.itin[i].depTime)))
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
            Text('Tax:'),
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
                Text('Alloacted Seats',
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
                Text('Passenger ${seat.pax} - ${seat.seat}  ${seat.name}'),
                Text(formatPrice(seat.cur ?? currencyCode, double.parse(seat.amt) ?? 0.0) ),
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

  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
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

  String buildCmd() {
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

  Future completeBookingNothingtoPay() async {
    setState(() {
      _displayProcessingText = 'Processing your changes...';
      _displayProcessingIndicator = true;
    });

    //New code
    String msg = '';
    if( this.isMmb) {
      msg = '*${widget.mmbBooking.rloc}';
      widget.mmbBooking.newFlights.forEach((flt) {
        print(flt);
        msg += '^' + flt;
      });
      msg += '^';
    }
    msg += 'e*r~x';

//End of new code

    //String msg = buildCmd();
    //msg += '*r~x';

    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
        .catchError((resp) {});

    if (response == null) {
      setState(() {
        _displayProcessingIndicator = false;
      });
      //showSnackBar(translate('Please, check your internet connection'));
      noInternetSnackBar(context);
      return null;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _displayProcessingIndicator = false;
      });
      //showSnackBar(translate('Please, check your internet connection'));
      noInternetSnackBar(context);
      return null;
    }

    try {
      // String result = response.body
      //     .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
      //     .replaceAll('<string xmlns="http://videcom.com/">', '')
      //     .replaceAll('</string>', '');

      // if (result.trim().startsWith('OK Locator')) {

      //has hosted flights?
      //print('New segments booked');

      bool flightsConfirmed = true;
      if (response.body.contains('ERROR - ')) {
        _error = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '')
            .replaceAll('ERROR - ', '')
            .trim();
        // _dataLoaded();
        // return null;

        print('completeBookingNothingtoPay: ' + _error);

        _error =
        'Unnable to change booking'; //response.body; // 'Please check your details';
        _dataLoaded();
        _showDialog();
        return null;
      } else if (response.body.contains('ERROR:')) {
        _error = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '')
            .replaceAll('ERROR: ', '')
            .trim();
        // _dataLoaded();
        // return null;

        print('completeBookingNothingtoPay: ' + _error);

        _dataLoaded();
        _showDialog();
        return null;
      } else {
        String pnrJson = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');
        Map map = json.decode(pnrJson);

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
            response = await http
                .get(Uri.parse(
                    "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
                .catchError((resp) {});
            if (response == null) {
              setState(() {
                _displayProcessingIndicator = false;
              });
              //showSnackBar(translate('Please, check your internet connection'));
              noInternetSnackBar(context);
              return null;
            }

            //If there was an error return an empty list
            if (response.statusCode < 200 || response.statusCode >= 300) {
              setState(() {
                _displayProcessingIndicator = false;
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
        setState(() {
          _displayProcessingIndicator = false;
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
//[0]:"0SI2051Q28Sep20ABZBRSNN1/15001605(CAB=Y)[CB=Blue Flex]"

        return null;
      }

      // }
      else {
        msg = '*${widget.mmbBooking.rloc}^';
        //update to use full cancel segment command
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
        msg += addFg(widget.mmbBooking.currency, true);
        msg += addFareStore(true);

        msg += 'e*r~x';
        //msg += 'fg^fs1^e*r~x';
      }
      response = await http
          .get(Uri.parse(
              "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
          .catchError((resp) {});

      if (response == null) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
        return null;
      }

      //If there was an error return an empty list
      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
        return null;
      }
      String result = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      if (result.contains("ERROR -")) {
        _error = 'Changes not completed';
        _dataLoaded();
        _showDialog();
      } else {
        Map map = json.decode(result);
        widget.pnrModel = new PnrModel.fromJson(map);

        setState(() {
          _displayProcessingText = 'Completing your booking...';
          _displayProcessingIndicator = true;
        });

        if (widget.pnrModel.pNR.tickets != null) {
          await pullTicketControl(widget.pnrModel.pNR.tickets);
        }
        ticketBooking();
      }
      try {
        // if (result.trim() == 'Payment Complete') {
        //   print('Payment success');
        //   setState(() {
        //     _displayProcessingText = 'Completing your booking...';
        //     _displayProcessingIndicator = true;
        //   });
        //   if (pnrModel.pNR.tickets != null) {
        //     await pullTicketControl(pnrModel.pNR.tickets);
        //   }
        //   ticketBooking();
        // } else {
        //   _error = 'Changes not completed';
        //   _dataLoaded();
        //   _showDialog();
        // }
      } catch (e) {
        _error = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', ''); // 'Please check your details';
        _dataLoaded();
        _showDialog();
        return null;
      }
    } catch (e) {
      _error = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''); // 'Please
           _dataLoaded();
      _showDialog();
      return null;
    }
    // setState(() {
    //   _displayProcessingText = 'Completing your booking...';
    //   _displayProcessingIndicator = true;
    // });
    // if (pnrModel.pNR.tickets != null) {
    //   await pullTicketControl(pnrModel.pNR.tickets);
    // }
    // ticketBooking();
  }

  Future<void> pullTicketControl(Tickets tickets) async {
    String msg = '';
    for (var i = 0; i < widget.pnrModel.pNR.tickets.tKT.length; i++) {
      if (widget.pnrModel.pNR.tickets.tKT[i].status == 'A') {
        msg = '*${widget.mmbBooking.rloc}^';
        msg += '*t-' +
            widget.pnrModel.pNR.tickets.tKT[i].tktNo.replaceAll(' ', '') +
            '/' +
            widget.pnrModel.pNR.tickets.tKT[i].coupon +
            '=o';
//        http.Response reponse = await http
        await http.get(Uri.parse(
                "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
            .catchError((resp) {});
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

  Future ticketBooking() async {
    http.Response response;
    String msg = '*${widget.mmbBooking.rloc}^';
    msg += nostop;
    msg += 'EZV*[E][ZWEB]^EZT*R~x';

    response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
        .catchError((resp) {});

    if (response == null) {
      setState(() {
        _displayProcessingIndicator = false;
      });
      //showSnackBar(translate('Please, check your internet connection'));
      noInternetSnackBar(context);
      return null;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _displayProcessingIndicator = false;
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
          .fetchApisStatus(widget.pnrModel.pNR.rLOC)
          .then((_) => sendEmailConfirmation(pnrModel))
          .then((_) => getArgs())
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

    if (_displayProcessingIndicator) {
      return Scaffold(
        key: _key,
        appBar: appBar(context, 'Payment',
          newBooking: widget.newBooking,
          curStep: 5,
          imageName: gblSettings.wantPageImages ? 'paymentPage' : null,),
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
      );
    } else if (gblPaymentMsg != null ) {
      return new Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('Contact Details',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body:getAlertDialog( context, 'Payment Error', gblPaymentMsg, onComplete: onComplete),
/*
          AlertDialog(
            title: new TrText("Payment Error"),
            content: TrText(gblPaymentMsg),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new TextButton(
                child: new TrText("OK"),
                onPressed: () {
                  setState(() {
                    gblPaymentMsg = null;
                  });

                },
              ),
            ],
          )
*/
      );
    } else {
      return WillPopScope(
        onWillPop: () {
          if( gblSettings.wantNewEditPax ){
            // double pop
            var nav = Navigator.of(context);
            nav.pop();
            nav.pop();
          } else {
            Navigator.pop(context, true);
          }
          return true as Future<bool>;
        },
        child: new Scaffold(
            key: _key,
            appBar: appBar(context, 'Payment',
              newBooking: widget.newBooking,
              curStep: 5,
              imageName: gblSettings.wantPageImages ? 'paymentpage' : null,) ,
            endDrawer: DrawerMenu(),
            body: SafeArea(
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
            )),
      );
    }
  }

  void onComplete(){
    gblPaymentMsg = null;
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
          child: new Form(
              key: formKey,
              child: new Column(children: getPayOptions(amount, cur),))),
    );
  }
List<Widget> getPayOptions(String amount, String cur) {
    List<Widget> list = [];


     list.add( ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          'Total ' +
              formatPrice(cur, double.parse(amount) ?? 0.0) ,
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
      list.add(Divider());
    list.add(Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TrText('Terms & Conditions'),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.push(
                context,
                SlideTopRoute(
                    page: WebViewWidget(
                        title: 'Terms & Conditions',
                        url: gblSettings
                            .termsAndConditionsUrl))),
          )
        ],
      ));
    list.add(Divider());
    list.add(Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TrText('Privacy Policy'),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.push(
                context,
                SlideTopRoute(
                    page: WebViewWidget(
                        title: translate('Privacy Policy'),
                        url: gblSettings
                            .privacyPolicyUrl))),
          )
        ],
      ));
    list.add(Divider());

    if( gblSettings.wantProducts) {
      //if( gblProductsState == LoadState.none) {
        list.add(DataLoaderWidget(dataType: LoadDataType.products, newBooking: widget.newBooking,
          pnrModel: widget.pnrModel,
          onComplete: (PnrModel pnrModel) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            logit('On Complete products');
            widget.pnrModel = pnrModel;
            pnrModel = pnrModel;
            setState(() {

            });
          },));
      /*} else {
        list.add(ExpansionTile(
          tilePadding: EdgeInsets.only(left: 0),
          initiallyExpanded: false,
          title: Text(
            'Baggage options',
          ),
          children: getBagOptions(),));
        list.add(Divider());
      }

       */
    }
      if( this.isMmb && amount == '0') {
      list.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
        onPressed: () => completeBookingNothingtoPay(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  this.isMmb
                      ? translate('AGREE AND MAKE CHANGES')
                      : translate('COMPLETE BOOKING'),
                  style: new TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ));
    } else {
        if( gblSettings.wantNewPayment) {
          list.add(  renderNewPaymentButtons());
        } else {
          list.add(  renderPaymentButtons());
        }
    }


    return list;
}

  Widget renderNewPaymentButtons() {
    List<Widget> paymentButtons = [];
    if( gblProviders != null ) {
      paymentButtons.add(Padding(
        padding: EdgeInsets.only(top: 8.0),
      ));

      gblProviders.providers.forEach((provider) {
        bool bShow = false;

        switch (provider.paymentType) {
          case 'ExternalPayment':
            bShow = true;
            break;
        }

        if( bShow){
        String btnText = '';
        btnText = provider.paymentSchemeDisplayName;
        paymentButtons.add(ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
          onPressed: () async {
            if ( gblPayBtnDisabled == false ) {
              logit('pay pressed');
              gblPayBtnDisabled = true;
              setState(() {

              });

              if (provider.paymentType == 'ExternalPayment') {
                gblCurrentRloc = widget.pnrModel.pNR.rLOC;
                gblPaymentMsg = null;
                if (provider.fields == null ||
                    provider.fields.paymentFields == null ||
                    provider.fields.paymentFields.length == 0) {
                  if (widget.mmbAction == 'CHANGEFLT') {
                    await changeFlt(
                        widget.pnrModel, widget.mmbBooking, context);
                  }

                  Navigator.push(
                      context, SlideTopRoute(page: WebPayPage(
                    provider.paymentSchemeName, newBooking: widget.newBooking,
                    pnrModel: widget.pnrModel,
                    isMmb: widget.isMmb,)));
                } else {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>
                      ProviderFieldsPage(pnrModel: widget.pnrModel,
                        provider: provider,
                        isMmb: isMmb,
                        mmbBooking: widget.mmbBooking,
                        mmbAction: widget.mmbAction,)));
                }
              } else {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    CreditCardPage(pnrModel: widget.pnrModel,
                      session: session,
                      isMmb: isMmb,
                      mmbBooking: widget.mmbBooking,
                      mmbAction: widget.mmbAction,)));
              }
            }
          },
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getPayButton(btnText)
              ),
            ],
          ),
        ));
      }
      });


      return Column(children: paymentButtons);
    } else {
      return DataLoaderWidget(dataType: LoadDataType.providers,
        newBooking: widget.newBooking,
        pnrModel: widget.pnrModel,
        onComplete: (PnrModel pnrModel) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          logit('Load Providers onComplete');
          widget.pnrModel = pnrModel;
          pnrModel = pnrModel;
          //setState(() {            });
          startTimer();
        },);
    }
  }


  Widget renderPaymentButtons() {
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
              primary: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
          onPressed: () {
            if (providerName.startsWith('3DS_')) {
              gblCurrentRloc = widget.pnrModel.pNR.rLOC;
              gblPaymentMsg = null;
              Navigator.push(
                  context, SlideTopRoute(page: WebPayPage(
                providerName, newBooking: widget.newBooking,
                pnrModel: widget.pnrModel,
                isMmb: widget.isMmb,)));
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) =>
                  CreditCardPage(pnrModel: widget.pnrModel,
                    session: session,
                    isMmb: isMmb,
                    mmbBooking: widget.mmbBooking,
                    mmbAction: widget.mmbAction,)));
            }
          },
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getPayButton(btnText)
              ),
            ],
          ),
        ));
      });

      return Column(children: paymentButtons);
  }

  Timer _timer;
 // int _start = 10;

  void startTimer() {
    const oneSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
          setState(() {
            timer.cancel();
          });
        });
  }


  List<Widget> _getPayButton(String text) {
    List<Widget> list = [];
    if(text == null  ) {
      text = 'AGREE AND PAY';
    }
    if(text.isEmpty) {
    text = 'AGREE AND PAY';
    }

    if( widget.pnrModel.pNR.basket.outstanding
        .amount ==
        '0') {
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
    list.add(Image.asset(
    'lib/assets/images/payment/visa.png',
    height: 40,
    ));
    list.add(Padding(
    padding: EdgeInsets.all(4),
    ));
    list.add(Image.asset(
    'lib/assets/images/payment/mastercard.png',
    height: 40,
    ));
    }
    return list;

  }
}


class TimerText extends StatefulWidget {
  TimerText({this.stopwatch, this.onComplete });
  final Stopwatch stopwatch;
  void Function() onComplete;
  final double timerStart = 600000;

  TimerTextState createState() => new TimerTextState(stopwatch: stopwatch);
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  final Stopwatch stopwatch;
  void Function() onComplete;

  TimerTextState({this.stopwatch, this.onComplete}) {
    timer = new Timer.periodic(new Duration(seconds: 1), callback);
  }
  void callback(Timer timer) {
    if (widget.timerStart < stopwatch.elapsedMilliseconds) {
      gblPayBtnDisabled = false;
      gblPaymentMsg = 'Payment Timeout';
      print('expired 2');
      timer.cancel();
      Navigator.of(context).pop();
      onComplete();
      return;
    }
    if (stopwatch.isRunning) {
       //setState(() {});
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
