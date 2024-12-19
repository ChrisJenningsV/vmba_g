
import 'package:flutter/material.dart';
import 'package:vmba/FlightSelectionSummary/FlightSelectionSummaryPage.dart';
import 'package:vmba/calendar/verticalFaresCalendar.dart';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/chooseFlight/chooseFlightPage.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/timeHelper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';

import '../Helpers/settingsHelper.dart';
import '../components/showDialog.dart';
import '../controllers/vrsCommands.dart';
import '../data/models/pnr.dart';
import '../passengerDetails/passengerDetailsPage.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import '../utilities/widgets/colourHelper.dart';
import '../v3pages/controls/V3Constants.dart';
import 'bookingFunctions.dart';
import 'calendarFunctions.dart';

class ReturnFlightSeletionPage extends StatefulWidget {
  ReturnFlightSeletionPage({Key key= const Key("retflt_key"), required this.newBooking,required this.outboundFlight, required this.outboundAvItem})
      : super(key: key);
  final NewBooking newBooking;
  final Flt outboundFlight;
  final AvItin outboundAvItem;
  @override
  _ReturnFlightSeletionState createState() => new _ReturnFlightSeletionState();
}

class _ReturnFlightSeletionState extends State<ReturnFlightSeletionPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _loadingInProgress = false;
  late ScrollController _scrollController;
  bool _noInternet = false;
  String _loading = '';
  String avErrorMsg = 'Please check your internet connection';

  DateTime _departureDate = DateTime.now();
  DateTime _returnDate= DateTime.now();

  AvailabilityModel? objAv;
  @override
  void initState() {
    super.initState();
    commonPageInit('RETURNING');

    //gblActionBtnDisabled = false;
    _loading = 'Searching for Flights';

    _scrollController = new ScrollController();
    _loadingInProgress = true;
    _noInternet = false;
    _loadData(false);
    _departureDate = DateTime.parse(
        DateFormat('y-MM-dd').format(widget.newBooking.departureDate as DateTime));

    if(widget.newBooking.returnDate!= null )    _returnDate = DateTime.parse(DateFormat('y-MM-dd').format(widget.newBooking.returnDate!));
  }

  String getAvReturnCommand(bool bRaw) {
    var buffer = new StringBuffer();
    buffer.write('A');
    buffer
        .write(new DateFormat('dd').format(this.widget.newBooking.returnDate!));
    buffer
        .write(new DateFormat('MMM').format(this.widget.newBooking.returnDate!));
    buffer.write(this.widget.newBooking.arrival);
    buffer.write(this.widget.newBooking.departure);

    buffer.write('[SalesCity=${this.widget.newBooking.arrival},Vars=True');
    if(  this.widget.newBooking.eVoucherCode.isNotEmpty && this.widget.newBooking.eVoucherCode != '' ){
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
    String outDate = DateFormat('ddMMMyyyy').format(this.widget.newBooking.departureDate as DateTime).toString().toUpperCase();
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
        this.widget.newBooking.ads.number != '') {
      if(this.widget.newBooking.ads.number.toUpperCase().contains('ADS')) {
        buffer.write(',ads=true');
      } else {
        buffer.write(',ADSResident=true');
      }
    }
    buffer.write(getPaxTypeCounts(this.widget.newBooking.passengers ));

    buffer.write(
        ',EarliestDate=${DateFormat('dd/MM/yyyy kk:mm:ss').format(this.widget.newBooking.departureDate as DateTime)}]');

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

  Future _loadData(bool doStatState ) async {
    _loadingInProgress = true;
    if( doStatState) setState(() {});
    Repository.get().getAv(getAvReturnCommand(/*gblSettings.useWebApiforVrs == false*/false )).then((rs) {
      if (rs.isOk()) {
        objAv = rs.body;
        removeDepartedFlights();
        try{
          objAv!.availability.MarkLowestFare();
        } catch(e) {

        }
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
      _loadData(false);
    });
  }

  void removeDepartedFlights() {
    if (objAv?.availability.itin != null) {
      int length = 1;
      if( objAv?.availability.itin?.length != null ) length = objAv?.availability.itin?.length as int ;
      length -= 1;
      for (int i = length; i >= 0; i--) {
        DateTime fltDate = DateTime.parse(
            objAv!.availability.itin![i].flt.first.time.ddaygmt +
                ' ' +
                (objAv!.availability.itin![i].flt.first.time.dtimgmt as String));
        if (fltDate.isBefore(getGmtTime().subtract(Duration(
            minutes: gblSettings.bookingLeadTime)))) {
          objAv!.availability.itin?.removeAt(i);
        }
      }
    }
  }

  void _dataLoaded() {
    int calenderWidgetSelectedItem = 0;
    double animateTo = 250;

    if (objAv!.availability.cal?.day != null) {
      for (var f in (objAv!.availability.cal?.day as List<Day>)) {
        if (DateTime.parse(f.daylcl).isAfter(_departureDate)) {
          calenderWidgetSelectedItem += 1;
          if (isSearchDate(DateTime.parse(f.daylcl), _returnDate)) {
            break;
          }
        }
      }
    }

    calenderWidgetSelectedItem = 0;
    for (var f in (objAv!.availability.cal?.day as List<Day>)) {
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
    // scroll control for cal day bar
    if (gblSettings.wantVericalFaresCalendar == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _scrollController.animateTo(animateTo,
              duration: new Duration(microseconds: 1), curve: Curves.ease));
    }
  }

  showSnackBar(String message) {
    final _snackbar = snackbar(message);
    ScaffoldMessenger.of(context).showSnackBar(_snackbar);
    //_key.currentState.showSnackBar(_snackbar);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress && gblInRefreshing == false) {
        return getProgressMessage(_loading, '');
    }

        return new Scaffold(
      key: _key,
      appBar: appBar(context,"Returning Flight", PageEnum.returningFlight),
        endDrawer: DrawerMenu(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_noInternet) {
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
                backgroundColor: gblSystemColors.primaryButtonColor,
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
      if( gblSettings.wantVericalFaresCalendar) return VerticalFaresCalendar( objAv:  objAv! , newBooking:  widget.newBooking, loadData: _loadData,isReturnFlight: true, showProgress: showProgress,);
      return flightSelection();
    }
  }
  void showProgress() {
    _loadingInProgress = true;
    setState(() {

    });
  }


  flightSelection() {
    EdgeInsets mar = EdgeInsets.symmetric(vertical: 1.0);
    if( wantHomePageV3()){
      mar = EdgeInsets.fromLTRB(10, 10, 0, 10);
    }


    if (!_returnDate.isBefore(_departureDate)) {
      return new Column(
        children: <Widget>[
          new Container(
            margin: mar,
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
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
              onPressed: () => showDatePicker(
                context: context,
                firstDate: _departureDate,
                initialDate: _departureDate,
                lastDate:
                    new DateTime.now().toUtc().add(new Duration(days: 363)),
               ).then((date) => _changeSearchDate(date!)),
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
    if (objAv != null || objAv!.availability.cal != null) {
      return new ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: (objAv!.availability.cal?.day as List<Day>)
              .map(
                (item) => getCalDay(item, 'ret' , widget.newBooking.returnDate!, _departureDate,
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
    if (objAv!.availability.itin != null) {
      return new ListView(
          scrollDirection: Axis.vertical,
          children: ((objAv!.availability.itin as List<AvItin>)
              .map(
                (item) =>flightItem( item),

              )
              .toList()));
    } else {
      return noFlightsFound();

    }
  }

  Widget flightItem( AvItin item) {
    if( wantHomePageV3() ) {
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
                pricebuttons(item, item.flt),
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


  validateSelection(AvItin avItem, index, item) {
    // get connect time
    int minConnTime = 0;

    if(widget.outboundAvItem.international == '1') {
      if( avItem.international == '1') {
        minConnTime = int.parse(avItem.arrmctii);
      } else {
        minConnTime = int.parse(avItem.arrmctid);
      }
    } else {
      if( avItem.international == '1') {
        minConnTime = int.parse(avItem.arrmctdi);
      } else {
        minConnTime = int.parse(avItem.arrmctdd);
      }
    }

    DateTime arrives =getFullTimeDate(widget.outboundFlight.time.adaylcl, widget.outboundFlight.time.atimlcl).add(Duration(minutes: minConnTime));
    DateTime departs = getFullTimeDate(item.first.time.ddaylcl, item.first.time.dtimlcl);

    logit( 'out arrives (inc conn): ' + arrives.toString());

    logit('ret leaves: ' + departs.toString());
    Classbands cbs ;
    cbs = objAv!.availability.classbands as Classbands;
    Band cb;
    cb = cbs.band![index];
    String bandName = cb.cbname;

    if (isJourneyAvailableForCb(item, index) == false) {
      print('No av');
    } else if (arrives.isAfter( departs) ) {
      showSnackBar(
          'This flight is before or to close to your outbound arrival time to book');
    } else if (((widget.newBooking.outboundflight[0].contains('[CB=Fly]') &&
            bandName == 'Fly Flex') ||
        (widget.newBooking.outboundflight[0].contains('[CB=Fly Flex]') &&
            bandName == 'Fly'))) {
      showSnackBar('Fly and Fly Flex can\'t be mixed within a booking');
    } else if (((widget.newBooking.outboundflight[0]
                .contains('[CB=Blue Fly]') &&
        bandName == 'Blue Flex') ||
        (widget.newBooking.outboundflight[0].contains('[CB=Blue Flex]') &&
            bandName == 'Blue Fly'))) {
      showSnackBar('Blue Fly and Blue Flex can\'t be mixed within a booking');
    } else {
      goToClassScreen(index, item);
    }
  }

  DateTime getFullTimeDate(String date, String time) {
    return DateTime.parse(date + ' ' + time.trim());
  }

  Widget pricebuttons(AvItin avItem, List<Flt> item) {
    if ((item[0].fltav.pri?.length as int) > 3) {
      return Wrap(
          spacing: 8.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          children: new List.generate(
              (item[0].fltav.pri?.length as int),
              (index) => GestureDetector(
                  onTap: () => {
                    if( gblNoNetwork == false ){
                      isJourneyAvailableForCb(item, index)
                          ? validateSelection(avItem, index, item)
                          : print('No av')
                    }
                      },
                  child: Chip(
                    backgroundColor: actionButtonColor(),
                    label: Column(
                      children: getPriceButtonList(objAv!.availability.classbands?.band![index].cbdisplayname, item, index, inRow: false),
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
      if (item[0].fltav.pri?.length == 2) {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      } else if (item[0].fltav.pri?.length == 3) {
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
      } else {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      }
      return new Row(
          mainAxisAlignment: _mainAxisAlignment,
          children: new List.generate(
            (item[0].fltav.pri?.length as int),
            (index) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                    //foregroundColor:gblSystemColors.primaryButtonColor,
                    backgroundColor: actionButtonColor(),
                    padding: new EdgeInsets.all(5.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                onPressed: () {
                  isJourneyAvailableForCb(item, index)
                      ? validateSelection(avItem,index, item) //goToClassScreen(index, item)
                      : print('No av');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: new Column(
                    children: getPriceButtonList(objAv!.availability.classbands?.band![index].cbdisplayname, item, index),
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
   // _loadingInProgress = true;
    gblActionBtnDisabled = false;
    _loading = 'Loading';
    var selectedFlt = await Navigator.push(
        context,
        SlideTopRoute(
            page: ChooseFlight(
          classband: objAv!.availability.classbands?.band![index],
          flts: flts, //objAv.availability.itin[0].flt,
          seats: widget.newBooking.passengers.adults +
              widget.newBooking.passengers.youths +
              widget.newBooking.passengers.seniors +
              widget.newBooking.passengers.students +
              widget.newBooking.passengers.children,
        )));
    if( selectedFlt != null ) {
      flightSelected(context, null, selectedFlt, flts,
          objAv!.availability.classbands?.band![index].cbname);
    }
  }

  void flightSelected(BuildContext context ,AvItin? avItem,List<String> flt, List<Flt> flts, String? className) {
    print(flt);
    if (flt != null && flt.length > 0) {
      this.widget.newBooking.returningflight = flt;
      this.widget.newBooking.returningflts = flts;
      this.widget.newBooking.returningClass = className as String;
    }

    _loadingInProgress = true;
    _loading = 'loading';
    if (this.widget.newBooking.returningflight.length > 0 &&
        this.widget.newBooking.returningflight[0] != null &&
        this.widget.newBooking.outboundflight[0] != null) {
      hasDataConnection().then((result) async {
        if (result == true) {
          if( gblSettings.wantProducts) {
            setError('');
            try {
            PnrModel pnrModel = await searchSaveBooking(
                this.widget.newBooking);
            // go to options page
            if (gblError != '') {
              showVidDialog(context, 'Error', gblError);
            } else {
              Navigator.push(
                  context,
                  //MaterialPageRoute(
                  CustomPageRoute(
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
            } catch(e){
              setError( e.toString());
              showVidDialog(context, 'Error', gblError);

            }
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FlightSelectionSummaryWidget(
                            newBooking: this.widget.newBooking)));
          }
        } else {
//          noInternetSnackBar(context);
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
      _loadData(false);
    });
  }


}
