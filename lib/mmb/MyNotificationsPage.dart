import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/components/trText.dart';

import '../components/showNotification.dart';
import '../data/globals.dart';
import '../data/models/notifyMsgs.dart';
import '../v3pages/controls/V3Constants.dart';


class MyNotificationsPage extends StatefulWidget {
  MyNotificationsPage({Key key= const Key("mynot_key")}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MyNotificationsPageState();
}

class _MyNotificationsPageState extends State<MyNotificationsPage> with TickerProviderStateMixin  {
  // new List<PnrDBCopy>();
  bool _loadingInProgress=false;
  Offset? _tapPosition;
  final formKey = GlobalKey<FormState>();
  String fqtvEmail = '';
  String fqtvNo = '';
  String fqtvPass='';
 // List<NotificationMessage> msgs;
  TabController? _controller;

  var tablen = 3;

  @override
  void initState() {
    super.initState();
    gblError = '';
    _loadingInProgress = true;
    _controller = TabController(length: tablen, vsync: this);
    gblNotifications = null;  // incase none found
    Repository.get().getAllNotifications().then((m) {
      gblNotifications = m;
      print('Got ${gblNotifications!.list.length} notifications');
      _loadingInProgress = false;
      setState(() {

      });
    }).catchError((onError){
      print(onError.toString());
    });
  }


  @override
  Widget build(BuildContext context) {
  //  final List<String> args = ModalRoute.of(context)!.settings.arguments as List<String>;
/*
    print('args = $args');
    if( args != null && args.toString().contains('new') ){
      _controller!.index = 1;
    }
    if( args != null && args.toString().contains('promo') ){
      _controller!.index = 2;
    }
*/

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
      String title = translate("My Notifications");
      List <Widget> tabs = [];
      List <Widget> tabeViews = [];
      tabs.add(TrText('All'));
      tabs.add(TrText('Unread'));
      tabs.add(TrText('Promotional'));

      tabeViews.add(new Container(child: myNotifies('all')));
      tabeViews.add(new Container(child: myNotifies('new')));
      tabeViews.add(new Container(child: myNotifies('promo')));

      if (gblNotifications != null) {
        if( gblIsLive ==  false &&  gblNotifications!.list.length == 0  && gblNotifications!.rawCount != 0){
          title += ' ${gblNotifications!.rawCount} ' + ' R ' + translate('found');

        } else {
          title += ' ${gblNotifications!.list.length} ' + translate('found');
        }
      }
      return Scaffold(
        appBar: appBar(context, title, PageEnum.myNotifications,
          bottom: new PreferredSize(
            preferredSize: new Size.fromHeight(30.0),
            child: new Container(
              height: 30.0, child: TabBar(

                indicatorColor: gblSystemColors.tabUnderlineColor == null ? Colors.amberAccent : gblSystemColors.tabUnderlineColor,
                isScrollable: true,
                labelColor: gblSystemColors.headerTextColor,
                tabs: tabs,
                controller: _controller),
            ),
          ),
        ), // translated in appBar
        endDrawer: DrawerMenu(),
        body: TabBarView(
          controller: _controller,
          children: tabeViews,
        ),

      );
    }
  }


  Widget myNotifies(String  show) {

    if( gblNotifications != null && gblNotifications!.list.length > 0 )
      {

      } else {
      String msg = 'No Notifications found';
      if( gblIsLive == false && gblNotifications!.errMsg != '' ){
        msg = gblNotifications!.errMsg;
      } else if (gblIsLive == false &&  gblError != '') {
        msg = gblError;
      }
      Center noFutureBookingsFound = Center(
          child: TrText(msg,
              style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
      if (show == 'new') {
        noFutureBookingsFound = Center(
            child: TrText('No Notifications found',
                style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
      }
      return  noFutureBookingsFound;
    }

    List<NotificationMessage> listMsgs;

    if (show == 'promo') {
      listMsgs = [];
      gblNotifications!.list.forEach((element) {
        if(element.data!['actions'] != null &&  element.data!['actions'] == 'promo'){
          listMsgs.add(element);
        }
      });

    } else if (show == 'new') {
      listMsgs = [];
      gblNotifications!.list.forEach((element) {
        if(element.background == 'true' && !element.data!['actions'].toString().contains('promo')){
          listMsgs.add(element);
        }
      });
    } else {
      listMsgs = gblNotifications!.list;
    }
    ListView listViewOfNote = ListView.builder(
        itemCount: listMsgs.length,
        itemBuilder: (BuildContext context, index) =>
            _buildListItem(context, listMsgs[index]));

    return listViewOfNote;
  }

  Widget _buildListItem(BuildContext context, NotificationMessage msg) {

    String title = '';
    String body = '';
    Color? clr = Colors.black38;
    Color? bkClr = Colors.white;

    if( msg.data!['actions'] != null && msg.data!['actions'].toString().contains('promo')) {
      bkClr = gblSystemColors.promoBackColor;
    } else  if(msg.background == 'true'){
      clr = Colors.blue;
    }
    if (msg != null && msg.notification != null ) {
      title = msg.notification!.title;
      if( title == null ) title = '';
      if( msg.data != null && msg.data!['rloc'] != null ){
        title = msg.data!['rloc'] + ' ' + title;
      }
      body = msg.notification!.body;
    }
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
              new Text( DateFormat('MMM dd kk:mm').format(msg.sentTime as DateTime) + ' $title', //document['rloc'],
                  style: new TextStyle(color: clr,
                      fontSize: 16.0, fontWeight: FontWeight.w700)),
              GestureDetector(
                child: Icon(Icons.more_vert),
                onTapDown: _storePosition,
                onTapUp: (tabUpDetails) => _showPopupMenu(msg.sentTime.toString()),
              ),
            ],
          ),
          new Divider(),
          Text(body),
        ]),
        onPressed: () {
          print('Click on notification');
          Map? m = msg.data;
          if( msg.background == 'true'){
            // mark as no longer no read
            Repository.get().updateNotification(convertMsg(msg) as RemoteMessage, false, true).then((value) {
              Repository.get().getAllNotifications().then((m) {
                gblNotifications = m;
                _loadingInProgress = false;
                setState(() {
                });
              });
            });

            // update glbs too
     /*       gblNotifications.forEach((element) {
              if(element.sentTime == msg.sentTime){
                element.background = 'false';
              }
            });*/
            setState(() {

            });
          }

          RemoteNotification n = RemoteNotification(title: msg.notification!.title, body: msg.notification!.body);
          showNotification( context, n, m as Map, 'note page');
          /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewBookingPage(
                  rloc: msg.sentTime.toString(),
                )),
          );*/
        },
      ),
      decoration: BoxDecoration(
        color: bkClr,
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
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition! & Size(40, 40), // smaller rect, the touch area
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
                  gblNotifications = m;
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
