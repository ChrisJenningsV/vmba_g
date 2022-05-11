import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/mmb/viewBookingPage.dart';
import 'package:vmba/utilities/widgets/buttons.dart';



void showNotification(BuildContext context, String title,  String msg, Map data) {
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
            child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0, left: 5, right: 5, bottom:  5),
              child:
                  Column(
                mainAxisSize: MainAxisSize.min,
                children: _getBody(context, title,  msg, data)

                ,
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
 */             ]
            ),
          ),
        ),
      );
    },
  );
}


Widget _getTitle(BuildContext context, String title,  String msg, Map data) {
  String time = DateFormat('kk:mm').format(DateTime.now());
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      InkWell(
          onTap: () {
           // Navigator.of(context).pop();
          },
          child: Image.asset("lib/assets/images/app.png", width: 20, height: 20,)),
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
  child:      Text(title),
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


List<Widget> _getBody(BuildContext context, String title,  String msg, Map data) {
  List<Widget> list = [];
  List<Widget> list2 = [];



  list2.add(_getTitle(context, title,  msg, data));
  list2.add(SizedBox(height: 5.0,));
  /* list2.add(Row(
  mainAxisAlignment: MainAxisAlignment.start,
  mainAxisSize: MainAxisSize.max,
  children: [
  Text(title, style: TextStyle(fontWeight: FontWeight.bold),)
  ]));
*/
  list2.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(msg)
      ]));

  // buttons?
  if(data != null ){
    if( data['image'] != null && data['image'].toString().isNotEmpty) {
 /*     list2.add( Row(
          mainAxisAlignment: MainAxisAlignment.center
          ,children: [
        Image(image: NetworkImage(
            '${gblSettings.gblServerFiles}/pageImages/${data['image']}'))
      ]));*/
      list2.add(SizedBox(height: 5.0,));
      list2.add(
          Image.network('${gblSettings.gblServerFiles}/pageImages/${data['image']}',
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
    // button(s)
    if( data['actions'] != null && data['rloc'] != null && data['actions'].toString().isNotEmpty &&
        data['rloc'].toString().isNotEmpty) {
      String actions = data['actions'];

      if( actions.contains('scheduleChange') ){
        list2.add(SizedBox(height: 5.0,));
        list2.add(smallButton( text: translate('Show Booking'), icon: Icons.check,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewBookingPage(
                      rloc: data['rloc'],
                    )),
              );
        }),);
      }

    }
  }

  list.add(Padding(
    padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom:  10),
    child:
    Column(
      mainAxisSize: MainAxisSize.min,
      children: list2,
    ),
  ));

/*
  list.add(
  Positioned( // will be positioned in the top right of the container
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
  )
  );
*/

  return list;
}