import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:vmba/FlightSelectionSummary/widgets/flightRules.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/controllers/vrsCommands.dart';

class FlightSelectionSummaryWidget extends StatefulWidget {
  FlightSelectionSummaryWidget(
      {Key key,
      //   this.newBooking,
      this.mmbBooking})
      : super(key: key);
  final MmbBooking mmbBooking;
  //final NewBooking newBooking;

  _FlightSelectionSummaryState createState() => _FlightSelectionSummaryState();
}

class _FlightSelectionSummaryState extends State<FlightSelectionSummaryWidget> {
  final formKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  PnrModel pnrModel = PnrModel();
  bool _loadingInProgress;
  String currencyCode;
  bool _noInternet;
  String _userErrorMessage;
  bool _hasError;

  @override
  initState() {
    super.initState();
    _loadingInProgress = true;
    _noInternet = false;
    //_eVoucherNotValid = false;
    _userErrorMessage = "";
    _hasError = false;
    getFareQuote();
  }

  retryBooking() {
    hasDataConnection().then((result) {
      if (result == true) {
        setState(() {
          _loadingInProgress = true;
          _noInternet = false;

          getFareQuote();
        });
      } else {
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
      }
    });
  }

  String convertNumberIntoWord(int number) {
    var _arrWordList = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen'
    ];
    return _arrWordList[number];
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //final _snackbar = snackbar(message);
    //_key.currentState.showSnackBar(_snackbar);
  }

  String buildCmd() {
    //Cancel journey
    Intl.defaultLocale = 'en';
    String cmd = '';
    cmd = '*${widget.mmbBooking.rloc}^';
    widget.mmbBooking.journeys.journey[widget.mmbBooking.journeyToChange - 1].itin.reversed
        .forEach((f) {
             cmd += 'X${f.line}^';
    });

    widget.mmbBooking.newFlights.forEach((flt) {
      int index = flt.indexOf('/');
      String bkFlt = flt.substring(0, index-3) + 'QQ' + flt.substring(index-1);
      print(bkFlt);
      cmd += bkFlt + '^';

//      print(flt.substring(0, 21) + 'QQ' + flt.substring(23));
  //    cmd += flt.substring(0, 21) + 'QQ' + flt.substring(23) + '^';
    });
/*
    widget.mmbBooking.newFlights.forEach((flt) {
      print(flt.substring(0, 21) + 'NN' + flt.substring(23));
      cmd += flt.substring(0, 21) + 'NN' + flt.substring(23) + '^';
    });
*/



    //Check if we have an interconnected flight and add marker if we do
    int flightLineNumber=-1;
    if(  gblBookingState == BookingState.changeFlt ) {
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
      flightLineNumber = getConnectingFlightLineIdentifier(widget.mmbBooking.journeys.journey[widget.mmbBooking.journeyToChange - 1]);
    }
    if (flightLineNumber >= 0){
      print("Journey has a connecting flight on itin($flightLineNumber)");
      cmd += '*r^.${flightLineNumber}x^';
    }

    cmd += addFg(widget.mmbBooking.currency, true);
    cmd += addFareStore(true);

    cmd += '*r~x';
//    cmd += 'E*r~x';
    print("flight selection cmd=$cmd");
    return cmd;
  }

  String displayUserErrorMessage(String responseError) {
    String msg = '${responseError.replaceAll('\r\nERROR: ', '')}';
    msg = '${responseError.replaceAll('\r\nERROR - ', '')}';
    if (responseError.contains('ERROR: E-VOUCHER ')) {
      msg = 'Your Promo code will no longer be valid for this booking. To make changes please contact customer services';
    }
    else if (responseError.contains('ERROR: CLASS BANDS ')) {
      msg = '${capitaliseFirstChar(msg)}. Please select an alternative class band';
    }
    else if (responseError.contains('ERROR: CANNOT FARE QUOTE ITINERARY ')) {
      msg = '${capitaliseFirstChar(msg)}.';
    }
    else if (responseError.contains('Server transaction timed out')){
      msg = 'The server is not currently responding. Please try again later';
    }
    else {
      //msg = 'We are unable to proceed with this request. To make changes please contact customer services';
      msg = '${capitaliseFirstChar(msg)}.';
    }
    return msg;
  }

  String capitaliseFirstChar(String data) {
    return "${data[0].toUpperCase()}${data.substring(1).toLowerCase()}";
  }
  int getConnectingFlightLine(List<String> newFlights) {
    int connectedLine = -1;
    if( newFlights.length > 1) return 0;

/*
    newFlights.forEach((flt) {
    });
*/
    return connectedLine;
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

  // String removeVoucher() {
  //   if (_eVoucherNotValid == true) {
  //     return '4X${widget.mmbBooking.eVoucher.line}^';
  //   } else {
  //     return '';
  //   }
  // }

  Future getFareQuote() async {
    Repository.get().getFareQuote(buildCmd()).then((rs) {

      if (rs.isOk()) {
        pnrModel = rs.body;
        setCurrencyCode();
        _dataLoaded();
      } else {
        setState(() {
          //_eVoucherNotValid = false;
          _loadingInProgress = false;
          _userErrorMessage = displayUserErrorMessage(rs.error);
          if (_userErrorMessage.isEmpty){
            _noInternet = true;
          }
          else {
            _hasError = true;
          }
        });
      }
    }).catchError((resp) {
      if (resp is FormatException) {
        String _error;

        FormatException ex = resp;
        print(ex.source.toString().trim());
        _error = ex.source.toString().trim();

        _userErrorMessage = displayUserErrorMessage(_error);
        setState(() {
          _loadingInProgress = false;
          _hasError = true;
        });
      }
    });
  }

  void setCurrencyCode() {
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
  }

  void _dataLoaded() {
    setState(() {
      _loadingInProgress = false;
    });
  }

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
        TrText('Total Tax: '),
        Text(formatPrice(currencyCode, tax)),
/*        Text(NumberFormat.simpleCurrency(
                locale: gblSettings.locale,
                name: currencyCode)
            .format(tax)),

 */
      ],
    );
  }

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
        TrText('Net Fare:'),
          Text(formatPrice(currencyCode,netFareTotal)),
