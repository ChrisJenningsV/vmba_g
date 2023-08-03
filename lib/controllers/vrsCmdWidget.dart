/*

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pax.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/utilities/helper.dart';

import '../Helpers/networkHelper.dart';
//import 'package:vmba/Products/widgets/productsWidget.dart';


class VrsCmdWidget extends StatefulWidget {
//  NewBooking newBooking;
//  PnrModel pnrModel;
  final VrsCmdType  dataType;
  final List<Pax> paxlist;
  //final String seatplan;
  final String rloc;
  final String journeyNo;
 // final int selectedpaxNo;

  final VrsCmdWidgetState myAppState=new VrsCmdWidgetState();

  VrsCmdWidget(
      { Key key= const Key("vrscmd_key"), this.dataType, this.rloc='', this.paxlist, this.journeyNo ='' }) : super( key: key);


  VrsCmdWidgetState createState() =>      VrsCmdWidgetState();

  void start(VrsCmdParams params){
    myAppState.start(params);
  }

}

class VrsCmdWidgetState extends State<VrsCmdWidget> {
  bool _displayProcessingIndicator;
  bool _displayFinalError;
  String _displayProcessingText;
  bool _wantOK;
  //String _dataName;
  //String _msg;
  //String _url;
  String _error;
  Session session;

  @override void initState() {
    // TODO: implement initState
    super.initState();
    _displayProcessingIndicator = false;
    _displayFinalError = false;
    _wantOK = false;
    _displayProcessingText = '';
    _error = '';
    //_initData();
    //_loadData();

  }


  @override
  Widget build(BuildContext context) {
    String msg = '';
    //Duration duration;

    // TODO: implement build
    if (_displayFinalError || (_error != null && _error.isNotEmpty)) {
      msg = _displayProcessingText + _error;
    } else if (gblNoNetwork == true) {
      msg = translate('No Internet Connection.');
      //duration =  const Duration(hours: 1);
    } else if (_displayProcessingIndicator) {
      msg = _displayProcessingText ;
    } else {
      switch(widget.dataType){
        case VrsCmdType.bookSeats:
//          return ProductsWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel,);
          break;
        case VrsCmdType.loadSeatplan:
          break;
      }
    }
   final snackBar = SnackBar(
      content: Text( msg    , style: TextStyle(color: Colors.red),),
      duration: const Duration(hours: 1),
      action: SnackBarAction(  label: translate('OK'),
      onPressed: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // Some code to undo the change.
      },
      ),
        );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
          return Container();
   }

   bool start(VrsCmdParams params) {
     _initData(params);
     _showstatus(params);
     return true;
   }

  _showstatus(VrsCmdParams params) {
    String msg = _displayProcessingText;
    final snackBar = SnackBar(
      content: Text( msg    , style: TextStyle(color: Colors.red),),
      duration: const Duration(hours: 1),
      action: (_wantOK) ? SnackBarAction(  label: translate('OK'),
        onPressed: () {
          ScaffoldMessenger.of(params.context).hideCurrentSnackBar();
          // Some code to undo the change.
        },
      ) : null,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(params.context).showSnackBar(snackBar);
    });
  }


  _bookSeats(VrsCmdParams params) async {
    setLoadState(VrsCmdState.loading, params);
    _displayProcessingIndicator = true;

    StringBuffer cmd = new StringBuffer();
    cmd.write('*${params.rloc}^');

    if (!gblSettings.webCheckinNoSeatCharge) {
      params.paxlist.forEach((f) {
        if ((f.seat != null && f.seat != '') && f.seat != f.savedSeat)
          cmd.write(f.savedSeat == null || f.savedSeat == ''
              ? '4-${f.id}S${int.parse(params.journeyNo) + 1}FRQST${f.seat}^'
              : '4-${f.id}S${int.parse(params.journeyNo) + 1}FRQST${f.seat}[replace=${f.savedSeat}]^');
      });
      cmd.write('FSM^');
    } else {
      params.paxlist.forEach((f) {
        if ((f.seat != null && f.seat != '') && f.seat != f.savedSeat)
          cmd.write(f.savedSeat == null || f.savedSeat == ''
              ? '4-${f.id}S${int.parse(params.journeyNo) + 1}FRQST${f.seat}[MmbFreeSeat=${gblSettings.webCheckinNoSeatCharge}]^'
              : '4-${f.id}S${int.parse(params.journeyNo) + 1}FRQST${f.seat}[replace=${f.savedSeat}][MmbFreeSeat=${gblSettings.webCheckinNoSeatCharge}]^');
      });
    }

    cmd.write('MB');
    //Session session = Session('', '');
    if ( gblSession == null ) {
      await login().then((result) {
        session =
            Session(result.sessionId, result.varsSessionId, result.vrsServerNo);
        gblSession = session;
      });

    } else {
      session = gblSession;
    }
    String msg = json
        .encode(RunVRSCommandList(session, cmd.toString().split('^')).toJson());
    print(msg);
    _sendVRSCommandList(msg).then((result) {
      if (result == 'No Amount Outstanding') {
        msg = json.encode(RunVRSCommand(session, "E"));
        _sendVRSCommand(msg).then(
                (onValue) => Repository.get().fetchPnr(params.rloc).then((pnr) {
              Map<String, dynamic> map = json.decode(pnr.data);
              PnrModel pnrModel = new PnrModel.fromJson(map);
              Navigator.pop(context, pnrModel);
            }));
      } else if (result.toString().toLowerCase().startsWith('error')) {
        print(result.toString());
        _displayProcessingText =result.toString();
        // _showError('Seating failed');
        //_dataLoadedFailed(result);
        //  showSnackBar(result);
       // setState(() {
          setLoadState(VrsCmdState.loadFailed, params);
        //});
        _showstatus(params);

      } else {
        msg = json.encode(RunVRSCommand(session, "*R~x"));
        _sendVRSCommand(msg).then((pnrJson) {
          Map<String, dynamic> map = json.decode(pnrJson);

          _displayProcessingIndicator = false;

          //saveData(response.body.trim());
         // setState(() {
            setLoadState(VrsCmdState.loaded, params);
          //});
          _showstatus(params);

          PnrModel pnrModel = new PnrModel.fromJson(map);
          _navigate(context, pnrModel, session);
          //  Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ChoosePaymenMethodWidget(
          //             pnrModel: pnrModel, isMmb: true, session: session)));
          //_resetloadingProgress();

        });
      }
    });
  }


  void _initData(VrsCmdParams params) {

    switch(params.dataType){
      case VrsCmdType.bookSeats:
        //_dataName = 'Book Seats';
        _displayProcessingText = translate('Booking your seat selection...');
        _wantOK = false;
        _bookSeats(params);
        //_msg = json.encode(GetProductsMsg(currency ).toJson());

        break;
      case VrsCmdType.loadSeatplan:
        //_dataName = 'language';
        break;
    }
    //_displayProcessingText = '${translate('Loading')} $_dataName ...';
  }

  void setLoadState(var newState, VrsCmdParams params) {
    switch(params.dataType){
      case VrsCmdType.bookSeats:
        gblBookSeatState = newState;
        break;
      case VrsCmdType.loadSeatplan:
        gblLoadSeatState = newState;
        break;
    }
  }

  void saveData(String data, VrsCmdParams params) {
    switch(widget.dataType){
      case VrsCmdType.bookSeats:
        break;
      case VrsCmdType.loadSeatplan:
        try {
          gblProducts = ProductCategorys.fromJson(data);
        } catch(e) {
          logit(e.toString());
        }
        break;
    }
  }

}
Future _sendVRSCommand(msg) async {
  final http.Response response = await http.post(
      Uri.parse(gblSettings.apiUrl + "/RunVRSCommand"),
      headers: getApiHeaders(),
      body: msg);

  if (response.statusCode == 200) {
    logit('message send successfully: $msg' );
    return response.body.trim();
  } else {
    logit('failed2: $msg');
  }
}


Future _sendVRSCommandList(msg) async {
  final http.Response response = await http.post(
      Uri.parse(gblSettings.apiUrl + "/RunVRSCommandList"),
      headers: getApiHeaders(),
      body: msg);

  if (response.statusCode == 200) {
    logit('message send successfully: $msg');
    return response.body.trim();
  } else {
    logit('failed3: $msg');
  }
}

_navigate(BuildContext context, PnrModel pnrModel, Session session) async {
  // Navigator.push returns a Future that completes after calling
  // Navigator.pop on the Selection Screen.
  gblPaymentMsg = '';
  final result = await Navigator.push(
    context,
    // Create the SelectionScreen in the next step.
    MaterialPageRoute(
        builder: (context) => ChoosePaymenMethodWidget(
          pnrModel: pnrModel, isMmb: true, session: session, mmbAction: 'SEAT',)),
  );
  if (result == true) {
  //  _cancelSeatSelection();
  //  setState(() {
 //     _loadingInProgress = true;
  //    _displayProcessingText = 'Cancelling your seat selection...';
 //   });
  }
}

class VrsCmdParams {
  final VrsCmdType  dataType;
  final List<Pax> paxlist;
  //final String seatplan;
  final String rloc;
  final String journeyNo;
  final BuildContext context;
  final ValueChanged<String> onStateChange;


  VrsCmdParams({this.journeyNo, this.paxlist, this.dataType, this.rloc, this.context, this.onStateChange});

}*/
