import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/mmb/viewBookingPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/apis_pnr.dart';
import 'dart:convert';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/timeHelper.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/data/globals.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/utilities/widgets/colourHelper.dart';

import '../Helpers/networkHelper.dart';
import '../components/bottomNav.dart';
import '../v3pages/cards/typogrify.dart';
import '../v3pages/v3Constants.dart';


class MyBookingsPage extends StatefulWidget {
  MyBookingsPage({Key key= const Key("mybook_key")}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new MyBookingsPageState();
}
List<PnrDBCopy> activePnrs = [];
List<PnrDBCopy> recentPnrs = [];
List<PnrDBCopy> oldPnrs = [];
String _error = '';
bool gotPnrs = false;

class MyBookingsPageState extends State<MyBookingsPage> with TickerProviderStateMixin  {
  // new List<PnrDBCopy>();
  bool _loadingInProgress = false;
  Offset? _tapPosition;
  TabController? _controller;
  final formKey = GlobalKey<FormState>();
  String _rloc ='';
  String fqtvEmail = '';
  String fqtvNo = '';
  String fqtvPass='';
  String _surname ='';
  bool _isButtonDisabled = false;
  bool _isHidden = false;
  TextEditingController _fqtvTextEditingController =   TextEditingController();
  TextEditingController _passwordEditingController =   TextEditingController();
  TextEditingController _emailEditingController =   TextEditingController();


  void onComplete(){
    _loadingInProgress = false;
    setState(() {
      print('getb setState');
      _loadingInProgress = false;
    });
  }

  @override
  void initState() {
    super.initState();
    gblActionBtnDisabled = false;
    gblPaymentMsg = '';
    gblError = '';
    gblCurPage = 'MYBOOKINGS';

    _loadingInProgress = true;
    _isButtonDisabled = false;
    _isHidden = true;

    var tablen = 3;
    if( gblSettings.displayErrorPnr) {
      tablen = 4;
    }
    if( gblSettings.wantFQTV && gblSettings.wantFindBookings) {
      tablen +=1;
    }
    _controller = TabController(length: tablen, vsync: this);

    getmybookings(onComplete);
    Repository.get().getAllCities().then((cities) {});
  }

