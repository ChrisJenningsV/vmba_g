import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/mmb/viewBookingPage.dart';
import 'package:vmba/data/models/pnr.dart';
import 'dart:convert';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/components/trText.dart';


class MyNotificationsPage extends StatefulWidget {
  MyNotificationsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MyNotificationsPageState();
}

class _MyNotificationsPageState extends State<MyNotificationsPage> {
  // new List<PnrDBCopy>();
  bool _loadingInProgress;
  Offset _tapPosition;
  final formKey = GlobalKey<FormState>();
  String fqtvEmail = '';
  String fqtvNo = '';
  String fqtvPass='';
  List<RemoteMessage> msgs;


  @override
  void initState() {
    super.initState();
    _loadingInProgress = true;


    Repository.get().getAllNotifications().then((m) {
      msgs = m;
      _loadingInProgress = false;
      setState(() {

      });
    });



  }


  @override
  Widget build(BuildContext context) {

    if (_loadingInProgress) {
      return Scaffold(
          body: new Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TrText('Loading notifications...'),
                ),
              ],
            ),
          ));
    } else {
      String title = "My Notifications";
      if( msgs != null ) {
        title += ' ${msgs.length} found';
      }
      return Scaffold(
        appBar: appBar(context, title,

        ),// translated in appBar
        endDrawer: DrawerMenu(),
        body: myNotifies(true)
      );
    }
  }


  Widget myNotifies(bool showActive) {

    if( msgs != null && msgs.length > 0 )
      {
  /*      return Center(
          child: TrText('${msgs.length} Notifications found',
            style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
*/
      } else {
      Center noFutureBookingsFound = Center(
          child: TrText('No Notifications found',
              style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
      if (showActive == false) {
        noFutureBookingsFound = Center(
            child: TrText('No Notifications found',
                style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
      }
      return  noFutureBookingsFound;
    }


    ListView listViewOfNote = ListView.builder(
        itemCount: msgs.length,
        itemBuilder: (BuildContext context, index) =>
            _buildListItem(context, msgs[index]));

    return listViewOfNote;
  }

  Widget _buildListItem(BuildContext context, RemoteMessage msg) {

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
              new Text( DateFormat('MMM dd kk:mm').format(msg.sentTime) + ' ${msg.notification.title}', //document['rloc'],
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w700)),
              GestureDetector(
                child: Icon(Icons.more_vert),
                onTapDown: _storePosition,
                onTapUp: (tabUpDetails) => _showPopupMenu(msg.sentTime.toString()),
              ),
            ],
          ),
          new Divider(),
          Text(msg.notification.body),
        ]),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewBookingPage(
                  rloc: msg.sentTime.toString(),
                )),
          );
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

  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  _showPopupMenu(String sTime) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size),
      items: [

        PopupMenuItem(
          child: TextButton.icon(
            icon: Icon(Icons.delete_outline_rounded),
            label: TrText('Remove message'),
            onPressed: () {
              Repository.get()
                  .deleteNotification(sTime)
                  .then((onValue) => Navigator.of(context).pop())
                  .then((onValue) {
                Repository.get().getAllNotifications().then((m) {
                  msgs = m;
                  _loadingInProgress = false;
                  setState(() {

                  });
                });

            },
          );
              },
        ),
        ),
      ],
      elevation: 8.0,
    );
  }


}
