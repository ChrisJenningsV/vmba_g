import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
//import 'creditcard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/payment/providers/paystack.dart';
import 'package:vmba/payment/v2/CreditCardPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

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
  final PnrModel pnrModel;
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
  PnrModel pnrModel;
  Stopwatch stopwatch = new Stopwatch();
  int timeout = 15;
  String _error;
  Passengers _passengers = new Passengers(1, 0, 0, 0);
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
    if (widget.isMmb != null) {
      isMmb = widget.isMmb;
    }

    if( widget.pnrModel != null ) {
      _passengers = widget.pnrModel.pNR.names.getPassengerTypeCounts();
    }

    pnrModel = widget.pnrModel;
    setCurrencyCode();
    if( session == null || session.varsSessionId == "" ) {
      signin().then((_) => makeMmbBooking());
    } else {
 //     makeMmbBooking();
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

  void makeMmbBooking() {
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

      msg += 'fg^fs1';
    }
    if(msg.isNotEmpty) {
    String vrsCommandList =
        json.encode(RunVRSCommandList(session, msg.split('^')).toJson());
    print(msg);
    sendVRSCommandList(vrsCommandList);
    }

    //sendVRSCommand(
    //  json.encode(JsonEncoder().convert(new RunVRSCommand(session, msg))));
  }

  Future setCurrencyCode() async {
    try {
      currencyCode = this
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
            NumberFormat.simpleCurrency(
                    locale: gblSettings.locale,
                    name: this.pnrModel.pNR.basket.outstanding.cur)
                .format((double.parse(
                        this.pnrModel.pNR.basket.outstanding.amount) ??
                    0.0)),
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
    double sepTax2 = 0.0;
    String desc2 = '';


    List <Row> rows = [];

    if (this.pnrModel.pNR.fareQuote.fareTax != null) {
      this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
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
        Text('Total Tax: '),
        Text(NumberFormat.simpleCurrency(
            locale: gblSettings.locale,
            name: currencyCode)
            .format(tax)),
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
          Text(NumberFormat.simpleCurrency(
              locale: gblSettings.locale,
              name: currencyCode)
              .format(sepTax1)),
        ],
      ));
    }


    return Column(
      children: rows,
    );
  }

  /*
  Row taxTotal() {
    double tax = 0.0;
    if (this.pnrModel.pNR.fareQuote.fareTax != null) {
      this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        tax += (double.tryParse(paxTax.amnt) ?? 0.0);
      });
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Total Tax: '),
        Text(NumberFormat.simpleCurrency(
                locale: gblSettings.locale,
                name: currencyCode)
            .format(tax))
      ],
    );
  }

   */

  Row netFareTotal() {
    double total = 0.0;
    total = (double.tryParse(this
            .pnrModel
            .pNR
            .fareQuote
            .fareStore
            .where((fareStore) => fareStore.fSID == 'Total')
            .first
            .total) ??
        0.0);
    double tax = 0.0;

    if (this.pnrModel.pNR.fareQuote.fareTax != null) {
      this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        tax += (double.tryParse(paxTax.amnt) ?? 0.0);
      });
    }
    double netFareTotal = total - tax;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Net Fare:'),
        Text(NumberFormat.simpleCurrency(
                locale: gblSettings.locale,
                name: currencyCode)
            .format(netFareTotal))
      ],
    );
  }

  Row grandTotal() {
    double total = 0.0;

    this.pnrModel.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          total += double.tryParse(d.fare ?? 0.0);
          total += double.tryParse(d.tax1 ?? 0.0);
          total += double.tryParse(d.tax2 ?? 0.0);
          total += double.tryParse(d.tax3 ?? 0.0);
          d.disc
              .split(',')
              .forEach((disc) => total += double.tryParse(disc ?? 0.0));
          //total += double.tryParse(d.disc ?? 0.0);
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
        Text('Flights Total: '),
        Text(NumberFormat.simpleCurrency(
                locale: gblSettings.locale,
                name: currencyCode)
            .format(total))
        // (double.tryParse(fareStore.total) ?? 0.0))),
      ],
    );
  }

  Row discountTotal() {
    double total = 0.0;

    this.pnrModel.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          d.disc
              .split(',')
              .forEach((disc) => total += double.tryParse(disc ?? 0.0));
          //total += double.tryParse(d.disc ?? 0.0);
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
          Text('Discount: '),
          Text(NumberFormat.simpleCurrency(
                  locale: gblSettings.locale,
                  name: currencyCode)
              .format(total)),
        ],
      );
    }
  }

  Widget flightSegementSummary() {
    List<Widget> widgets = [];
    // new List<Widget>();
    for (var i = 0; i <= pnrModel.pNR.itinerary.itin.length - 1; i++) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              future: cityCodeToName(
                pnrModel.pNR.itinerary.itin[i].depart,
              ),
              initialData: pnrModel.pNR.itinerary.itin[i].depart.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return new Text(text.data,
                    style: TextStyle(fontWeight: FontWeight.w700));
              },
            ),
            Text(
              ' to ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            FutureBuilder(
              future: cityCodeToName(
                pnrModel.pNR.itinerary.itin[i].arrive,
              ),
              initialData: pnrModel.pNR.itinerary.itin[i].arrive.toString(),
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
            Text('Flight No:'),
            Text(
                '${pnrModel.pNR.itinerary.itin[i].airID}${pnrModel.pNR.itinerary.itin[i].fltNo}')
          ],
        ),
      );
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Departure Time:'),
            Text(DateFormat('dd MMM kk:mm').format(DateTime.parse(
                pnrModel.pNR.itinerary.itin[i].depDate +
                    ' ' +
                    pnrModel.pNR.itinerary.itin[i].depTime)))
          ],
        ),
      );
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Fare Type:'),
            Text(pnrModel.pNR.itinerary.itin[i].classBandDisplayName ==
                    'Fly Flex Plus'
                ? 'Fly Flex +'
                : pnrModel.pNR.itinerary.itin[i].classBandDisplayName)
          ],
        ),
      );
      double taxTotal = 0.0;

      if (this.pnrModel.pNR.fareQuote.fareTax != null) {
        this
            .pnrModel
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
            Text(NumberFormat.simpleCurrency(
                    locale: gblSettings.locale,
                    name: currencyCode)
                .format(taxTotal))
          ],
        ),
      );
      double sepTax1 = 0.0;
      String desc1 = '';

      if (this.pnrModel.pNR.fareQuote.fareTax != null) {
        this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
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
              Text(NumberFormat.simpleCurrency(
                  locale: gblSettings.locale,
                  name: currencyCode)
                  .format(sepTax1)),
            ],
          ),
        );
      }




      String cityPair =
          '${pnrModel.pNR.itinerary.itin[i].depart}${pnrModel.pNR.itinerary.itin[i].arrive}';
      if (pnrModel.pNR.aPFAX != null &&
          pnrModel.pNR.aPFAX.aFX
                  .where((aFX) =>
                      aFX.aFXID == "SEAT" &&
                      aFX.text.split(' ')[1] ==
                          pnrModel.pNR.itinerary.itin[i].cityPair.toString())
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

        pnrModel.pNR.aPFAX.aFX
            .where((aFX) =>
                aFX.aFXID == "SEAT" && aFX.text.split(' ')[1] == cityPair)
            .forEach((seat) {
          widgets.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Passenger ${seat.pax} - ${seat.seat}  ${seat.name}'),
                Text(NumberFormat.simpleCurrency(
                        locale: gblSettings.locale,
                        name: seat.cur ?? currencyCode)
                    .format(double.parse(seat.amt) ?? 0.0))
              ],
            ),
          );
        });
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
    cmd += 'fg^fs1^e';
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
      showSnackBar('Please check your internet connection');
      return null;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _displayProcessingIndicator = false;
      });
      showSnackBar('Please check your internet connection');
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

        pnrModel = new PnrModel.fromJson(map);
        print(pnrModel.pNR.rLOC);
        if (pnrModel.hasNonHostedFlights() &&
            pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          int noFLts = pnrModel
              .flightCount(); //if external flights aren't confirmed they get removed from the PNR
          // which makes it look like the flights are confirmed

          flightsConfirmed = false;
          for (var i = 0; i < 4; i++) {
            msg = '*' + pnrModel.pNR.rLOC + '~x';
            response = await http
                .get(Uri.parse(
                    "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
                .catchError((resp) {});
            if (response == null) {
              setState(() {
                _displayProcessingIndicator = false;
              });
              showSnackBar('Please check your internet connection');
              return null;
            }

            //If there was an error return an empty list
            if (response.statusCode < 200 || response.statusCode >= 300) {
              setState(() {
                _displayProcessingIndicator = false;
              });
              showSnackBar('Please check your internet connection');
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
          _displayProcessingIndicator = false;
        });
        showSnackBar('Unable to confirm partner airlines flights.');

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
        msg += 'fg^fs1^e*r~x';
      }
      response = await http
          .get(Uri.parse(
              "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
          .catchError((resp) {});

      if (response == null) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        showSnackBar('Please check your internet connection');
        return null;
      }

      //If there was an error return an empty list
      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        showSnackBar('Please check your internet connection');
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
        pnrModel = new PnrModel.fromJson(map);

        setState(() {
          _displayProcessingText = 'Completing your booking...';
          _displayProcessingIndicator = true;
        });

        if (pnrModel.pNR.tickets != null) {
          await pullTicketControl(pnrModel.pNR.tickets);
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
      showSnackBar('Please check your internet connection');
      return null;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _displayProcessingIndicator = false;
      });
      showSnackBar('Please check your internet connection');
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
          .then((_) => sendEmailConfirmation())
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
    args.add(this.pnrModel.pNR.rLOC);
    if (pnrModel.pNR.itinerary.itin
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
      print(e.toString());
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

  // Future<bool> _onBackPressed() {
  //   return true;
  //   //Navigator.pop(context, true);
  // }

  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator) {
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
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(_displayProcessingText),
              ),
            ],
          ),
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, true);
          return true as Future<bool>;
        },
        child: new Scaffold(
            key: _key,
            appBar: new AppBar(
              brightness: gblSystemColors.statusBar,
              backgroundColor:
              gblSystemColors.primaryHeaderColor,
              iconTheme: IconThemeData(
                  color:
                  gblSystemColors.headerTextColor),
              title: new Text('Payment',
                  style: TextStyle(
                      color: gblSystemColors
                          .headerTextColor)),
            ),
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
                                  Text(
                                    'Please complete your payment within ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  TimerText(
                                    stopwatch: stopwatch,
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
  Widget _getMiles() {
    Column col = new Column();
    if( gblRedeemingAirmiles == true && this.pnrModel.pNR != null) {
      var miles = this.pnrModel.pNR.basket.outstandingairmiles.airmiles;
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
   String cur = this.pnrModel.pNR.basket.outstanding.cur;
    String amount =   this.pnrModel.pNR.basket.outstanding.amount;
   var dAmount =double.parse(amount);
   if( dAmount <= 0 ) {
     dAmount = 0.0;
     amount = '0';
   }
    if( gblRedeemingAirmiles) {
      // get tax amount
      cur = this.pnrModel.pNR.basket.outstandingairmiles.cur;
      amount =   this.pnrModel.pNR.basket.outstandingairmiles.amount;
    }


     return Expanded(
      child: new SingleChildScrollView(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: new Form(
              key: formKey,
              child: new Column(children: [
                ExpansionTile(
                  initiallyExpanded: false,
                  title: Text(
                    'Total ' +
                        NumberFormat.simpleCurrency(
                            locale: GobalSettings
                                .shared.settings.locale,
                            name: cur)
                            .format((double.parse(amount) ??
                            0.0)),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  children: [
                    _passengers.adults != 0
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('No of adults: '),
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
                        Text('No of youths: '),
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
                        Text('No of children: '),
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
                        Text('No of infants: '),
                        Text(
                            _passengers.infants.toString()),
                      ],
                    )
                        : Padding(
                      padding: EdgeInsets.zero,
                    ),
                    Divider(),
                    flightSegementSummary(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
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
                        Text(
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
                ),
                Divider(),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Terms and Conditions'),
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
                ),
                Divider(),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Privacy Policy'),
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down),
                      onPressed: () => Navigator.push(
                          context,
                          SlideTopRoute(
                              page: WebViewWidget(
                                  title: 'Privacy Policy',
                                  url: gblSettings
                                      .privacyPolicyUrl))),
                    )
                  ],
                ),
                Divider(),
                 this.isMmb &&
                    amount == '0'
                    ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30.0))),
                  onPressed: () => completeBookingNothingtoPay(),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            this.isMmb ? 'AGREE AND MAKE CHANGES' : 'COMPLETE BOOKING',
                            style: new TextStyle(
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    : renderPaymentButtons()
                /* RaisedButton(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  /*PaymentWidget(
                                                    newBooking:
                                                        widget.newBooking,
                                                    pnrModel: pnrModel,
                                                    stopwatch: stopwatch,
                                                    mmbBooking:
                                                        widget.mmbBooking,
                                                    isMmb: this.isMmb,
                                                    session: widget.session,
                                                  ),*/
                                                  CreditCardPage())),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                'AGREE AND PAY',
                                                style: new TextStyle(
                                                    color: Colors.black),
                                              ),
                                              Image.asset(
                                                'lib/assets/images/payment/visa.png',
                                                height: 40,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(4),
                                              ),
                                              Image.asset(
                                                'lib/assets/images/payment/mastercard.png',
                                                height: 40,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ), */
              ]))),
    );
  }


  Column renderPaymentButtons() {
    List<Widget> paymentButtons = [];
    // List<Widget>();

    paymentButtons.add(Padding(
      padding: EdgeInsets.only(top: 8.0),
    ));
    paymentButtons.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreditCardPage(pnrModel: pnrModel, session: session, isMmb: isMmb, mmbAction: widget.mmbAction,))),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _getPayButton()
          ),
        ],
      ),
    ));

    if( gblSettings.wantPayStack == true) {
      paymentButtons.add(Padding(
        padding: EdgeInsets.only(top: 8.0),
      ));
      paymentButtons.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
        onPressed: () =>
            Paystack(context, pnrModel, session).load(), //Navigator.push(
        //context, MaterialPageRoute(builder: (context) => Paystack())),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'AGREE AND PAY',
                  style: new TextStyle(color: Colors.black),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
                Image.asset(
                  'lib/assets/images/payment/paystack.png',
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ));
    }
    return Column(children: paymentButtons);
  }
  List<Widget> _getPayButton() {
    List<Widget> list = [];

    if( widget.pnrModel.pNR.basket.outstanding
        .amount ==
        '0') {
      list.add(Text('COMPLETE BOOKING' ,
        style: new TextStyle(color: Colors.black),
      ));

    } else {
      list.add(Text( 'AGREE AND PAY',
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
  TimerText({this.stopwatch});
  final Stopwatch stopwatch;
  final double timerStart = 600000;

  TimerTextState createState() => new TimerTextState(stopwatch: stopwatch);
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  final Stopwatch stopwatch;

  TimerTextState({this.stopwatch}) {
    timer = new Timer.periodic(new Duration(seconds: 1), callback);
  }
  void callback(Timer timer) {
    if (widget.timerStart < stopwatch.elapsedMilliseconds) {
      print('expired');
      stopwatch.stop();
      Navigator.popUntil(context, ModalRoute.withName('/HomePage'));
      //(context) => HomePage();
/*      Navigator.of(context).pushNamedAndRemoveUntil(
          '/HomePage', (Route<dynamic> route) => false);

 */
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
