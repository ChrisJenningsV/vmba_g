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

import '../Helpers/settingsHelper.dart';
import '../calendar/calendarFunctions.dart';
import '../utilities/messagePages.dart';

// ignore: must_be_immutable
class ChangeFlightPage extends StatefulWidget {
  ChangeFlightPage(
      {Key key= const Key("changflt_key"),
      required this.pnr,
      // this.journey,
      required this.departureDate, //this.journeys,
      required this.mmbBooking})
      : super(key: key);
  final PnrModel pnr;
  DateTime departureDate;
  MmbBooking mmbBooking;
  @override
  _ChangeFlightState createState() => new _ChangeFlightState();
}

class _ChangeFlightState extends State<ChangeFlightPage> {
  bool _loadingInProgress= false  ;
  AvailabilityModel objAv = AvailabilityModel();
  ScrollController _scrollController = ScrollController();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _noInternet = false;
  bool _isReturn = false;
  @override
  void initState() {
    super.initState();
    _isReturn = isReturn();
    _scrollController = new ScrollController();
    _loadingInProgress = true;
    _noInternet = false;
    gblPayAction = 'CHANGEFLT';

    gblBookingState = BookingState.changeFlt;

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

  String getAvCommand(bool bRaw) {
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
    if(bRaw) {
      buffer.write('[');
    } else {
      buffer.write('%5B');
    }
    buffer.write(
        'SalesCity=${this.widget.pnr.pNR.itinerary.itin[widget.mmbBooking.journeyToChange - 1].depart}');
/*
    if( this.widget.newBooking.eVoucherCode != null && this.widget.newBooking.eVoucherCode.isNotEmpty && this.widget.newBooking.eVoucherCode != '' ){
      buffer.write(',evoucher=${this.widget.newBooking.eVoucherCode}');
    }
*/

    buffer.write(',Vars=True');
    buffer.write(',ClassBands=True');
    // get currency from booking

    buffer.write(',QuoteCurrency=${this.widget.pnr.getBookingCurrency()}');
    if( gblRedeemingAirmiles) {
      buffer.write(',FQTV=True');
    }

    buffer
        .write(',StartCity=${this.widget.pnr.pNR.itinerary.itin.first.depart}');
    if (_isReturn) {
      buffer.write(',SingleSeg=r');
      if( widget.mmbBooking.journeyToChange > 1) {
        // add outbound details
        String outDate = DateFormat('ddMMMyyyy').format(DateTime.parse(this.widget.mmbBooking.journeys.journey[0].itin.first.ddaygmt)).toString().toUpperCase();
        String arrDate = DateFormat('ddMMMyyyy').format(DateTime.parse(this.widget.mmbBooking.journeys.journey[0].itin.first.adaygmt)).toString().toUpperCase();
        buffer.write(',RFAD=$arrDate,DEPART=$outDate');
      } else {
        // add return details
        String retDate = DateFormat('ddMMMyyyy').format(DateTime.parse(this.widget.mmbBooking.journeys.journey[1].itin.first.ddaygmt)).toString().toUpperCase();
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

    String msg =buffer.toString();
    logit('getAvCommand ch: ' + msg);
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
    // rload booking
    String cmd = '*${this.widget.pnr.pNR.rLOC}[MMB]';
    logit(cmd);
    await await runVrsCommand(cmd);


    Repository.get().getAv(getAvCommand(gblSettings.useWebApiforVrs == false)).then((rs) {
      if (rs.isOk()) {
        objAv = rs.body!;
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
      int length = objAv.availability.itin!.length - 1;
      for (int i = length; i >= 0; i--) {
        DateTime fltDate = DateTime.parse(
            objAv.availability.itin![i].flt.first.time.ddaygmt +
                ' ' +
                objAv.availability.itin![i].flt.first.time.dtimgmt);
        if (fltDate.isBefore(DateTime.now().toUtc().subtract(Duration(
            minutes: gblSettings.bookingLeadTime)))) {
          objAv.availability.itin!.removeAt(i);
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
    for (var f in objAv.availability.cal!.day) {
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
    endProgressMessage();

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

    if (isJourneyAvailableForCb(item, index) == false) {
      print('No av');
    } else if ((widget.mmbBooking.journeys.journey[noneChangingJourney].itin
                    .first.classBand
                    .toUpperCase() ==
                'BLUE FLEX' &&
            objAv.availability.classbands!.band![index].cbname.toUpperCase() ==
                'BLUE FLY') ||
        (widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                    .classBand
                    .toUpperCase() ==
                'BLUE FLY' &&
            objAv.availability.classbands!.band![index].cbname.toUpperCase() ==
                'BLUE FLEX')) {
      showSnackBar(
          'You can only change to another ${widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first.classBand} flight');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'FLY FLEX' &&
        objAv.availability.classbands!.band![index].cbname == 'Fly') {
      showSnackBar('Fly and Fly Flex can\'t be mixed within a booking');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'FLY' &&
        objAv.availability.classbands!.band![index].cbname == 'Fly Flex') {
      showSnackBar('Fly and Fly Flex can\'t be mixed within a booking');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'BLUE FLEX' &&
        objAv.availability.classbands!.band![index].cbname == 'Blue Fly') {
      showSnackBar('Blue Fly and Blue Flex can\'t be mixed within a booking');
    } else if (widget.mmbBooking.journeys.journey.length > 1 &&
        widget.mmbBooking.journeys.journey[noneChangingJourney].itin.first
                .classBand
                .toUpperCase() ==
            'BLUE FLY' &&
        objAv.availability.classbands!.band![index].cbname == 'Blue Flex') {
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
      if( gblSettings.wantCustomProgress) {
        progressMessagePage(context, 'Searching for Flights', title: 'loading');
        return Container();
      } else {
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
      }
    } else if (_noInternet) {
      return new Center(
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
          children: objAv.availability.cal!.day
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
      return new TrText('No Calender results');
    }
  }

  Widget flightAvailability() {
    if (objAv != null && objAv.availability.itin != null) {
      return new ListView(
          scrollDirection: Axis.vertical,
          children: (objAv.availability.itin!
              .map(
                (item) => flightItem(item),

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

  Widget flightItem(AvItin item) {
    if( wantPageV2() ) {
      int seatCount =
        this.widget.pnr.pNR.names.pAX.where((pax) => pax.paxType == 'AD').length +
          this.widget.pnr.pNR.names.pAX.where((pax) => pax.paxType == 'CH').length +
          this.widget.pnr.pNR.names.pAX.where((pax) => pax.paxType == 'CD').length +
          this.widget.pnr.pNR.names.pAX.where((pax) => pax.paxType == 'SD').length +
          this.widget.pnr.pNR.names.pAX.where((pax) => pax.paxType == 'TD').length +
          this.widget.pnr.pNR.names.pAX.where((pax) => pax.paxType == 'TH').length;

      return CalFlightItemWidget(  objAv:  objAv, item: item, flightSelected: flightSelected ,seatCount: seatCount,); //  calFlightItem(context,widget.newBooking, objAv, item);
    } else {
      return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.only(
              left: 8.0, right: 8.0, bottom: 8.0, top: 8.0),
          child: Column(
            children: <Widget>[

              flightRow(context, item),
              Divider(),
              gblSettings.wantCanFacs ? CannedFactWidget(flt: item.flt) : Container(),
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


  void goToClassScreen(int index, List<Flt> flts) async {
    gblActionBtnDisabled = false;
    var selectedFlt = await Navigator.push(
        context,
        SlideTopRoute(
            page: ChooseFlight(
          classband: objAv.availability.classbands!.band![index],
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
    flightSelected(context,null, selectedFlt, flts, '');
  }

  void flightSelected(BuildContext context,AvItin? avItem, List<String> flt, List<Flt> outboundflts, String c) {
    NewBooking newFlight = NewBooking();
    newFlight.outboundflight = [];
    widget.mmbBooking.currency = this.widget.pnr.getBookingCurrency();
    // List<String>();
    if(flt != null) {
      //print(flt);
      if (flt != null && flt.length > 0) {
        newFlight.outboundflight = flt;
        widget.mmbBooking.newFlights = flt;
        //print('Capture choice');
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
    int noItems =item[0].fltav.pri!.length;

   /* item.forEach((element) {
      int noAV = 0;
      element.fltav.fav!.forEach((avelement) {
        if(avelement != '' && avelement != '0' ) noAV +=1;
      });
      logit('len = $noAV');
      if( noAV < noItems){
        noItems = noAV;
      }
    });*/

//  logit('noItems = $noItems');

    if (noItems > 3) {
      return Wrap(
          spacing: 8.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          children: new List.generate(
              noItems,
              (index) => GestureDetector(
                  onTap: () => {
                    isJourneyAvailableForCb(item, index)
                            ? goToClassScreen(index, item)
                            : print('No av')
                      },
                  child: Chip(
                    backgroundColor:
                    gblSystemColors.primaryButtonColor,
                    label: Column(
                      children: getPriceButtonList(objAv.availability.classbands!.band![index].cbdisplayname, item, index, inRow: false),
                    ),
                  ))));
    } else {
      MainAxisAlignment _mainAxisAlignment;
      if (noItems == 2) {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      } else if (noItems == 3) {
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
      } else {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      }
      return new Row(
          mainAxisAlignment: _mainAxisAlignment,
          children: new List.generate(
            noItems,
            (index) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary:
                    gblSystemColors.primaryButtonColor,
                    padding: new EdgeInsets.all(5.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                onPressed: () {

                  isJourneyAvailableForCb(item, index)
                      ? validateSelection(
                          index, item) //goToClassScreen(index, item)
                      : print('No av');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: new Column(
                    children: getPriceButtonList(objAv.availability.classbands!.band![index].cbdisplayname, item, index),
                  ),
                )),
          ));
    }
  }
}
