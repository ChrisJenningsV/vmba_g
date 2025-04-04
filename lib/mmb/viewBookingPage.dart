
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vmba/data/models/pax.dart';
import 'package:vmba/mmb/widgets/apis.dart';
import 'package:vmba/mmb/widgets/boardingPass.dart';
import 'dart:math' as math;
import 'package:vmba/mmb/widgets/datepicker.dart';
import 'package:vmba/mmb/widgets/seatplan.dart';
import 'package:vmba/passengerDetails/DangerousGoodsWidget.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/models/pnr.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/models/cities.dart';
import 'package:provider/provider.dart';
import 'package:vmba/data/models/apis_pnr.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/utilities/timeHelper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/data/models/vrsRequest.dart';

import '../Helpers/dateTimeHelper.dart';
import '../Helpers/networkHelper.dart';
import '../components/showDialog.dart';
import '../components/vidButtons.dart';
import '../components/vidGraphics.dart';
import '../controllers/vrsCommands.dart';
import '../Managers/commsManager.dart';
import '../home/home_page.dart';
import '../menu/contact_us_page.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/colourHelper.dart';
import '../utilities/widgets/dataLoader.dart';
import '../v3pages/controls/V3AppBar.dart';
import '../v3pages/controls/V3Constants.dart';
part 'viewBookingPagePax.dart';

enum Month { jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec }

//int _journeyToChange;
MmbBooking _mmbBooking = MmbBooking();
bool buttonEnabled = false;
//PnrModel pnr;

bool wantChangeAnyFlight = true;

class PnrChangeNotifier with ChangeNotifier {
  PnrModel _pnr = new PnrModel();

  PnrModel get statePnr => _pnr;

  set statePnr(PnrModel newValue) {
    _pnr = newValue;
    notifyListeners();
  }
}

class ViewBookingPage extends StatefulWidget {
  ViewBookingPage({Key key= const Key("viewbpag_key"), this.rloc=''}) : super(key: key);
  String rloc;


  ViewBookingPageState createState() => ViewBookingPageState();
}

class ViewBookingPageState extends State<ViewBookingPage> {
  //final String rloc;

  //CheckinBoardingPassesPage({this.rloc});
  GlobalKey<ScaffoldState> _key = GlobalKey();
  late bool _buttonEnabled ;

  // int currentPaxNo;
  // int currentJourneyNo;

  @override
  initState() {
    gblCurPage = 'VIEWBOOKING';
    gblActionBtnDisabled = false;
    _buttonEnabled = false;
    setError( '');
    gblPaymentMsg = '';
    if(widget.rloc == null || widget.rloc == ''){
      widget.rloc = gblCurrentRloc;
    }

    super.initState();
  }

  @override void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gblCurrentRloc = widget.rloc;

    Color menuColor = gblSystemColors.headerTextColor as Color;
    /*   if (gblPnrModel != null &&
        double.parse(gblPnrModel!.pNR.basket.outstanding.amount) > 0) {
      menuColor = Colors.red;
    }*/

    //  int noSeats = gblPnrModel!.pNR.seatCount();

    return ChangeNotifierProvider(
      //builder: (context) => PnrChangeNotifier(),
        create: (context) => PnrChangeNotifier(),
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(

              key: _key,
              appBar: V3AppBar(
                PageEnum.myBookings,
                //brightness: gblSystemColors.statusBar,
                //backgroundColor:gblSystemColors.primaryHeaderColor,
                actions: [
                  Builder(
                    builder: (context) =>
                        IconButton(
                          icon: Icon(Icons.menu,),
                          color: menuColor,
                          onPressed: () {
                            if (gblPnrModel != null &&
                                gblPnrModel!.isFundTransferPayment() == false &&
                                double.parse(
                                    gblPnrModel!.pNR.basket.outstanding.amount) >
                                    0) {
                              _getDialog();
                            } else {
                              Scaffold.of(context).openEndDrawer();
                            }
                          },
                          tooltip: MaterialLocalizations
                              .of(context)
                              .openAppDrawerTooltip,
                        ),
                  ),
                ],
                iconTheme: IconThemeData(
                    color: gblSystemColors.headerTextColor),
                titleText: gblSettings.wantNewMMB ? 'Manage My Booking' : "My Booking",
              ),
              endDrawer: DrawerMenu(),
              body: new Container(
                child: new Center(
                    child: new RefreshIndicator(
                        child: ViewBookingBody(
                          rloc: widget.rloc,
                          onLoad: _onLoad,
                          showSnackBar: showSnackBar,
                          key: mmbGlobalKeyBooking,),
                        onRefresh: doRefresh //(context),
                    )),
              )),
        ));
  }
  Future <void> doRefresh() async{
    refreshBooking(gblCurrentRloc);
    setState(() {

    });
  }
  void _onLoad(BuildContext? context) {
    setState(() {

    });
  }



  void _getDialog() {
    showDialog(
      context: context,
      builder: (context) =>
      new AlertDialog(
        title: new TrText('Payment outstanding'),
        content: new Text(translate('Do you want to pay ') + ' ${formatPrice( gblPnrModel!.pNR.basket.outstanding.cur,double.parse(gblPnrModel!.pNR.basket.outstanding.amount))} ' + translate('now')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              gblPayBtnDisabled = false;
              Navigator.of(context).pop(false);
            },
            child: new TrText('No'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                foregroundColor: gblSystemColors.primaryButtonTextColor,
                backgroundColor: gblSystemColors.primaryButtonColor
            ),
            onPressed: () {
              //gblPnrModel = pnr;
              gblPaymentMsg = '';
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChoosePaymenMethodWidget(
                            mmbBooking: _mmbBooking,
                            pnrModel: gblPnrModel!,
                            isMmb: true,
                            mmbAction: 'PAYOUTSTANDING',
                            mmbCmd: '',
                          )));
            },
            child: new TrText('Pay now'),
          ),
        ],
      ),
    );
  }




  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //final _snackbar = snackbar(message);
    //_key.currentState.showSnackBar(_snackbar);
  }


  Future<bool> _onWillPop() async {
    // not this page!
    return true;
    if (double.parse(gblPnrModel!.pNR.basket.outstanding.amount) == 0) {
      return true;
    } else {
      return (await showDialog(
        context: context,
        builder: (context) =>
        new AlertDialog(
          title: new TrText('Are you sure?'),
          content: new TrText('Do you want to abandon your booking '),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                gblPayBtnDisabled = false;
                Navigator.of(context).pop(false);
              },
              child: new TrText('No'),
            ),
            TextButton(
              onPressed: () async {
                await reloadSavedBooking(widget.rloc);
                gblNeedPnrReload = true;
                Navigator.of(context).pop(true);
              },
              child: new TrText('Yes'),
            ),
          ],
        ),
      )) ?? false;
    }
  }
}

class ViewBookingBody extends StatefulWidget {
  ViewBookingBody({Key key= const Key("checkboardpa_key"), this.rloc='',required this.showSnackBar,required this.onLoad})
      : super(key: key);
  String rloc;
  final ValueChanged<String> showSnackBar;
  void Function(BuildContext? context) onLoad;
  final formKey = new GlobalKey<FormState>();
  bool isBeforeClosed = false;
  bool isAfterClosed =false;
  bool isAfterOpens = false;
  bool isBeforeOpens = false;


  @override
  State<StatefulWidget> createState() =>
      new ViewBookingBodyState();
}

