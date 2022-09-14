import 'package:flutter/material.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/models/providers.dart' as PaymentProvider;

import '../components/trText.dart';
import '../data/globals.dart';

class ErrorPage extends StatefulWidget {
  ErrorPage({
    Key key,
    this.action,
    this.msg,
    this.title,
  }) : super(key: key);

  final String action;
  String msg;
  String title;
  void Function(dynamic p) onComplete;

  @override
  ErrorPageState createState() => ErrorPageState();
}

class ErrorPageState extends State<ErrorPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();
  String errorlevel;
  @override
  initState() {
    super.initState();
    if( widget.title == null ) {
      widget.title = 'Critical error';
    }
    errorlevel = '1';
  }

  @override
  Widget build(BuildContext context) {
    if( widget.title == null) {
      widget.title = 'Critical error';
    }
    if( widget.msg == null){
      widget.msg = 'test';
    }



    if( errorlevel == '1') {
      return Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('',
                style: TextStyle(
                    color:
                    gblSystemColors.headerTextColor)),
          ),
          //endDrawer: DrawerMenu(),
          body: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            titlePadding: const EdgeInsets.all(0),
            title: Container(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                color: Colors.red,
                child: Text(widget.title,style: TextStyle(color: Colors.white),)
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
                children: <Widget> [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 3)
                    ),
                    child: Icon(Icons.close, color: Colors.red,size: 100,),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Text(widget.msg),
                ]),
            actions: <Widget>[
              Align(
                alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.grey.shade200) ,
                child: TrText("OK", style: TextStyle(backgroundColor: Colors.grey.shade200, color: Colors.black),),
                onPressed: () {
                  //Put your code here which you want to execute on Cancel button click.
                  if( widget.onComplete != null ){
                    widget.onComplete(false);
                  }
                  Navigator.of(context).pop();
                },
              )),
            ],

          )
      );
    }

    // no error
    return Container();

  }


}




void criticalErrorPage(BuildContext context, String msg, {String title}){
  Navigator.push(
      context, MaterialPageRoute(builder: (context) =>
      ErrorPage( msg: msg,
        title: title,))
  );
}