 /* getmybookings()  {
    gblNeedPnrReload = false;
    Repository.get().getAllPNRs().then((pnrsDBCopy) {
      List<PnrDBCopy> thispnrs = [];
      List<PnrDBCopy> thisOldpnrs = [];

      List<PnrDBCopy> olderPnrs = [];
      // new List<PnrDBCopy>();
      logit('get my bookings');
      for (var item in pnrsDBCopy) {
        String pnrJson = item.data ; //.replaceAll('"APPVERSION": 1.0.0.98,','"');

        Map<String, dynamic> map = jsonDecode(pnrJson);
        PnrModel _pnr = new PnrModel.fromJson(map);
        PnrDBCopy _pnrs = new PnrDBCopy(
            rloc: item.rloc,
            data: item.data,
            nextFlightSinceEpoch: _pnr.getnextFlightEpoch(),
            delete: item.delete);
        //if (_pnrs.nextFlightSinceEpoch != 0) {
//        logit('Loading ${_pnr.pNR.rLOC}');
        _error = _pnr.validate();
        //logit('Loading ${_pnr.pNR.rLOC}  $_error');
        if (_error.isEmpty && _pnr.hasFutureFlightsAddDayOffset(0)) {
          thispnrs.add(_pnrs);
        } else if (_error.isEmpty && _pnr.hasFutureFlightsMinusDayOffset(7)) {
          thisOldpnrs.add(_pnrs);
        } else if (gblSettings.displayErrorPnr) {
          if ( _pnr.hasFutureFlightsAddDayOffset(0)) {
            thispnrs.add(_pnrs);
          } else if ( _pnr.hasFutureFlightsMinusDayOffset(7)) {
            thisOldpnrs.add(_pnrs);
          } else {
            olderPnrs.add(_pnrs);
          }

        } else {
          // remove old booking
          try {
            logit('Deleting ${item.rloc}');
            Repository.get().deletePnr(item.rloc);
            Repository.get().deleteApisPnr(item.rloc);
          } catch(e) {
            logit(e.toString());
          }
        }

        //}
      }

      thispnrs.sort(
          (a, b) => a.nextFlightSinceEpoch.compareTo(b.nextFlightSinceEpoch));
      setState(() {
        print('getb setState');
        activePnrs = thispnrs;
        recentPnrs = thisOldpnrs;
        oldPnrs = olderPnrs;
        _loadingInProgress = false;
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
  if( gblNeedPnrReload){
    getmybookings(onComplete);
  }
    if (_loadingInProgress) {
      return Scaffold(
          body: new Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TrText('Loading your bookings...'),
            ),
          ],
        ),
      ));
    } else {
      List <Widget> tabs = [];
      List <Widget> tabeViews = [];
      tabs.add(TrText('Active'));
      tabs.add(TrText('Recent'));
      if( gblSettings.displayErrorPnr) {
        tabs.add(TrText('Old'));
      }
      tabs.add(TrText('Add Booking'));

      tabeViews.add(new Container(child: myTrips('A')));
      tabeViews.add(new Container(child: myTrips('R')));
      if( gblSettings.displayErrorPnr) {
        tabeViews.add(new Container(child: myTrips('O')));
      }
      tabeViews.add(new Container(child: addBooking()));

      if( gblSettings.wantFQTV && gblSettings.wantFindBookings) {
        tabs.add(TrText('Import Bookings'));
        tabeViews.add(new Container(child: findAllBookings()));
      }

      return Scaffold(
          appBar: appBar(context, "My Bookings",
          bottom:  new PreferredSize(
          preferredSize: new Size.fromHeight(30.0),
    child: new Container(
    height: 30.0, child:        TabBar(

          indicatorColor: gblSystemColors.tabUnderlineColor == null ? Colors.amberAccent : gblSystemColors.tabUnderlineColor,
          isScrollable: true,
          labelColor: gblSystemColors.headerTextColor,
          tabs: tabs,
          controller: _controller),
          ),
          ),
          ),// translated in appBar
          endDrawer: DrawerMenu(),
        bottomNavigationBar: getBottomNav(context, ),
          body: TabBarView(
              controller: _controller,
              children: tabeViews,
      ),

    );
    }
  }
  Widget findAllBookings() {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        titlePadding: EdgeInsets.only(top: 0),
        contentPadding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 0),
        title: Column(children: [
          ListTile(
            leading: Icon(
              Icons.person_pin,
              color: Colors.blue,
              size: 40,
            ),
            title: Text(
                translate('${gblSettings.fqtvName} ') + translate('CONNECT')),
          ),
          Divider(
            color: Colors.grey,
            height: 4.0,
          ),
        ]),
        content: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TrText( 'Please provide your Login to load your future bookings'),
                new TextFormField(
                  decoration: getDecoration(
                      '${gblSettings.fqtvName} ' + translate('number')),
                  controller: _fqtvTextEditingController,
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    if (value != null) {
                      //.contactInfomation.phonenumber = value.trim()
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                new TextFormField(
                  obscureText: _isHidden,
                  obscuringCharacter: "*",
                  controller: _passwordEditingController,
                  decoration: getDecoration(translate('Password')),
/*                  suffix: InkWell(
                    onTap: _togglePasswordView,
                    child: Icon( Icons.visibility),
                  ),
                ),*/
                  keyboardType: TextInputType.visiblePassword,
                  onSaved: (value) {
                    if (value != null) {
                      //.contactInfomation.phonenumber = value.trim()
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                 /*   ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey.shade100),
                      child: TrText(
                        "CANCEL",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        //Put your code here which you want to execute on Cancel button click.
                        Navigator.of(context).pop();
                      },
                    ),

                  */
                    // SizedBox(                      width: 20,                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(foregroundColor: Colors.blue),
                      child: Row(children: <Widget>[
                        (_isButtonDisabled)
                            ? new Transform.scale(
                                scale: 0.5,
                                child: CircularProgressIndicator(),
                              )
                            : Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                        _isButtonDisabled
                            ? new TrText("Logging in...",
                                style: TextStyle(color: Colors.white))
                            : TrText('CONTINUE',
                                style: TextStyle(color: Colors.white))
                      ]),
                      onPressed: () {
                        if (_isButtonDisabled == false) {
                          if (_fqtvTextEditingController.text.isNotEmpty &&
                              _passwordEditingController.text.isNotEmpty) {
                            _isButtonDisabled = true;
                            _loadingInProgress = true;
                             _fqtvLogin();

                            setState(() {});
                          } else {
                            _error = "Please complete both fields";
                            _loadingInProgress = false;
                            _isButtonDisabled = false;
                            // _actionCompleted();
                            showAlertDialog(context, 'Error', _error);
                          }
                        }
                        //});

                        //Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ));
  }
      //actions: <Widget>[)    ]


  void _fqtvLogin() async {
    if ( gblSession == null || gblSession!.isTimedOut()) {
      await login().then((result) {
        gblSession =
            Session(result.sessionId, result.varsSessionId, result.vrsServerNo);
        logit('new session');
      });
    }
    FqtvMemberloginDetail fqtvMsg = FqtvMemberloginDetail(_emailEditingController.text,
        _fqtvTextEditingController.text,
        _passwordEditingController.text);
    String msg = json.encode(FqTvCommand(gblSession!, fqtvMsg ).toJson());
    String method = 'GetAirMilesBalance';

    logit(msg);
    _sendVRSCommand(msg, method).then((result) {
      if( result == null || result == ''){
        _error = translate('Bad server response logging on');
        _isButtonDisabled = false;
        _loadingInProgress = false;
        _actionCompleted();
        showAlertDialog(context, 'Error', _error);
        return;
      }
      Map<String, dynamic> map = json.decode(result);
      ApiFqtvMemberAirMilesResp resp = new ApiFqtvMemberAirMilesResp.fromJson(
          map);
      _loadingInProgress = false;
      if (resp.statusCode != 'OK') {
        _error = resp.message;
        _isButtonDisabled = false;
        _actionCompleted();
        showAlertDialog(context, 'Error', _error);
      } else {
        _error ='';
        //widget.passengerDetail.fqtv = _fqtvTextEditingController.text;
        fqtvNo = _fqtvTextEditingController.text;
        gblFqtvNumber = fqtvNo;
        fqtvEmail = _emailEditingController.text;
        fqtvPass = _passwordEditingController.text;
        gblFqtvBalance = resp.balance;

        _loadingInProgress = true;
        // now load transactions
        _loadTransactions();
        /*
        method = 'GetDetailsByUsername';
        msg = json.encode(
            ApiFqtvGetDetailsRequest(fqtvEmail, fqtvNo, fqtvPass).toJson());

        _sendVRSCommand(msg, method).then((result) {
          Map map = json.decode(result);

          try {
            ApiFqtvMemberDetailsResponse resp = new ApiFqtvMemberDetailsResponse
                .fromJson(map);
            if (resp.statusCode != 'OK') {
              _error = resp.message;
              _actionCompleted();
              _isButtonDisabled = false;
              showAlertDialog(context, 'Error', _error);
            } else {
              _loadingInProgress = true;
              // now load transactions
              _loadTransactions();

              gblPassengerDetail.fqtv = fqtvNo;
              gblPassengerDetail.fqtvPassword = fqtvPass;

              setState(() {});
            }
          } catch(e) {
            _loadingInProgress = false;
            print(e);
          }
        });
        */

      }});
  }

  void _loadTransactions() async {
    ApiFqtvPendingRequest fqtvMsg = ApiFqtvPendingRequest(
        fqtvNo,
        fqtvPass);
    String msg = json.encode(fqtvMsg.toJson());
    String method = 'GetPendingTransactions';

    logit(msg);
    _sendVRSCommand(msg, method).then((result){
      if( result == null || result == '') {
        //_error = translate('Error searching for bookings');
        _loadingInProgress = false;
        _isButtonDisabled = false;
        _actionCompleted();
 //       showAlertDialog(context, 'Error', _error);
        return;
      } else {
        Map<String, dynamic> map = json.decode(result);
        ApiFqtvMemberTransactionsResp resp = new ApiFqtvMemberTransactionsResp
            .fromJson(map);
        if (resp.statusCode != 'OK') {
          _error = resp.message;
          _actionCompleted();
          showAlertDialog(context, 'Error', _error);
        } else {
          var transactions = resp.transactions;
          _loadingInProgress = true;
          setState(() {});
          _bulkLoadPnrs(transactions!);
          //showAlertDialog(context, 'Information', 'Found ${transactions.length} PNRs');
        }
      }
    });
  }



  Future _sendVRSCommand(msg, method) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/FqTvMember/$method"),
        headers: getApiHeaders(),
        body: msg);

    if (response.statusCode == 200) {
      logit('message send successfully: $msg' );
      return response.body.trim();
    } else {
      logit('failed1: $msg error: ${response.statusCode}');
      _error = translate('message failed Error code ') + response.statusCode.toString();
      try{
        if( response.body != null && response.body.isNotEmpty) {
          logit(response.body);
          _error = response.body;
        }
      } catch(e){}

      _actionCompleted();
      showAlertDialog(context, 'Error' , _error);
    }
  }
  void _actionCompleted() {
    setState(() {
//      _loadingInProgress = false;
    });
  }