class ViewBookingBodyState
    extends State<ViewBookingBody> {
  //AsyncSnapshot snapshot;
  //GlobalKey<ScaffoldState> _key = GlobalKey();
  PnrModel? objPNR;
  ApisPnrStatusModel? apisPnrStatus;
  bool apisOK = false;
  bool _loadingInProgress = false;
//  String _error = '';
  String _displayProcessingText = '';
  //Journeys journeys = Journeys(List<Journey>());
//  MmbBooking mmbBooking = MmbBooking();
  List<City> cities = [];
  // new List<City>();
  int currentPaxNo = 1;
  int currentJourneyNo = 1;


  @override
  void initState() {
    super.initState();
    commonPageInit('VIEWBOOKING');

    _mmbBooking = MmbBooking();
    _loadingInProgress = true;
    _displayProcessingText = '';
    initValues();
    currentJourneyNo = 0;
    currentPaxNo = 0;
    apisOK = false;
  }

  initValues() {
    Repository.get()
        .getPnr(widget.rloc)
        .then((pnrDb) {
      if(pnrDb.data.isEmpty) {
        // load from server
        _refreshBooking();
        //loadJourneys(objPNR);
        return;
      }

      Map<String, dynamic> map = jsonDecode(pnrDb.data);
      // PnrModel
      PnrModel pnr = new PnrModel.fromJson(map);
      loadJourneys(pnr);
      gblPnrModel = pnr;
      gblSelectedCurrency = _mmbBooking.currency;

      _mmbBooking.rloc = pnr.pNR.rLOC;
      gblPnrModel = pnr;

      _mmbBooking.passengers.adults =
          pnr.pNR.names.pAX.where((pax) => pax.paxType == 'AD').length;
      _mmbBooking.passengers.children =
          pnr.pNR.names.pAX.where((pax) => pax.paxType == 'CH').length;
      _mmbBooking.passengers.youths =
          pnr.pNR.names.pAX.where((pax) => pax.paxType == 'TH').length;
      _mmbBooking.passengers.infants =
          pnr.pNR.names.pAX.where((pax) => pax.paxType == 'IN').length;

      // save currency
      gblSelectedCurrency = pnr.getBookingCurrency();
      /*  if( pnr.pNR.payments != null && pnr.pNR.payments.fOP.length > 0 && pnr.pNR.payments.fOP[0].payCur != 'ZZZ'){
              gblSelectedCurrency = pnr.pNR.payments.fOP[0].payCur;
          } else if (pnr.pNR.fareQuote != null && pnr.pNR.fareQuote.fQItin.length > 0 ) {
            gblSelectedCurrency =pnr.pNR.fareQuote.fQItin[0].cur;
          }*/

      widget.onLoad(context);
      // setState(() {
      //   objPNR = pnr;
      // });
    })
        .then((onValue) => gblPnrModel!.pNR.itinerary.itin.forEach((itin) {
      Repository.get().getCityByCode(itin.depart).then((city) {
        if (city != null) {
          cities.add(city);
        }
      });
    }))
        .then((onValue) =>
    //GET APIS STATUS
    Repository.get().getPnrApisStatus(widget.rloc).then((record) {
      if(record == null || record.data == null || record.data.isEmpty) {
        objPNR = null;
        _loadingInProgress = false;
        _displayProcessingText = '';

        return;
      }
      Map<String, dynamic> map = jsonDecode(record.data);
      ApisPnrStatusModel _apisPnrStatus =
      new ApisPnrStatusModel.fromJson(map);
      setState(() {
        apisPnrStatus = _apisPnrStatus;
      });
    }))
        .then((onValue) => (gblPnrModel!.validate()=='') ? null : gblPnrModel = null)
        .then((onValue) => setState(() {
      objPNR = gblPnrModel!;
      if( gblPnrModel!.isFundTransferPayment()) {
        setError( '');
      }
      _loadingInProgress = false;
      _displayProcessingText = '';
    }));
  }

  void refresh(){
    widget.onLoad(null);
    setState(() {
      if( gblPnrModel != null ) {
        objPNR = gblPnrModel;
      }
    });
  }
  void reload( String rloc){

    gblCurrentRloc = rloc;
    widget.rloc = rloc;
    initValues();
    setState(() {
    });
  }



//  void loadCities(List<Itin> itin) {}


  loadJourneys(PnrModel pnrModel) {
    // reset list
    //_mmbBooking.journeys.journey = [];

    if( pnrModel.pNR != null && pnrModel.pNR.itinerary != null && pnrModel.pNR.itinerary.itin != null ) {
      int journeyCount = 0;
      pnrModel.pNR.itinerary.itin.forEach((flt) {
        if (_mmbBooking.journeys.journey.length == journeyCount) {
          _mmbBooking.journeys.journey.add(Journey([])); //List<Itin>()));
        }
        _mmbBooking.journeys.journey[journeyCount].itin.add(flt);
        if (flt.nostop != 'X') {
          journeyCount++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress)
      return new Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(_displayProcessingText),
            ),
          ],
        ),
      );
    if ((objPNR == null || (gblError != null && gblError.isNotEmpty)) && ! objPNR!.isFundTransferPayment()) {
      String er = 'Sorry your booking can\'t be loaded';
      if( gblError.isNotEmpty){
        er = gblError;
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrText(
                er,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.rloc,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrText(
                'Please contact the airline to view this booking on the mobile app',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                //_refreshBooking();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/MyBookingsPage', (Route<dynamic> route) => false);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
              child: TrText(
                //'Reload booking',
                'Return to My Bookings',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    //

    return ListView(children: getBookingViewWidgets(objPNR!));
  }

  void setState1(){
    logit('setState1');
    setState((){});
  }

  reloadApis(String rloc) {
    Repository.get()
        .getPnrApisStatus(rloc)
        .then((record) {
      if (record.data != null && record.data.isNotEmpty) {
        Map<String, dynamic> map = jsonDecode(record.data);
        ApisPnrStatusModel _apisPnrStatus = new ApisPnrStatusModel.fromJson(map);
        // apisPnrStatus = _apisPnrStatus;
      }
      setState(() {});
    })
        .then((onValue){
      String val = gblPnrModel!.validate();

      setState(() {
        //_loadingInProgress = false;
        //_displayProcessingText = '';
        if( val == '') {
          if( gblPnrModel != null ) {
            if (gblPnrModel!.isFundTransferPayment()) {
              setError( '');
            }
            //objPNR = gblPnrModel!;
          }

        } else {
          if( val == 'No Flights'){
            setError( 'Cancelled');
          } else {
            setError(val);
          }
        }
      });

    });
  }


  _refreshBooking() {
    reloadApis(widget.rloc);
    setState(() {
      _loadingInProgress = true;
    });

    //PnrModel pnr;
    gblCurrentRloc = widget.rloc;
/*    gblPnrModel!.reloadAndSave(widget.rloc, _mmbBooking, setState1 );
    return;*/

    try {
      Repository.get().fetchPnr(widget.rloc).then((pnrDb) {
        if (pnrDb != null) {
          if (pnrDb.success == false) {
            setError(pnrDb.data);
            return;
          }

          if (pnrDb.success) {
            Map<String, dynamic> map = jsonDecode(pnrDb.data);
            PnrModel pnr = new PnrModel.fromJson(map);
            setState(() {
              objPNR = pnr;
              gblPnrModel = pnr;
              _mmbBooking.journeys.journey = [];
              loadJourneys(objPNR!);
            });
          } else {

          }
        } else {
          return;
        }
      }).then((onValue) {
        gblActionBtnDisabled = false;
        if (objPNR != null) {
          //GET APIS STATUS
          Repository.get()
              .getPnrApisStatus(widget.rloc)
              .then((record) {
            if (record.data != null && record.data.isNotEmpty) {
              Map<String, dynamic> map = jsonDecode(record.data);
              ApisPnrStatusModel _apisPnrStatus =
              new ApisPnrStatusModel.fromJson(map);
              apisPnrStatus = _apisPnrStatus;
            }
            setState(() {});
          })
              .then((onValue){
            String val = gblPnrModel!.validate();

            setState(() {
              _loadingInProgress = false;
              _displayProcessingText = '';
              if( val == '') {
                if( gblPnrModel != null ) {
                  if (gblPnrModel!.isFundTransferPayment()) {
                    setError( '');
                  }
                  objPNR = gblPnrModel!;
                }

              } else {
                if( val == 'No Flights'){
                  setError( 'Cancelled');
                } else {
                  setError(val);
                }
              }
            });

          });
        }
      }
      ).catchError((e) {
        setError( e.toString());
        logit(e.toString());
        _loadingInProgress = false;
        setState(() {      });
      }
      );
    } catch(e) {
      logit(e.toString());
      setError(e.toString());
      _loadingInProgress = false;
      setState(() {

      });

    }
  }

  void _actionCompleted() {
    setState(() {
      _loadingInProgress = false;
      _displayProcessingText = '';
    });
  }

  List<Widget> getBookingViewWidgets(PnrModel pnr) {
    List<Widget> list = [];
    // new List<Widget>();

    //print(pnr.getNextFlight());
    //Check in or board passes
    list.add(checkinOrPassesWidget(pnr.pNR.rLOC, pnr));

    for (var i = 0; i <= pnr.pNR.itinerary.itin.length - 1; i++) {
      list.add(getFlightViewWidgets(pnr, i));
    }
    if( gblError != null && gblError.isNotEmpty) {
      list.add(Text(gblError));
    }

    //list.add(Text('abc'));
    return list;
  }

  Widget checkinOrPassesWidget(String rLOC, PnrModel pnr) {
    //double c_width = MediaQuery.of(context).size.width * 0.95;
    List<Widget>  list = [];
    list.add( Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new TrText("Booking reference",
            style: new TextStyle(
                fontSize: 16.0, fontWeight: FontWeight.w700)),
        new Text(rLOC,
            style: new TextStyle(
                fontSize: 16.0, fontWeight: FontWeight.w700)),
        gblNoNetwork == false ? _refreshButton(pnr) : Container(),
      ],
    ),);

    if( pnr.pNR.zpay != null && pnr.pNR.zpay.reference.isNotEmpty){
      list.add( Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new TrText("Payment Reference Number",
              style: new TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w700)),
          new Text(pnr.pNR.zpay.reference,
              style: new TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w700)),
        ],
      ),);
    }

    if( gblSettings.wantMmbProducts
        && pnr.isFundTransferPayment() == false
        && pnr.hasFutureFlightsAddDayOffset(0) ){
      // only add products if has furture flights


      list.add(DataLoaderWidget(dataType: LoadDataType.products, newBooking: null,
        pnrModel: pnr,
        onComplete: (PnrModel pnrModel) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if(gblLogProducts) { logit('On Complete products');}
          pnr = pnrModel;
          //pnrModel = pnrModel;
          setState(() {

          });
        },));

    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.only(left: 3.0, right: 3.0, bottom: 3.0, top: 3.0),
        child: new Column(
          children: list,
        ),
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
      ),
      padding: EdgeInsets.all(10.0),
    );
  }

  /*List<Widget> getPassengerViewWidgets(PnrModel pnr, int journey) {
    List<Widget> list = [];
    // new List<Widget>();

    if (pnr.pNR.aPFAX != null) {
      bool found = false;
      pnr.pNR.aPFAX.aFX.forEach((element) {
        if( found == false && element.aFXID =='DISC'){
          _mmbBooking.eVoucher = element;
          found=true;
        }
      });
*//*
      _mmbBooking.eVoucher = pnr.pNR.aPFAX.aFX
          .firstWhere((f) => f.aFXID == 'DISC', );
*//*
    } else {
     // _mmbBooking.eVoucher = null;
    }

    //TODO:
    //Remove from list if pax checked in
    List<Pax> paxlist = [];
    // new List<Pax>();
    for (var pax = 0; pax <= pnr.pNR.names.pAX.length - 1; pax++) {
      if (pnr.pNR.names.pAX[pax].paxType != 'IN') {
        paxlist.add(Pax(
            pnr.pNR.names.pAX[pax].firstName +
                ' ' +
                pnr.pNR.names.pAX[pax].surname,
            pnr.pNR.aPFAX != null
                ? pnr.pNR.aPFAX.aFX
                    .firstWhere(
                        (aFX) =>
                            aFX.aFXID == "SEAT" &&
                            aFX.pax == pnr.pNR.names.pAX[pax].paxNo &&
                            aFX.seg == (journey + 1).toString(),
                        orElse: () => new AFX())
                    .seat
                : '',
            pax == 0 ? true : false,
            pax + 1,
            pnr.pNR.aPFAX != null
                ? pnr.pNR.aPFAX.aFX
                    .firstWhere(
                        (aFX) =>
                            aFX.aFXID == "SEAT" &&
                            aFX.pax == pnr.pNR.names.pAX[pax].paxNo &&
                            aFX.seg == (journey + 1).toString(),
                        orElse: () => new AFX())
                    .seat
                : '',
            pnr.pNR.names.pAX[pax].paxType));
      }
    }

    for (var i = 0; i <= pnr.pNR.names.pAX.length - 1; i++) {
      String seatNo = '';
      if( pnr.pNR.aPFAX != null && pnr.pNR.aPFAX.aFX != null) {
        AFX? seatAfx ;
        bool found = false;
        pnr.pNR.aPFAX.aFX.forEach((f) {
          if(found==false &&  f.aFXID == 'SEAT' && f.pax == pnr.pNR.names.pAX[i].paxNo &&
              f.seg == (journey + 1).toString()){
            seatAfx = f;
            found = true;
          }
        });
*//*
            .firstWhere((f) =>
        f.aFXID == 'SEAT' && f.pax == pnr.pNR.names.pAX[i].paxNo &&
            f.seg == (journey + 1).toString(), );
*//*

        if (seatAfx != null) {
          seatNo = seatAfx!.seat;
        }
      }


      list.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            (seatNo!= '' ) ? vidSeatIcon(seatNo) : Container(),
            Expanded(
              flex: 7,

              child: new Text(
                  pnr.pNR.names.pAX[i].firstName +
                      ' ' +
                      pnr.pNR.names.pAX[i].surname,
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w400)),
            ),
            //(seatNo!= '' )? Text(seatNo + '  ') : Container(),
            new Row(children: [
              ( gblSettings.wantApis) ? Column(
                children: [
                apisButtonOption(pnr, i, journey, paxlist),
                buttonOption(pnr, i, journey, paxlist),
                ]) :
              buttonOption(pnr, i, journey, paxlist),
            ]),
            //    ),
          ],
        ),
      );
    }

    list.add(Divider());
    if( pnr.allPaxCheckedIn()) {
      list.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Icon(Icons.info),
        Padding(
          padding: EdgeInsets.only(left: 5)),
          Text('All passengers checked in'),
        ]
      ));
    } else {
      list.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.info),
            Padding(
              padding: EdgeInsets.only(left: 5),
            ),
            Expanded(
              child: FutureBuilder(
                future: checkinStatus(pnr.pNR.itinerary.itin[journey]),
                initialData: 'Check-in not open',
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  if (text.data != null) {
                    return new Text(text.data!);
                  } else {
                    return Text('');
                  }
                },
              ),
            )
          ],
        ),
      );
    }

    if( pnr.isFundTransferPayment()) {
      list.add(Padding(padding: EdgeInsets.all(3)));
      list.add(_paymentPending(pnr));
    }

    if (pnr.pNR.editFlights == true && pnr.isFundTransferPayment() == false  ) {
      int journeyToChange = getJourney(journey, pnr.pNR.itinerary);

      if(  _mmbBooking.journeys.journey.length >= journeyToChange) {
      var departureDate = DateTime.parse(_mmbBooking
              .journeys.journey[journeyToChange - 1].itin.first.depDate +
          ' ' +
          _mmbBooking.journeys.journey[journeyToChange - 1].itin.first.depTime);

      if ( wantChangeAnyFlight || DateTime.now().add(Duration(hours: 1)).isBefore(departureDate) ) {
        //&&             pnr.pNR.itinerary.itin[journey].status != 'QQ') {
        list.add(Divider());
        if (gblSettings.displayErrorPnr &&
            double.parse(objPNR!.pNR.basket.outstanding.amount) > 0) {
          list.add(Row(
              children: <Widget>[
                Expanded(child: payOutstandingButton(
                    pnr, objPNR!.pNR.basket.outstanding.amount))
              ]));


//          'Payment incomplete, ${basket.outstanding.amount} outstanding';
          list.add(Divider());
        }
        list.add(Row(
          children: <Widget>[
            _flightButtons(pnr, journeyToChange),
          ],
        ));
      }
      }
    }

    return list;
  }*/

  Widget _paymentPending(PnrModel pnr){
    if( pnr.pNR.itinerary == null || pnr.pNR.itinerary.itin.length == 0){
      // cannot pay for nothing !
      return Container();
    }
    return
      Container(
          color: Colors.grey.shade200,
          padding: EdgeInsets.all(5),
          child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Icon(Icons.warning_amber),
                    //Padding(padding: EdgeInsets.all(2)),
                    TrText('Payment Pending'),
                    payOutstandingButton(
                        pnr, objPNR!.pNR.basket.outstanding.amount),

                    //   Padding(padding: EdgeInsets.all(4)),
                    //   Text(formatPrice(pnr.pNR.basket.outstanding.cur, double.parse(pnr.pNR.basket.outstanding.amount)))
                  ],
                ),
                Row(
                  children: [
                    TrText('If you have paid, press '),
                    TrText('RELOAD', style: TextStyle(fontWeight: FontWeight.bold),)
                  ],
                )
              ])
      );
  }

  Widget _refreshButton( pnr  ) {
    return ElevatedButton(
        onPressed: () {
          _refreshBooking();
        },
        style: TextButton.styleFrom(
            side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
            foregroundColor: gblSystemColors.primaryButtonTextColor,
            backgroundColor: gblSystemColors.primaryButtonColor
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TrText(
              'Reload',
              style: TextStyle(
                  color: gblSystemColors.primaryButtonTextColor),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0),
            ),
            RotatedBox(
              quarterTurns: 1,
              child: Icon(
                Icons.refresh,
                size: 20.0,
                color: gblSystemColors.primaryButtonTextColor,
              ),
            )
          ],
        )
    );

  }
  Widget _flightButtons( pnr ,journeyToChange ) {
    //_journeyToChange = journeyToChange;
    if( gblNoNetwork == true){
      return Container();
    }

    if (pnr.pNR.itinerary.itin[journeyToChange-1].status == 'QQ' && gblSettings.canChangeCancelledFlight == false) {
      return Container();
    }
    if( pnr.pNR.editPNR == false ||
        pnr.pNR.editFlights == false ||
        pnr.pNR.itinerary.itin[journeyToChange-1].editFlight == false ){
      return Container();
    }

    // check if any pax checked in this journey
    if( pnr.anyPaxCheckedin(journeyToChange)){
      return Container();
    }


    if( gblSettings.wantRefund &&
        objPNR!.canRefund(journeyToChange)
    ){
      if( gblSettings.wantAllColorButtons ) {
        return Expanded(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            vidTextButton(
                context, 'Change Flight', _onPressedChangeFlt,
                icon: Icons.airplanemode_active,
                iconRotation: 1, p1: journeyToChange),
            //SizedBox(width: 50),
            vidTextButton(
                context, 'Refund', _onPressedRefund, icon: Icons.money,
                iconRotation: 1, p1: journeyToChange),
          ],));
      } else {
        return Expanded(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            vidTextButton(
                context, 'Change Flight', _onPressedChangeFlt,
                icon: Icons.airplanemode_active,
                iconRotation: 1, p1: journeyToChange),
            //SizedBox(width: 50),
            vidTextButton(
                context, 'Refund', _onPressedRefund, icon: Icons.money,
                iconRotation: 1, p1: journeyToChange),
          ],));
      }
    } else {
      if( gblSettings.wantAllColorButtons ) {
        return Expanded(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              vidWideActionButton(
                  context, 'Change Flight', _onPressedChangeFlt2,
                  icon: Icons.airplanemode_active,
                  iconRotation: 1, param1: journeyToChange),
            ])
        );
      } else {
        return vidWideTextButton(
            context, 'Change Flight', _onPressedChangeFlt,
            icon: Icons.airplanemode_active,
            iconRotation: 1, p1: journeyToChange);

      }
    }
  }

  void _onPressedRefund({int? p1, int? p2, String? p3}) async {
    RefundRequest rfund = new RefundRequest();
    rfund.rloc = widget.rloc;
    rfund.journeyNo = p1!;
    gblReturnDate = null;

    String data =  json.encode(rfund);

    try {
      String reply = await callSmartApi('REFUND', data);
      Map<String, dynamic> map = json.decode(reply);
      RefundReply refundRs = new RefundReply.fromJson(map);
      gblActionBtnDisabled = false;
      if( refundRs.success == true ) {
        showVidDialog(context, 'Refund', 'Refund successful');
      } else {
        showVidDialog(context, 'Refund', 'refund failed');
      }
    } catch(e) {
      logit(e.toString());
    }
  }
  void _onPressedChangeFlt({int? p1, int? p2, String? p3}) {
    gblReturnDate = null;
    if( objPNR!.pNR.isFQTVBooking()) {
      gblRedeemingAirmiles = true;
    } else {
      gblRedeemingAirmiles = false;
    }
    if( p1 == 1) {
      // out
      gblOrigin = objPNR!.pNR.itinerary.itin[0].depart;
      gblDestination = objPNR!.pNR.itinerary.itin[0].arrive;
    } else {
      // back = 2
      gblOrigin = objPNR!.pNR.itinerary.itin[1].depart;
      gblDestination = objPNR!.pNR.itinerary.itin[1].arrive;
    }


    if( objPNR!.pNR.fareQuote != null && objPNR!.pNR.fareQuote.fQItin != null && objPNR!.pNR.fareQuote.fQItin.length >0 ){
      if( objPNR!.pNR.payments != null && objPNR!.pNR.payments.fOP != null && objPNR!.pNR.payments.fOP.length > 0) {
        // should not change currency
//        gblSettings.currency = objPNR!.pNR.payments.fOP[0].payCur;
      }
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MmbDatePickerWidget(
            pnr: objPNR!,
            mmbBooking: _mmbBooking,
            journeyToChange: p1!,
          ),
        ));
  }
  void _onPressedChangeFlt2(BuildContext context, dynamic p1) {
/*
    gblOrigin = objPNR!.pNR.
    gblDestination
*/
    if( objPNR!.pNR.fareQuote != null && objPNR!.pNR.fareQuote.fQItin != null && objPNR!.pNR.fareQuote.fQItin.length >0 ){
      //gblSettings.currency = objPNR!.pNR.fareQuote.fQItin[0].cur;
      if( objPNR!.pNR.payments != null && objPNR!.pNR.payments.fOP != null && objPNR!.pNR.payments.fOP.length > 0) {
        // should not change currency
        //gblSettings.currency = objPNR!.pNR.payments.fOP[0].payCur;
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MmbDatePickerWidget(
            pnr: objPNR!,
            mmbBooking: _mmbBooking,
            journeyToChange: p1,
          ),
        ));
  }
  int getJourney(int leg, Itinerary itinerary) {
    int journey = 0;
    for (var i = 0; i <= leg; i++) {
      if ((itinerary.itin[i].nostop != 'X') ||
          (itinerary.itin[i].nostop == 'X' && i == leg) ||
          (leg == 0)) {
        journey += 1;
      }
    }
    return journey;
  }

  bool hasSeatSelected(APFAX aPFAX, String paxNo, int journeyNo, Names names) {
    if (aPFAX != null &&
        (aPFAX.aFX
            .firstWhere(
                (aFX) =>
            aFX.pax == paxNo &&
                aFX.seg == (journeyNo).toString() &&
                aFX.aFXID == 'SEAT',
            orElse: () => new AFX())
            .seat !=
            null && aPFAX.aFX
            .firstWhere(
                (aFX) =>
            aFX.pax == paxNo &&
                aFX.seg == (journeyNo).toString() &&
                aFX.aFXID == 'SEAT',
            orElse: () => new AFX())
            .seat !='')
        ||
        names.pAX[int.parse(paxNo) - 1].paxType == 'IN') {
      return true;
    } else {
      return false;
    }
  }

  _checkin(String cmd) {
    _sendVrsCheckinCommand(cmd);
    setState(() {
      _loadingInProgress = true;
      _displayProcessingText = 'Check-in progress...';
    });
  }

  Future _sendVrsCheckinCommand(String cmd) async {
    String msg = '';
    //   if( gblSettings.useWebApiforVrs) {
    if (gblSession == null) gblSession = new Session('0', '', '0');
    msg = json.encode(
        VrsApiRequest(
            gblSession!, cmd,
            gblSettings.xmlToken.replaceFirst('token=', ''),
            vrsGuid: gblSettings.vrsGuid,
            notifyToken: gblNotifyToken,
            rloc: gblCurrentRloc,
            phoneId: gblDeviceId,
            language: gblLanguage
        )
    );
    msg = "${gblSettings.xmlUrl}VarsSessionID=${gblSession!.varsSessionId}&req=$msg";
    // }
    /*   else {
       msg = gblSettings.xmlUrl +
          gblSettings.xmlToken +
          '&Command=' + cmd;
    }
*/
    print("_sendVrsCheckinCommand::$msg");

    final response = await http.get(Uri.parse(msg),headers: getXmlHeaders());
    //Map map;
    if (response.statusCode == 200) {
      try {
        Map map = jsonDecode( response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', ''));
        msg = map['data'];
        print(msg);

        if (!msg.contains('Error')) {
          Repository.get().fetchPnr(widget.rloc).then((v) {
            _checkinCompleted(v!);
          });
        } else {
          _showError(msg.replaceFirst('Error - ', ''));
          _actionCompleted();
        }
      } catch (e) {
        print(e.toString());
        _showError('Please check your internet connection');
        _actionCompleted();
      }
    } else {
      _actionCompleted();
    }
  }

  _checkinCompleted(PnrDBCopy pnrDBCopy) {
    Map<String, dynamic> map = json.decode(pnrDBCopy.data);
    PnrModel _objPNR = new PnrModel.fromJson(map);
    setState(() {
      objPNR = _objPNR;
      _loadingInProgress = false;
      _displayProcessingText = '';
    });
  }

  _autoSeatCompleted(PnrDBCopy pnrDBCopy) {
    Map<String, dynamic> map = json.decode(pnrDBCopy.data);
    PnrModel _objPNR = new PnrModel.fromJson(map);

    setState(() {
      objPNR = _objPNR;
      _loadingInProgress = false;
      _displayProcessingText = '';
    });
    // if (apisPnrStatus.apisInfoEnteredAll(currentJourneyNo)) {
    //   _displayCheckingAllDialog(_objPNR, currentJourneyNo);
    // } else {
    //   widget.showSnackBar(
    //       'Can\'t check in all passengers as APIS information not complete');
    // }

    if (apisPnrStatus != null &&
        apisPnrStatus!.apisRequired(currentJourneyNo) &&
        !apisPnrStatus!.apisInfoEnteredAll(currentJourneyNo)) {
      //widget.showSnackBar(          'Can\'t check in all passengers as APIS information not complete');
    } else {

      _displayCheckingAllDialog(_objPNR, currentJourneyNo);
    }
  }

  _showError(String err) {
    print(err);
    //widget.showSnackBar(err.trim());
  }

  _handleApisInfoChanged(ApisPnrStatusModel apisPnrStatusModel) {
    if (apisPnrStatusModel != null) {
      setState(() {
        apisPnrStatus = apisPnrStatusModel;
      });
    }
  }

  _handleSeatChanged(PnrModel pnrModel) {
    if (pnrModel != null) {
      setState(() {
        objPNR = pnrModel;
      });
    }
  }

  bool isFltPassedDate(Itin journey, int offset) {
    //DateTime now = DateTime.now();
    DateTime now = getGmtTime();
    DateTime fltDate;
    bool result = false;

    fltDate = DateTime.parse(journey.ddaygmt + ' ' + journey.dtimgmt);
    fltDate = fltDate.add(Duration(hours: gblSettings.hideBookingHours));
    //.add(Duration(hours: offset));
    if (now.isAfter(fltDate)) {
      result = true;
    }

    return result;
  }

  bool _hasApisInfoForPax(int fltNo, int paxNo){
    bool bFound = false;
    if(apisPnrStatus != null &&
        apisPnrStatus!.xml != null &&
        apisPnrStatus!.xml!.pnrApis != null &&
        apisPnrStatus!.xml!.pnrApis.flights != null &&
        apisPnrStatus!.xml!.pnrApis.flights!.flight.length >= fltNo ){

      if( apisPnrStatus!.xml!.pnrApis.flights!.flight[fltNo].passengers != null) {
        apisPnrStatus!.xml!.pnrApis.flights!.flight[fltNo].passengers?.passenger.forEach((element) {

          if( int.parse(element.paxno) == paxNo +1) {
            if (element.apisentered == 'True') {
              bFound = true;
            }
          }
        });
      }

    }

    return bFound;
  }

  Widget apisButtonOption(PnrModel pnr, int paxNo, int journeyNo, List<Pax> paxlist) {
    //Apis
    if (apisPnrStatus != null &&
        (apisPnrStatus!.apisRequired(journeyNo)
/*
            &&
            !apisPnrStatus.apisInfoEntered(journeyNo, paxNo + 1)
*/
        )) {
      //return new TextButton(
      return new TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApisWidget(
                    apisCmd:
                    'dsx/${pnr.pNR.itinerary.itin[journeyNo].airID + pnr.pNR.itinerary.itin[journeyNo].fltNo}/${new DateFormat('ddMMMyy').format(DateTime.parse(pnr.pNR.itinerary.itin[journeyNo].depDate + ' ' + pnr.pNR.itinerary.itin[journeyNo].depTime))}/${pnr.pNR.itinerary.itin[journeyNo].depart}/${pnr.pNR.itinerary.itin[journeyNo].arrive}/${pnr.pNR.rLOC + (paxNo + 1).toString()}',
                    rloc: widget.rloc,
                    paxIndex: paxNo,
                    pnr: pnr.pNR,
                  ),
                )).then((apisState) {
              apisOK = true;
              _handleApisInfoChanged(apisState);

            });
          },
          style: TextButton.styleFrom(
              side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
              foregroundColor: Colors.black),
          child: Row(
            children: <Widget>[
              TrText(
                  'Additional Information',
                  style: TextStyle(
                      color:
                      gblSystemColors.textButtonTextColor)
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
              ),

              (_hasApisInfoForPax(journeyNo, paxNo) == true ) ?
              Icon(Icons.check_circle_outline,
                size: 20.0,
                color: Colors.green,
              ) :
              Icon(
                Icons.close,
                size: 20.0,
                color: Colors.red,
              )
            ],
          ));

    }
    return Container();
  }


  Widget payOutstandingButton(PnrModel pnr, String amount) {
    return new TextButton(
      onPressed: () {
        gblPaymentMsg = '';
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChoosePaymenMethodWidget(
                      mmbBooking: _mmbBooking,
                      pnrModel: pnr,
                      isMmb: true,
                      mmbAction: 'PAYOUTSTANDING',
                      mmbCmd: '',
                    )));
      },
      style: TextButton.styleFrom(
        //backgroundColor:  gblSystemColors.te,
          side: BorderSide(
              color: gblSystemColors.textButtonTextColor, width: 1),
          foregroundColor: gblSystemColors.textButtonTextColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            translate('Pay') + ' ' + formatPrice(
                pnr.pNR.basket.outstanding.cur, double.parse(amount)) + ' ' +
                translate('Outstanding'),
            style: TextStyle(
                color: gblSystemColors
                    .textButtonTextColor),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
          ),
          Icon(
            //Icons.airline_seat_recline_normal,
            Icons.done,
            size: 20.0,
            color: gblSystemColors.textButtonTextColor,
          ),
          Text(
            '',
            style: TextStyle(
                color: gblSystemColors
                    .textButtonTextColor),
          )
        ],
      ),
    );
  }



  Future<String> checkinStatus(Itin itin) async {
    String response = '';
    DateTime checkinOpens;
    DateTime checkinClosed;
    DateTime departureDateTime;
    DateTime now;

    if( itin.onlineCheckinTimeStartGMT != '' ) {
      checkinOpens = DateTime.parse(itin.onlineCheckinTimeStartGMT);
    } else {
      checkinOpens = DateTime.now().add(Duration(days: 100));
    }
    if( itin.onlineCheckinTimeEndGMT != '' ) {
      checkinClosed = DateTime.parse(itin.onlineCheckinTimeEndGMT);
    } else {
      checkinClosed = DateTime.now().add(Duration(days: 1));
    }

    departureDateTime = DateTime.parse(itin.ddaygmt + ' ' + itin.dtimgmt);
    now = getGmtTime();

    widget.isBeforeClosed = is1After2( checkinClosed, now); // now.difference(checkinClosed).inMinutes <0;
    widget.isAfterClosed = is1After2( now, checkinClosed); // now.difference(checkinClosed).inMinutes >0;
    widget.isAfterOpens =  is1After2( now, checkinOpens); // checkinOpens.difference(now).inMinutes > 0;
    widget.isBeforeOpens =  is1After2(  checkinOpens, now);
    // nb DateTime isBefore and isAfter do not work accurateley !!!
    //  logit('Checkin Op:$checkinOpens Cl:$checkinClosed now:$now');

    if( itin.mMBCheckinAllowed == 'False' || gblSettings.wantSeats == false){
      response = translate('No online Check-in ');
    } else if (itin.secRLoc != '') {
      response = translate('Check-in with other airline ');
    } else if( itin.mMBCheckinAllowed != null &&  itin.mMBCheckinAllowed == 'False') {
      if( widget.isBeforeOpens ) {
        DateTime dt = DateTime.parse(
            itin.onlineCheckinTimeStartLocal);
        response = translate('Online check-in opens at ') +
            getIntlDate('H:mm a dd MMM', dt);
      } else {
        response = translate('No Online Check');
      }
      //   } else if ( city.webCheckinEnabled == 0 ) {
      //   response = translate('no Check-in online for this city ');
    } else if ( itin.onlineCheckin != null &&  itin.onlineCheckin == 'False' ) {
      response = translate('Online Check in closed ');
    } else if (widget.isBeforeClosed &&
        widget.isAfterOpens &&
        (itin.airID != gblSettings.aircode && itin.airID != gblSettings.altAircode)) {
      response = translate('Check-in with other airline ');
      //} else if (now.isBefore(checkinClosed) && now.isAfter(checkinOpens)) {
    } else if ( widget.isBeforeClosed  && widget.isAfterOpens) {
      response = translate('Online check-in open ');
    } else if (widget.isBeforeClosed &&
        (itin.airID != gblSettings.aircode && itin.airID != gblSettings.altAircode)) {
      response = translate('Check-in with other airline ');
    } else if (widget.isBeforeClosed) {
      // get date time local
      if( itin.onlineCheckinTimeStartLocal == null || itin.onlineCheckinTimeStartLocal == '') {
        response = translate('Please Reload');
      } else {
        DateTime dt = DateTime.parse(
            itin.onlineCheckinTimeStartLocal);
        response = translate('Online check-in opens at ') +
            getIntlDate('H:mm a dd MMM', dt);
      }
      //DateFormat('H:mm a dd MMM').format(checkinOpens);
    } else if (widget.isAfterClosed &&
        now.isBefore(departureDateTime)) {
      response = translate('Online check-in closed ');
    } else {
      response = translate('Flight closed ');
    }


    return response;
  }

  Widget getFlightViewWidgets(PnrModel pnr, int journey) {
    var timeFormat = 'h:mm a';
    //bool isFundTransferPayment = pnr.isFundTransferPayment();

    bool isFltPassedDate(Itin journey, int offset) {
      //DateTime now = DateTime.now();
      DateTime now = getGmtTime();
      DateTime fltDate;
      bool result = false;

      fltDate = DateTime.parse(journey.ddaygmt + ' ' + journey.dtimgmt);
      fltDate = fltDate.add(Duration(hours: gblSettings.hideBookingHours));
      //.add(Duration(hours: offset));
      if (now.isAfter(fltDate)) {
        result = true;
      }

      return result;
    }
    if (!isFltPassedDate(pnr.pNR.itinerary.itin[journey], 24 * 7)) { // was 24

      List <Widget> list = [];
      list.add( Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(children: [
            new Icon(Icons.date_range),
            new Padding(
              child: new Text(
                //new DateFormat('EEE dd MMM h:mm a').format(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' + pnr.pNR.itinerary.itin[journey].depTime))
                //  .toString().substring(0, 10),
                  getIntlDate('EEE dd MMM', DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' + pnr.pNR.itinerary.itin[journey].depTime)),
                  style: new TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w300)),
              padding: EdgeInsets.only(left: 8.0),
            )
          ]),
        ],
      ));
      list.add( Divider());
      list.add( Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(pnr.pNR.itinerary.itin[journey].depart,
              style: new TextStyle(
                  fontSize: 32.0, fontWeight: FontWeight.w700)),
          new RotatedBox(
              quarterTurns: 1,
              child: new Icon(
                Icons.airplanemode_active,
                size: 32.0,
              )),
          new Text(pnr.pNR.itinerary.itin[journey].arrive,
              style: new TextStyle(
                  fontSize: 32.0, fontWeight: FontWeight.w700))
        ],
      ));
      list.add( Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(cityCodetoAirport(pnr.pNR.itinerary.itin[journey].depart),
              style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)),
          /*        FutureBuilder(
                future: cityCodeToName(
                  pnr.pNR.itinerary.itin[journey].depart,
                ),
                initialData:
                pnr.pNR.itinerary.itin[journey].depart.toString(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> text) {
                  return new Text(translate(text.data!),
                      style: new TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w300));
                },
              ),*/
          gblSettings.trackerUrl != '' ? _trackerButton(pnr.pNR.itinerary.itin[journey]) : Container(),
          Text(cityCodetoAirport(pnr.pNR.itinerary.itin[journey].arrive),
              style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)),

          /*            FutureBuilder(
                future: cityCodeToName(
                  pnr.pNR.itinerary.itin[journey].arrive,
                ),
                initialData:
                pnr.pNR.itinerary.itin[journey].arrive.toString(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> text) {
                  return new Text(translate(text.data!),
                      style: new TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w300));
                },
              ),*/
        ],
      ));
      list.add( Divider());
      if( pnr.isFundTransferPayment()){
        list.add( TrText('Payment Pending'));
      }
      if (pnr.pNR.itinerary.itin[journey].status == 'QQ') {
        list.add( Row(children: [
          TrText('Flight Not Operating, contact airline',
            style: TextStyle(color: Colors.red, fontSize: 18.0),)
        ],));
      }
      list.add( Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            children: [
              new DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: new BorderRadius.all(
                          new Radius.circular(2.0))),
                  child: Transform.rotate(
                    angle: -math.pi / 4,
                    child: new Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 14.0,
                    ),
                  )),
              new Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: new Text(
                    translate('Depart') + ' ' +
                        //(new DateFormat('h:mm a').format(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate +
                        //            ' ' + pnr.pNR.itinerary.itin[journey].depTime))).replaceAll('12:00 AM', '00:00 AM'),
                        getIntlDate(timeFormat, DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate  + ' ' + pnr.pNR.itinerary.itin[journey].depTime)).replaceFirst('12:00 AM', '00:00 AM'),
                    style: new TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          new Row(
            children: [
              new DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: new BorderRadius.all(
                          new Radius.circular(2.0))),
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: new Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 14.0,
                    ),
                  )),
              new Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: new Text(
                    translate('Arrival') + ' ' +
                        //(new DateFormat('h:mm a').format(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' +
                        //           pnr.pNR.itinerary.itin[journey].arrTime))).replaceFirst('12:00 AM', '00:00 AM'),
                        getIntlDate('h:mm a', DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' + pnr.pNR.itinerary.itin[journey].arrTime)).replaceFirst('12:00 AM', '00:00 AM'),

                    //'Arrival ${snapshot.data['arrivalTimes'][journey]}',
                    style: new TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.w500),
                  )),
            ],
          ),
        ],
      ));
      list.add(  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.query_builder,
                size: 20.0,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    (pnr.pNR.itinerary.itin[journey]
                        .getFlightDuration()),
                  ))
            ],
          ),
          Padding(padding: EdgeInsets.all(15)),
          Row(
            children: <Widget>[
              new RotatedBox(
                  quarterTurns: 1,
                  child: new Icon(
                    Icons.airplanemode_active,
                    size: 20.0,
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(pnr.pNR.itinerary.itin[journey].airID +
                      pnr.pNR.itinerary.itin[journey].fltNo))
            ],
          )
        ],
      ));

      list.add( Divider());
      list.add(Padding(
        padding: EdgeInsets.only(bottom: 5.0),
      ));

      // outstanding ?
      if( pnr.isFundTransferPayment() == false &&
          pnr.pNR.hasAmountOutstanding()
      ){
        list.add(Row(
            children: <Widget>[
              Expanded(child: payOutstandingButton(
                  pnr, objPNR!.pNR.basket.outstanding.amount != '0' ? objPNR!.pNR.basket.outstanding.amount : objPNR!.pNR.basket.outstandingairmiles.amount))
            ]));
      }

      list.add( Column(
        children: getPassengerViewWidgets(pnr, journey),
      ));
      // new Divider(),


      return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: Container(
          padding:
          EdgeInsets.only(left: 3.0, right: 3.0, bottom: 3.0, top: 3.0),
          child: new Column(children: [
            //starting col
            new Column(
              children: list,
            )
          ]),
          // end col
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
        ),
        padding: EdgeInsets.all(10.0),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0),
      );
    }
  }

  Widget _trackerButton(Itin itin){
    // itin.airID +itin.fltNo
    String url = gblSettings.trackerUrl + itin.airID +itin.fltNo;

    return TextButton(
        child: new Text("track"),
        style: TextButton.styleFrom(
            backgroundColor: gblSystemColors.primaryButtonColor ,
            side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
            foregroundColor: gblSystemColors.primaryButtonTextColor),
        onPressed: () {
          Navigator.push(context, SlideTopRoute(page: CustomPageWeb('Flight Tracker: ' + itin.airID +itin.fltNo, url)));
        }
    );
  }

