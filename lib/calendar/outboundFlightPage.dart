import 'package:flutter/material.dart';
import 'package:vmba/FlightSelectionSummary/FlightSelectionSummaryPage.dart';
import 'package:vmba/calendar/returningFlightPage.dart';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/chooseFlight/chooseFlightPage.dart';
import 'dart:async';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:intl/intl.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/calendar/calendarFunctions.dart';

import '../Helpers/settingsHelper.dart';
import '../data/models/pnr.dart';
import '../passengerDetails/passengerDetailsPage.dart';
import '../utilities/messagePages.dart';
import 'bookingFunctions.dart';

class FlightSeletionPage extends StatefulWidget {
  FlightSeletionPage({Key key, this.newBooking}) : super(key: key);
  final NewBooking newBooking;
  @override
  _FlightSeletionState createState() => new _FlightSeletionState();
}

class _FlightSeletionState extends State<FlightSeletionPage> {
  bool _loadingInProgress;
  AvailabilityModel objAv;
  ScrollController _scrollController;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _noInternet;
  String avErrorMsg = 'Please check your internet connection';
  String _loading = '';

  @override
  void initState() {
    super.initState();
    gblActionBtnDisabled = false;
    _scrollController = new ScrollController();
    _loadingInProgress = true;
    _loading = 'Searching for Flights';
    _noInternet = false;
    gblBookingState = BookingState.newBooking;

    _loadData();
  }

  retrySearch() {
    setState(() {
      _loadingInProgress = true;
      _noInternet = false;
      _loadData();
    });
  }

  String getAvCommand(bool bRaw) {
    var buffer = new StringBuffer();
    //String _salesCity = 'ABZ';
    //String _equalsSafeString = '%3D';
    //String _commaSafeString = '%2C';
    //Intl.defaultLocale = 'en'; // VRS need UK format
    buffer.write('A');
    buffer.write(
        new DateFormat('dd').format(this.widget.newBooking.departureDate));
    buffer.write(
        new DateFormat('MMM').format(this.widget.newBooking.departureDate));
    buffer.write(this.widget.newBooking.departure);
    buffer.write(this.widget.newBooking.arrival);
    // [
    if( bRaw ) {
      buffer.write('[');
    } else {
      buffer.write('%5B');
    }
    //SalesCity=ABZ
    buffer.write('SalesCity=${this.widget.newBooking.departure}');
    // voucher
    if( this.widget.newBooking.eVoucherCode != null && this.widget.newBooking.eVoucherCode.isNotEmpty && this.widget.newBooking.eVoucherCode != '' ){
      buffer.write(',evoucher=${this.widget.newBooking.eVoucherCode.trim()}');
    }
    //&Vars=True
    buffer.write(',Vars=True');
    //&ClassBands=True
    buffer.write(',ClassBands=True');
    if( gblRedeemingAirmiles) {
      buffer.write(',FQTV=True');
    }
    if(this.widget.newBooking.currency != null && this.widget.newBooking.currency.isNotEmpty) {
      buffer.write(',QuoteCurrency=${this.widget.newBooking.currency}');
    }
    //&StartCity=ABZ
    buffer.write(',StartCity=${this.widget.newBooking.departure}');
    //&SingleSeg=s
    if (this.widget.newBooking.isReturn) {
      buffer.write(',SingleSeg=r');

      // add return details
      String retDate = DateFormat('ddMMMyyyy').format(this.widget.newBooking.returnDate).toString().toUpperCase();
      buffer.write(',RFDD=$retDate,RETURN=$retDate');

    } else {
      buffer.write(',SingleSeg=s');
    }

    //&FGNoAv=True
    buffer.write(',FGNoAv=True');
    //&qtyseats=1
    String _paxSeatsRequire = (this.widget.newBooking.passengers.adults +
            this.widget.newBooking.passengers.children +
            this.widget.newBooking.passengers.youths +
            this.widget.newBooking.passengers.seniors +
            this.widget.newBooking.passengers.students)
        .toString();
    buffer.write(',qtyseats=$_paxSeatsRequire');
    //&journey=ABZ-KOI
    String _journey = '';
    if (this.widget.newBooking.isReturn) {
      _journey =
          '${this.widget.newBooking.departure}-${this.widget.newBooking.arrival}-${this.widget.newBooking.departure}';
    } else {
      _journey =
          '${this.widget.newBooking.departure}-${this.widget.newBooking.arrival}';
    }
    buffer.write(',journey=$_journey');

    if (this.widget.newBooking.ads.pin != '' &&
        this.widget.newBooking.ads.number != '') buffer.write(',ads=true');


    buffer.write(getPaxTypeCounts(this.widget.newBooking.passengers ));

    buffer.write(
        ',EarliestDate=${DateFormat('dd/MM/yyyy kk:mm:ss').format(DateTime.now().toUtc())}]');
    //Intl.defaultLocale = gblLanguage;

    String msg =buffer.toString();
    logit('getAvCommand out: ' + msg);
    if( bRaw) {
      return msg;
    }
    return msg
        .replaceAll('=', '%3D')
        .replaceAll(',', '%2C')
        .replaceAll('/', '%2F')
        .replaceAll(':', '%3A')
        .replaceAll('[', '%5B')
        .replaceAll(']', '%5D');
  }

