import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:package_info/package_info.dart';


//import 'package:vmba/resources/app_config.dart';

// import 'package:loganair/data/repository.dart';

class RootPage extends StatefulWidget {
  RootPage();

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool appInitalized = false;
  bool _displayProcessingIndicator;
  bool _displayFinalError;
  String _displayProcessingText;

  @override
  void initState() {
    super.initState();
    _displayProcessingIndicator = true;
    gbl_NoNetwork = false;
    _displayFinalError = false;
    _displayProcessingText = 'Loading settings...';
    var appVersion = 'Checking..';
    String projectVersion;

      loadData();
  }

  loadData() async {
    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) =>
    packageInfo.version + '.' + packageInfo.buildNumber)
        .then((String version) async {
      gbl_version = version;
      gbl_isIos = Platform.isIOS;
      // await Repository.get().init();
      await Repository.get().settings().catchError((e) {
        setState(() {
          _displayProcessingText = 'Error loading : ' + e.toString();
          _displayFinalError = true;
          _displayProcessingIndicator = false;
        });
        return;
      });
    }

   // await Repository.get().init();
 /*   await Repository.get().settings().catchError((e){
      setState(() {
        _displayProcessingText = 'Error loading : ' + e.toString();
        _displayFinalError = true;
        _displayProcessingIndicator = false;
      });
      return;
    }
*/
      );
   /* GobalSettings.shared
        .init()
        .then((b) =>

    */
        Repository.get().initCities().then((_) {
              Repository.get()
                  .initRoutes()
                  .then((_) => setState(() {
                        _displayProcessingIndicator = false;
                      }))
                  .catchError((e) {
                setState(() {
                  _displayProcessingIndicator = false;
                });
              }).then((_) {});
              setState(() {
                _displayProcessingText = 'Loading routes...';
              });
            }).catchError((e) {
              setState(() {
                _displayProcessingText = 'Error loading routes: ' + e.toString() ;
                _displayFinalError = true;
                _displayProcessingIndicator = false;
              });
            });
  }

  @override
  Widget build(BuildContext context) {

    if (_displayFinalError || (gbl_error != null && gbl_error.isNotEmpty) ) {
      return Scaffold(
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
             Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText(_displayProcessingText + gbl_error, style: TextStyle(fontSize: 14.0)),
                  ),
                ],
              ),
            ),
          ));
    } else if (_displayProcessingIndicator) {
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
                      child: TrText(_displayProcessingText + ' ' + gbl_version),
                    ),
                  ],
                ),
              ),
            ));
    } else {
      return new HomePage();
    }
          }
}
