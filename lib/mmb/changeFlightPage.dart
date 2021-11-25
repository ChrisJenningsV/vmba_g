import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/chooseFlight/chooseFlightPage.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/mmb/widgets/flight_selection_summary.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/components/trText.dart';

// ignore: must_be_immutable
class ChangeFlightPage extends StatefulWidget {
  ChangeFlightPage(
      {Key key,
      this.pnr,
      // this.journey,
      this.departureDate, //this.journeys,
      this.mmbBooking})
      : super(key: key);
  final PnrModel pnr;
  DateTime departureDate;
  MmbBooking mmbBooking;
  @override
  _ChangeFlightState createState() => new _ChangeFlightState();
}

class _ChangeFlightState extends State<ChangeFlightPage> {
  bool _loadingInProgress;
  AvailabilityModel objAv;
  ScrollController _scrollController;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _noInternet;
  bool _isReturn;
  @override
  void initState() {
    super.initState();
    _isReturn = isReturn();
    _scrollController = new ScrollController();
    _loadingInProgress = true;
    _noInternet = false;

    // check if we are redeeming airmiles
    gblRedeemingAirmiles = false;
    if( widget.pnr != null && widget.pnr.pNR != null && widget.pnr.pNR.payments != null && widget.pnr.pNR.payments.fOP != null) {
      widget.pnr.pNR.payments.fOP.forEach((element) {
        if (element.fOPID == 'ZZZ') {
          gblRedeemingAirmiles = true;
        };
      });
    }

    _loadData();
  }

  bool isReturn() {
    return (this
                    .widget
                    .pnr
                    .pNR
                    .itinerary
                    .itin
                    .where((itin) => itin.stops == '0')
                    .length -
                this
                    .widget
                    .pnr
                    .pNR
                    .itinerary
                    .itin
                    .where((itin) => itin.nostop == 'X')
                    .length) >
            1
        ? true
        : false;
  }

  retrySearch() {
    setState(() {
      _loadingInProgress = true;
      _noInternet = false;
      _loadData();
    });
  }