  Future _loadData() async {

      Repository.get().getAv(getAvCommand(gblSettings.useWebApiforVrs == false)).then((rs) async {
      if (rs.isOk()) {
        objAv = rs.body;
        removeDepartedFlights();
        _dataLoaded();
      } else if(rs.statusCode == notSinedIn)  {
        await login().then((result) {});
        Repository.get().getAv(getAvCommand(gblSettings.useWebApiforVrs == false)).then((rs) {
          objAv = rs.body;
          removeDepartedFlights();
          _dataLoaded();
        });
      } else {
        avErrorMsg = rs.errorStatus();
        setState(() {
          _loadingInProgress = false;
          _noInternet = true;
        });
      }
    });
  }

  void removeDepartedFlights() {
    if (objAv.availability.itin != null) {
      int length = objAv.availability.itin.length - 1;
      for (int i = length; i >= 0; i--) {
        DateTime fltDate = DateTime.parse(
            objAv.availability.itin[i].flt.first.time.ddaygmt +
                ' ' +
                objAv.availability.itin[i].flt.first.time.dtimgmt);
        //DateTime utcNow = DateTime.now().toUtc().subtract(Duration(minutes: gblSettings.bookingLeadTime));
        DateTime utcNow = DateTime.now().toUtc().add(Duration(minutes: gblSettings.bookingLeadTime));
        if (fltDate.isBefore(utcNow)) {
          objAv.availability.itin.removeAt(i);
        }
      }
    }
  }
/*
  showSnackBar(String message) {
    final _snackbar = snackbar(message);
    ScaffoldMessenger.of(context).showSnackBar(_snackbar);
    //_key.currentState.showSnackBar(_snackbar);
  }
*/
  void _dataLoaded() {
    int calenderWidgetSelectedItem;
    double animateTo = 250;
    DateTime _departureDate = DateTime.parse(
        DateFormat('y-MM-dd').format(widget.newBooking.departureDate));
    DateTime _currentDate =
        DateTime.parse(DateFormat('y-MM-dd').format(DateTime.now().toUtc()));

    calenderWidgetSelectedItem = 0;
    if(objAv.availability.cal != null && objAv.availability.cal.day != null  ) {
      for (var f in objAv.availability.cal.day) {
        if (DateTime.parse(f.daylcl).isAfter(_currentDate) ||
            isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
          calenderWidgetSelectedItem += 1;
          if (isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
            break;
          }
        }
      }
    }

    if (calenderWidgetSelectedItem == 0 || calenderWidgetSelectedItem == 1) {
      animateTo = 0;
    } else if (calenderWidgetSelectedItem == 2) {
      animateTo = 150;
    }
    endProgressMessage();
    setState(() {
      _loadingInProgress = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo(animateTo,
            duration: new Duration(microseconds: 1), curve: Curves.ease));
  }

  _changeSearchDate(DateTime newDate) {
    print(this.widget.newBooking.departureDate.toString());
    setState(() {
      this.widget.newBooking.departureDate = newDate;
      _loadingInProgress = true;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
  if ( gblError!= null && gblError.isNotEmpty  ){
    return criticalErrorPageWidget( context, gblError,title: gblErrorTitle, onComplete:  onComplete);


  }
    return new Scaffold(
      key: _key,
      appBar: appBar(context,  "Outbound Flight", leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () async {
          Navigator.pop(context, widget.newBooking);
        },
      )),
      /*new AppBar(
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context, widget.newBooking);
          },
        ),
        title: new TrText("Outbound Flight",
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
       */
      endDrawer: DrawerMenu(),
      body: _buildBody(),
    );

    //return _buildBody();
  }
  void onComplete (dynamic p) {
    gblError = null;
    setState(() {});
  }

  Widget _buildBody() {
    if (_loadingInProgress) {
      if( gblSettings.wantCustomProgress) {
        progressMessagePage(context, _loading, title: 'loading');
        return Container();
      } else {
        return new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TrText(_loading),
              )
            ],
          ),
        );
      }
    } else if (_noInternet ) {
      return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(avErrorMsg), //'Please check your internet connection'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  primary: gblSystemColors.primaryButtonColor),
              onPressed: () => retrySearch(),
              child: TrText(
                'Retry Search',
                style: new TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    } else {
      return flightSelection();
    }
  }

  Widget getCalenderWidget() {
    if (objAv != null && objAv.availability.cal != null && objAv.availability.cal.day != null) {
      return new ListView(
          shrinkWrap: true,
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: objAv.availability.cal.day
              .map(
                (item) =>
                    getCalDay(item, 'out', widget.newBooking.departureDate, DateTime.parse(DateFormat('y-MM-dd').format(DateTime.now().toUtc())),
                        onPressed:() => {
                    hasDataConnection().then((result) {
                    if (result == true) {
                    _changeSearchDate(DateTime.parse(item.daylcl));
                    } else {
                    //showSnackBar('Please, check your internet connection');
                    noInternetSnackBar(context);
                    }
                    })
                    }),

              )
              .toList());
    } else {
      return new TrText('No Calender results');
    }
  }

  Widget flightAvailability() {
    if (objAv != null && objAv.availability.itin != null && objAv.availability.itin.length > 0) {
      return new ListView(
          scrollDirection: Axis.vertical,
          children: (objAv.availability.itin
              .map(
                (item) => flightItem( item),

              )
              .toList()));
    } else {
      return noFlightsFound();
    }
  }

  Widget flightItem(avItin item){
      if( wantPageV2() ) {
        int seatCount = widget.newBooking.passengers.adults +
            widget.newBooking.passengers.youths +
            widget.newBooking.passengers.seniors +
            widget.newBooking.passengers.students +
            widget.newBooking.passengers.children;
        return CalFlightItemWidget( newBooking: widget.newBooking, objAv:  objAv, item: item, flightSelected: flightSelected ,seatCount: seatCount,); //  calFlightItem(context,widget.newBooking, objAv, item);
      } else {
        return Container(
            margin: EdgeInsets.only(bottom: 10.0),
            padding: EdgeInsets.only(
                left: 8.0, right: 8.0, bottom: 8.0, top: 8.0),
            child: Column(
              children: <Widget>[
                flightRow(context, item),
                Divider(),
                gblSettings.wantCanFacs
                    ? CannedFactWidget(flt: item.flt)
                    : Container(),
                infoRow(context, item),
                Padding(
                  padding: EdgeInsets.all(0),
                ),
                new Divider(),
                pricebuttons(item.flt),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0x90000000),
                  offset: Offset(0.0, 6.0),
                  blurRadius: 10.0,
                ),
              ],
            )
        );
      }
  }

  flightSelection() {
    return new Column(
      children: <Widget>[
        new Container(
          margin: EdgeInsets.symmetric(vertical: 1.0),
          //height: 70.0,
          constraints: new BoxConstraints(
            minHeight: 60.0,
            maxHeight: 80.0,
          ),
          child: getCalenderWidget(),
        ),
        new Expanded(
          child: flightAvailability(),
        ),
      ],
    );
  }

  void goToClassScreen(int index, List<Flt> flts) async {
    _loadingInProgress = true;
    gblActionBtnDisabled = false;
    _loading = 'Loading';
    var selectedFlt = await Navigator.push(
        context,
        SlideTopRoute(
            page: ChooseFlight(
          classband: objAv.availability.classbands.band[index],
          flts: flts, //objAv.availability.itin[0].flt,
          seats: widget.newBooking.passengers.adults +
              widget.newBooking.passengers.youths +
              widget.newBooking.passengers.seniors +
              widget.newBooking.passengers.students +
              widget.newBooking.passengers.children,
        )));
    flightSelected(context, selectedFlt, flts, objAv.availability.classbands.band[index].cbname);
  }

  void flightSelected(BuildContext context, List<String> flt, List<Flt> outboundflts, String className) {
    /*setState(() {

    });*/
    if (flt != null) {
      print(flt);
      if (flt != null && flt.length > 0) {
        this.widget.newBooking.outboundflight = flt;
        this.widget.newBooking.outboundflts = outboundflts;
        this.widget.newBooking.outboundClass = className;
      }

      hasDataConnection().then((result) async {
        logit('FlightSelected: $result');
      //  endProgressMessage();
        if (result == true) {
          _loadingInProgress = false;
          if (this.widget.newBooking.isReturn &&
              this.widget.newBooking.outboundflight[0] != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReturnFlightSeletionPage(
                          newBooking: this.widget.newBooking,
                          outboundFlight: outboundflts.last,
                        )));
          } else if (this.widget.newBooking.outboundflight[0] != null) {

            if( gblSettings.wantProducts) {
              // first save new booking
              gblError = '';
              PnrModel pnrModel = await searchSaveBooking(
                  this.widget.newBooking);
              gblPnrModel = pnrModel;
              refreshStatusBar();
              // go to options page
              if (gblError != '') {

              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PassengerDetailsWidget(
                            newBooking: widget.newBooking,
                            pnrModel:  pnrModel,)));


              }

            } else {

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FlightSelectionSummaryWidget(
                              newBooking: this.widget.newBooking)));
            }
          }
        } else {
          logit('FlightSelected: no iternet');
          //showSnackBar(translate('Please, check your internet connection'));
       //   endProgressMessage();
          noInternetSnackBar(context);
        }
      });
    }
  }

  bool isUmnr() {
    if( this.widget.newBooking.passengers.adults == 0 &&
        this.widget.newBooking.passengers.teachers == 0 &&
        this.widget.newBooking.passengers.students == 0 &&
        this.widget.newBooking.passengers.children == 1 &&
        this.widget.newBooking.passengers.seniors == 0
    ) {
      return true;
    }
    return false;
  }


  Widget pricebuttons(List<Flt> item) {
     if (item[0].fltav.pri.length > 3) {
      return Wrap(
          spacing: 8.0, //gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          children: new List.generate(
              item[0].fltav.pri.length,
              (index) => GestureDetector(
                  onTap: () => {
                        item[0].fltav.fav[index] != '0'
                            ? goToClassScreen(index, item)
                            : print('No av')
                      },
                  child: Chip(
                    backgroundColor:
                    gblSystemColors.primaryButtonColor,
                    label: Column(
                      children:
                      <Widget>[
                        TrText(
                            objAv.availability.classbands.band[index]
                                        .cbdisplayname ==
                                    'Fly Flex Plus'
                                ? 'Fly Flex +'
                                : objAv.availability.classbands.band[index]
                                    .cbdisplayname,
                            style: TextStyle(
                                color: gblSystemColors
                                    .primaryButtonTextColor)),
                        item[0].fltav.fav[index] != '0'
                            ? new Text(
                                calenderPrice(
                                    item[0].fltav.cur[index],
                                    item
                                        .fold(
                                            0.0,
                                            (previous, current) =>
                                                previous +
                                                (double.tryParse(current
                                                        .fltav.pri[index]) ??
                                                    0.0) +
                                                (double.tryParse(current
                                                        .fltav.tax[index]) ??
                                                    0.0))
                                        .toStringAsFixed(2),
                                    item[0].fltav.miles[index]),
                                style: new TextStyle(
                                  color: gblSystemColors
                                      .primaryButtonTextColor,
                                  fontSize: 12.0,
                                ),
                              )
                            : new TrText('No Seats',
                                style: new TextStyle(
                                  color: gblSystemColors
                                      .primaryButtonTextColor,
                                  fontSize: 12.0,
                                )),
                      ],
                    ),
                  ))));
    } else {
      MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.spaceAround;
      if (item[0].fltav.pri.length == 2) {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      } else if (item[0].fltav.pri.length == 3) {
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
      }
      return new Row(
          mainAxisAlignment: _mainAxisAlignment,
          children: new List.generate(
            item[0].fltav.pri.length,
            (index) => ElevatedButton(
                onPressed: () {
                  item[0].fltav.fav[index] != '0'
                      ? goToClassScreen(index, item)
                      : print('No av');
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    primary:
                    gblSystemColors.primaryButtonColor,
                    padding: new EdgeInsets.all(5.0)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: new Column(
                    children: getPriceButtonList(objAv.availability.classbands.band[index].cbdisplayname, item, index),
                  ),
                )),
          ));
    }
  }
}
