import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/data/models/vouchers.dart';
import '../components/showDialog.dart';
import '../data/globals.dart';
import '../Managers/commsManager.dart';
import '../menu/contact_us_page.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/controls/V3Constants.dart';


class GetericListPageWidget extends StatefulWidget {

  GetericListPageWidget(this.listType);
  // : super(key: key);

  final String listType;


  GetericListPageWidgetState createState() =>      GetericListPageWidgetState();
}

class GetericListPageWidgetState extends State<GetericListPageWidget>  with TickerProviderStateMixin {
  late bool _loadingInProgress;
  late News news;
  late String title;
  bool wantTitle2 = false;

  @override void initState() {
    super.initState();
    _loadingInProgress = true;

    switch(widget.listType.toUpperCase()) {
      case 'NEWS':
        title = 'NEWS';
        wantTitle2 = true;
        loadData();
        break;
      case 'VOUCHERS':
        _loadingInProgress = false;
        title = 'My Vouchers';
        wantTitle2 = false;
        break;
    }

  }


  @override
  Widget build(BuildContext context) {
    return

      new Scaffold(
        backgroundColor: Colors.grey.shade50, //v2PageBackgroundColor(),
        appBar: appBar(context, title,
          PageEnum.news, 'LIST',
          //imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                  Navigator.pop(context);
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

    if( gblError != ''){

    }
      return getResults();

  }

  Widget getResults(){

    //var set = Set<String>();
    String sError ='';
    int len = 0;
    double pad = 0;
    switch(widget.listType.toUpperCase()){
      case 'NEWS':
        sError = 'No NEWS available';
        len =  news.items.length;
        break;
      case 'VOUCHERS':
        sError = 'No Vouchers available';
        if( gblFopVouchers != null ) {
          len = gblFopVouchers!.vouchers.length;
          pad = 10;
        }
        break;
    }

    if( len == 0){
      return getAlertDialog(context, title, sError, setState, onComplete: () {
        setState(() {});
      },
          type: DialogType.Information,wantActions: false);

    }


    return Container(
      padding: EdgeInsets.all(pad),
        child:
         ListView.builder(
            shrinkWrap: true,
            itemCount: len ,
            itemBuilder: (BuildContext context, i) {
              Widget itemBody = Container();

              switch(widget.listType.toUpperCase()){
                case 'NEWS':
                  itemBody = getnews(news.items[i], i);
                  break;
                case 'VOUCHERS':
                  len = gblFopVouchers!.vouchers.length;
                  itemBody = getVoucher(i);
                  break;
              }

      return new ListTile(
        //minVerticalPadding: 0,
//        tileColor: Colors.white ,
          contentPadding: EdgeInsets.all(0),
          dense: false,
          visualDensity: VisualDensity(vertical: -2),
          title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (i==0 && wantTitle2) ?  getTitle() : Container(),
                itemBody,
              ]
          ),
          onTap: () {
            //Navigator.pop(context, '${routes![i]}');
          });
    }
    )
        ) ;
  }

  Widget getnews(NewsItem ni, int index) {
    return InkWell(
        onTap: (){
          Navigator.push(context,
    SlideTopRoute(page: CustomPageWeb('', ni.link)));
            },
        child: Container(
      child: Column(
        children: [
          Row(
            children: [
                Expanded(child:Text(ni.title, softWrap: true,overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold),))
            ],
          ),
          Row(
            children: [
              Expanded(child: Text(ni.description))
            ],
          ),
          Divider(thickness: 2,)
        ],
      ),
    ));
  }

  Widget getVoucher(int index){

    FopVoucher v = gblFopVouchers!.vouchers[index];

    return InkWell(
        onTap: (){
/*
          Navigator.push(context,
              SlideTopRoute(page: CustomPageWeb('', ni.link)));
*/
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
          shape: BoxShape.rectangle,
            border: Border.all(
              width: 2.0,
              // assign the color to the border color
              color: Colors.grey,
              ),
/*
            boxShadow: <BoxShadow>[
              BoxShadow(
              color: const Color(0x90000000),
              offset: Offset(0.0, 6.0),
              blurRadius: 5.0,
              ),
            ],
*/
            borderRadius:
            new BorderRadius.all(new Radius.circular(5.0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text('No: ' + v.voucherNumber, style: TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Value: ${(v.amount-v.amountUsed) } ${v.currency}' ))
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('From: ' + v.senderEmail))
                ],
              ),
 //             Divider(thickness: 2,)
            ],
          ),
        ));
  }

  Widget getTitle() {
    return Container(
        color: Colors.black12,
        padding: EdgeInsets.all(5),
        child: Column(
          
        children: [
        Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [Text('${news.description}', style: TextStyle(color: Colors.black87),)]),
      ])
    );
  }

  Future<void> loadData() async {
    String data = '';
    gblError = '';
    try {
      String reply = await callSmartApi('GETNEWS', data);
      Map<String, dynamic> map = json.decode(reply);
      news = new News.fromJson(map['news']);

      _loadingInProgress = false;
      setState(() {

      });
    } catch(e) {
      _loadingInProgress = false;
      setState(() {

      });
      showVidDialog(context, 'Error', e.toString(), type: DialogType.Error);
    }
  }


}


class News {

  List<NewsItem> items = [];
  String title = '';
  String description = '';
  String link = '';
  String image = '';

  News.fromJson(Map<String, dynamic> json) {
    if( json['title'] != null ) {
      title = getStringfromMap(json, 'title');
      if( json['description'] != null) description = getStringfromMap(json, 'description');
      if( json['link'] != null) link = getStringfromMap(json, 'link');
      // image is an object
//      if( json['image'] != null) image = getStringfromMap(json, 'image');

      if (json['item'] != null) {
        items = [];
        // new List<Itin>();
        if (json['item'] is List) {
          try {
          //  List<Map<dynamic>> map = json['item'];
            //int count = map.length;
            json['item'].forEach((v) {
            items.add(new NewsItem.fromJson(v));
          });
          } catch(e) {
            logit(e.toString());
          }
        } else  if (json['item'] is Map) {
          try {
            //List<Map<String, dynamic>> map = json['item'];
          } catch(e) {

          }
            json['item'].forEach((v) {
              //Map m = v;

              items.add(new NewsItem.fromJson(v));
            });
        } else {

          items.add(new NewsItem.fromJson(json['item']));
        }
      } else {
        items = [];
      }
    }
  }



}

class NewsItem {
  String title = '';
  String description = '';
  String link = '';
  String guid = '';
  String pubDate = '';



  NewsItem.fromJson(Map<String, dynamic> json) {
    if( json['title'] != null) title = getStringfromMap(json, 'title');
    if( json['description'] != null) description = getStringfromMap(json, 'description');
    if( json['link'] != null) link = json['link'];
   // if( json['guid'] != null) guid = json['guid'];
    if( json['pubDate'] != null) pubDate = json['pubDate'];
  }
}

String getStringfromMap(Map json, String key){
  String result = json[key];
  result = result.replaceAll('\n', '').replaceAll('\r', '');
  return result;
}