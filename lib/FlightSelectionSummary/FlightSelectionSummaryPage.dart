import 'package:flutter/material.dart';
import 'package:vmba/FlightSelectionSummary/widgets/flightRules.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/passengerDetails/passengerDetailsPage.dart';
import 'package:vmba/utilities/helper.dart';
import '../Helpers/stringHelpers.dart';
import '../calendar/flightPageUtils.dart';
import '../components/bottomNav.dart';
import '../components/pageStyleV2.dart';
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

import '../utilities/navigation.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import '../v3pages/controls/V3Constants.dart';
import '../v3pages/v3Theme.dart';

class FlightSelectionSummaryWidget extends StatefulWidget {
//  FlightSelectionSummaryWidget({Key key = GlobalKey(), this.newBooking }) : super(key: key);
  FlightSelectionSummaryWidget({Key key = const Key("flt_key"), required this.newBooking  }) : super(key: key);

  final NewBooking newBooking;

  _FlightSelectionSummaryState createState() => _FlightSelectionSummaryState();
}

class _FlightSelectionSummaryState extends State<FlightSelectionSummaryWidget> {
  final formKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  PnrModel pnrModel = PnrModel();
  bool _loadingInProgress = false;
  String currencyCode = '';
  //bool _noInternet = false;
  bool _eVoucherNotValid = false;
  bool _tooManyUmnr = false;
  bool _hasError = false;
  String _error = '';
  var miles = 0;

  @override
  initState() {
    super.initState();
    commonPageInit('SUMMARY');

    _loadingInProgress = true;
    //_noInternet = false;
    _eVoucherNotValid = false;
    _tooManyUmnr = false;
    _hasError = false;
    gblActionBtnDisabled = false;
    _error = '';

    // _error = 'We are unable to proceed with this request. Please contact customer services to make your booking';
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
    if (this.widget.newBooking.ads.pin != ''  && this.widget.newBooking.ads.number != '') {
      sb.write(
          '4-${paxNo}FADSU/${this.widget.newBooking.ads.number}/${this.widget.newBooking.ads.pin}^');
    }
    return sb.toString();
  }

