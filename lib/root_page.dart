
import 'dart:async';
import 'dart:io';
//import 'package:connectivity/connectivity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vmba/menu/stopPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/notification_service.dart';

import 'controllers/vrsCommands.dart';


class RootPage extends StatefulWidget {
  RootPage();

  @override
  State<StatefulWidget> createState() => new RootPageState();
}

class RootPageState extends State<RootPage> with WidgetsBindingObserver {
  Map _source = {ConnectivityResult.none: false};
  MyConnectivity _connectivity = MyConnectivity.instance;

  bool appInitalized = false;
  bool _displayProcessingIndicatorS=false;
  bool _displayProcessingIndicatorC=false;
  bool _displayProcessingIndicatorR=false;
  bool _displayFinalError=false;
  bool _dataLoaded = false;
  bool _dataLoading = false;
  String _displayProcessingText='';

  @override
  void initState() {
    super.initState();
    logit('init RootPageState', verboseMsg: true);
    gblCurPage = 'ROOTPAGE';
    //showAlert('init root');

    _displayProcessingIndicatorS = true;
    _displayProcessingIndicatorC = true;
    _displayProcessingIndicatorR = true;
    gblNoNetwork = false;
    _displayFinalError = false;
    _displayProcessingText = 'Loading settings...';

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if( gblCurPage == 'ROOTPAGE' || gblCurPage == 'HOME') {
        setState(() => _source = source);
      }
      if (_source.keys.toList()[0] != ConnectivityResult.none) {
        if( _dataLoaded == false && _dataLoading == false ) {
          _dataLoading = true;
          loadData();
        }
      } else {
        gblNoNetwork = true;
      }
      networkStateChange(source);
    }
    );
    //   loadData();
    WidgetsBinding.instance.addObserver(this);

  }

  retryLoadData() {
    _displayProcessingIndicatorS = true;
    _displayProcessingIndicatorC = true;
    _displayProcessingIndicatorR = true;
    gblNoNetwork = false;
    _displayFinalError = false;
    _displayProcessingText = 'Loading settings...';

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
      if( _source.keys.toList()[0] != ConnectivityResult.none ){
        if( _dataLoaded == false && _dataLoading == false) {
          _dataLoading = true;
          loadData();
        }
      } else {
        gblNoNetwork = true;
      }
    });
  }

  loadData() async {
    logit('loadData');
    await Repository.initFqtv();

    _dataLoaded = true;
    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) =>
    packageInfo.version + '.' + packageInfo.buildNumber)
        .then((String version) async {
      gblVersion = version;
      gblIsIos = Platform.isIOS;
      // await Repository.get().init();
      await Repository.get().settings().then((_){
        setState(() {
          _displayProcessingIndicatorS = false;
          _dataLoaded = true;
          _dataLoading = true;
        });
      }
      ).catchError((e) {
        _displayProcessingText = 'Error loading : ' + e.toString();
        setError('Error loading : ' + e.toString());
        logit('Error loading : ' + e.toString());
        _displayFinalError = true;
        _displayProcessingIndicatorS = false;
        _dataLoaded = false;
        _dataLoading = true;
        try {
          setState(() {});
        } catch(e) {}
        return;
      });
//      Repository.get().initFqtv();
    }
      );

    if( gblSettings.useLogin2) {
      setState(() {
        _displayProcessingIndicatorC = false;
        _displayProcessingIndicatorR = false;
        _displayProcessingIndicatorS = false;
        _dataLoaded = true;
      });
        return;
    }
      // if new login we're done



    String loading = 'Cities';
    Repository.get().initCities().then((_) {
      _displayProcessingIndicatorC = false;
        if( gblNoNetwork == true) {
          setState(() {
            _dataLoaded = false;
          });
          return;
        }
          loading = 'Routes';
          Repository.get()
              .initRoutes()
              .then((_) => setState(() {
                    _displayProcessingIndicatorR = false;
                  }))
              .catchError((e) {
            setState(() {
              _displayProcessingIndicatorR = false;
              _dataLoaded = false;
            });
          }).then((_) {});
          setState(() {
            _displayProcessingText = 'Loading routes...';

          });
        }).catchError((e) {
          setState(() {
            _displayProcessingText = 'Error loading $loading: ' + e.toString() ;
            gblError= 'Error loading routes: ' + e.toString() ;
            print(_displayProcessingText);
            _displayFinalError = true;
            _displayProcessingIndicatorR = false;
            _dataLoaded = false;
          });
        });

    //Repository.get().initFqtv();
  }

  @override
  Widget build(BuildContext context) {
    //MaterialLocalizations localizations = MaterialLocalizations.of(context);
    if (_displayFinalError || (gblError != null && gblError.isNotEmpty) ) {
      return Scaffold(
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(gblErrorTitle ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText(gblError,
                        style: TextStyle(fontSize: 14.0)),
                  ),
                ],
              ),
            ),
          ));
    } else if( gblNoNetwork == true) {
      return Scaffold(
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('lib/assets/images/noNetwork.png'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText('No Internet Connection.',
                    style: TextStyle(fontSize: 16),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText('Please check your connection.'),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              //shape: buttonShape,
                              backgroundColor: gblSystemColors
                                  .primaryButtonColor),
                          onPressed: () =>
                              Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                  '/MyBookingsPage',
                                      (Route<dynamic> route) => false),
                          child: Container(
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.card_travel,
                                    color: Colors.white,
                                  ),
                                ),
                                TrText(
                                  'My Bookings & Check-in',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),


                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          //shape: buttonShape,
                            backgroundColor: gblSystemColors
                                .primaryButtonColor),
                        onPressed: () {
                          retryLoadData();
                        },
                        child: Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              ),
                              TrText(
                                'Retry connection',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
    } else if (_displayProcessingIndicatorC || _displayProcessingIndicatorS || _displayProcessingIndicatorR) {
        return Scaffold(
            body: Container(
              color: Colors.white, constraints: BoxConstraints.expand(),
              child: Center(
                child:
               Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('lib/assets/$gblAppTitle/images/loader.png'),
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TrText(_displayProcessingText),
                    ),
                  ],
                ),
              ),
            ));
    } else {
      // check special actions
      switch (gblAction) {
        case 'LIVE':
          break;
        case 'TEST':
          break;
        case 'LOGIN':
          break;
        case 'UPDATE':
          //return new UpdatePage();
          //updateAppDialog(context);
          break;
        case 'SUSSPEND':
        case 'STOP':
          return new StopPageWeb();
      }
      _connectivity.disposeStream();

      // now do firebase
      if( gblSettings.wantPushNoticications && !gblPushInitialized) {
        gblPushInitialized = true;
        initFirebase(context);
      }

      return new HomePage();
    }
  }

 /* @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        logit("app in resumed");
        break;
      case AppLifecycleState.inactive:
        logit("app in inactive");
        break;
      case AppLifecycleState.paused:
        logit("app in paused");
        break;
      case AppLifecycleState.detached:
        logit("app in detached");
        break;
    }
  }
*/
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

}
Future<void> initFirebase(BuildContext context) async {

  if( gblIsLive == false ) {
    //serverLog('Starting app $gblAppTitle');
  }
  logit('InitFirebase');
  NotificationService().init(context);
}

class MyConnectivity {
  MyConnectivity._internal();

  static final MyConnectivity _instance = MyConnectivity._internal();

  static MyConnectivity get instance => _instance;
  bool _closed = false;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController.broadcast();

  Stream get myStream => controller.stream;

/*
  void initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }
*/
  void initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

 /* void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOnline = true;
      } else
        isOnline = false;
    } on SocketException catch (_) {
      isOnline = false;
    }
    try {
      controller.sink.add({result: isOnline});
    } catch(e) {}
  }*/
  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      isOnline = false;
    }
    if( _closed == false ) {
      controller.sink.add({result: isOnline});
    }
  }

  void disposeStream() {
    _closed = true;
    controller.close();
  }
}