  Widget addBooking() {
    return Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: new Theme(
            data: new ThemeData(
              primaryColor: Colors.blueAccent,
              primaryColorDark: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.all(10),
                  child: new TrText(
                      'Add an existing booking using your booking reference and passenger last name',
                      style: TextStyle(fontSize: 16.0, color: Colors.black)),
                ),
                new TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  //maxLength: 6,
                  decoration: getDecoration(translate("Enter your booking reference")),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9A-Za-z]"))
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return translate('Please enter a booking reference');
                    }
                    if (value.trim().length != 6) {
                      return translate(
                          'Your booking reference is 6 charactors long');
                    }
                    return null;
                  },
                  onSaved: (value) => _rloc = value!.trim(),
                ),
                new Padding(padding: EdgeInsets.all(10)),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: getDecoration(translate("Enter your surname")),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return translate('Please enter a surname');
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => _surname = value!.trim().toUpperCase(),
                ),
                Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: actionButtonColor(),
                    borderRadius: BorderRadius.circular(25.0),
                    shadowColor: Colors.grey.shade100,
                    elevation: 5.0,
                    child: new MaterialButton(
                      minWidth: 180,
                      height: 50.0,
                      child: TrText(
                        'ADD BOOKING',
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: gblSystemColors.primaryButtonTextColor),
                      ),
                      onPressed: () {
                        if (gblNoNetwork == false &&  formKey.currentState!.validate()) {
                          _loadPnr();
                        }
                      },
                    ),
                  ),
                )),
              ],
            ),
          ),
        ));
  }

  Widget myTrips(String typePnr) {
    List<PnrDBCopy> pnrs = activePnrs;

    Center noFutureBookingsFound =  Center(
        child: TrText('No future bookings found',
            style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
    if(typePnr == 'R'  ) {
      pnrs = recentPnrs;
      noFutureBookingsFound = Center(
          child: TrText('No recent bookings found',
              style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
    } else if(typePnr == 'O'  ) {
        pnrs = oldPnrs;
        noFutureBookingsFound =  Center(
            child: TrText('No old bookings found',
                style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
    }
    if (pnrs.length == 0) return noFutureBookingsFound;

    ListView listViewOfBookings = ListView.builder(
        itemCount: pnrs.length,
        itemBuilder: (BuildContext context, index) =>
            _buildListItem(context, pnrs[index]));

    return listViewOfBookings.semanticChildCount! > 0
        ? new Container(child: listViewOfBookings)
        : noFutureBookingsFound;
  }

  Widget _buildListItem(BuildContext context, PnrDBCopy document) {

    String pnrJson =document.data;
    //pnrJson = pnrJson.replaceAll('"APPVERSION": 1.0.0.98,','"');
    Map<String, dynamic> map = jsonDecode(pnrJson);
    PnrModel pnr = new PnrModel.fromJson(map);
    //if (hasFutureFlights(pnr.pNR.itinerary.itin.last)) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        style: TextButton.styleFrom(
            padding:
                EdgeInsets.only(left: 3.0, right: 3.0, bottom: 3.0, top: 3.0)),
        child: new Column(children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Text(document.rloc, //document['rloc'],
                  style: new TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w700)),
              _getIcons(pnr),
              TrText((pnr.pNR.appVersion  == null ) ?'Needs Reload' : ' ', style: TextStyle(color: Colors.red),),
              GestureDetector(
                child: Icon(Icons.more_vert),
                onTapDown: _storePosition,
                onTapUp: (tabUpDetails) {
                  if( gblNoNetwork == false) {
                    _showPopupMenu(document.rloc);
                  }
                }
                ,
              ),
            ],
          ),
          new Divider(),
          fltLines(pnr),
          pnr.isFundTransferPayment() ? _paymentPending(pnr) : Container(),
        ]),
        onPressed: () {
          if(pnr.pNR.appVersion  != null ) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ViewBookingPage(
                        rloc: document.rloc,
                      )),
            ).then((value) => setState((){
              print('reload');
            }));
          }
        },
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
//     }
//     else {
//       return null;
// return new Padding(
//         padding: EdgeInsets.all(0),
//       );
//    }
  }
  
  Widget _getIcons(PnrModel pnr){
    if( pnr == null || pnr.pNR == null ){
      return Container();
    }
    int noPax = pnr.pNR.paxCount();
    int noSeats = pnr.pNR.seatCount();
    return Row( mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(noPax.toString()),
        Icon(Icons.person),
        Padding(padding: EdgeInsets.all(2)),
        Text(noSeats.toString()),
        Icon(Icons.event_seat),

      ],);
  } 

  Widget _paymentPending(PnrModel pnr){
    return
      Container(
        color: Colors.grey.shade200,
        padding: EdgeInsets.all(5),
      child: Row(

      children: [
        Icon(Icons.warning_amber),
        Padding(padding: EdgeInsets.all(2)),
        TrText('Payment Pending'),
        Padding(padding: EdgeInsets.all(4)),
        Text(formatPrice(pnr.pNR.basket.outstanding.cur, double.parse(pnr.pNR.basket.outstanding.amount)))
      ],
    )
      );
  }


  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  _showPopupMenu(String rloc) async {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition! & Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size),
      items: [
         PopupMenuItem(
           child: TextButton.icon(
             icon: Icon(Icons.refresh),
             label: TrText('Reload booking'),
             onPressed: () {
                gblCurrentRloc = rloc;
                _refreshBooking(rloc);
/*
                   .then((onValue) => Navigator.of(context).pop())
                   .then((onValue) => getmybookings());
*/
             },
           ),
         ),

        PopupMenuItem(
          child: TextButton.icon(
            icon: Icon(Icons.delete_outline_rounded),
            label: TrText('Remove booking'),
            onPressed: () {
              Repository.get()
                  .deletePnr(rloc)
                  .then((onValue) => Navigator.of(context).pop())
                  .then((onValue) => getmybookings(onComplete));
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  Future<void> _refreshBooking(String rloc) async {
    logit('_refreshBooking');
    Navigator.of(context).pop();
    setState(() {
      _loadingInProgress = true;

    });
    try {
      await Repository.get().fetchApisStatus(rloc);
      await Repository.get().fetchPnr(rloc);
      Future.delayed(const Duration(milliseconds: 500), () {
        getmybookings(onComplete);
      });
    } catch(e) {
      logit(e.toString());
      _error = e.toString();
      setState(() {
        _loadingInProgress = false;
      });
      showAlertDialog(context, 'Error', _error);
    }

    }

  bool isFltPassedDate(List<Itin> journey) {
//      DateTime now = DateTime.now();
    DateTime now = getGmtTime(); // DateTime.now().toUtc();
    var fltDate;
    bool result = false;
    journey.forEach((f) {
      // fltDate = DateTime.parse(f.depDate + ' ' + f.depTime);
      fltDate = DateTime.parse(f.ddaygmt + ' ' + f.dtimgmt);
      //f.ddaygmt)
      if (now.isAfter(fltDate)) {
        result = true;
      }
    });

    return result;
  }

  Widget fltLines(PnrModel pnr) {
    List<Widget> fltWidgets = [];
    // List<Widget>();
    //List<List<Itin>> journeys  = List<List<Itin>>();
    List<Itin> flt = [];
    // List<Itin>();
    List<List<Itin>> journeys = [];
    // List<List>();
    //journeys



    int noFlts = 0;
    if(pnr.pNR.itinerary != null && pnr.pNR.itinerary.itin != null  ) {
      noFlts = pnr.pNR.itinerary.itin.length;
      pnr.pNR.itinerary.itin.forEach((f) {
        flt.add(f);
        if (f.nostop != 'X' || (f.nostop == 'X' && noFlts == 1)) {
          journeys.add(flt);
          flt = [];
          // List<Itin>();
        }
      });
    }

    if (fltWidgets.length > 1) {
      new Divider();
    }

    int no = 0;
    journeys.forEach((journey) {
      //can this be moved outside
      no +=1;
      List <Widget> list =[];

      if( journey.last.depart.length + journey.last.arrive.length < 40) {
          list.add(Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(cityCodetoAirport(journey.first.depart),style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
              Padding(padding: EdgeInsets.all(2)),
              Icon(Icons.arrow_forward,color: Colors.black,size: 12.0,),
              Padding(padding: EdgeInsets.all(2)),
              Text(cityCodetoAirport(journey.last.arrive),style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            ],
          )) ;
      } else {
        list.add(Text(cityCodetoAirport(journey.first.depart),
            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)));
        list.add(Text(cityCodetoAirport(journey.last.arrive),
            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)));
      }

      list.add( Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: (formatFltTimeWidget(journey.first)),
      ),
      new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
      new RotatedBox(
      quarterTurns: 1,
      child: Icon(
      Icons.airplanemode_active,
      )),
      new Padding(
      padding: EdgeInsets.only(left: 5.0),
      ),
      // new Text(
      //   journey.first.airID +
      //       journey.first.fltNo,
      new Text(
      isFltPassedDate(journey)
      ? translate('departed')
          : journey.length > 1
      ? '${journey.length - 1} ' + translate('connection')
          : translate('Direct Flight'),
      style: new TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w300),
      ),
      ],
      ),
      ],
      ));



      fltWidgets.add(
        new Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list),
      );
      if( no < journeys.length ) {
        fltWidgets.add(Padding(padding: EdgeInsets.all(5)));
      }
    });

    return new Column(children: fltWidgets.toList());
  }

  List<Widget> formatFltTimeWidget(Itin journey) {
    List<Widget> list = [];
    // List<Widget>();
    if (journey.fltNo != '0000') {
      list.add(Icon(Icons.date_range));
      list.add(Padding(
        padding: EdgeInsets.only(left: 5.0),
      ));
      list.add(Text(
          //(DateFormat('EEE dd MMM h:mm a').format(DateTime.parse(journey.depDate + ' ' + journey.depTime)).toString()).replaceFirst('12:00 AM', '00:00 AM'),
          getIntlDate('EEE dd MMM h:mm a', DateTime.parse(journey.depDate + ' ' + journey.depTime)).replaceFirst('12:00 AM', '00:00 AM'),
          style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)));
    } else {
      if (journey.status == 'QQ') {
        list.add(TrText('Flight Not Operating',
            style: new TextStyle(fontSize: 16.0,
                color: Colors.red,
                fontWeight: FontWeight.bold)));
      } else {
        list.add(TrText('Flight Problem',
            style: new TextStyle(fontSize: 14.0,
                color: Colors.red,
                fontWeight: FontWeight.bold)));
      }
    }
    return list;
  }
  void _loadPnr() async {
    setState(() {
      _loadingInProgress = true;
    });
    validateAndSubmit();
    // _pnrLoaded();
  }

  void _pnrLoaded() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  void _bulkLoadPnrs(List<ApiFQTVMemberTransaction> transactions) async {
    setState(() {
      _loadingInProgress = true;
    });
    var index = 0;
    var count = transactions.length;

    if( count > 0 ) {
      transactions.forEach((tran) {
        loadBooking(tran.pnr).then((pnrJson) {
          index++;
          pnrJson = pnrJson!.replaceAll('\n', '').replaceAll('\r', '');
          if (pnrJson.startsWith('{')) {
            Map<String, dynamic> pnrMap = json.decode(pnrJson);
            if( gblVerbose) logit('Loaded PNR: ${tran.pnr}');
            var objPnr = new PnrModel.fromJson(pnrMap);
            _rloc = tran.pnr;

            // save
            PnrDBCopy pnrDBCopy = new PnrDBCopy(
                rloc: objPnr.pNR.rLOC,
                data: pnrJson,
                delete: 0,
                nextFlightSinceEpoch: objPnr.getnextFlightEpoch());
            Repository.get().updatePnr(pnrDBCopy).then((w) {
              fetchApisStatus(false);

              if (index >= count) {
                setState(() {

                });
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/MyBookingsPage', (Route<dynamic> route) => false);
              }
              //Navigator.of(context).pop();
            });
          } else {
            logit('Error loading pnr: ' + pnrJson);
          }
        });
      });
    } else {

      showAlertDialog(context, 'Alert','No pending bookings');

      Navigator.of(context).pushNamedAndRemoveUntil(
          '/MyBookingsPage', (Route<dynamic> route) => false);
    }

  }

  Future<String?> loadBooking(String rloc) async {


    String data = await runVrsCommand('*$rloc~x');
    String pnrJson;
    //Map pnrMap;
    // await for (String pnrRaw in resStream) {

    if (data.contains('ERROR - RECORD NOT FOUND -')) {
      _error = 'Please check your details';
      //_pnrLoaded();
      showAlertDialog(context, 'Alert', _error);

    } else {
      pnrJson = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      //pnrMap = json.decode(pnrJson);
      // }

      try {
        //pnrMap = json.decode(pnrJson);
        if( gblVerbose) logit('Loaded PNR');
        //var objPnr = new PnrModel.fromJson(pnrMap);
        return pnrJson;
      } catch (e) {
        logit(e.toString());
      }
    }
    return null;
  }


  Future<void> fetchBooking() async {
    //AATMRA
    //AATKK7

    try {
      gblCurrentRloc = _rloc;
      String data = await runVrsCommand('*$_rloc~x');

      String pnrJson;
      Map<String, dynamic> pnrMap;
      // await for (String pnrRaw in resStream) {

      if (data.contains('ERROR - RECORD NOT FOUND -')) {
        _error = 'Please check your details';
        _pnrLoaded();
        //_showDialog();
        showAlertDialog(context, 'Alert', _error);
      } else {
        pnrJson = data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');

        pnrMap = json.decode(pnrJson);
        // }

        try {
          pnrMap = json.decode(pnrJson);
          if( gblVerbose) logit('Loaded PNR');
          var objPnr = new PnrModel.fromJson(pnrMap);
          if (validate(objPnr)) {
            PnrDBCopy pnrDBCopy = new PnrDBCopy(
                rloc: objPnr.pNR.rLOC,
                data: pnrJson,
                delete: 0,
                nextFlightSinceEpoch: objPnr.getnextFlightEpoch());
            Repository.get().updatePnr(pnrDBCopy).then((w) {
              fetchApisStatus(true);
              //Navigator.of(context).pop();
            });

            logit('matched rloc and name');
            //   Navigator.of(context).pop();
          } else {
            _pnrLoaded();
            //_showDialog();
            if (_error == '') {
              _error = translate('name does not match booking');
            }
            showAlertDialog(context, 'Alert', _error);

            logit('did not matched rloc and name');
          }
        } catch (e) {
          _pnrLoaded();
          _error = e.toString();
          showAlertDialog(context, 'Alert', _error);
          //_showDialog();
          logit('$e');
        }
      }
    } catch(e) {
      _pnrLoaded();
      _error = e.toString();
      showAlertDialog(context, 'Alert', _error);
      //_showDialog();
      logit('$e');
    }
  }

  Future<void> fetchApisStatus(bool redirect) async {
    //AATMRA
    //AATKK7

    String data = await runVrsCommand('DSP/$_rloc');
    String apisStatusJson;
    //Map map;
    // await for (String pnrRaw in resStream) {
    apisStatusJson = data
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '')
        .trim();
    try {
      Map<String, dynamic> map = json.decode(apisStatusJson);
      if( gblVerbose) logit('Loaded APIS status');
      ApisPnrStatusModel apisPnrStatus = new ApisPnrStatusModel.fromJson(map);
      DatabaseRecord databaseRecord = new DatabaseRecord(
          rloc: apisPnrStatus.xml!.pnrApis.pnr, //_rloc,
          data: apisStatusJson,
          delete: 0);
      Repository.get().updatePnrApisStatus(databaseRecord).then(
              (v) { //Navigator.of(context).pop()
              if( redirect) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/MyBookingsPage', (Route<dynamic> route) => false);
                }
              });
    } catch (e) {
      showAlertDialog(context, 'Alert', e.toString());
      //_showDialog();
      logit('$e');
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        fetchBooking();
        if( gblSettings.wantApis) {
          fetchApisStatus(false);
        }
        logit('Getting PNR');
      } catch (e) {
        logit('Error: $e');
      }
    }
  }

  bool validate(PnrModel pnr) {
    if (!validateRlocWithName(pnr.pNR.names.pAX)) {
      return false;
    }

    _error = pnr.validate();
    if (_error.isNotEmpty) {
      return false;
    }
    if( pnr.hasFutureFlightsAddDayOffset(1) || pnr.hasFutureFlightsMinusDayOffset(7)) {
      return true;
    }

    _error = 'No future flights';
    return false;
  }

  bool validateRlocWithName(List<PAX> passengers) {
    for (PAX pAX in passengers) {
      if (pAX.surname == _surname.toUpperCase()) {
        return true;
      }
    }
    return false;
  }

}
getmybookings(void Function() onComplete )  {
  gblNeedPnrReload = false;
  gotPnrs = true;
  Repository.get().getAllPNRs().then((pnrsDBCopy) {
    List<PnrDBCopy> thispnrs = [];
    List<PnrDBCopy> thisOldpnrs = [];

    List<PnrDBCopy> olderPnrs = [];
    // new List<PnrDBCopy>();
    logit('get my bookings');
    for (var item in pnrsDBCopy) {
      String pnrJson = item.data ; //.replaceAll('"APPVERSION": 1.0.0.98,','"');

      Map<String, dynamic> map = jsonDecode(pnrJson);
      PnrModel _pnr = new PnrModel.fromJson(map);
      PnrDBCopy _pnrs = new PnrDBCopy(
          rloc: item.rloc,
          data: item.data,
          nextFlightSinceEpoch: _pnr.getnextFlightEpoch(),
          delete: item.delete);
      //if (_pnrs.nextFlightSinceEpoch != 0) {
//        logit('Loading ${_pnr.pNR.rLOC}');
      _error = _pnr.validate();
      //logit('Loading ${_pnr.pNR.rLOC}  $_error');
      if (_error.isEmpty && _pnr.hasFutureFlightsAddDayOffset(0)) {
        thispnrs.add(_pnrs);
      } else if (_error.isEmpty && _pnr.hasFutureFlightsMinusDayOffset(7)) {
        thisOldpnrs.add(_pnrs);
      } else if (gblSettings.displayErrorPnr) {
        if ( _pnr.hasFutureFlightsAddDayOffset(0)) {
          thispnrs.add(_pnrs);
        } else if ( _pnr.hasFutureFlightsMinusDayOffset(7)) {
          thisOldpnrs.add(_pnrs);
        } else {
          olderPnrs.add(_pnrs);
        }

      } else {
        // remove old booking
        try {
          logit('Deleting ${item.rloc}');
          Repository.get().deletePnr(item.rloc);
          Repository.get().deleteApisPnr(item.rloc);
        } catch(e) {
          logit(e.toString());
        }
      }

      //}
    }

    thispnrs.sort(
            (a, b) => a.nextFlightSinceEpoch.compareTo(b.nextFlightSinceEpoch));
    activePnrs = thispnrs;
    recentPnrs = thisOldpnrs;
    oldPnrs = olderPnrs;

    onComplete();
/*
    setState(() {
      print('getb setState');
      activePnrs = thispnrs;
      recentPnrs = thisOldpnrs;
      oldPnrs = olderPnrs;
      _loadingInProgress = false;
    });
*/
  });
}

