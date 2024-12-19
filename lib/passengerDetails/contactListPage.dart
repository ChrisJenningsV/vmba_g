import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/globals.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/controls/V3Constants.dart';


class ContactListPageWidget extends StatefulWidget {
  ContactListPageWidget();
  // : super(key: key);

  ContactListPageWidgetState createState() =>
      ContactListPageWidgetState();
}

class ContactListPageWidgetState extends State<ContactListPageWidget>{
  late bool _loadingInProgress;
  late bool _showResults;

  TabController? _tabViewController;

  @override void initState() {
    _loadingInProgress = true;
    _showResults = false;
    loadData();
  }


  @override
  Widget build(BuildContext context) {
    return

      new Scaffold(
        backgroundColor: Colors.grey.shade50, //v2PageBackgroundColor(),
        appBar: appBar(context,'Contacts',
          PageEnum.editPax,
          //imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (_showResults) {
                  _showResults = false;
                  setState(() {

                  });
                } else {
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
        extendBodyBehindAppBar: gblSettings.wantPageImages,
        //endDrawer: DrawerMenu(),
        body: _body(),
      );
  }

  Widget _body() {
    if (_loadingInProgress) {
      return getProgressMessage('Loading...', '');
    }
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(40)),
            Image.network('${gblSettings.gblServerFiles}/pageImages/contacts.png',
                errorBuilder: (BuildContext context, Object obj,
                    StackTrace? stackTrace) {
                  return Text('', style: TextStyle(color: Colors.red));
                }
            ), //
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: renderPax(),
                ),
              ),
            )
          ],
        )
    );
  }
  List<Widget> renderPax() {
    List<Widget> paxWidgets = [];
    //print('renderPax');
    // List<Widget>();
    int i = 0;

    gblContacts!.contacts!.forEach((pax) {
      List<Widget> list = [];
      pax.paxNo = i;
      list.add(Icon(Icons.person_pin, color: Colors.grey,));
      list.add(Text(pax.title));
      list.add(Text(pax.firstname));
      list.add(Text(pax.lastname));
      list.add(Icon(Icons.add_circle, color: Colors.blue,));

      paxWidgets.add(
          InkWell(
            onTap: (){
              Navigator.pop(context, pax.paxNo);
            },
            child:
          Container(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: list,
      )))
      );
      i++;
    });

    return paxWidgets;
  }

  Future<void> loadData() async {
    String data = '';
    _loadingInProgress = false;
    setState(() {

    });
  }
}