//new collapsable items
  Widget getFlightViewCollapsableWidgets(PnrModel pnr, int journey) {
    var timeFormat = 'h:mm a';
    /*
    if( gblSettings.want24HourClock ){
      timeFormat = 'HH:mm';
    }
*/

    bool isFltPassedDate(Itin journey, int offset) {
      //DateTime now = DateTime.now();
      DateTime now = getGmtTime();
      var fltDate;
      bool result = false;

      fltDate = DateTime.parse(journey.ddaygmt + ' ' + journey.dtimgmt);
      //.add(Duration(hours: offset));
      if (now.isAfter(fltDate)) {
        result = true;
      }

      return result;
    }

    final theme = Theme.of(context).copyWith(dividerColor: Colors.white);

    //if (!isFltPassedDate(pnr.pNR.itinerary.itin[journey], 24)) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.only(
          //left: 3.0, right: 3.0,
            bottom: 3.0,
            top: 3.0),
        child: new Column(children: [
          new Column(
            children: [
              Theme(
                  data: theme,
                  child: ExpansionTile(
                    initiallyExpanded:
                    !isFltPassedDate(pnr.pNR.itinerary.itin[journey], 24),
                    title: Row(
                      children: [
                        new Icon(Icons.date_range),
                        new Padding(
                          child: new Text(
                            //new DateFormat('EEE dd MMM h:mm a').format(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate +
                            //       ' ' + pnr.pNR.itinerary.itin[journey].depTime)).toString().substring(0, 10),
                              getIntlDate('EEE dd MMM', DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate +
                                  ' ' + pnr.pNR.itinerary.itin[journey].depTime)),
                              style: new TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w300)),
                          padding: EdgeInsets.only(left: 8.0),
                        )
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: new Divider(
                          color: Colors.black26,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(pnr.pNR.itinerary.itin[journey].depart,
                                style: new TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w700)),
                            new RotatedBox(
                                quarterTurns: 1,
                                child: new Icon(
                                  Icons.airplanemode_active,
                                  size: 32.0,
                                )),
                            new Text(pnr.pNR.itinerary.itin[journey].arrive,
                                style: new TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(cityCodetoAirport(pnr.pNR.itinerary.itin[journey].depart),
                                style:TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w300)),

                            /*                         FutureBuilder(
                              future: cityCodeToName(
                                pnr.pNR.itinerary.itin[journey].depart,
                              ),
                              initialData: pnr
                                  .pNR.itinerary.itin[journey].depart
                                  .toString(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> text) {
                                return new Text(text.data!,
                                    style: new TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w300));
                              },
                            ),*/
                            /*FutureBuilder(
                              future: cityCodeToName(
                                pnr.pNR.itinerary.itin[journey].arrive,
                              ),
                              initialData: pnr
                                  .pNR.itinerary.itin[journey].arrive
                                  .toString(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> text) {
                                return new Text(text.data!,
                                    style: new TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w300));
                              },
                            ),*/
                            Text(cityCodetoAirport(pnr.pNR.itinerary.itin[journey].arrive),
                                style:TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w300)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: new Divider(
                          color: Colors.black26,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              children: [
                                new DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: new BorderRadius.all(
                                            new Radius.circular(2.0))),
                                    child: Transform.rotate(
                                      angle: -math.pi / 4,
                                      child: new Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 14.0,
                                      ),
                                    )),
                                new Padding(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: new Text(
                                      translate('Depart') + ' '+
                                          //(new DateFormat('h:mm a').format(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate +
                                          //            ' ' +pnr.pNR.itinerary.itin[journey].depTime))).replaceAll('12:00 AM', '00:00 AM'),
                                          getIntlDate(timeFormat, DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' +pnr.pNR.itinerary.itin[journey].depTime)).replaceAll('12:00 AM', '00:00 AM'),
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                            new Row(
                              children: [
                                new DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: new BorderRadius.all(
                                            new Radius.circular(2.0))),
                                    child: Transform.rotate(
                                      angle: math.pi / 4,
                                      child: new Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 14.0,
                                      ),
                                    )),
                                new Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: new Text(
                                      translate('Arrival') + ' ' +
                                          //(new DateFormat('h:mm a').format(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate +
                                          //           ' ' + pnr.pNR.itinerary.itin[journey].arrTime))).replaceFirst('12:00 AM', '00:00 AM'),
                                          getIntlDate('h:mm a', DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate +
                                              ' ' + pnr.pNR.itinerary.itin[journey].arrTime)).replaceFirst('12:00 AM', '00:00 AM'),
                                      //'Arrival ${snapshot.data['arrivalTimes'][journey]}',
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: new Divider(
                          color: Colors.black26,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 5),
                        child: Column(
                          children: getPassengerViewWidgets(pnr, journey),
                        ),
                      ),
                    ],
                  )),
            ],
          )
        ]),
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
      ),
      padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
    );
  }

  Widget seatButton(int paxNo, int journeyNo, PnrModel pnr, List<Pax> paxlist,
      bool checkinOpen, bool chargeForPreferredSeating) {

    String action = '';
    String btnText = '';
    if(checkinOpen) {
      if( gblSettings.wantSeats ==  false ) return Container();
      // apis button required and yet to be done ?
      if(apisPnrStatus != null && apisPnrStatus!.apisRequired(journeyNo) && _hasApisInfoForPax(journeyNo, paxNo) == false){
        logit('APIS required');
        return Container();
      }

      btnText = 'Check-in';
      action = 'checkin';
    } else {
      if( widget.isAfterClosed) return Container();
      if( gblSettings.wantSeats ==  false ) return Container();
      if(paxlist
          .firstWhere((p) => p.id == paxNo + 1)
          .seat == null ||
          paxlist
              .firstWhere((p) => p.id == paxNo + 1)
              .seat ==
              '') {
        btnText = 'Choose Seat';
        action= 'chooseseat';
      } else {
        btnText = 'Change Seat';
        action = 'changeseat';
      }
    }
    ButtonClickParams buttonClickParams = new ButtonClickParams(paxNo: paxNo, journeyNo: journeyNo, action: action);


    if( gblSettings.wantAllColorButtons) {
      if( paxlist
          .firstWhere((p) => p.id == paxNo + 1)
          .seat != null && paxlist
          .firstWhere((p) => p.id == paxNo + 1)
          .seat != ''
      ) {
        btnText += '  ' +  (paxlist.firstWhere((p) => p.id == paxNo + 1).seat);
      }
      return vidActionButton(context, btnText, (p0, params){

        if( gblPnrModel!.hasContactDetails()) {

        }

        bool found = false;
        gblCurPax = 0;
        paxlist.forEach((element) {
          if(found== false &&  (element.id == paxNo+1) && (element.seat == null || element.seat == '' ) ){
            found=true;
            gblCurPax = paxNo;
          }
        });

        if (gblSettings.autoSeatOption && found
            /*
            (paxlist
                .firstWhere((p) => p.id == paxNo + 1)
                .seat == null ||
                paxlist
                    .firstWhere((p) => p.id == paxNo + 1)
                    .seat == '')*/ &&
            checkinOpen) {
          autoSeatingSelection(
              paxNo, journeyNo, pnr, paxlist, chargeForPreferredSeating);
          gblActionBtnDisabled = false;
        } else {
          preferredSeating(buttonClickParams, pnr, paxlist, checkinOpen);
          gblActionBtnDisabled = false;
        }
      } ,
          isRectangular: true,
          params: buttonClickParams,
          icon: Icons.event_seat );

    } else {
      return new TextButton(

        onPressed: () {
          gblCurPax = 0;
          if( ! gblPnrModel!.hasContactDetails()) {
            gblActionBtnDisabled = false;
            return addContactDetails();
          }

          if (gblSettings.autoSeatOption &&
              (paxlist
                  .firstWhere((p) => p.id == paxNo + 1)
                  .seat == null ||
                  paxlist
                      .firstWhere((p) => p.id == paxNo + 1)
                      .seat == '') &&
              checkinOpen) {
            autoSeatingSelection(
                paxNo, journeyNo, pnr, paxlist, chargeForPreferredSeating);
            gblActionBtnDisabled = false;
          } else {
            gblCurPax = paxNo;
            gblCurJourney = journeyNo;
            preferredSeating(buttonClickParams, pnr, paxlist, checkinOpen);
            gblActionBtnDisabled = false;
          }
        },
        style: TextButton.styleFrom(
            side: BorderSide(
                color: gblSystemColors.textButtonTextColor, width: 1),
            foregroundColor: gblSystemColors.textButtonTextColor),
        child: Row(
          children: <Widget>[
            TrText(btnText,style: TextStyle(
                color: gblSystemColors
                    .textButtonTextColor)),
            /*checkinOpen
                ? TrText(
              'Check-in',
              style: TextStyle(
                  color: gblSystemColors
                      .textButtonTextColor),
            )
                : Text(
              (paxlist
                  .firstWhere((p) => p.id == paxNo + 1)
                  .seat == null ||
                  paxlist
                      .firstWhere((p) => p.id == paxNo + 1)
                      .seat ==
                      '')
                  ? 'Choose Seat'
                  : 'Change Seat',
              style: TextStyle(
                  color: gblSystemColors
                      .textButtonTextColor),
            ),*/
            Padding(
              padding: EdgeInsets.only(left: 5.0),
            ),
            /*        Icon(
            Icons.airline_seat_recline_normal,
            size: 20.0,
            color: Colors.grey,
          ),*/
            Text(
              paxlist
                  .firstWhere((p) => p.id == paxNo + 1)
                  .seat != null
                  ? paxlist
                  .firstWhere((p) => p.id == paxNo + 1)
                  .seat
                  : '',
              style: TextStyle(
                  color: gblSystemColors.primaryButtonTextColor),
            ),
          ],
        ),
      );
    }
  }
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  addContactDetails(){

    if( gblPnrModel!.pNR.contacts != null && gblPnrModel!.pNR.contacts.cTC.length > 0) {
      gblPnrModel!.pNR.contacts.cTC.forEach((element) {
        if( element.cTCID == 'E') {
          _emailController.text = element.text;
        } else  if( element.cTCID == 'M') {
          _phoneController.text = element.text;
        }
      });

    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: alertShape(),
          titlePadding: const EdgeInsets.all(0),
          title: alertTitle(
              translate('Add Contact details'), gblSystemColors.headerTextColor!, gblSystemColors.primaryHeaderColor),
          content: /*Form(
          key: widget.formKey,
          child: */Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                maxLength: 50,
                //          autovalidateMode: AutovalidateMode.disabled,
                decoration: getDecoration('Phone Number'),
                controller: _phoneController,
                keyboardType: TextInputType.number,
                //validator: (value) =>            value!.isEmpty ? translate('Phone Number cannot be empty') : null,
/*
            onFieldSubmitted: (value) {
              //widget.passengerDetail.phonenumber = value;
            },
            onSaved: (value) {
              if (value != null) {
               // widget.passengerDetail.phonenumber = value.trim();
              }
            },
*/
              ),
              Padding(
                padding: EdgeInsets.all(4),
              ),
              TextFormField(
                maxLength: 50,
                decoration: getDecoration('Email'),
                autovalidateMode: AutovalidateMode.disabled,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  String er = validateEmail(value!.trim());
                  if( er != '') return er;
                  return null;
                },
                onFieldSubmitted: (value) {
                  //  widget.passengerDetail.email = value;
                },
                onSaved: (value) {
                  if (value != null) {
                    //widget.passengerDetail.email = value.trim();
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.all(4),
              ),

            ],
            //          )
          ),

          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new TrText("Cancel",
                  style: new TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  foregroundColor:
                  gblSystemColors.primaryButtonColor),
              child: new Text(
                "Save",
                style: new TextStyle(
                    color: gblSystemColors
                        .primaryButtonTextColor),
              ),
              onPressed: () {
//                final form = widget.formKey.currentState;
                //              if (form!.validate()) {
//                  form.save();
                if( _emailController.text != '' && _phoneController.text != '' && validateEmail(_emailController.text) == ''){
// add ctc to PNR
                  saveContactDetails(_emailController.text, _phoneController.text);
                  // save

                  // back
                  Navigator.of(context).pop();
                  //return true;
                } else {
                  //return false;
                }

              },
            ),
          ],
        );
      },
    );
  }

  saveContactDetails(String email, String phone) async {
    StringBuffer sb = new StringBuffer();
    // remove old contact
    sb.write('*$gblCurrentRloc^');
    sb.write('9X1^9X1^');
    sb.write('9M*$phone^');
    sb.write('9E*$email^E*R');
    await runVrsCommand(sb.toString());

    Repository.get().fetchPnr(gblPnrModel!.pNR.rLOC).then((pnrDb) {
      if (pnrDb != null) {
        if (pnrDb.success == false) {
          setError( pnrDb.data);
          //showSnackBar(gblError, context);
          return;
        }

        if (pnrDb.success) {
          Map<String, dynamic> map = jsonDecode(pnrDb.data);
          gblPnrModel = new PnrModel.fromJson(map);
          showSnackBar('Saved', context);
        }
      }
    });

  }


  autoseat(PnrModel pnr, int journey) {
    currentJourneyNo = journey;
    _autoseat(pnr, journey);
    setState(() {
      _loadingInProgress = true;
      _displayProcessingText = 'Seating in progress...';
    });
  }

  _displayCheckingDialog(PnrModel pnr, int journeyNo, int paxNo) {
    Widget para1 = Text(      translate( "Passenger cabin bags and hold luggage must not contain any articles or substances that may present a danger during transport. Please read the Prohibited Items Notice."));
    if(gblSettings.aircode == 'SI') {
      para1 = RichText(
        text: new TextSpan(
          children: [
            new TextSpan(
              text: 'Passenger cabin bags and hold luggage must not contain any articles or substances that may present a danger during transport. ',
              style: new TextStyle(color: Colors.black),
            ),
            new TextSpan(
              text: 'Please read the Prohibited Items Notice.',
              style: new TextStyle(color: Colors.blue,decoration: TextDecoration.underline),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('https://www.blueislands.com/media/cpdjyjlw/cap1402as_dangerousgoods_1920x1080_2018.jpg'));
                },
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new TrText("Online Check-in"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(child: para1          ),
              Padding(
                padding: EdgeInsets.all(4),
              ),
              (gblSettings.prohibitedItemsNoticeUrl != null && gblSettings.prohibitedItemsNoticeUrl != 'null')
                  ? appLinkWidget(
                  'https',
                  gblSettings.prohibitedItemsNoticeUrl.replaceAll('https:', '').replaceAll('https', '').trimLeft().trimRight(),
                  Text(
                      gblSettings.prohibitedItemsNoticeUrl,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      )))
                  : Text(''),
              Padding(
                padding: EdgeInsets.all(4),
              ),
              Flexible(child: Text(
                  translate('I confirm I have read and understand the restrictions on dangerous goods in cabin and hold luggage'))),
              Padding(
                padding: EdgeInsets.all(4),
              ),
              (gblSettings.aircode != 'SI' )?
              TrText(
                  'I also confirm I am fit to travel and devoid of any Covid-19 symptoms')
                  : Container()
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  backgroundColor: cancelButtonColor()),
              child: new TrText("Decline",
                  style: new TextStyle(color: Colors.black)),
              onPressed: () {
                gblActionBtnDisabled = false;
                Navigator.of(context).pop();
              },
            ),
            new ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  backgroundColor: gblSystemColors.primaryButtonColor),
              child: new Text(
                "Accept",
                style: new TextStyle(
                    color: gblSystemColors
                        .primaryButtonTextColor),
              ),
              onPressed: () {
                _doPaxCheckin(pnr, journeyNo, paxNo);
                ;                /*_checkin(
                    'EW${pnr.pNR.rLOC + pnr.pNR.names.pAX[paxNo].paxNo}:${pnr.pNR.itinerary.itin[journeyNo].depart}:${pnr.pNR.itinerary.itin[journeyNo].arrive}');*/
                gblActionBtnDisabled = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _doPaxCheckin(PnrModel pnr,int journeyNo, int paxNo){
    // if pax 1 include infants
    // EWZZZMBU1:ENI:MNL|ZZZMBU3:ENI:MNL
    String route = ':${pnr.pNR.itinerary.itin[journeyNo].depart}:${pnr.pNR.itinerary.itin[journeyNo].arrive}';
    String cmd = 'EW${pnr.pNR.rLOC}${pnr.pNR.names.pAX[paxNo].paxNo}'+ route;
    if( paxNo == 0){
      // look for infants
      pnr.pNR.names.pAX.forEach((pax) {
        if(pax.paxType == 'IN'){
          cmd += '|${pnr.pNR.rLOC}${pax.paxNo}' + route;
        }
      });
    }
    cmd = cmd + '^E';
    logit('do checkin cmd $cmd');
    _checkin(cmd);

  }

  _displayCheckingAllDialog(PnrModel pnr, int journeyNo) {
    Widget para1 = Text(      translate( "Passenger cabin bags and hold luggage must not contain any articles or substances that may present a danger during transport. Please read the Prohibited Items Notice."));
    if(gblSettings.aircode == 'SI') {
      para1 = RichText(
        text: new TextSpan(
          children: [
            new TextSpan(
              text: 'Passenger cabin bags and hold luggage must not contain any articles or substances that may present a danger during transport. ',
              style: new TextStyle(color: Colors.black),
            ),
            new TextSpan(
              text: 'Please read the Prohibited Items Notice.',
              style: new TextStyle(color: Colors.blue,decoration: TextDecoration.underline),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('https://www.blueislands.com/media/cpdjyjlw/cap1402as_dangerousgoods_1920x1080_2018.jpg'));
                },
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        List <Widget> body  = [];

        if( gblSettings.wantDangerousGoods || gblSettings.wantDangerousGoodsCheckin) {
          body.add(TrText('The following is a non-exhaustive list of Prohibited Items'));

          double height = gblIsIos ? 350 : 450;
          double width = gblIsIos ? 220 : 250;
          if( gblSettings.dagerousdims != '' ){
            // format {"iOSw": "220", "iOSh": "350", "aNDw": "400", "aNDh": "500"}
            Map dimMap = json.decode(gblSettings.dagerousdims.toUpperCase());
            if( gblIsIos) {
              height = double.parse(dimMap['IOSH']);
              width = double.parse(dimMap['IOSW']);
            } else {
              height = double.parse(dimMap['ANDH']);
              width = double.parse(dimMap['ANDW']);
            }
          }


          //list.add(Padding(padding: EdgeInsets.only(top: 60)));
          body.add( Image(
            image: NetworkImage('${gblSettings.gblServerFiles}/pageImages/dangerousgoods.jpg'),
            height: height,
            width: width,
            fit: BoxFit.fill,
          ));

         /* body.add(CheckboxListTile(
            title: TrText("I confirm that I have read and understood this notice and there are no Dangerous Goods or Prohibited Items in my hand luggage or checked-in baggage."),
            value: buttonEnabled,
            onChanged: (newValue) {
              setState(() {
                buttonEnabled = newValue!;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
          ));*/
        } else {
          body.add(para1);
          body.add(Padding(padding: EdgeInsets.all(4)));
          if (gblSettings.prohibitedItemsNoticeUrl != null) {
            body.add(appLinkWidget(
                'https',
                gblSettings.prohibitedItemsNoticeUrl.replaceAll('https', ''),
                Text(gblSettings.prohibitedItemsNoticeUrl,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ))));
          }
          body.add(Padding(padding: EdgeInsets.all(4),),);
          body.add(TrText(
              'I confirm I have read and understand the restrictions on dangerous goods in cabin and hold luggage'));
          body.add(Padding(padding: EdgeInsets.all(4)));
          if (gblSettings.aircode != 'SI') {
            body.add(TrText(
                'I also confirm I am fit to travel and devoid of any Covid-19 symptoms'));
          }
        }
        return AlertDialog(
          title: new TrText("Online Check-in"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: body,
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new TrText("Decline",
                  style: new TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  backgroundColor: gblSystemColors.primaryButtonColor),
              child: new Text(
                "Accept",
                style: new TextStyle(
                    color: gblSystemColors
                        .primaryButtonTextColor),
              ),
              onPressed: () {
                var buffer = new StringBuffer();
                buffer.write('EW');

                for (var paxNo = 1;
                paxNo <= pnr.pNR.names.pAX.length;
                paxNo++) {
                  if (paxNo != 1) {
                    buffer.write('|');
                  }
                  buffer.write(
                      '${pnr.pNR.rLOC}$paxNo:${pnr.pNR.itinerary.itin[journeyNo].depart}:${pnr.pNR.itinerary.itin[journeyNo].arrive}');
                }

                _checkin(buffer.toString());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _sendAutoseatCommand(String cmd) async {
    String msg = '';
    //if( gblSettings.useWebApiforVrs) {
    if (gblSession == null) gblSession = new Session('0', '', '0');
    msg = json.encode(
        VrsApiRequest(
            gblSession!, cmd,
            gblSettings.xmlToken.replaceFirst('token=', ''),
            vrsGuid: gblSettings.vrsGuid,
            notifyToken: gblNotifyToken,
            rloc: gblCurrentRloc,
            phoneId: gblDeviceId,
            language: gblLanguage
        )
    );
    msg = "${gblSettings.xmlUrl}VarsSessionID=${gblSession!.varsSessionId}&req=$msg";
    //}
    /*  else {
      msg = gblSettings.xmlUrl +
          gblSettings.xmlToken +
          '&Command=' +
          cmd;
    }*/

    print('_sendAutoseatCommand::$msg');
    //final response = await
    http.get(Uri.parse(msg),headers: getXmlHeaders()).then((response) {
      //Map map;
      if (response.statusCode == 200) {
        try {
          String vrsResponse;
          vrsResponse = response.body
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '');

          print('_sendAutoseatCommand_vrsResponse::$vrsResponse');

          if (!vrsResponse.contains('ERROR:')) {
            Repository.get().fetchPnr(widget.rloc).then((v) {
              _autoSeatCompleted(v!);

              //Map map = json.decode(v.data);
              //PnrModel pnr = new PnrModel.fromJson(map);
              //_displayCheckingAllDialog(pnr, 0);
            });
          } else {
            print(vrsResponse);
            if (vrsResponse.contains('ERROR - FAILED TO AUTO ALLOCATE SEATS')) {
              _showError(
                  'Please report to the airport check-in desk to complete check-in.');
            } else {
              _showError(vrsResponse);
            }

            _actionCompleted();
          }

          //refreshBooking();
        } catch (e) {
          print(e.toString());
          _showError('Please check your internet connection');
          _actionCompleted();
        }
      } else {
        _actionCompleted();
      }
    }).catchError((e) {
      _showError('Please check your internet connection');
      _actionCompleted();
    });
  }

  _autoseat(PnrModel pnr, int journey) async {
    List<PAX> paxList = [];
    // new List<PAX>();
    StringBuffer cmd = new StringBuffer();

    // paxList = pnr.pNR.names.pAX.where((p) => p.paxType != 'IN').toList();

    if (pnr.pNR.aPFAX == null) {
      pnr.pNR.names.pAX.forEach((p) {
        //paxList = pnr.pNR.names.pAX.where((p) => p.paxType != 'IN').toList();
        if( p.paxType != 'IN'){
          paxList.add(p);
        }
      });
    } else {
      pnr.pNR.names.pAX.forEach((p ) {
        if (p.paxType != 'IN') {
          bool found = false;
          pnr.pNR.aPFAX.aFX.forEach((ap) {
            if(ap.pax == p.paxNo &&
                ap.seat != "" &&
                ap.text.contains(pnr.pNR.itinerary.itin[journey].cityPair)){
              found = true;
            }
          });
          if(found == false ) paxList.add(p);
        }
        /* pnr.pNR.aPFAX.aFX.firstWhere(
                    (ap) =>
                        ap.pax == p.paxNo &&
                        ap.seat != "" &&
                        ap.text
                            .contains(pnr.pNR.itinerary.itin[journey].cityPair),
                    ) ==
                null) {
          paxList.add(p);
        }*/
      });
    }

    //ES-1RABH5Z8ABZKOI*LM0032/27/SEP/2019AUTO-Y3|1, 2, 3

    cmd.write('ES-'); //ES-
    //1 = First pax number you want to allocate a seat for in the group

    paxList.sort((a, b) => a.paxNo.compareTo(b.paxNo));

    cmd.write(paxList.first.paxNo);
    cmd.write('R'); //R
    cmd.write('${pnr.pNR.rLOC}'); //ABH5Z8 = Record Locator
    cmd.write(
        pnr.pNR.itinerary.itin[journey].cityPair); //ABZKOI = Origin Destination

    cmd.write(
        '*${pnr.pNR.itinerary.itin[journey].airID}${pnr.pNR.itinerary.itin[journey].fltNo}'); //LM0032 = Flight Number
    DateTime fltDate = DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate);
    List<Month> month = Month.values;
    String fltDay = fltDate.day.toString().padLeft(2, '0');
    String fltMonth = month[fltDate.month - 1].toString().split('.')[1];
    String fltYear = fltDate.year.toString();
    cmd.write('/$fltDay/$fltMonth/$fltYear');
    cmd.write('AUTO-');
    cmd.write(pnr.pNR.itinerary.itin[journey].cabin); //Y = Cabin Class
    cmd.write(paxList.length); //3 = Total seats you want to assign
    cmd.write('|'); //|
    paxList.forEach((p) => cmd.write('${p.paxNo},'));

    //print(cmd.toString());
    print('_autoseat vrsCmd = ${cmd.toString().substring(0, cmd.toString().length - 1)}');
    _sendAutoseatCommand(cmd.toString().substring(0, cmd.toString().length - 1));
    //  .then((v) {
    //   if (v) {
    //   _displayCheckingAllDialog(pnr, journey);
    //   }
    // }
    // );
  }

  preferredSeating(ButtonClickParams buttonClickParams, PnrModel pnr, List<Pax> paxlist, bool checkinOpen) {
    gblPnrModel = pnr;
    gblButtonClickParams = buttonClickParams;

    logit('seatplan cmd ls${pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].airID + pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].fltNo}/${new DateFormat('ddMMM').format(DateTime.parse(pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].depDate +
        ' ' + pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].depTime))}${pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].depart + pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].arrive}[CB=${pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].classBand}][CUR=${pnr.pNR.fareQuote.fQItin[0].cur}][MMB=True]~x}');

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatPlanWidget(
            paxlist: paxlist,
            isMmb: true,
            ischeckinOpen: checkinOpen,
            flt: pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].airID + ' ' + pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].fltNo + ' ' +
                pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].depart + '-' + pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].arrive,
            seatplan:
            'ls${pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].airID + pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].fltNo}/${new DateFormat('ddMMM').format(DateTime.parse(pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].depDate + ' ' +
                pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].depTime))}${pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].depart +
                pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].arrive}[CB=${pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].classBand}][CUR=${pnr.pNR.fareQuote.fQItin[0].cur}][MMB=True]~x',
            rloc: pnr.pNR.rLOC,
            cabin: pnr.pNR.itinerary.itin[buttonClickParams.journeyNo].cabin,
            journeyNo: buttonClickParams.journeyNo.toString(),
            selectedpaxNo: buttonClickParams.paxNo + 1,
          ),
        )).then((pnrModel) {
      if( pnrModel != null ) {
        // pnrModel null if page closed
        _handleSeatChanged(pnrModel);
      } else if (gblPnrModel != null ) {
        setState(() {
          objPNR = gblPnrModel;
        });
      }
      // Navigator.of(context).pop();
    });
  }

  autoSeatingSelection(int paxNo, int journeyNo, PnrModel pnr,
      List<Pax> paxlist, bool chargeForPreferredSeating) {
    String text =
    translate('Your remaining unallocated seats will now be allocated randomly, do you wish to proceed?');

    Widget autoseatingButton = OutlinedButton(
      // style: OutlinedButton.styleFrom(
      // borderSide: BorderSide(
      //     color: AppConfig.of(context).systemColors.primaryButtonColor))
      //     ,
      child: TrText('Allocate seats randomly',
          textAlign: TextAlign.center,
          style: new TextStyle(
              color: gblSystemColors.primaryButtonColor)),
      onPressed: () {
        //Navigator.of(context).pop();
        autoseat(pnr, journeyNo);
        Navigator.of(context).pop();
      },
    );

    Widget preferredSeatingButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: gblSystemColors.primaryButtonColor),
      child: Text(
        chargeForPreferredSeating
            ? 'Pay for preferred seat'
            : 'Choose preferred seat',
        textAlign: TextAlign.center,
        style: new TextStyle(
            color: gblSystemColors.primaryButtonTextColor ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        preferredSeating( ButtonClickParams(paxNo: paxNo, journeyNo:journeyNo), pnr, paxlist,false);
      },
    );

    AlertDialog alert = AlertDialog(
        title: TrText('Seating Preference'),
        content: Text(text),
        actions: <Widget>[
          autoseatingButton,
          preferredSeatingButton,
        ]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

List<Widget> checkinAllButton() {
  List<Widget> list = [];
  // new List<Widget>();
  list.add(Divider());
  list.add(Row(
    children: <Widget>[
      Expanded(
        child: TextButton(
          onPressed: () => {},
          style: TextButton.styleFrom(
              side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
              foregroundColor: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Check-in All Passengers',
                style: TextStyle(color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
              ),
              Icon(
                Icons.done,
                size: 20.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      )
    ],
  ));
  return list;
}
