import 'package:flutter/material.dart';
import 'package:vmba/FlightSelectionSummary/FlightSelectionSummaryPage.dart';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/chooseFlight/chooseFlightPage.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';

import '../Helpers/settingsHelper.dart';
import '../data/models/pnr.dart';
import '../passengerDetails/passengerDetailsPage.dart';
import '../utilities/messagePages.dart';
import 'bookingFunctions.dart';
import 'calendarFunctions.dart';

class ReturnFlightSeletionPage extends StatefulWidget {
  ReturnFlightSeletionPage({Key key, this.newBooking, this.outboundFlight})
      : super(key: key);
  final NewBooking newBooking;
  final Flt outboundFlight;
  @override
  _ReturnFlightSeletionState createState() => new _ReturnFlightSeletionState();
}

class _ReturnFlightSeletionState extends State<ReturnFlightSeletionPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _loadingInProgress;
  ScrollController _scrollController;
  bool _noInternet;
  String _loading = '';
  String avErrorMsg = 'Please check your internet connection';

  DateTime _departureDate;
  DateTime _returnDate;

  AvailabilityModel objAv;
  @override
  void initState() {
    super.initState();
    gblActionBtnDisabled = false;
    _loading = 'Searching for Flights';

    _scrollController = new ScrollController();
    _loadingInProgress = true;
    _noInternet = false;
    _loadData();
    _departureDate = DateTime.parse(
        DateFormat('y-MM-dd').format(widget.newBooking.departureDate));
    _returnDate = DateTime.parse(
        DateFormat('y-MM-dd').format(widget.newBooking.returnDate));
  }

  String getAvReturnCommand(bool bRaw) {
    var buffer = new StringBuffer();
    buffer.write('A');
    buffer
        .write(new DateFormat('dd').format(this.widget.newBooking.returnDate));
    buffer
        .write(new DateFormat('MMM').format(this.widget.newBooking.returnDate));
    buffer.write(this.widget.newBooking.arrival);
    buffer.write(this.widget.newBooking.departure);

    buffer.write('[SalesCity=${this.widget.newBooking.arrival},Vars=True');
    if( this.widget.newBooking.eVoucherCode != null && this.widget.newBooking.eVoucherCode.isNotEmpty && this.widget.newBooking.eVoucherCode != '' ){
      buffer.write(',evoucher=${this.widget.newBooking.eVoucherCode.trim()}');
    }

    buffer.write(
        ',ClassBands=True,StartCity=${this.widget.newBooking.departure}');

    //if (this.widget.newBooking.isReturn) {
    //  buffer.write(',SingleSeg=s');
    //} else {
    if( gblRedeemingAirmiles) {
      buffer.write(',FQTV=True');
    }
    if(this.widget.newBooking.currency != null && this.widget.newBooking.currency.isNotEmpty) {
      buffer.write(',QuoteCurrency=${this.widget.newBooking.currency}');
    }

    buffer.write(',SingleSeg=r');
    // add outbound details
    String outDate = DateFormat('ddMMMyyyy').format(this.widget.newBooking.departureDate).toString().toUpperCase();
    String arrDate = DateFormat('ddMMMyyyy').format(DateTime.parse(widget.outboundFlight.time.adaylcl)).toString().toUpperCase();
    buffer.write(',RFAD=$arrDate,DEPART=$outDate');
    //}
    buffer.write(',FGNoAv=True');
    String _paxSeatsRequire = (this.widget.newBooking.passengers.adults +
        this.widget.newBooking.passengers.seniors +
        this.widget.newBooking.passengers.students +
        this.widget.newBooking.passengers.children +
            this.widget.newBooking.passengers.youths)
        .toString();
    buffer.write(',qtyseats=$_paxSeatsRequire');
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
        ',EarliestDate=${DateFormat('dd/MM/yyyy kk:mm:ss').format(this.widget.newBooking.departureDate)}]');

    String msg =buffer.toString();
    logit('getAvCommand ret: ' + msg);
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
    Repository.get().getAv(getAvReturnCommand(gblSettings.useWebApiforVrs == false)).then((rs) {
      if (rs.isOk()) {
        objAv = rs.body;
        removeDepartedFlights();
        _dataLoaded();
      } else {
        avErrorMsg = rs.errorStatus();
        setState(() {
          _loadingInProgress = false;
          _noInternet = true;
        });
      }
    });
  }

  retrySearch() {
    setState(() {
      _loadingInProgress = true;
      _noInternet = false;
      _loadData();
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
        if (fltDate.isBefore(DateTime.now().toUtc().subtract(Duration(
            minutes: gblSettings.bookingLeadTime)))) {
          objAv.availability.itin.removeAt(i);
        }
      }
    }
  }

  void _dataLoaded() {
    int calenderWidgetSelectedItem = 0;
    double animateTo = 250;

    for (var f in objAv.availability.cal.day) {
      if (DateTime.parse(f.daylcl).isAfter(_departureDate)) {
        calenderWidgetSelectedItem += 1;
        if (isSearchDate(DateTime.parse(f.daylcl), _returnDate)) {
          break;
        }
      }
    }

    calenderWidgetSelectedItem = 0;
    for (var f in objAv.availability.cal.day) {
      if (DateTime.parse(f.daylcl).isAfter(_departureDate) ||
          isSearchDate(DateTime.parse(f.daylcl), _returnDate)) {
        calenderWidgetSelectedItem += 1;
        if (isSearchDate(DateTime.parse(f.daylcl), _returnDate)) {
          break;
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

  showSnackBar(String message) {
    final _snackbar = snackbar(message);
    ScaffoldMessenger.of(context).showSnackBar(_snackbar);
    //_key.currentState.showSnackBar(_snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _key,
      appBar: appBar(context,"Returning Flight"),
        endDrawer: DrawerMenu(),
      body: _buildBody(),
    );
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
    } else if (_noInternet) {
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
                primary: gblSystemColors.primaryButtonColor,
              ),
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

  flightSelection() {
    if (!_returnDate.isBefore(_departureDate)) {
      return new Column(
        children: <Widget>[
          new Container(
            margin: EdgeInsets.symmetric(vertical: 1.0),
            constraints: new BoxConstraints(
              minHeight: 60.0,
              maxHeight: 80.0,
            ),
            // height: 70.0,
            child: getCalenderWidget(),
          ),
          new Expanded(
            child: flightAvailability(),
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrText(
                'Your outbound flight is now after your original requested return date. You will need to select a new return date to continue.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
              onPressed: () => showDatePicker(
                context: context,
                firstDate: _departureDate,
                initialDate: _departureDate,
                lastDate:
                    new DateTime.now().toUtc().add(new Duration(days: 363)),
                builder: (BuildContext context, Widget child) {
                return Theme(
                    data: ThemeData.light().copyWith(
                    //primarySwatch: gblSystemColors.primaryHeaderColor,//OK/Cancel button text color

                    primaryColor: gblSystemColors.primaryHeaderColor,//Head background
                    //accentColor: gblSystemColors.primaryHeaderColor, //selection color
                    colorScheme: ColorScheme.light(primary: gblSystemColors.primaryHeaderColor),
                  buttonTheme: ButtonThemeData(
                  textTheme: ButtonTextTheme.primary
                  ),
                  ),
                  child: child,
                  );},
              ).then((date) => _changeSearchDate(date)),
              child: TrText(
                'CHOOSE NEW DATE',
                style: new TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget getCalenderWidget() {
    if (objAv != null || objAv.availability.cal != null) {
      return new ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: objAv.availability.cal.day
              .map(
                (item) => getCalDay(item, 'ret' , widget.newBooking.returnDate, _departureDate,
                    onPressed: () => {
                    hasDataConnection().then((result) {
                    if (result == true) {
                    _changeSearchDate(DateTime.parse(item.daylcl));
                    } else {
                    showSnackBar(
                    'Please check your internet connection');
                    }
                    })
                    })
/*
                    Container(
                  decoration: new BoxDecoration(
                    border: new Border.all(color: Colors.black12),
                    color: !isSearchDate(DateTime.parse(item.daylcl),
                            widget.newBooking.returnDate)
                        ? Colors.white
                        : gblSystemColors.accentButtonColor,
                  ),
                  //width: 120.0,
                  width: DateTime.parse(item.daylcl).isBefore(_departureDate)
                      ? 0
                      : 120.0,
                  child: new TextButton(
                      onPressed: () {
                        hasDataConnection().then((result) {
                          if (result == true) {
                            _changeSearchDate(DateTime.parse(item.daylcl));
                          } else {
                            showSnackBar(
                                'Please check your internet connection');
                          }
                        });
                      },
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Text(getIntlDate('EEE dd', DateTime.parse(item.daylcl)),
                              //new DateFormat('EEE dd').format(DateTime.parse(item.daylcl)),
                              style: TextStyle(
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.newBooking.returnDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            new TrText(
                              'from',
                              style: TextStyle(
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.newBooking.returnDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            new Text(
                              calenderPrice(item.cur, item.amt, item.miles),
                              style: TextStyle(
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.newBooking.returnDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ])),
                ),
*/
              )
              .toList());
    } else {
      return new TrText('No Calender results');
    }
  }

  Widget flightAvailability() {
    if (objAv.availability.itin != null) {
      return new ListView(
          scrollDirection: Axis.vertical,
          children: (objAv.availability.itin
              .map(
                (item) =>flightItem( item),

              )
              .toList()));
    } else {
      return noFlightsFound();
/*
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Sorry no flights found',
            style: TextStyle(fontSize: 14.0),
          ),
          Text(
            'Try search for a different date',
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ));
*/
    }
  }

  Widget flightItem( avItin item) {
    if( wantPageV2() ) {
      int seatCount = widget.newBooking.passengers.adults +
          widget.newBooking.passengers.youths +
          widget.newBooking.passengers.seniors +
          widget.newBooking.passengers.students +
          widget.newBooking.passengers.children;

      return CalFlightItemWidget( newBooking: widget.newBooking, objAv:  objAv, item: item, flightSelected: flightSelected,seatCount: seatCount,);
        //calFlightItem(context,widget.newBooking, objAv, item);
    } else {
      return
        Container(
            margin: EdgeInsets.only(bottom: 10.0),
            padding: EdgeInsets.only(
                left: 3.0, right: 3.0, bottom: 3.0, top: 3.0),
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
            ));
    }
  }


  validateSelection(index, item) {
    if (item[0].fltav.fav[index] == '0') {
      print('No av');
    } else if (getFullTimeDate(widget.outboundFlight.time.adaylcl,
            widget.outboundFlight.time.atimlcl)
        .isAfter(getFullTimeDate(
            item.first.time.adaylcl, item.first.time.atimlcl))) {
      showSnackBar(
          'This flight is before or to close to your outbound arrival time to book');
    } else if (((widget.newBooking.outboundflight[0].contains('[CB=Fly]') &&
            objAv.availability.classbands.band[index].cbname == 'Fly Flex') ||
        (widget.newBooking.outboundflight[0].contains('[CB=Fly Flex]') &&
            objAv.availability.classbands.band[index].cbname == 'Fly'))) {
      showSnackBar('Fly and Fly Flex can\'t be mixed within a booking');
    } else if (((widget.newBooking.outboundflight[0]
                .contains('[CB=Blue Fly]') &&
            objAv.availability.classbands.band[index].cbname == 'Blue Flex') ||
        (widget.newBooking.outboundflight[0].contains('[CB=Blue Flex]') &&
            objAv.availability.classbands.band[index].cbname == 'Blue Fly'))) {
      showSnackBar('Blue Fly and Blue Flex can\'t be mixed within a booking');
    } else {
      goToClassScreen(index, item);
    }
  }

  DateTime getFullTimeDate(String date, String time) {
    return DateTime.parse(date + ' ' + time.trim());
  }

  Widget pricebuttons(List<Flt> item) {
    if (item[0].fltav.pri.length > 3) {
      return Wrap(
          spacing: 8.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          children: new List.generate(
              item[0].fltav.pri.length,
              (index) => GestureDetector(
                  onTap: () => {
                        item[0].fltav.fav[index] != '0'
                            ? validateSelection(index, item)
                            : print('No av')
                      },
                  child: Chip(
                    backgroundColor:
                    gblSystemColors.primaryButtonColor,
                    label: Column(
                      children: getPriceButtonList(objAv.availability.classbands.band[index].cbdisplayname, item, index, inRow: false),
                     /* <Widget>[
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

                        // Text(calenderPrice('NGN', '55000'),
                        //  style: TextStyle(color: Colors.white)),
                      ],*/
                    ),
                  ))));
    } else {
      MainAxisAlignment _mainAxisAlignment;
      if (item[0].fltav.pri.length == 2) {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      } else if (item[0].fltav.pri.length == 3) {
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
      } else {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      }
      return new Row(
          mainAxisAlignment: _mainAxisAlignment,
          children: new List.generate(
            item[0].fltav.pri.length,
            (index) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary:
                    gblSystemColors.primaryButtonColor,
                    padding: new EdgeInsets.all(5.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                onPressed: () {
                  item[0].fltav.fav[index] != '0'
                      ? validateSelection(
                          index, item) //goToClassScreen(index, item)
                      : print('No av');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: new Column(
                    children: getPriceButtonList(objAv.availability.classbands.band[index].cbdisplayname, item, index),
/*                    <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new TrText(
                            objAv.availability.classbands.band[index]
                                        .cbdisplayname ==
                                    'Fly Flex Plus'
                                ? 'Fly Flex +'
                                : objAv.availability.classbands.band[index]
                                    .cbdisplayname,
                            style: new TextStyle(
                              color: gblSystemColors
                                  .primaryButtonTextColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
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
                      )
                    ],*/
                  ),
                )),
          ));
    }
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

  void flightSelected(BuildContext context ,List<String> flt, List<Flt> flts, String className) {
    print(flt);
    if (flt != null && flt.length > 0) {
      this.widget.newBooking.returningflight = flt;
      this.widget.newBooking.returningflts = flts;
      this.widget.newBooking.returningClass = className;
    }

    _loadingInProgress = true;
    _loading = 'loading';
    if (this.widget.newBooking.returningflight.length > 0 &&
        this.widget.newBooking.returningflight[0] != null &&
        this.widget.newBooking.outboundflight[0] != null) {
      hasDataConnection().then((result) async {
        if (result == true) {
          if( gblSettings.wantProducts) {
            gblError = '';
            PnrModel pnrModel = await searchSaveBooking(
                this.widget.newBooking);
            // go to options page
            if (gblError != '') {

            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PassengerDetailsWidget(
                          newBooking: widget.newBooking,
                          pnrModel:  pnrModel)));
 /*             Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OptionsPageWidget(
                            newBooking: this.widget.newBooking,
                            pnrModel: pnrModel,)));
*/            }
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FlightSelectionSummaryWidget(
                            newBooking: this.widget.newBooking)));
          }
        } else {
          //showSnackBar(translate('Please, check your internet connection'));
          noInternetSnackBar(context);
        }
      });
    }
  }

  _changeSearchDate(DateTime newDate) {
    print(this.widget.newBooking.returnDate.toString());
    setState(() {
      _returnDate = DateTime.parse(DateFormat('y-MM-dd').format(newDate));
      this.widget.newBooking.returnDate = newDate;
      _loadingInProgress = true;
      _loadData();
    });
  }


}
