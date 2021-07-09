import 'package:flutter/material.dart';
import 'package:vmba/FlightSelectionSummary/widgets/flightRules.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/passengerDetails/passengerDetailsPage.dart';
import 'package:vmba/utilities/helper.dart';
import '../data/models/models.dart';
import 'dart:async';
import '../data/models/pnr.dart';
import 'package:intl/intl.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import '../data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class FlightSelectionSummaryWidget extends StatefulWidget {
  FlightSelectionSummaryWidget({Key key, this.newBooking}) : super(key: key);

  final NewBooking newBooking;

  _FlightSelectionSummaryState createState() => _FlightSelectionSummaryState();
}

class _FlightSelectionSummaryState extends State<FlightSelectionSummaryWidget> {
  final formKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  PnrModel pnrModel = PnrModel();
  bool _loadingInProgress;
  String currencyCode;
  bool _noInternet;
  bool _eVoucherNotValid;
  bool _hasError;
  String _error ;
  var miles = 0;

  @override
  initState() {
    super.initState();
    _loadingInProgress = true;
    _noInternet = false;
    _eVoucherNotValid = false;
    _hasError = false;
    _error = 'We are unable to proceed with this request. Please contact customer services to make your booking';
    getFareQuote();

    /*
  for ( FQItin fqi in  this.pnrModel.pNR.fareQuote.fQItin) {
          miles =  miles + int.tryParse(fqi.miles) ?? 0;
    };

     */

  }

  String buildAddPaxCmd() {
    StringBuffer sb = new StringBuffer();

    for (var adults = 1;
        adults < widget.newBooking.passengers.adults + 1;
        adults++) {
      sb.write("-TTTT${convertNumberIntoWord(adults)}/AdultMr^");
    }
    for (var youths = 1;
        youths < widget.newBooking.passengers.youths + 1;
        youths++) {
      sb.write("-TTTT${convertNumberIntoWord(youths)}/YouthMr.TH15^");
    }
    for (var child = 1;
        child < widget.newBooking.passengers.children + 1;
        child++) {
      sb.write("-TTTT${convertNumberIntoWord(child)}/ChildMr.CH10^");
    }
    for (var infant = 1;
        infant < widget.newBooking.passengers.infants + 1;
        infant++) {
      sb.write("-TTTT${convertNumberIntoWord(infant)}/infantMr.IN^");
    }

    return sb.toString();
  }

  String buildADSCmd() {
    StringBuffer sb = new StringBuffer();
    String paxNo = '1';
    if (this.widget.newBooking.ads.pin != null && this.widget.newBooking.ads.pin != '' &&
        this.widget.newBooking.ads.number != null && this.widget.newBooking.ads.number != '') {
      sb.write(
          '4-${paxNo}FADSU/${this.widget.newBooking.ads.number}/${this.widget.newBooking.ads.pin}^');
    }
    return sb.toString();
  }

