import 'package:flutter/material.dart';
import 'package:vmba/FlightSelectionSummary/widgets/flightRules.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/passengerDetails/passengerDetailsPage.dart';
import 'package:vmba/utilities/helper.dart';
import '../Helpers/stringHelpers.dart';
import '../calendar/flightPageUtils.dart';
import '../components/bottomNav.dart';
import '../components/vidButtons.dart';
import '../data/models/models.dart';
import 'dart:async';
import '../data/models/pnr.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import '../data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/controllers/vrsCommands.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/utilities/messagePages.dart';

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
  bool _tooManyUmnr;
  bool _hasError;
  String _error ;
  var miles = 0;

  @override
  initState() {
    super.initState();
    _loadingInProgress = true;
    _noInternet = false;
    _eVoucherNotValid = false;
    _tooManyUmnr = false;
    _hasError = false;
    _error = null;
    gblError = null;
    gblCurPage = 'FLIGHTSEARCH';
    _error = 'We are unable to proceed with this request. Please contact customer services to make your booking';
    getFareQuote();

    // save some stuff
    gblDestination = widget.newBooking.arrival;
    gblOrigin = widget.newBooking.departure;

    /*
  for ( FQItin fqi in  this.pnrModel.pNR.fareQuote.fQItin) {
          miles =  miles + int.tryParse(fqi.miles) ?? 0;
    };

     */

  }

  String buildAddPaxCmd() {
    StringBuffer sb = new StringBuffer();

    if( gblSettings.useWebApiforVrs) {
     sb.write('I^');
    }

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
    for (var seniors = 1;
        seniors < widget.newBooking.passengers.seniors + 1;
        seniors++) {
      sb.write("-TTTT${convertNumberIntoWord(seniors)}/SeniorMr.CD^");
    }
    for (var students = 1;
          students < widget.newBooking.passengers.students + 1;
          students++) {
      sb.write("-TTTT${convertNumberIntoWord(students)}/StudentMr.SD^");
    }
    for (var child = 1;
        child < widget.newBooking.passengers.children + 1;
        child++) {
      sb.write("-TTTT${convertNumberIntoWord(child)}/ChildMr.CH10^");
    }
    for (var infant = 1;
        infant < widget.newBooking.passengers.infants + 1;
        infant++) {
      sb.write("-TTTT${convertNumberIntoWord(infant)}/infantMr.IN09^");
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
          _tooManyUmnr = false;
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
    //final _snackbar = snackbar(message);
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //_key.currentState.showSnackBar(_snackbar);
  }

  String buildCmd() {
    String cmd;
    cmd = buildAddPaxCmd();
    cmd += buildADSCmd();
    widget.newBooking.outboundflight.forEach((flt) {
      int index = flt.indexOf('/');
      String bkFlt = flt.substring(0, index-3) + 'QQ' + flt.substring(index-1);
      print(bkFlt);
      cmd += bkFlt + '^';
      //print(flt.substring(0, 21) + 'QQ' + flt.substring(23));
      //cmd += flt.substring(0, 21) + 'QQ' + flt.substring(23) + '^';
    });

    widget.newBooking.returningflight.forEach((flt) {
      int index = flt.indexOf('/');
      String bkFlt = flt.substring(0, index-3) + 'QQ' + flt.substring(index-1);
      print(bkFlt);
      cmd += bkFlt + '^';
   //   print(flt.substring(0, 21) + 'QQ' + flt.substring(23));
   //   cmd += flt.substring(0, 21) + 'QQ' + flt.substring(23) + '^';
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
    cmd += addFg(widget.newBooking.currency, true);
    cmd += addFareStore(true);
    cmd += '*r~x';
//    cmd += 'fg^fs1^*r~x';
    logit('getFareQuote2: ' + cmd);
    return cmd;
  }

  Future getFareQuote() async {
    gblPayable = '';

    Repository.get().getFareQuote(buildCmd()).then((rs) {
      if (rs.isOk()) {
        pnrModel = rs.body;
        setCurrencyCode();
        if (gblRedeemingAirmiles == true) {
          miles =
              int.tryParse(
                  this.pnrModel.pNR.basket.outstandingairmiles.airmiles) ??
                  0;
          if (gblFqtvBalance < miles) {
            setState(() {
              _loadingInProgress = false;
              endProgressMessage();

              _eVoucherNotValid = false;
              _tooManyUmnr = false;
              _hasError = false;
              _error =
              'You do not have enough ${gblSettings
                  .fQTVpointsName} to pay for this booking\nBalance = $gblFqtvBalance, \n${gblSettings
                  .fQTVpointsName} required = $miles';
              gblError = _error;
              gblErrorTitle = 'Booking Error';
            });
          }
        }
        _dataLoaded();
      } else if (rs.statusCode == 0) {
        _error = rs.error;
        _hasError = true;
        setState(() {
          _loadingInProgress = false;
          endProgressMessage();

        });
      } else {
        setState(() {
          _loadingInProgress = false;
          endProgressMessage();

          _noInternet = true;
        });
      }
    }).catchError((resp) {
      logit('catchError1: $resp');
      if (resp is FormatException) {
        //String _error;
        FormatException ex = resp;
        print(ex.source.toString().trim());
        _error = ex.source.toString().trim();
        if (_error.contains('ERROR: E-VOUCHER ')) {
          setState(() {
            _loadingInProgress = false;
            endProgressMessage();

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
            endProgressMessage();

            _eVoucherNotValid = false;
            _hasError = true;
          });
        }

        // setState(() {
        //   _loadingInProgress = false;
        //   _eVoucherNotValid = true;
        // });
      }
      else {
        _error = resp;
        _loadingInProgress = false;
        endProgressMessage();

        _hasError = true;
        setState(() {});
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
      //endProgressMessage();

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
        TrText('Total Tax: '),
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
        TrText('Net Fare:'),
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
          if (d.disc != null ) {
            if( d.disc != null ) {
              d.disc
                  .split(',')
                  .forEach((disc) => total += double.tryParse(disc ?? 0.0));
              // total += double.tryParse(d.disc ?? 0.0);
            }
          }
        });

      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TrText('Flights Total: '),
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
    String price = formatPrice(currencyCode,double.tryParse(amount) ?? 0.0);
    if( gblPayable != price) {
      gblPayable = price;
      setState(() {

      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(price,
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
                return new Text(translate(text.data),
                    style: TextStyle(fontWeight: FontWeight.w700));
              },
            ),
            Text(
              ' ' + translate('to') + ' ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            FutureBuilder(
              future: cityCodeToName(
                pnrModel.pNR.itinerary.itin[i].arrive,
              ),
              initialData: pnrModel.pNR.itinerary.itin[i].arrive.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return new Text(
                  translate(text.data),
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
            Text(getIntlDate('dd MMM kk:mm',DateTime.parse(
                pnrModel.pNR.itinerary.itin[i].depDate +
                    ' ' +
                    pnrModel.pNR.itinerary.itin[i].depTime)))
          ],
        ),
      );



/*
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
*/
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TrText('Fare Type:'),
            Text(pnrModel.pNR.itinerary.itin[i].classBandDisplayName ==
                    'Fly Flex Plus'
                ? 'Fly Flex +'
                : translate(pnrModel.pNR.itinerary.itin[i].classBandDisplayName))
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
              TrText('Tax:'),
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
      if( gblSettings.wantCustomProgress) {
        progressMessagePage(
            context, 'Calculating your price...', title: 'Summary');
        return Container();
      } else {
        return Scaffold(
          appBar: appBar(context, 'Summary',
            newBooking: widget.newBooking,
            curStep: 3,
            imageName: gblSettings.wantPageImages ? 'flightSummary' : null,),
          extendBodyBehindAppBar: gblSettings.wantPageImages,
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
      }
    } else if (_noInternet) {
      return Scaffold(
          key: _key,
          appBar: appBar(context, 'Summary',
            curStep: 3,
            newBooking: widget.newBooking,
            imageName: gblSettings.wantPageImages ? 'flightSummary' : null,) ,
          extendBodyBehindAppBar: gblSettings.wantPageImages,
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
                  child: Text(
                    'Retry booking',
                    style: new TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ));
    } else if (_eVoucherNotValid || _tooManyUmnr || _hasError) {
      return Scaffold(
          key: _key,
          appBar: appBar(context, 'Summary',
            curStep: 3,
            newBooking: widget.newBooking,
            imageName: gblSettings.wantPageImages ? 'flightSummary' : null,),
          extendBodyBehindAppBar: gblSettings.wantPageImages,
          endDrawer: DrawerMenu(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _eVoucherNotValid
                      ? TrText('Promo code not vaild')
                      : Text(_error,
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
                  child: TrText(
                    'Remove and retry booking',
                    style: new TextStyle(color: Colors.white),
                  ),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      primary: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/FlightSearchPage', (Route<dynamic> route) => false);
                  },
                  child: TrText('Restart booking',
                    style: new TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ));
    } else if (_error != null && _error.isNotEmpty) {
      return criticalErrorPageWidget( context, _error,title: 'Booking Error', onComplete:  onComplete);
    } else {
      List<Widget> list = [];

      if(gblSettings.wantButtonIcons) {
        list.add(Icon(
          Icons.check,
          color: Colors.white,
        ));
      }
        list.add(TrText(
          'CONTINUE',
          style: TextStyle(color: Colors.white),
        ));


      return new Scaffold(
          key: _key,
          appBar: appBar(context, 'Summary',
            curStep: 3,
            newBooking: widget.newBooking,
            imageName: gblSettings.wantPageImages ? 'flightSummary' : null,) ,
          //extendBodyBehindAppBar: gblSettings.wantCityImages,
          endDrawer: DrawerMenu(),
          bottomNavigationBar: getBottomNav(context),
          body: new Container(
              padding: EdgeInsets.all(16.0),
              child: new ListView(children: [
                widget.newBooking.passengers.adults != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(translate('No of ') + translate('Adults') + ': '),
                          Text(translateNo(widget.newBooking.passengers.adults.toString())),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.newBooking.passengers.youths != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(translate('No of ') + translate('Youths') + ': '),
                          Text(translateNo(widget.newBooking.passengers.youths.toString())),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.newBooking.passengers.students != 0
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(translate('No of ') + translate('Students') + ': '),
                    Text(translateNo(widget.newBooking.passengers.students.toString())),
                  ],
                )
                    : Padding(
                  padding: EdgeInsets.zero,
                ),
                widget.newBooking.passengers.seniors != 0
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(translate('No of ') + translate('Seniors') + ': '),
                    Text(translateNo(widget.newBooking.passengers.seniors.toString())),
                  ],
                )
                    : Padding(
                  padding: EdgeInsets.zero,
                ),
                widget.newBooking.passengers.children != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TrText('No of children: '),
                          Text(
                            translateNo(widget.newBooking.passengers.children.toString())),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
                widget.newBooking.passengers.infants != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(translate('No of ') + translate('Infants') +': '),
                          Text(translateNo(widget.newBooking.passengers.infants.toString())),
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
                    TrText(
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
                      primary: gblSystemColors
                          .primaryButtonColor, //Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: getButtonRadius())),
                  onPressed: () {
                    hasDataConnection().then((result) {
                      if (result == true) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PassengerDetailsWidget(
                                    newBooking: widget.newBooking)));
                      } else {
                        //showSnackBar(translate('Please, check your internet connection'));
                        noInternetSnackBar(context);
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: list,
                  ),
                ),
              ])));
    }
  }

  void onComplete (dynamic p) {
      _error = null;
      setState(() {});
      Navigator.of(context).pop();
  }
}
