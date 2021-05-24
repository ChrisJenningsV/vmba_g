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
  String avErrorMsg = 'Please check your internet connection';

  DateTime _departureDate;
  DateTime _returnDate;

  AvailabilityModel objAv;
  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _loadingInProgress = true;
    _noInternet = false;
    _loadData();
    _departureDate = DateTime.parse(
        DateFormat('y-MM-dd').format(widget.newBooking.departureDate));
    _returnDate = DateTime.parse(
        DateFormat('y-MM-dd').format(widget.newBooking.returnDate));
  }

  String getAvReturnCommand() {
    var buffer = new StringBuffer();
    buffer.write('A');
    buffer
        .write(new DateFormat('dd').format(this.widget.newBooking.returnDate));
    buffer
        .write(new DateFormat('MMM').format(this.widget.newBooking.returnDate));
    buffer.write(this.widget.newBooking.arrival);
    buffer.write(this.widget.newBooking.departure);

    buffer.write('[SalesCity=${this.widget.newBooking.arrival},Vars=True');
    buffer.write(
        ',ClassBands=True,StartCity=${this.widget.newBooking.departure}');

    //if (this.widget.newBooking.isReturn) {
    //  buffer.write(',SingleSeg=s');
    //} else {
    buffer.write(',SingleSeg=r');
    //}
    buffer.write(',FGNoAv=True');
    String _paxSeatsRequire = (this.widget.newBooking.passengers.adults +
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

    buffer.write(
        ',EarliestDate=${DateFormat('dd/MM/yyyy kk:mm:ss').format(this.widget.newBooking.departureDate)}]');

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
    Repository.get().getAv(getAvReturnCommand()).then((rs) {
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
      appBar: new AppBar(
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new TrText("Returning Flight",
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
      endDrawer: DrawerMenu(),
      body: _buildBody(),
    );
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
                'Your outbound flight is now after your original requested return date. You will need to select a new return date to contine.',
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
                (item) => Container(
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
                            new Text(
                              new DateFormat('EEE dd')
                                  .format(DateTime.parse(item.daylcl)),
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
                              calenderPrice(item.cur, item.amt),
                              style: TextStyle(
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.newBooking.returnDate)
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
    if (objAv.availability.itin != null) {
      return new ListView(
          scrollDirection: Axis.vertical,
          children: (objAv.availability.itin
              .map(
                (item) => Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    padding: EdgeInsets.only(
                        left: 3.0, right: 3.0, bottom: 3.0, top: 3.0),
                    child: Column(
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    new DateFormat('EEE dd MMM h:mm a')
                                        .format(DateTime.parse(
                                            item.flt[0].time.ddaylcl))
                                        .toString()
                                        .substring(0, 10),
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
                                    return new TrText(text.data,
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
                                Text(
                                    new DateFormat('EEE dd MMM h:mm a')
                                        .format(DateTime.parse(
                                            item.flt.last.time.adaylcl))
                                        .toString()
                                        .substring(0, 10),
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
                                        variety: 'airport',noTrans: true);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        Divider(),
                        CannedFactWidget(
                          flt: item.flt,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(children: [
                              Row(
                                children: <Widget>[
                                  Icon(Icons.timer),
                                  Text(item.journeyDuration())
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
                                            // return object of type Dialog
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
                                                title: new Text('Connections'),
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
                                    : Text('Direct Flight'),
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
                      children: <Widget>[
                        Text(
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
                                        .toStringAsFixed(2)),
                                style: new TextStyle(
                                  color: gblSystemColors
                                      .primaryButtonTextColor,
                                  fontSize: 12.0,
                                ),
                              )
                            : new Text('No Seats',
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
      MainAxisAlignment _mainAxisAlignment;
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
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Text(
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
                                          .toStringAsFixed(2)),
                                  style: new TextStyle(
                                    color: gblSystemColors
                                        .primaryButtonTextColor,
                                    fontSize: 12.0,
                                  ),
                                )
                              : new Text('No Seats',
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

  void goToClassScreen(int index, List<Flt> flts) async {
    var selectedFlt = await Navigator.push(
        context,
        SlideTopRoute(
            page: ChooseFlight(
          classband: objAv.availability.classbands.band[index],
          flts: flts, //objAv.availability.itin[0].flt,
          seats: widget.newBooking.passengers.adults +
              widget.newBooking.passengers.youths +
              widget.newBooking.passengers.children,
        )));
    flightSelected(selectedFlt);
  }

  void flightSelected(List<String> flt) {
    print(flt);
    if (flt != null && flt.length > 0) {
      this.widget.newBooking.returningflight = flt;
    }

    if (this.widget.newBooking.returningflight.length > 0 &&
        this.widget.newBooking.returningflight[0] != null &&
        this.widget.newBooking.outboundflight[0] != null) {
      hasDataConnection().then((result) {
        if (result == true) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FlightSelectionSummaryWidget(
                      newBooking: this.widget.newBooking)));
        } else {
          showSnackBar('Please check your internet connection');
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

  String calenderPrice(String currency, String price) {
    NumberFormat numberFormat = NumberFormat.simpleCurrency(
        locale: gblSettings.locale, name: currency);
    String _currencySymbol;
    _currencySymbol = numberFormat.currencySymbol;
    if (price.length == 0) {
      return 'N/A';
    } else {
      return _currencySymbol + price;
    }
  }
}
