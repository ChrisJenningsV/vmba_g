import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
//import 'package:package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vmba/menu/stopPage.dart';
import 'package:vmba/menu/updatePage.dart';
import 'package:vmba/utilities/helper.dart';

class RootPage extends StatefulWidget {
  RootPage();

  @override
  State<StatefulWidget> createState() => new RootPageState();
}

class RootPageState extends State<RootPage> {
  Map _source = {ConnectivityResult.none: false};
  MyConnectivity _connectivity = MyConnectivity.instance;

  bool appInitalized = false;
  bool _displayProcessingIndicatorS;
  bool _displayProcessingIndicatorC;
  bool _displayProcessingIndicatorR;
  bool _displayFinalError;
  bool _dataLoaded = false;
  String _displayProcessingText;

  @override
  void initState() {
    super.initState();
    logit('init RootPageState');

    _displayProcessingIndicatorS = true;
    _displayProcessingIndicatorC = true;
    _displayProcessingIndicatorR = true;
    gblNoNetwork = false;
    _displayFinalError = false;
    _displayProcessingText = 'Loading settings...';

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
      if (_source.keys.toList()[0] != ConnectivityResult.none) {
        if( _dataLoaded == false ) {
          loadData();
        }
      } else {
        gblNoNetwork = true;
      }
    });
    //   loadData();
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
        loadData();
      } else {
        gblNoNetwork = true;
      }
    });
  }

  loadData() async {
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
        });
      }
      ).catchError((e) {
        setState(() {
          _displayProcessingText = 'Error loading : ' + e.toString();
          _displayFinalError = true;
          _displayProcessingIndicatorS = false;
          _dataLoaded = false;
        });
        return;
      });
      Repository.get().initFqtv();
    }
      );

        Repository.get().initCities().then((_) {
          _displayProcessingIndicatorC = false;
            if( gblNoNetwork == true) {
              setState(() {
                _dataLoaded = false;
              });
              return;
            }
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
                _displayProcessingText = 'Error loading routes: ' + e.toString() ;
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
                    child: TrText(_displayProcessingText + gblError,
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
          return new UpdatePage();
          break;
        case 'SUSSPEND':
        case 'STOP':
          return new StopPageWeb();
          break;
      }
      _connectivity.disposeStream();
      return new HomePage();
    }
  }
}

class MyConnectivity {
  MyConnectivity._internal();

  static final MyConnectivity _instance = MyConnectivity._internal();

  static MyConnectivity get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController.broadcast();

  Stream get myStream => controller.stream;

  void initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
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
  }

  void disposeStream() => controller.close();
}