/*        Text(NumberFormat.simpleCurrency(
                locale: gblSettings.locale,
                name: currencyCode)
            .format(netFareTotal)),

 */
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
          //total += double.tryParse(d.disc ?? 0.0);
          if( d.disc != null ) {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc ?? 0.0));
          }
        });
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TrText('Flights Total: '),
        Text(formatPrice(currencyCode,total)),

      ],
    );
  }

  Row discountTotal() {
    double total = 0.0;

    this.pnrModel.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          //total += double.tryParse(d.disc ?? 0.0);
          if( d.disc != null ) {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc ?? 0.0));
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
          Text(formatPrice(currencyCode,total)),
        ],
      );
    }
  }

  Row amountPayable() {
    var amount = this.pnrModel.pNR.basket.outstanding.amount;
    var dAmount =double.parse(amount);
    if( dAmount <= 0 ) {
      dAmount = 0.0;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          formatPrice(currencyCode,dAmount),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
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
            TrText(
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
            TrText('Flight No:'),
            Text(
                '${pnrModel.pNR.itinerary.itin[i].airID}${pnrModel.pNR.itinerary.itin[i].fltNo}')
          ],
        ),
      );
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TrText('Departure Time:'),
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
            TrText('Fare Type:'),
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
          taxTotal += (double.tryParse(paxTax.amnt) ?? 0.0);
        });
      }
      if (taxTotal != 0.0) {
        widgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TrText('Tax:'),
              Text(formatPrice(currencyCode,taxTotal)),
            ],
          ),
        );
      }

      widgets.add(Divider());
    }
    return Column(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress) {
      return Scaffold(
        appBar: new AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('Summary',
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
                child: new TrText("Calculating your price..."),
              ),
            ],
          ),
        ),
      );
    } else if (_noInternet) {
      return Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('Summary',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TrText('Please check your internet connection'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      primary: Colors.black),
                  onPressed: () => retryBooking(),
                  child: TrText(
                    'Retry booking',
                    style: new TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ));
    } else if (_hasError) {
      return Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('Summary',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _hasError
                      ? TrText(_userErrorMessage,
                          textAlign: TextAlign.center,
                        )
                      : TrText(
                          'We are unable to proceed with this request. To make changes please contact customer services',
                          textAlign: TextAlign.center,
                        ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      primary: Colors.black),
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: TrText(
                    'Return to My Bookings',
                    style: new TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ));
    } else {
      return new Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('Summary',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body: new Container(
              padding: EdgeInsets.all(16.0),
              child: new ListView(children: [
                widget.mmbBooking.passengers.adults != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(translate('No of ') + translate('Adults') + ': '),
                          Text(widget.mmbBooking.passengers.adults.toString()),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.mmbBooking.passengers.youths != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(translate('No of ') + translate('Youths') + ': '),
                          Text(widget.mmbBooking.passengers.youths.toString()),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.mmbBooking.passengers.children != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(translate('No of ') + translate('Children') + ': '),
                          Text(
                              widget.mmbBooking.passengers.children.toString()),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.mmbBooking.passengers.infants != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(translate('No of ') + translate('Infants') + ': '),
                          Text(widget.mmbBooking.passengers.infants.toString()),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.mmbBooking.passengers.seniors != 0
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(translate('No of ') + translate('Seniors') + ': '),
                    Text(widget.mmbBooking.passengers.seniors.toString()),
                  ],
                )
                    : Padding(
                  padding: EdgeInsets.zero,
                ),
                widget.mmbBooking.passengers.students != 0
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(translate('No of ') + translate('Students') + ': '),
                    Text(widget.mmbBooking.passengers.students.toString()),
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
                    TrText(
                      'Summary',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
                      'Amount payable',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                amountPayable(),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                Divider(),
                gblSettings.hideFareRules
                    ? Padding(
                        padding: EdgeInsets.only(top: 0),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TrText('Fare Rules'),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down),
                            onPressed: () => Navigator.push(
                                context,
                                SlideTopRoute(
                                    page: FlightRulesWidget(
                                  fQItin: pnrModel.pNR.fareQuote.fQItin,
                                  itin: pnrModel.pNR.itinerary.itin,
                                ))),
                          )
                        ],
                      ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary:
                      gblSystemColors.primaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                  onPressed: () {
                    hasDataConnection().then((result) async {
                      if (result == true) {
/*
                        if( gblSettings.wantNewPayment) {
                          await saveChanges(context);
                        }
*/
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChoosePaymenMethodWidget(
                                      mmbBooking: widget.mmbBooking,
                                      pnrModel: pnrModel,
                                      isMmb: true,
                                      mmbAction: 'CHANGEFLT',
                                      mmbCmd: '',
                                    )));
                      } else {
                        //showSnackBar(translate('Please,, check your internet connection'));
                        noInternetSnackBar(context);
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: gblSystemColors
                            .primaryButtonTextColor,
                      ),
                      TrText(
                        'CONFIRM CHANGES',
                        style: TextStyle(
                          color: gblSystemColors
                              .primaryButtonTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ])));
    }
  }
}