Widget getMiniMyBookingsPage(BuildContext context)
{
  if( gotPnrs == false ){
    getmybookings((){

    });
  }
  /*ListView listViewOfBookings = ListView.builder(
      shrinkWrap: true,
      itemCount: activePnrs.length,
      itemBuilder: (BuildContext context, index) =>
          getMiniItem(context, activePnrs[index]));
*/
  List<Widget> list = [];
  activePnrs.forEach((element) {
    list.add(getMiniItem(context, element));
  });

  return Container(
 //   color: Colors.lightBlueAccent,
      alignment: Alignment.topLeft,
   //   width: 700,
 //     height: 100,
      child:Column(
        children: list,
      )
  );
    return Text('bookings');
    //return myTrips('A');

}
Widget getMiniItem(BuildContext context , PnrDBCopy document) {
  String pnrJson = document.data;
  //pnrJson = pnrJson.replaceAll('"APPVERSION": 1.0.0.98,','"');
  Map<String, dynamic> map = jsonDecode(pnrJson);
  PnrModel pnr = new PnrModel.fromJson(map);
  DateTime ddt = DateTime.parse(pnr.pNR.itinerary.itin[0].depDate);
  DateTime adt = ddt;
  if( pnr.pNR.itinerary.itin[0].arrOfst.trim() != '') adt.add(Duration(days: int.parse(pnr.pNR.itinerary.itin[0].arrOfst )));
  return InkWell(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) =>
            ViewBookingPage(
              rloc: document.rloc,
            )));
        },
      child: Card( child: Row(
    children: [
      minFlight(getIntlDate('dd MMM', ddt),
          pnr.pNR.itinerary.itin[0].depTime,
          pnr.pNR.itinerary.itin[0].depart,
          pnr.pNR.itinerary.itin.length> 1,
          pnr.pNR.itinerary.itin[0].arrive)
  /*    originDestination(cityCodetoAirport(pnr.pNR.itinerary.itin[0].depart),
          pnr.pNR.itinerary.itin[0].depart, getIntlDate('dd MMM yyyy', ddt), pnr.pNR.itinerary.itin[0].depTime),

      RotatedBox(quarterTurns: 1,child:  Icon(Icons.airplanemode_active)),

      originDestination(cityCodetoAirport(pnr.pNR.itinerary.itin[0].arrive),
          pnr.pNR.itinerary.itin[0].arrive, getIntlDate('dd MMM yyyy', adt), pnr.pNR.itinerary.itin[0].arrTime),*/
    ])),
  );
}
Widget minFlight(String strDate, String strTime, String fromCode, bool isReturn, String toCode ){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: EdgeInsets.all(2),),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(strDate, textScaler: TextScaler.linear(1.2),), // style: TextStyle(fontWeight: FontWeight.bold),
      labelText(strTime.substring(0, 5)),
      ]),
      Padding(padding: EdgeInsets.all(2),),
      Column(
        children: [
      Text(fromCode, textScaler: TextScaler.linear(1.6),style: TextStyle(fontWeight: FontWeight.bold),),
          labelText(cityCodetoAirport(fromCode)),
        ]),
      isReturn ? Icon(Icons.connecting_airports_outlined): RotatedBox(quarterTurns: 1,child:  Icon(Icons.airplanemode_active)),
  Column(
  children: [
    Text(toCode, textScaler: TextScaler.linear(1.6),style: TextStyle(fontWeight: FontWeight.bold),),
    labelText(cityCodetoAirport(toCode)),
  ]),

    ],
  );
}
Widget originDestination(String city, String code, String dt, String tim ){
  return SizedBox(
      width: selectAirportCardWidth - 15,
      //height: 50,

        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
          child: Column(
            children: [
              Align(alignment: Alignment.topLeft,child: labelText(dt),),
              labelText(city),
              Text(code, textScaler: TextScaler.linear(2.0),),

              Text(tim, textScaler: TextScaler.linear(1.2),),

            ],
          ),
        ),
  );
}