import 'package:flutter/material.dart';

import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';

import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/components/trText.dart';

class ProfileListPage extends StatefulWidget {
  ProfileListPage(
      {Key key, this.passengerDetail, this.isAdsBooking, this.isLeadPassenger})
      : super(key: key);

  _ProfileListPageState createState() => _ProfileListPageState();

  final PassengerDetail passengerDetail;
  final bool isAdsBooking;
  final bool isLeadPassenger;
}


class _ProfileListPageState extends State<ProfileListPage> {
  List<UserProfileRecord> _profileList;
String _displayProcessingText = 'Loading...';

  @override
  initState() {
    super.initState();

    Repository.get()
        .getUserProfile().then((profile) {
      if (profile.length > 0) {
        _profileList = profile;
        setState( (){
          _displayProcessingText = 'Loading profiles...';
        });
      }});
  }

  @override
  Widget build(BuildContext context) {
    if( _profileList != null ) {
    return Scaffold(
        appBar: new AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new Text('Passenger profiles',
              style: TextStyle(
                  color: gblSystemColors
                      .headerTextColor)),
        ),
        body: Container(child: Padding(
            padding:
            const EdgeInsets.only(left: 8.0, right: 8.0, top: 3.0, bottom: 3.0),
            child: profileListView(),
    ))
    );
    } else {
      return Scaffold(
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new Text('Passenger profiles',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*    Image.asset(
                  'lib/assets/${AppConfig.of(context).appTitle}/images/logo.png'),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ), */
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
    }
}

  ListView profileListView() {
    List<Widget> widgets = [];
    //new List<Widget>();

    _profileList.forEach((profile) =>
        widgets.add(ListTile(
            title: Text(profile.name ),
            trailing: _getButton(profile.name),

            onTap: () {
              Navigator.pop(context, profile.name);
              //_updateTitle(title);
            })));
    widgets.add(_getCancelButton('cancel'));
    return new ListView(
      children: widgets,
    );
   }
  ElevatedButton _getButton(String txt) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            primary: Colors.black),
        onPressed: () => _deleteProfile(txt),//Navigator.pop(context, ''),
        child: Text(
          'delete',
          style: new TextStyle(color: Colors.white),
        ));
  }

  _deleteProfile(String name){
    Repository.get()
        .deleteUserProfile(name).then((result) {
            setState( (){
                _displayProcessingText = 'Loading profiles...';
            });
        });
  }

  ElevatedButton _getCancelButton(String txt) {
   return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            primary: Colors.black),
        onPressed: () => Navigator.pop(context, ''),
        child: Text(
          'Cancel',
          style: new TextStyle(color: Colors.white),
        ));
  }
}