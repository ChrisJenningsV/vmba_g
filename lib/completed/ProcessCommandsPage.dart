import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';

class ProcessCommandsPage extends StatefulWidget {
  ProcessCommandsPage({Key key, this.runVRSCommandArgs}) : super(key: key);
  final RunVRSCommand runVRSCommandArgs;
  @override
  _ProcessCommandsWidgetState createState() => _ProcessCommandsWidgetState();
}

class _ProcessCommandsWidgetState extends State<ProcessCommandsPage> {
  //GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _loadingInProgress;
  String _displayProcessingText;
  //bool _noInternet;
  //bool _hasError;
  PnrModel pnrModel;

  @override
  initState() {
    super.initState();
    _loadingInProgress = true;
    // _noInternet = false;
    // _hasError = false;
    _displayProcessingText = "Completing your booking...";
    processCommands();
  }

  showSnackBar(String message) {
    final _snackbar = snackbar(message);
    ScaffoldMessenger.of(context).showSnackBar(_snackbar);
    // _key.currentState.showSnackBar(_snackbar);
  }

  // void _dataLoaded() {
  //   setState(() {
  //     _loadingInProgress = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress) {
      return Scaffold(
        appBar: new AppBar(
          brightness:gbl_SystemColors.statusBar,
          backgroundColor: gbl_SystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gbl_SystemColors.headerTextColor),
          title: new Text('Processing',
              style: TextStyle(
                  color: gbl_SystemColors.headerTextColor)),
        ),
        body: new Center(
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
        ),
      );
    } else {
      return Scaffold();
    }
  }

  // Future _sendVRSCommand(msg) async {
  //   final http.Response response = await http.post(
  //       //'http://192.168.0.79:53792/api/Payment/InitPayment',
  //       GobalSettings.shared.settings.apiUrl + "/Payment/InitPayment",
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Videcom_ApiKey': '0dc43646b379435695a28688ee5c9468'
  //       },
  //       body: JsonEncoder().convert(msg));
  //   if (response.statusCode == 200) {
  //     print('message send successfully');
  //     return response.body.trim();
  //   } else {
  //     print('failed');
  //   }
  // }

  getArgs() {
    List<String> args = [];
    //List<String>();
    args.add(this.pnrModel.pNR.rLOC);
    if (pnrModel.pNR.itinerary.itin
            .where((itin) =>
                itin.classBand.toLowerCase() != 'fly' &&
                itin.openSeating != 'True')
            .length >
        0) {
      args.add('true');
    } else {
      args.add('false');
    }
    return args;
  }

  void processCommands() {
    sendVRSCommand(json.encode(widget.runVRSCommandArgs.toJson()))
        .then((onValue) {
      Map map = json.decode(onValue);
      pnrModel = new PnrModel.fromJson(map);
      PnrDBCopy pnrDBCopy = new PnrDBCopy(
          rloc: pnrModel.pNR.rLOC, //_rloc,
          data: onValue,
          delete: 0,
          nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
      Repository.get().updatePnr(pnrDBCopy).then((n) => getArgs()).then((arg) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/CompletedPage', (Route<dynamic> route) => false,
            arguments: arg);
      });
    });
  }
}