  String getAvCommand() {
    //Intl.defaultLocale = 'en';
    var buffer = new StringBuffer();
    buffer.write('A');
    buffer.write(new DateFormat('dd').format(this.widget.departureDate));
    buffer.write(new DateFormat('MMM').format(this.widget.departureDate));
    buffer.write(this
        .widget
        .mmbBooking
        .journeys
        .journey[widget.mmbBooking.journeyToChange - 1]
        .itin
        .first
        .depart);
    buffer.write(this
        .widget
        .mmbBooking
        .journeys
        .journey[widget.mmbBooking.journeyToChange - 1]
        .itin
        .last
        .arrive);
    buffer.write('%5B');
    buffer.write(
        'SalesCity=${this.widget.pnr.pNR.itinerary.itin[widget.mmbBooking.journeyToChange - 1].depart}');
    buffer.write(',Vars=True');
    buffer.write(',ClassBands=True');
    if( gblRedeemingAirmiles) {
      buffer.write(',FQTV=True');
    }

    buffer
        .write(',StartCity=${this.widget.pnr.pNR.itinerary.itin.first.depart}');
    if (_isReturn) {
      buffer.write(',SingleSeg=r');
      if( widget.mmbBooking.journeyToChange > 1) {
        // add outbound details
        String outDate = DateFormat('dMMMyyyy').format(DateTime.parse(this.widget.mmbBooking.journeys.journey[0].itin.first.ddaygmt)).toString().toUpperCase();
        String arrDate = DateFormat('dMMMyyyy').format(DateTime.parse(this.widget.mmbBooking.journeys.journey[0].itin.first.adaygmt)).toString().toUpperCase();
        buffer.write(',RFAD=$arrDate,DEPART=$outDate');
      } else {
        // add return details
        String retDate = DateFormat('dMMMyyyy').format(DateTime.parse(this.widget.mmbBooking.journeys.journey[1].itin.first.ddaygmt)).toString().toUpperCase();
        buffer.write(',RFDD=$retDate,RETURN=$retDate');

      }
    } else {
      buffer.write(',SingleSeg=s');
    }
    buffer.write(',FGNoAv=True');
    String _paxSeatsRequire = (this
                .widget
                .pnr
                .pNR
                .names
                .pAX
                .where((pax) => pax.paxType == 'AD')
                .length +
            this
                .widget
                .pnr
                .pNR
                .names
                .pAX
                .where((pax) => pax.paxType == 'CH')
                .length +
            this
                .widget
                .pnr
                .pNR
                .names
                .pAX
                .where((pax) => pax.paxType == 'TH')
                .length)
        .toString();
    buffer.write(',qtyseats=$_paxSeatsRequire');
    String _journey = '';
    if (_isReturn) {
      _journey = _journey =
          '${this.widget.mmbBooking.journeys.journey.first.itin.first.depart}-${this.widget.mmbBooking.journeys.journey.first.itin.last.arrive}-${this.widget.mmbBooking.journeys.journey.last.itin.last.arrive}';
    } else {
      _journey =
          '${this.widget.mmbBooking.journeys.journey.first.itin.first.depart}-${this.widget.mmbBooking.journeys.journey.last.itin.last.arrive}';
    }
    buffer.write(',journey=$_journey');

    if (this.widget.pnr.pNR.aDS == 'True') buffer.write(',ads=true');

    buffer.write(getPaxTypeCounts(this.widget.mmbBooking.passengers ));

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
        if (fltDate.isBefore(DateTime.now().toUtc().subtract(Duration(
            minutes: gblSettings.bookingLeadTime)))) {
          objAv.availability.itin.removeAt(i);
        }
      }
    }
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //final _snackbar = snackbar(message);
    //_key.currentState.showSnackBar(_snackbar);
  }

  void _dataLoaded() {
    int calenderWidgetSelectedItem;
    double animateTo = 250;
    DateTime _departureDate =
        DateTime.parse(DateFormat('y-MM-dd').format(widget.departureDate));
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

  validateSelection(index, item) {
    int noneChangingJourney = 0;
    if (widget.mmbBooking.journeys.journey.length > 1) {
      if (widget.mmbBooking.journeyToChange == 1) {
        noneChangingJourney = 1;
      } else {
        noneChangingJourney = 0;
      }
    }

    if (item[0].fltav.fav[index] == '0') {
      print('No av');
    } else if ((widget.mmbBooking.journeys.journey[noneChangingJourney].itin
                    .first.classBand
                    .toUpperCase() ==
                'BLUE FLEX' &&
            objAv.availability.classbands.band[index].cbname.toUpperCase() ==
                'BLUE FLY') ||
        (widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                    .classBand
                    .toUpperCase() ==
                'BLUE FLY' &&
            objAv.availability.classbands.band[index].cbname.toUpperCase() ==
                'BLUE FLEX')) {
      showSnackBar(
          'You can only change to another ${widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first.classBand} flight');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'FLY FLEX' &&
        objAv.availability.classbands.band[index].cbname == 'Fly') {
      showSnackBar('Fly and Fly Flex can\'t be mixed within a booking');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'FLY' &&
        objAv.availability.classbands.band[index].cbname == 'Fly Flex') {
      showSnackBar('Fly and Fly Flex can\'t be mixed within a booking');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'BLUE FLEX' &&
        objAv.availability.classbands.band[index].cbname == 'Blue Fly') {
      showSnackBar('Blue Fly and Blue Flex can\'t be mixed within a booking');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'BLUE FLY' &&
        objAv.availability.classbands.band[index].cbname == 'Blue Flex') {
      showSnackBar('Blue Fly and Blue Flex can\'t be mixed within a booking');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeyToChange == 2 &&
        getFullTimeDate(
                widget.mmbBooking.journeys.journey[noneChangingJourney].itin
                    .first.depDate,
                widget.mmbBooking.journeys.journey[noneChangingJourney].itin
                    .first.depTime)
            .isAfter(
                getFullTimeDate(item[0].time.ddaylcl, item[0].time.dtimlcl))) {
      showSnackBar(
          'This flight is before or to close to your outbound arrival time to book');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeyToChange == 1 &&
        getFullTimeDate(
                widget.mmbBooking.journeys.journey[noneChangingJourney].itin
                    .first.depDate,
                widget
                    .mmbBooking
                    .journeys
                    .journey[widget.mmbBooking.journeyToChange]
                    .itin
                    .first
                    .depTime)
            .isBefore(
                getFullTimeDate(item[0].time.ddaylcl, item[0].time.atimlcl))) {
      showSnackBar(
          'This flight is after or to close to your return departure time to book');
    } else {
      goToClassScreen(index, item);
    }
  }

  DateTime getFullTimeDate(String date, String time) {
    return DateTime.parse(date + ' ' + time.trim());
  }

  _changeSearchDate(DateTime newDate) {
    print(this.widget.departureDate.toString());
    setState(() {
      this.widget.departureDate = newDate;
      _loadingInProgress = true;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _key,
      appBar: new AppBar(
        //brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new Text("Choose Flight",
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
              child: Text('Searching for Flights'),
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
              child: Text('Please check your internet connection'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  primary: Colors.black),
              onPressed: () => retrySearch(),
              child: Text(
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

  /*
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

   */

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
                    color: !isSearchDate(
                            DateTime.parse(item.daylcl), widget.departureDate)
                        ? Colors.white
                        : gblSystemColors.accentButtonColor,
                  ),
                  width: DateTime.parse(item.daylcl).isBefore(DateTime.parse(
                          DateFormat('y-MM-dd').format(DateTime.now().toUtc())))
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
                            new Text(getIntlDate('EEE dd', DateTime.parse(item.daylcl)),
                              //new DateFormat('EEE dd').format(DateTime.parse(item.daylcl)),
                              style: TextStyle(
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.departureDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            new Text(
                              'from',
                              style: TextStyle(
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.departureDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            //new Text(item.cur + item.amt)
                            new Text(
                              calenderPrice(item.cur, item.amt, '0'),
                              style: TextStyle(
                                  color: isSearchDate(
                                          DateTime.parse(item.daylcl),
                                          widget.departureDate)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ])),
                ),
              )
              .toList());
    } else {
      return new Text('No Calender results');
    }
  }

  Widget flightAvailability() {
    if (objAv != null && objAv.availability.itin != null) {
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
                                    return new Text(text.data,
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w300));
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
                                Text(getIntlDate('EEE dd MMM',DateTime.parse(item.flt.last.time.adaylcl)),
                                    //new DateFormat('EEE dd MMM h:mm a').format(DateTime.parse(item.flt.last.time.adaylcl)).toString().substring(0, 10),
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
                                    return new Text(text.data,
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w300));
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
                                                    child: new Text("OK"),
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

  flightSelection() {
    return new Column(
      children: <Widget>[
        new Container(
          margin: EdgeInsets.symmetric(vertical: 1.0),
          //height: 60.0,
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
          seats: (this
                      .widget
                      .pnr
                      .pNR
                      .names
                      .pAX
                      .where((pax) => pax.paxType == 'AD')
                      .length +
                  this
                      .widget
                      .pnr
                      .pNR
                      .names
                      .pAX
                      .where((pax) => pax.paxType == 'CH')
                      .length +
              this
                  .widget
                  .pnr
                  .pNR
                  .names
                  .pAX
                  .where((pax) => pax.paxType == 'CD')
                  .length +
              this
                  .widget
                  .pnr
                  .pNR
                  .names
                  .pAX
                  .where((pax) => pax.paxType == 'SD')
                  .length +
              this
                  .widget
                  .pnr
                  .pNR
                  .names
                  .pAX
                  .where((pax) => pax.paxType == 'TD')
                  .length +
                  this
                      .widget
                      .pnr
                      .pNR
                      .names
                      .pAX
                      .where((pax) => pax.paxType == 'TH')
                      .length)
              .toString(),
        )));
    flightSelected(selectedFlt, flts);
  }

  void flightSelected(List<String> flt, List<Flt> outboundflts) {
    NewBooking newFlight = NewBooking();
    newFlight.outboundflight = [];
    // List<String>();
    if (flt != null) {
      print(flt);
      if (flt != null && flt.length > 0) {
        newFlight.outboundflight = flt;
        widget.mmbBooking.newFlights = flt;
        print('Capture choice');
      }

      hasDataConnection().then((result) {
        if (result == true) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FlightSelectionSummaryWidget(
                        // newBooking: newFlight,
                        mmbBooking: widget.mmbBooking,
                        //journeys: widget.journeys,
                        //intJourney: widget.journey,
                      )));
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
                                        .toStringAsFixed(2),'0'),
                                style: new TextStyle(
                                  color: Colors.white,
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
                                          .toStringAsFixed(2),'0'),
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
