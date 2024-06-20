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
import 'package:vmba/utilities/timeHelper.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/calendar/calendarFunctions.dart';

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

class FlightSeletionPage extends StatefulWidget {
  FlightSeletionPage({Key key= const Key("fltsel_key"), required this.newBooking}) : super(key: key);
  final NewBooking newBooking;
  @override
  _FlightSeletionState createState() => new _FlightSeletionState();
}

class _FlightSeletionState extends State<FlightSeletionPage> {
  bool _loadingInProgress = false;
  AvailabilityModel objAv = AvailabilityModel();
  ScrollController _scrollController = ScrollController();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _noInternet = false;
  String avErrorMsg = 'Please check your internet connection';
  String _loading = '';

  @override
  void initState() {
    super.initState();
    commonPageInit('NEWBOOKING');
    gblBookSeatCmd = '';

//    gblActionBtnDisabled = false;

    _scrollController = new ScrollController();
    gblActionBtnDisabled = false;
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

  int seatCount() {
    return widget.newBooking.passengers.adults +
        widget.newBooking.passengers.youths +
        widget.newBooking.passengers.seniors +
        widget.newBooking.passengers.students +
        widget.newBooking.passengers.children;
  }

  String getAvCommand(bool bRaw) {
    bRaw=true;
    var buffer = new StringBuffer();
    //String _salesCity = 'ABZ';
    //String _equalsSafeString = '%3D';
    //String _commaSafeString = '%2C';
    //Intl.defaultLocale = 'en'; // VRS need UK format

    buffer.write('A');
    buffer.write(
        new DateFormat('dd').format(this.widget.newBooking.departureDate as DateTime));
    buffer.write(
        new DateFormat('MMM').format(this.widget.newBooking.departureDate as DateTime));
    buffer.write(this.widget.newBooking.departure);
    buffer.write(this.widget.newBooking.arrival);
    // [
    if( bRaw ) {
      buffer.write('[');
    } else {
      buffer.write('%5B');
    }
    // voucher
    if( this.widget.newBooking.eVoucherCode != null && this.widget.newBooking.eVoucherCode.isNotEmpty && this.widget.newBooking.eVoucherCode != '' ){
      buffer.write('evoucher=${this.widget.newBooking.eVoucherCode.trim()},');
    }
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

      // add return details
      String retDate = '';
      if(this.widget.newBooking.returnDate != null)  DateFormat('ddMMMyyyy').format(this.widget.newBooking.returnDate!).toString().toUpperCase();
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

    if (this.widget.newBooking.ads.pin != '' &&        this.widget.newBooking.ads.number != '') {
        if(this.widget.newBooking.ads.number.toUpperCase().contains('ADS')) {
          buffer.write(',ads=true');
        } else {
          buffer.write(',ADSResident=true');
        }
    }


    buffer.write(getPaxTypeCounts(this.widget.newBooking.passengers ));

    buffer.write(
        ',EarliestDate=${DateFormat('dd/MM/yyyy kk:mm:ss').format(getGmtTime())}]');
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
    // clear out any current booking
    await runVrsCommand('I');


      Repository.get().getAv(getAvCommand(gblSettings.useWebApiforVrs == false)).then((rs) async {
      if (rs.isOk()) {
        objAv = rs.body!;
        removeDepartedFlights();
        _dataLoaded();

        // check if invalid voucher
        if( this.widget.newBooking.eVoucherCode != '' && objAv.availability.itin != null ){
          // look for discprice
          bool bFound = false;
          objAv.availability.itin!.forEach((element) {
            if( element.flt != null ){
              element.flt.forEach((flt) {
                if(flt.fltav.discprice!= null ) {
                  flt.fltav.discprice!.forEach((discprice) {
                    if( discprice != '' ) {
                      // logit('discp $discprice');
                      bFound = true;
                    }
                  });
                }
              });
            }
          });

        }
      } else if(rs.statusCode == notSinedIn)  {
        await login().then((result) {});
        Repository.get().getAv(getAvCommand(gblSettings.useWebApiforVrs == false)).then((rs) {
          objAv = rs.body!;

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
    final itin = objAv.availability.itin;
    if (itin != null) {
      int length = itin.length - 1;
      for (int i = length; i >= 0; i--) {
        DateTime fltDate = DateTime.parse(itin[i].flt.first.time.ddaygmt + ' ' + itin[i].flt.first.time.dtimgmt);
        //DateTime utcNow = DateTime.now().toUtc().subtract(Duration(minutes: gblSettings.bookingLeadTime));
        DateTime cutOffTime = getGmtTime().add(Duration(minutes: gblSettings.bookingLeadTime));
        // if flight is before cutoff time, remove it!
        if (fltDate.isBefore(cutOffTime)) {
          itin.removeAt(i);
        }
      }
    }
    // check days, removing any with no flights
    objAv.availability.cal!.day.forEach((element) {
      //print('check day ${element.daylcl}');
      if( DateFormat('yyyy-MM-dd').format(this.widget.newBooking.departureDate as DateTime) == element.daylcl){
        if( objAv.availability.itin == null || objAv.availability.itin?.length == 0){
          element.amt = '';
        }
      }
    });

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
        DateFormat('y-MM-dd').format(widget.newBooking.departureDate as DateTime));
    DateTime _currentDate =
        DateTime.parse(DateFormat('y-MM-dd').format(getGmtTime()));

    calenderWidgetSelectedItem = 0;
    if(objAv.availability.cal != null && objAv.availability.cal?.day != null  ) {
      for (var f in objAv.availability.cal!.day) {
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
    logit('obf b _loadingInProgress=$_loadingInProgress');
  if ( gblError!= null && gblError.isNotEmpty  ){
    return criticalErrorPageWidget( context, gblError,title: gblErrorTitle, onComplete:  onComplete, wantButtons: true);


  }
    return new Scaffold(
      key: _key,
      appBar: appBar(context,  "Outbound Flight",PageEnum.outboundFlight,
          leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () async {
          Navigator.pop(context, widget.newBooking);
        },
      )),

      endDrawer: DrawerMenu(),
      body: _buildBody(),
    );

    //return _buildBody();
  }
  void onComplete (dynamic p) {
    setError( '');
    setState(() {});
  }

  Widget _buildBody() {
    if (_loadingInProgress) {
      if( gblSettings.wantCustomProgress) {
        progressMessagePage(context, _loading, title: '');
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
                  backgroundColor: gblSystemColors.primaryButtonColor),
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
    if (objAv != null && objAv.availability.cal != null && objAv.availability.cal!.day != null) {
      return new ListView(
          shrinkWrap: true,
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: objAv.availability.cal!.day
              .map(
                (item) =>
                    getCalDay(item, 'out', widget.newBooking.departureDate as DateTime, DateTime.parse(DateFormat('y-MM-dd').format(getGmtTime())),
                        onPressed:() => {
                    hasDataConnection().then((result) {
                    if (result == true) {
                    _changeSearchDate(DateTime.parse(item.daylcl));
                    } else {
//                    noInternetSnackBar(context);
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
    if (objAv != null && objAv.availability.itin != null && objAv.availability.itin!.length > 0) {
      return new
      ListView(
          scrollDirection: Axis.vertical,
          children: (objAv.availability.itin!
              .map(
                (item) =>  flightItem( item),
              )
              .toList()));
    } else {
      return noFlightsFound();
    }
  }

  Widget flightItem(AvItin item){
      if( wantHomePageV3()  ) {
        int seatCount = widget.newBooking.passengers.adults +
            widget.newBooking.passengers.youths +
            widget.newBooking.passengers.seniors +
            widget.newBooking.passengers.students +
            widget.newBooking.passengers.children;
        return
             CalFlightItemWidget( newBooking: widget.newBooking, objAv:  objAv, item: item, flightSelected: flightSelected ,seatCount: seatCount,); //  calFlightItem(context,widget.newBooking, objAv, item);
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
                  _pricebuttons(item, item.flt),
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
    EdgeInsets mar = EdgeInsets.symmetric(vertical: 1.0);
    if( wantHomePageV3()){
      mar = EdgeInsets.fromLTRB(10, 10, 0, 10);
    }

    return new Column(
      children: <Widget>[
        new Container(
          //margin: EdgeInsets.symmetric(vertical: 1.0),
          margin: mar,
          //height: 70.0,
          constraints: new BoxConstraints(
            minHeight: 65.0,
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

  void goToClassScreen(AvItin avItem,int index, List<Flt> flts) async {
    //_loadingInProgress = true;
    gblActionBtnDisabled = false;
    _loading = 'Loading';
    double pri = 0.0;
    String currency='';
    flts.forEach((element) {
      if(element.fltav.discprice != null  && element.fltav.discprice!.length > index &&
          element.fltav.discprice![index] != null &&
          element.fltav.discprice![index].isNotEmpty && element.fltav.discprice![index] != '0'

      ){
        pri += double.tryParse(element.fltav.discprice![index]) as double;
      } else {
        pri += double.tryParse(element.fltav.pri![index] ) as double;
      }
      currency = element.fltav.cur![index];
    });

    var selectedFlt = await Navigator.push(
        context,
        SlideTopRoute(
            page: ChooseFlight(
          classband: objAv.availability.classbands!.band![index],
          flts: flts, //objAv.availability.itin[0].flt,
          price: pri,
          currency: currency,
          seats: widget.newBooking.passengers.adults +
              widget.newBooking.passengers.youths +
              widget.newBooking.passengers.seniors +
              widget.newBooking.passengers.students +
              widget.newBooking.passengers.children,
        )));
    _loadingInProgress = false;
    if( selectedFlt != null ) {
      _loadingInProgress = true;
      setState(() {
      });
      flightSelected(context, avItem, selectedFlt, flts,
          objAv.availability.classbands!.band![index].cbname);
    }
  }

  void flightSelected(BuildContext context,AvItin? avItem, List<String> flt, List<Flt> outboundflts, String className) {
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
                          outboundAvItem: avItem as AvItin,
                        )));
          } else if (this.widget.newBooking.outboundflight[0] != null) {

            if( gblSettings.wantProducts) {
              // first save new booking
              setError( '');
              try {
                PnrModel pnrModel = await searchSaveBooking(
                    this.widget.newBooking);
                gblPnrModel = pnrModel;
                refreshStatusBar();
                // go to options page
                if (gblError != '') {
                  showAlertDialog(context, 'Error', gblError, onComplete:() { gblError = ''; setState(() {}); });
                } else {
                  Navigator.push(
                      context,
                      //MaterialPageRoute(
                      CustomPageRoute(
                          builder: (context) =>
                              PassengerDetailsWidget(
                                newBooking: widget.newBooking,
                                pnrModel: pnrModel,)));
                }
              } catch(e){
                setError( e.toString());
                showAlertDialog(context, 'Error', gblError);

              }

            } else {

              Navigator.push(
                  context,
                 // MaterialPageRoute(
                  CustomPageRoute(
                      builder: (context) =>
                          FlightSelectionSummaryWidget(
                              newBooking: this.widget.newBooking)));
            }
          }
        } else {
          logit('FlightSelected: no iternet');
//          noInternetSnackBar(context);
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


  Widget _pricebuttons(AvItin avItem, List<Flt> item) {
     if (item[0].fltav.pri!.length > 3) {
      return Wrap(
          spacing: 8.0, //gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          children: new List.generate(
              item[0].fltav.pri!.length,
              (index) => GestureDetector(
                  onTap: () => {
                    if( gblNoNetwork == false ){
                      isJourneyAvailableForCb(item, index)
                          ? goToClassScreen(avItem, index, item)
                          : print('No av')
                    }
                      },
                  child: Chip(
                    backgroundColor: actionButtonColor(),
                    label: Column(
                      children: getPriceButtonList(objAv.availability.classbands!.band![index].cbdisplayname, item, index, inRow: false),

                    ),
                  ))));
    } else {
      MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.spaceAround;
      if (item[0].fltav.pri!.length == 2) {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      } else if (item[0].fltav.pri!.length == 3) {
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
      }
      return new Row(
          mainAxisAlignment: _mainAxisAlignment,
          children: new List.generate(
            item[0].fltav.pri!.length,
            (index) => ElevatedButton(
                onPressed: () {
                  if( gblNoNetwork == false) {
                    isJourneyAvailableForCb(item, index)
                        ? goToClassScreen(avItem, index, item)
                        : print('No av');
                  }
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    backgroundColor: actionButtonColor(),
                    padding: new EdgeInsets.all(5.0)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: new Column(
                    children: getPriceButtonList(objAv.availability.classbands!.band![index].cbdisplayname, item, index),
                  ),
                )),
          ));
    }
  }
}
