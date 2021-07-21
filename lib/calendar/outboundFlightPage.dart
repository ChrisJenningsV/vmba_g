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

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _loadingInProgress = true;
    _noInternet = false;
    _loadData();
  }

  retrySearch() {
    setState(() {
      _loadingInProgress = true;
      _noInternet = false;
      _loadData();
    });
  }

  String getAvCommand() {
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
    buffer.write('%5B');
    //SalesCity=ABZ
    buffer.write('SalesCity=${this.widget.newBooking.departure}');
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

    buffer.write(
        ',EarliestDate=${DateFormat('dd/MM/yyyy kk:mm:ss').format(DateTime.now().toUtc())}]');
    //Intl.defaultLocale = gblLanguage;

    return buffer
        .toString()
        .replaceAll('=', '%3D')
        .replaceAll(',', '%2C')
        .replaceAll('/', '%2F')
        .replaceAll(':', '%3A')
        .replaceAll('[', '%5B')
        .replaceAll(']', '%5D');
  }

  Future _loadData() async {
    Repository.get().getAv(getAvCommand()).then((rs) {
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
    for (var f in objAv.availability.cal.day) {
      if (DateTime.parse(f.daylcl).isAfter(_currentDate) ||
          isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
        calenderWidgetSelectedItem += 1;
        if (isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
          break;
        }
      }
    }

    if (calenderWidgetSelectedItem == 0 || calenderWidgetSelectedItem == 1) {
      animateTo = 0;
    } else if (calenderWidgetSelectedItem == 2) {
      animateTo = 150;
    }

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
    return new Scaffold(
      key: _key,
      appBar: new AppBar(
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
      endDrawer: DrawerMenu(),
      body: _buildBody(),
    );

    //return _buildBody();
  }

  Widget _buildBody() {
    if (_loadingInProgress) {
      return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrText('Searching for Flights'),
            )
          ],
        ),
      );
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
    if (objAv != null || objAv.availability.cal != null) {
      return new ListView(
          shrinkWrap: true,
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: objAv.availability.cal.day
              .map(
                (item) => Container(
                  decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black12),
                      color: !isSearchDate(DateTime.parse(item.daylcl),
                              widget.newBooking.departureDate)
                          ? Colors.white
                          : gblSystemColors.accentButtonColor //Colors.red,
                      ),
                  width: DateTime.parse(item.daylcl).isBefore(DateTime.parse(DateFormat('y-MM-dd').format(DateTime.now().toUtc())))
                      ? 0
                      : 120.0,
                  child: new TextButton(
                      onPressed: () {
                        hasDataConnection().then((result) {
                          if (result == true) {
                            _changeSearchDate(DateTime.parse(item.daylcl));
                          } else {
                            //showSnackBar('Please, check your internet connection');
                            noInternetSnackBar(context);
                          }
                        });
                      },
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Text( getIntlDate('EEE dd', DateTime.parse(item.daylcl)),
                              //new DateFormat('EEE dd').format(DateTime.parse(item.daylcl)),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.newBooking.departureDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            new TrText(
                              'from',
                              //textScaleFactor: 1.0,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.newBooking.departureDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            //new Text(item.cur + item.amt)
                            new Text(
                              calenderPrice(item.cur, item.amt, item.miles),
                              //textScaleFactor: 1.0,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.newBooking.departureDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ])),
                ),
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
                (item) => Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    padding: EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 8.0, top: 8.0),
                    child: Column(
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(getIntlDate('EEE dd MMM', DateTime.parse(item.flt[0].time.ddaylcl)),
                                    //new DateFormat('EEE dd MMM h:mm a').format(DateTime.parse(item.flt[0].time.ddaylcl)).toString().substring(0, 10),
                                    style: new TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w300)),
                                new Text(
                                    item.flt.first.time.dtimlcl
                                        .substring(0, 5)
                                        .replaceAll(':', ''),
                                    style: new TextStyle(
                                        fontSize: 36.0,
                                        fontWeight: FontWeight.w700)),
                                FutureBuilder(
                                  future: cityCodeToName(
                                    item.flt.first.dep,
                                  ),
                                  initialData: item.flt.first.dep.toString(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> text) {
                                    return TrText(text.data,
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w300),
                                            variety: 'airport',noTrans: true);
                                  },
                                ),
                              ],
                            ),
                            Column(children: [
                              new RotatedBox(
                                  quarterTurns: 1,
                                  child: new Icon(
                                    Icons.airplanemode_active,
                                    size: 60.0,
                                  ))
                            ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text( getIntlDate('EEE dd MMM',DateTime.parse(item.flt.last.time.adaylcl)),
                                    /*new DateFormat('EEE dd MMM h:mm a')
                                        .format(DateTime.parse(
                                            item.flt.last.time.adaylcl))
                                        .toString()
                                        .substring(0, 10),*/
                                    style: new TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w300)),
                                new Text(
                                    item.flt.last.time.atimlcl
                                        .substring(0, 5)
                                        .replaceAll(':', ''),
                                    style: new TextStyle(
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w700)),
                                FutureBuilder(
                                  future: cityCodeToName(
                                    item.flt.last.arr,
                                  ),
                                  initialData: item.flt.last.arr.toString(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> text) {
                                    return new TrText(text.data,
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w300),
                                        variety: 'airport', noTrans: true,);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        Divider(),
                        CannedFactWidget(flt: item.flt),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(children: [
                              Row(
                                children: <Widget>[
                                  Icon(Icons.timer),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(item.journeyDuration()),
                                  )
                                ],
                              )
                            ]),
                            Column(children: [
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(item.flt[0].fltdet.airid + item.flt[0].fltdet.fltno),
                                  )
                                ],
                              )
                            ]),
                            Column(
                              children: <Widget>[
                                item.flt.length > 1
                                    ? GestureDetector(
                                        onTap: () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                actions: <Widget>[
                                                  new TextButton(
                                                    child: new TrText("OK"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                                title: new TrText('Connections'),
                                                content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: (item.flt.map(
                                                      (f) => Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(f.dep),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(DateFormat(
                                                                      'kk:mm')
                                                                  .format(DateTime.parse(f
                                                                          .time
                                                                          .ddaylcl +
                                                                      ' ' +
                                                                      f.time
                                                                          .dtimlcl))
                                                                  .toString()),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child:
                                                                  new RotatedBox(
                                                                      quarterTurns:
                                                                          1,
                                                                      child:
                                                                          new Icon(
                                                                        Icons
                                                                            .airplanemode_active,
                                                                        size:
                                                                            20.0,
                                                                      )),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child:
                                                                  Text(f.arr),
                                                            ),
                                                            Text(DateFormat(
                                                                    'kk:mm')
                                                                .format(DateTime.parse(f
                                                                        .time
                                                                        .ddaylcl +
                                                                    ' ' +
                                                                    f.time
                                                                        .atimlcl))
                                                                .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                    )).toList()));
                                          },
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            new Text(
                                              item.flt.length == 2
                                                  ? '${item.flt.length - 1} connection'
                                                  : '${item.flt.length - 1} connections',
                                              style: new TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            new Icon(Icons.expand_more),
                                          ],
                                        ),
                                      )
                                    : TrText('Direct Flight'),
                              ],
                            )
                          ],
                        ),
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
                    )),
              )
              .toList()));
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TrText(
            'Sorry no flights found',
            style: TextStyle(fontSize: 14.0),
          ),
          TrText(
            'Try search for a different date',
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ));
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
    flightSelected(selectedFlt, flts);
  }

  void flightSelected(List<String> flt, List<Flt> outboundflts) {
    if (flt != null) {
      print(flt);
      if (flt != null && flt.length > 0) {
        this.widget.newBooking.outboundflight = flt;
      }

      hasDataConnection().then((result) {
        if (result == true) {
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FlightSelectionSummaryWidget(
                        newBooking: this.widget.newBooking)));
          }
        } else {
          //showSnackBar(translate('Please, check your internet connection'));
          noInternetSnackBar(context);
        }
      });
    }
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
                            ? goToClassScreen(index, item)
                            : print('No av')
                      },
                  child: Chip(
                    backgroundColor:
                    gblSystemColors.primaryButtonColor,
                    label: Column(
                      children: <Widget>[
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
                    children: <Widget>[
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
                    ],
                  ),
                )),
          ));
    }
  }
}
