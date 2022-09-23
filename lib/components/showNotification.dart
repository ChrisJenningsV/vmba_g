import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/mmb/viewBookingPage.dart';
import 'package:vmba/mmb/widgets/boardingPass.dart';
import 'package:vmba/utilities/widgets/buttons.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../menu/contact_us_page.dart';
import '../utilities/helper.dart';

void showNotification(
    BuildContext context, RemoteNotification notification, Map data) {
  //String time = DateFormat('kk:mm').format(DateTime.now());
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext cxt) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Material(
            color: Colors.grey.shade200,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Stack(children: [
              Padding(
                padding: EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _getBody(context, notification, data),
                ),
              ),
              /*                 Positioned( // will be positioned in the top right of the container
                      top: -12,
                      right: -12,
                          child: new IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }), //
                        ),
   */
            ]),
          ),
        ),
      );
    },
  );
}

Widget _getTitle(
    BuildContext context, RemoteNotification notification, Map data) {
  String time = DateFormat('kk:mm').format(DateTime.now());
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      InkWell(
          onTap: () {
            // Navigator.of(context).pop();
          },
          child: Image.asset(
            "lib/assets/$gblAppTitle/images/app.png",
            width: 20,
            height: 20,
          )),
      SizedBox(width: 5),
      /*
        Expanded(
          child:
  */
      Text(
        gblSettings.airlineName.toUpperCase(),
        //style: TextStyle(                            color: Colors.white,                          ),
      ),
      /*      ),*/
      SizedBox(width: 5),
      Expanded(
        child: Text(data['title']), //Text(notification.title),
      ),
      Text(time),
      new IconButton(
          icon: Icon(
            Icons.cancel,
            color: Colors.red,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          }), //
    ],
  );
}

List<Widget> _getBody(
    BuildContext context, RemoteNotification notification, Map data) {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  List<Widget> list = [];
  List<Widget> list2 = [];
  List<Widget> list3 = [];

  // if (notification != null ) {
  list2.add(_getTitle(context, notification, data));
  //  }
  list2.add(SizedBox(
    height: 5.0,
  ));

  // web view
  String body = "";
  if (data['format'] != null && data['format'] == 'HTML') {
    body = data['html'];
  } else {
    body = notification.body;
  }
  double h = 200;
  if (data['height'] != null && data['height'] != '') {
    h = double.parse(data['height']);
  }
  list2.add(Container(
      height: h,
      width: 400,
      child: WebView(
        initialUrl: Uri.dataFromString(
                '<html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head><body>' +
                    body +
                    '</body></html>',
                mimeType: 'text/html')
            .toString(),
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      )));
  /* } else {
      if( notification != null ) {
        list2.add(Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(notification.body)
            ]));
      }
    }*/
  // buttons?
  if (data != null) {
    if (data['image'] != null && data['image'].toString().isNotEmpty) {
      list2.add(SizedBox(
        height: 5.0,
      ));
      list2.add(Image.network(
        '${gblSettings.gblServerFiles}/pageImages/${data['image']}',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ));
      /*  Container(
          //width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: NetworkImage('${gblSettings.gblServerFiles}/pageImages/${data['image']}'),
            ),
          ),
        ));*/

    }

    if (data['buttons'] != null) {
      list2.add(SizedBox(
        height: 5.0,
      ));

      List map = json.decode(data['buttons']);

      map.forEach((v) {
        if( v != null ) {
          String c = v['caption'];
          String a = v['action'];
          String d = v['data'];
          String d2 = v['data2'];

          list3.add(
            smallButton(
                text: translate(c), //icon: Icons.check,
                onPressed: () {
                  switch (a.toUpperCase()) {
                    case 'URL':
                      Navigator.push(
                          context, SlideTopRoute(page: CustomPageWeb(d2, d)));
                      break;
                    case 'APP':
                      switch (d.toUpperCase()) {
                        case 'OPENPNR':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewBookingPage(
                                      rloc: d2,
                                    )),
                          );
                          break;
                        case 'RELOADPNR':
                          break;
                        case 'CHECKIN':
                          break;
                        case 'UPDATEBOARDINGPASS':
                          reloadBoardingPass(d2);
                          break;
                      }
                      break;
                  }
                }),
          );
        }
      });
      list2.add(Row(
        children: list3,
      ));
    }

  }

  list.add(Padding(
    padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 10),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: list2,
    ),
  ));

  return list;
}