  retryBooking() {
    hasDataConnection().then((result) {
      if (result == true) {
        setState(() {
          _loadingInProgress = true;
          _noInternet = false;
          _eVoucherNotValid = false;
          getFareQuote();
        });
      } else {
        showSnackBar('Please check your internet connection');
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
    //final _snackbar = snackbar(message);
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //_key.currentState.showSnackBar(_snackbar);
  }

  String buildCmd() {
    String cmd;
    cmd = buildAddPaxCmd();
    cmd += buildADSCmd();
    widget.newBooking.outboundflight.forEach((flt) {
      print(flt.substring(0, 21) + 'QQ' + flt.substring(23));
      cmd += flt.substring(0, 21) + 'QQ' + flt.substring(23) + '^';
    });

    widget.newBooking.returningflight.forEach((flt) {
      print(flt.substring(0, 21) + 'QQ' + flt.substring(23));
      cmd += flt.substring(0, 21) + 'QQ' + flt.substring(23) + '^';
    });

    //Add connecting indicators for outbound and return flights
    if (widget.newBooking.outboundflight.length > 1) {
      for (var i = 1; i < widget.newBooking.outboundflight.length; i++) {
        print('.${i}x^');
        cmd += '.${i}x^';
      }
    }

    if (widget.newBooking.returningflight.length > 1) {
      for (var i = widget.newBooking.outboundflight.length + 1;
          i <
              widget.newBooking.outboundflight.length +
                  widget.newBooking.returningflight.length;
          i++) {
        print('.${i}x^');
        cmd += '.${i}x^';
      }
    }

    //Add voucher code
    if (widget.newBooking.eVoucherCode != null &&
        widget.newBooking.eVoucherCode.trim() != '') {
      cmd += '4-1FDISC${widget.newBooking.eVoucherCode.trim()}^';
    }

    cmd += 'fg^fs1^*r~x';
    print('buildCmd: ' + cmd);
    return cmd;
  }

  Future getFareQuote() async {
    Repository.get().getFareQuote(buildCmd()).then((rs) {
      if (rs.isOk()) {
        pnrModel = rs.body;
        setCurrencyCode();
        if ( gblRedeemingAirmiles == true ) {
          miles =
              int.tryParse(this.pnrModel.pNR.basket.outstandingairmiles.airmiles) ??
                  0;
          if (gblFqtvBalance < miles) {
            setState(() {
              _loadingInProgress = false;
              _eVoucherNotValid = false;
              _hasError = true;
              _error =
              'You do not have enough ${gblSettings.fQTVpointsName} to pay for this booking\n Balance = $gblFqtvBalance, ${gblSettings.fQTVpointsName} required = $miles';
            });
          }
        }
        _dataLoaded();
      } else {
        setState(() {
          _loadingInProgress = false;
          _noInternet = true;
        });
      }
    }).catchError((resp) {
      if (resp is FormatException) {
        String _error;
        FormatException ex = resp;
        print(ex.source.toString().trim());
        _error = ex.source.toString().trim();
        if (_error.contains('ERROR: E-VOUCHER ')) {
          setState(() {
            _loadingInProgress = false;
            _eVoucherNotValid = true;
          });
        } else {
          setState(() {
            _loadingInProgress = false;
            _eVoucherNotValid = false;
            _hasError = true;
          });
        }

        // setState(() {
        //   _loadingInProgress = false;
        //   _eVoucherNotValid = true;
        // });
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

  Widget taxTotal() {
    double tax = 0.0;
    double sepTax1 = 0.0;


    List <Row> rows = [];

    if (this.pnrModel.pNR.fareQuote.fareTax != null) {
      this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        if(  paxTax.separate == 'true'){
            sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
        } else {
          tax += (double.tryParse(paxTax.amnt) ?? 0.0);
        }
      });
    }
    rows.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Total Tax: '),
        Text(formatPrice(currencyCode,tax)),
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
          Text(formatPrice(currencyCode,sepTax1)),
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
Row airMiles() {



    return  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text('${gblSettings.fqtvName}' + translate( ' Required points')),
      Text('$miles'),
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
        Text('Net Fare:'),
        Text(formatPrice(currencyCode,netFareTotal)),
/*
        Text(NumberFormat.simpleCurrency(
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
          d.disc
              .split(',')
              .forEach((disc) => total += double.tryParse(disc ?? 0.0));
          // total += double.tryParse(d.disc ?? 0.0);
        });
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Flights Total: '),
        Text(formatPrice(currencyCode,total)),
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
          Text(formatPrice(currencyCode,total)),
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

  Row amountPayable() {
    FareStore fareStore = this
          .pnrModel
          .pNR
          .fareQuote
          .fareStore
          .where((fareStore) => fareStore.fSID == 'Total')
          .first;

    var amount = fareStore.total;
    if( double.parse(amount) <= 0 ) {
      amount = "0";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          formatPrice(currencyCode,double.tryParse(amount) ?? 0.0),
/*
          NumberFormat.simpleCurrency(
                  locale: gblSettings.locale,
                  name: currencyCode)
              .format((double.tryParse(amount) ?? 0.0)),

 */

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
      if (taxTotal != 0.0) {
        widgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Tax:'),
              Text(formatPrice(currencyCode,taxTotal)),
/*
              Text(NumberFormat.simpleCurrency(
                      locale: gblSettings.locale,
                      name: currencyCode)
                  .format(taxTotal)),

 */
            ],
          ),
        );
      }

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
              Text(formatPrice(currencyCode,sepTax1)),
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
          brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new Text('Summary',
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
                child: new Text("Calculating your price..."),
              ),
            ],
          ),
        ),
      );
    } else if (_noInternet) {
      return Scaffold(
          key: _key,
          appBar: new AppBar(
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new Text('Summary',
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
                  child: Text('Please check your internet connection'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      primary: Colors.black),
                  onPressed: () => retryBooking(),
                  child: Text(
                    'Retry booking',
                    style: new TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ));
    } else if (_eVoucherNotValid || _hasError) {
      return Scaffold(
          key: _key,
          appBar: new AppBar(
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new Text('Summary',
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
                  child: _eVoucherNotValid
                      ? Text('Promo code not vaild')
                      : Text( _error                          ,
                          textAlign: TextAlign.center,
                        ),
                ),
                _eVoucherNotValid
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            primary: Colors.black),
                        onPressed: () {
                          widget.newBooking.eVoucherCode = '';
                          retryBooking();
                        },
                        child: Text(
                          'Remove and retry booking',
                          style: new TextStyle(color: Colors.white),
                        ),
                      )
                    :               ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      primary: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/FlightSearchPage', (Route<dynamic> route) => false);
                    },
                    child: Text('Restart booking',
                    style: new TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ));
    } else {
      return new Scaffold(
          key: _key,
          appBar: new AppBar(
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new Text('Summary',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body: new Container(
              padding: EdgeInsets.all(16.0),
              child: new ListView(children: [
                widget.newBooking.passengers.adults != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('No of adults: '),
                          Text(widget.newBooking.passengers.adults.toString()),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.newBooking.passengers.youths != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('No of youths: '),
                          Text(widget.newBooking.passengers.youths.toString()),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.newBooking.passengers.children != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('No of children: '),
                          Text(
                              widget.newBooking.passengers.children.toString()),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.newBooking.passengers.infants != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('No of infants: '),
                          Text(widget.newBooking.passengers.infants.toString()),
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
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                ( gblRedeemingAirmiles == true ) ?
                  airMiles() : netFareTotal(),
                taxTotal(),
                ( gblRedeemingAirmiles != true ) ?
                grandTotal() : Column(),
                discountTotal(),
                Divider(),
                ( gblRedeemingAirmiles != true ) ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Amount payable',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ) : Column(),
                ( gblRedeemingAirmiles != true ) ? amountPayable() : Column(),
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
                          Text('Fare Rules'),
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
                      primary: gblSystemColors
                          .primaryButtonColor, //Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                  onPressed: () {
                    hasDataConnection().then((result) {
                      if (result == true) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PassengerDetailsWidget(
                                    newBooking: widget.newBooking)));
                      } else {
                        showSnackBar('Please check your internet connection');
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      Text(
                        'CONTINUE',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ])));
    }
  }
}