  /*retryBooking() {
    hasDataConnection().then((result) {
      if (result == true) {
        setState(() {
          _loadingInProgress = true;
          //_noInternet = false;
          _eVoucherNotValid = false;
          _tooManyUmnr = false;
          getFareQuote();
        });
      } else {
        //noInternetSnackBar(context);
      }
    });
  }*/

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
    if (widget.newBooking.eVoucherCode.trim() != '') {
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
        pnrModel = rs.body!;
        setCurrencyCode();
        if (gblRedeemingAirmiles == true) {
          miles =
              int.tryParse(
                  this.pnrModel.pNR.basket.outstandingairmiles.airmiles) ??
                  0;
          endProgressMessage();
          if (gblFqtvBalance < miles) {
            setState(() {
              _loadingInProgress = false;


              _eVoucherNotValid = false;
              _tooManyUmnr = false;
              _hasError = false;
              _error =
              'You do not have enough ${gblSettings
                  .fQTVpointsName} to pay for this booking\nBalance = $gblFqtvBalance, \n${gblSettings
                  .fQTVpointsName} required = $miles';
              setError( _error);
              gblErrorTitle = 'Booking Error';
            });
          }
        } else {
          endProgressMessage();
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

          //_noInternet = true;
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


    List <Widget> rows = [];

   // if (this.pnrModel.pNR.fareQuote.fareTax != null) {
      this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        if(  paxTax.separate == 'true'){
            sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
        } else {
          tax += (double.tryParse(paxTax.amnt) ?? 0.0);
        }
      });
    //}
    rows.add( V3ItemPriceRow('Total Tax: ', currencyCode,tax) );

    if( sepTax1 > 0) {
      rows.add(V3ItemPriceRow('Additional Item(s) ',currencyCode,sepTax1));
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

 //   if (this.pnrModel.pNR.fareQuote.fareTax != null) {
      this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        tax += (double.tryParse(paxTax.amnt) ?? 0.0);
      });
   // }

    double netFareTotal = total - tax;

    return V3ItemPriceRow('Net Fare:',currencyCode,netFareTotal);
  }

  Row grandTotal() {
    double total = 0.0;

    this.pnrModel.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          total += double.tryParse(d.fare) as double;
          total += double.tryParse(d.tax1) as double;
          total += double.tryParse(d.tax2) as double;
          total += double.tryParse(d.tax3) as double;
            if( d.disc != '' ) {
              d.disc
                  .split(',')
                  .forEach((disc) {
                    if( disc != '' ) {
                      total += double.tryParse(disc) as double;
                    }
                  }
              );

              // total += double.tryParse(d.disc ?? 0.0);
            }

        });

      }
    });

    return V3ItemPriceRow('Flights Total: ',currencyCode,total);
  }

  Row discountTotal() {
    double total = 0.0;

    this.pnrModel.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          if( d.disc != '') {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc) as double);
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
      String arCode = pnrModel.pNR.itinerary.itin[i].arrive;
      String deCode = pnrModel.pNR.itinerary.itin[i].depart;
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(cityCodetoAirport(deCode),style: TextStyle(fontWeight: FontWeight.w700) ),
            /*FutureBuilder(
              future: cityCodeToName(
                deCode,
              ),
              initialData: deCode.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                String lName = deCode;
                if( text.data != null ) lName = text.data as String;
                return new Text(translate(lName ),
                    style: TextStyle(fontWeight: FontWeight.w700));
              },
            ),*/
            Text(
              ' ' + translate('to') + ' ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(cityCodetoAirport(arCode),style: TextStyle(fontWeight: FontWeight.w700) ),
/*
            FutureBuilder(
              future: cityCodeToName(
                arCode,
              ),
              initialData: arCode.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                String lName = arCode;
                if( text.data != null ) lName = text.data  as String;
                return new Text(
                  translate(lName),
                  style: TextStyle(fontWeight: FontWeight.w700),
                );
              },
            ),
*/
          ],
        ),
      );
      widgets.add(Padding(padding: EdgeInsets.all(5)));
      widgets.add(V3ItemRow('Flight No:','${pnrModel.pNR.itinerary.itin[i].airID}${pnrModel.pNR.itinerary.itin[i].fltNo}'));

      widgets.add(V3ItemRow('Departure Time:',
            getIntlDate('dd MMM kk:mm',DateTime.parse(
                pnrModel.pNR.itinerary.itin[i].depDate + ' ' +
                    pnrModel.pNR.itinerary.itin[i].depTime))));

      widgets.add(V3ItemRow('Fare Type:',
          pnrModel.pNR.itinerary.itin[i].classBandDisplayName ==
                    'Fly Flex Plus'
                ? 'Fly Flex +'
                : translate(pnrModel.pNR.itinerary.itin[i].classBandDisplayName)));

      double taxTotal = 0.0;

 //     if (this.pnrModel.pNR.fareQuote.fareTax != null) {
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
  //    }
      if (taxTotal != 0.0) {
        widgets.add(V3ItemPriceRow('Tax:',currencyCode,taxTotal));
      }

      double sepTax1 = 0.0;
      String desc1 = '';

 //     if (this.pnrModel.pNR.fareQuote.fareTax != null) {
        this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
          if(  paxTax.separate == 'true' && paxTax.seg == (i + 1).toString()){ //
            if( desc1 == '' || desc1 == paxTax.desc) {
              desc1 = paxTax.desc;
              sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
            }
          }
        });
 //     }
      if (sepTax1 != 0.0) {
        widgets.add(V3ItemPriceRow(desc1,currencyCode,sepTax1));
      }


      widgets.add(V3Divider());
    }
    return Container(
        decoration: containerDecoration( location: 'middle') ,
        margin: containerMargins(location: 'middle') ,
/*
        padding:(wantHomePageV3()) ? null : EdgeInsets.only(left: 16.0, right: 16.0, top: 5),
*/
        child: Column(
      children: widgets,
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress && gblInRefreshing == false) {
      if( gblSettings.wantCustomProgress) {
        return getProgressMessage('Calculating your price...', 'Summary');
      } else {
        return Scaffold(
          appBar: appBar(context, 'Summary', PageEnum.summary,
            newBooking: widget.newBooking,
            curStep: 3,
            imageName: gblSettings.wantPageImages ? 'flightSummary' : '',),
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

    } else if (_eVoucherNotValid || _tooManyUmnr || _hasError) {
      return Scaffold(
          key: _key,
          appBar: appBar(context, 'Summary',PageEnum.summary,
            curStep: 3,
            newBooking: widget.newBooking,
            imageName: gblSettings.wantPageImages ? 'flightSummary' : '',),
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
                      foregroundColor: Colors.black),
                  onPressed: () {
                    widget.newBooking.eVoucherCode = '';
                    //retryBooking();
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
                      foregroundColor: Colors.black),
                  onPressed: () {
                    navToFlightSearchPage(context);
/*
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/FlightSearchPage', (Route<dynamic> route) => false);
*/
                  },
                  child: TrText('Restart booking',
                    style: new TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ));
    } else if (_error != '' && _error.isNotEmpty) {
      return criticalErrorPageWidget( context, _error,title: 'Booking Error', onComplete:  onComplete);
    } else {

      return new Scaffold(
          key: _key,
          appBar: appBar(context, 'Summary',PageEnum.summary,
            curStep: 3,
            newBooking: widget.newBooking,
            imageName: gblSettings.wantPageImages ? 'flightSummary' : '',) ,
          //extendBodyBehindAppBar: gblSettings.wantCityImages,
          endDrawer: DrawerMenu(),
          bottomNavigationBar: getBottomNav(context),
          body: _getBody(),
          floatingActionButton: /*(wantPageV2() || wantHomePageV3()) ? */vidWideActionButton(context,'Continue', onCompletePressed, icon: Icons.check, offset: 35.0 ) /*: null*/,
      );

    }
  }
  onCompletePressed(BuildContext context, dynamic p) {
    //hasDataConnection().then((result) {
      if (gblNoNetwork == false) {
        Navigator.push(
            context,
           // MaterialPageRoute(
            CustomPageRoute(
                builder: (context) => PassengerDetailsWidget(
                    newBooking: widget.newBooking)));
      }
  }

  Widget _getBody() {
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

    if( wantPageV2()) {
        Widget peopleList ;
        peopleList =
            Container(
                decoration: containerDecoration( location: 'top') ,
                margin: containerMargins(location: 'top') ,
                padding: EdgeInsets.all(16.0),
                child: Column(
                    children: [
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
            ]
            )
            );
              //Divider(),


      return ListView(
        children: [
            peopleList,
            flightSegementSummary(),
          bookingSummary(),
          Padding(padding: EdgeInsets.all(35)),
     //     Container(height: 30,),
    //     Spacer(),
    //      Divider(height: 2.0, thickness: 2.0, color: Colors.blue,),
        ]
        ,
      );
    }



    return new Container(
        decoration: containerDecoration() ,
        margin: containerMargins() ,
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
          V3Divider(),
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
              Padding(padding: EdgeInsets.all(5)),
          ( gblRedeemingAirmiles == true ) ?
          airMiles() : netFareTotal(),
          taxTotal(),
          ( gblRedeemingAirmiles != true ) ?
          grandTotal() : Column(),
          discountTotal(),
          V3Divider(),
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
          V3Divider(),
          gblSettings.hideFareRules
              ? Padding(
            padding: EdgeInsets.only(top: 0),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TrText('Fare Rules'),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  if( gblNoNetwork == false ) {
                    Navigator.push(
                        context,
                        SlideTopRoute(
                            page: FlightRulesWidget(
                              fQItin: pnrModel.pNR.fareQuote.fQItin,
                              itin: pnrModel.pNR.itinerary.itin,
                            )));
                  }

                }
              )
            ],
          ),
      /*    ( wantHomePageV3()) ? Container() :
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                //foregroundColor: gblSystemColors.primaryButtonColor, //Colors.black,
                backgroundColor: gblSystemColors.primaryButtonColor, //Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: getButtonRadius())),
            onPressed: () {
                if (gblNoNetwork == false) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PassengerDetailsWidget(
                              newBooking: widget.newBooking)));
                }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: list,
            ),
          ),*/
        ]));
  }

Widget bookingSummary() {
    return Container(
        decoration: containerDecoration( location: 'middle') ,
        margin: containerMargins(location: 'middle') ,
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 5),
        child: Column(
      children: [
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
        V3Divider(),
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
  /*Padding(
  padding: EdgeInsets.only(top: 5),
  ),
  Divider(),*/
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
  )
  ]
  )
    );
}

  void onComplete (dynamic p) {
      _error = '';
      setState(() {});
      Navigator.of(context).pop();
  }
}
