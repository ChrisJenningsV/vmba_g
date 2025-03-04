
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vmba/utilities/widgets/colourHelper.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../calendar/ImageAnimations.dart';
import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../home/home_page.dart';
import '../v3pages/controls/V3AppBar.dart';
import '../v3pages/controls/V3Constants.dart';


class MessagePage extends StatefulWidget {
  MessagePage({
    Key? key,
    this.action='',
    this.actions,
    this.msg='',
    this.title='',
    this.borderClr,
    this.iconClr,
    this.backClr,
    this.titleBackClr,
    this.titleTextClr,
    this.icon,
    this.isHtml=false,
    this.displayFormat='',
    this.onOk,
    this.doublePop=false,
  }) /*: super(key: key)*/;

  final String action;
  List<Widget>? actions;
  String msg;
  String title;
  Color? borderClr;
  Color? backClr;
  Color? iconClr;
  Color? titleBackClr;
  Color? titleTextClr;
  IconData? icon;
  bool isHtml=false;
  bool doublePop = false;
  String displayFormat ='';
  void Function(dynamic p)? onComplete;
  String Function(dynamic p, String user, String pw)? onOk;
  String _errorMsg='';

  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  String _msg ='';
  TextEditingController _sineController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
//  final formKey = new GlobalKey<FormState>();
  //String errorlevel;
  @override
  initState() {
    super.initState();
    _msg = widget.msg;
    widget._errorMsg = '';
    if( widget.title == null ) {
      widget.title = 'Critical error';
    }
    //errorlevel = '1';
  }

  @override
  Widget build(BuildContext context) {
    if( widget.title == null) {
      widget.title = 'Critical error';
    }
    if( widget.msg == null){
      widget.msg = 'test';
    }



    if( widget.displayFormat == '1') {
      if( widget.actions == null ){
        widget.actions = <Widget>[
          Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200) ,
                child: TrText("OK", style: TextStyle(backgroundColor: Colors.black, color: Colors.white),),
                onPressed: () {
                  //Put your code here which you want to execute on Cancel button click.
                  if( widget.onComplete != null ){
                    widget.onComplete!(false);
                  }
                  Navigator.of(context).pop();
                },
              )),
        ];
      }
      return Scaffold(
          key: _key,
          appBar: new V3AppBar(
            PageEnum.progress,
            automaticallyImplyLeading: false,
            //brightness: gblSystemColors.statusBar,
            //backgroundColor:gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('',
                style: TextStyle(
                    color:
                    gblSystemColors.headerTextColor)),
          ),
          //endDrawer: DrawerMenu(),
          body: messageBodyWidget(widget.title, widget.msg, widget.icon!, widget.titleBackClr!, widget.backClr!,widget.borderClr, widget.iconClr,actions: widget.actions, isHtml: widget.isHtml )
      );
    }
    else if( widget.displayFormat == '2') {
      return Scaffold(
          appBar: new V3AppBar(
            //brightness: gblSystemColors.statusBar,
            PageEnum.progress,
            automaticallyImplyLeading: false,
            // backgroundColor:            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('',
                style: TextStyle(
                    color:
                    gblSystemColors.headerTextColor)),
          ),
          //endDrawer: DrawerMenu(),
          body: AlertDialog(

            shape: alertShape(),
            titlePadding: const EdgeInsets.all(0),
            title: alertTitle(
                translate(widget.title), widget.titleTextClr!, widget.titleBackClr!),

            content: dialogBody(),

          )
      );
    } else if( widget.displayFormat == '3') {
      return Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
            automaticallyImplyLeading: false,
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
          body:     AlertDialog(
            shape: alertShape(),
            titlePadding: const EdgeInsets.all(0),
            title: alertTitle(
                translate('LOGIN'), widget.titleTextClr!, widget.titleBackClr!),
            content: contentBox(context),
            actions: <Widget>[
            vidCancelButton( context, "CANCEL", (context) {
                  //Put your code here which you want to execute on Cancel button click.
                  Navigator.of(context).pop();
                  if( widget.doublePop) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: gblSystemColors.primaryHeaderColor) ,
                child: TrText("CONTINUE"),
                onPressed: () {
                  String result = widget.onOk!(context, _sineController.text, _passwordController.text);
                  widget._errorMsg = '';
                  if( result == 'OK') {
                    // close dialog
                    Navigator.of(context).pop();
                  }else {
                    // error
                    widget._errorMsg = result;
                    setState(() {

                    });
                  }
                },
              ),
            ],
          ));
    }


    // no error
    return Container();

  }
  Widget  contentBox(context){


    return Stack(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'User',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                controller: _sineController,
                //keyboardType: TextInputType.number ,


                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),
              SizedBox(height: 15,),
              new TextFormField(
                obscureText: true,
                obscuringCharacter: "*",
                controller: _passwordController ,
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Password',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                // keyboardType: TextInputType.visiblePassword,

                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),
              Padding(padding: EdgeInsets.all(2)),
              Text(widget._errorMsg),
            ],
          ),
        ),
      ],
    );
  }

  Widget dialogBody() {
    if( gblSettings.wantCustomAnimations) {
      return RoataingImage(wantButtons: false);
    }

    // scale and offset image if required, default offset 25 gives radius 48
    double radius = 73 - gblSettings.progressFactor ; // 48
    double offset =  gblSettings.progressFactor; // 25
    return Center(
        heightFactor: 1,
        child:
        Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 210,
                height: 200,
              child:
              Stack(
                children:  [
                  Positioned(
                      left: 38 + offset,
                      top: 22 + offset,
                      child:
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: radius,
                          child: Image.asset('lib/assets/$gblAppTitle/images/loader.png') //Icon(Icons.check),
                      )),
                  Positioned(
                    left: 20,
                    top: 10,
                    child:
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      color: gblSystemColors.progressColor,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade100, //shade 100
                      // value: .5, // Change this value to update the progress
                    ),
                  )),
                ],
              )),
              Padding(padding: EdgeInsets.all(10.0)),
              TrText('' + _msg),
            ])
    );
  }

  void setMsg(String msg){
    //widget.onLoad(null);
    _msg = msg;
    setState(() {
    });
  }

  void hide(){
    //widget.onLoad(null);
    Navigator.pop(context);
    setState(() {
    });
  }
}
/*
Widget messageWidget() {

}*/
Widget criticalErrorPageWidget(BuildContext context, String msg, {String title='', bool wantButtons=false, void Function(dynamic p)? onComplete}) {
  return Scaffold(
/*
    key: _key,
*/
      appBar: new AppBar(
        automaticallyImplyLeading: false,
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
      body: criticalErrorWidget(context,msg,title: title, wantButtons: wantButtons, onComplete: onComplete)
  );
}


Widget criticalErrorWidget(BuildContext context, String msg, {String title='', bool wantButtons=false, void Function(dynamic p)? onComplete}) {
  List<Widget> actionList ;
  if( wantButtons != null && wantButtons == false) {
    actionList = [];
    actionList.add(Container());
  } else {
    actionList = <Widget>[
      Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.grey.shade200) ,
            child: TrText("OK", style: TextStyle(backgroundColor: Colors.black, color: Colors.white),),
            onPressed: () {
              //Put your code here which you want to execute on Cancel button click.
              if( onComplete != null ){
                onComplete(false);
              } else {
                Navigator.of(context).pop();
              }
            },
          )),
    ];
  }
  return messageBodyWidget(title, msg,
      Icons.close, Colors.red,
      Colors.red,Colors.red,
      Colors.yellow,
      actions: actionList );
}

void criticalErrorPage(BuildContext context, String msg, {String title='', bool wantButtons=false, bool doublePop=false}){
  List<Widget>? actionList ;
  if( wantButtons != null && wantButtons == false) {
    actionList = [];
    actionList.add(Container());
  }
  Navigator.push(
      context, MaterialPageRoute(builder: (context) =>
      MessagePage( msg: msg,
        borderClr: Colors.red,
        actions: actionList,
        backClr: Colors.red,
        iconClr: Colors.yellow,
        icon: Icons.close,
        titleBackClr: Colors.red,
        displayFormat: '1',
        title: title,
          doublePop: doublePop,
        ))
  );
}

void loginPage(BuildContext context, String msg, {String title='', bool wantButtons=false,String Function(dynamic p, String user, String pw)? onOk }){
  List<Widget>? actionList ;
  if( wantButtons != null && wantButtons == false) {
    actionList = [];
    actionList.add(Container());
  }
  Navigator.push(
      context, MaterialPageRoute(builder: (context) =>
      MessagePage( msg: msg,
        borderClr: Colors.red,
        actions: actionList,
        backClr: gblSystemColors.primaryHeaderColor,
        iconClr: gblSystemColors.headerTextColor,
        icon: Icons.close,
        titleBackClr: gblSystemColors.primaryHeaderColor,
        titleTextClr: gblSystemColors.headerTextColor,
        displayFormat: '3',
        onOk: onOk,
        title: title,))
  );
}

void successMessagePage(BuildContext context, String msg, {String title='', bool isHtml=true, List<Widget>? actions}){
  Navigator.push(
      context, MaterialPageRoute(builder: (context) =>
      MessagePage( msg: msg,
        borderClr: Colors.green,
        backClr: Colors.green,
        iconClr: Colors.white,
        icon: Icons.check,
        titleBackClr: gblSystemColors.primaryHeaderColor,
        titleTextClr: gblSystemColors.headerTextColor,
        displayFormat: '1',
        isHtml: isHtml,
        actions: actions,
        title: title,))
  );
}

void progressMessagePage(BuildContext context, String msg, {String title=''}){

  Timer(Duration(milliseconds: 50), ()
  {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) =>
        MessagePage(msg: msg,
          key: messageGlobalKeyProgress,
          borderClr: Colors.green,
          backClr: Colors.green,
          iconClr: Colors.white,
          icon: Icons.check,
          titleBackClr: gblSystemColors.primaryHeaderColor,
          titleTextClr: gblSystemColors.headerTextColor,
          displayFormat: '2',
          title: title,))
    );
  });
}

Widget progressMessagePageWidget(BuildContext context, String msg, {String title=''}){
  return MessagePage(msg: msg,
    key: messageGlobalKeyProgress,
    borderClr: Colors.green,
    backClr: Colors.green,
    iconClr: Colors.white,
    icon: Icons.check,
    titleBackClr: gblSystemColors.primaryHeaderColor,
    titleTextClr: gblSystemColors.headerTextColor,
    displayFormat: '2',
    title: title,);
}


void setProgressMessage(String msg) {
  try {
    if( messageGlobalKeyProgress != null && messageGlobalKeyProgress.currentState != null ) {
      messageGlobalKeyProgress.currentState!.setMsg(msg);
    }
  } catch (e) {

  }
}


void endProgressMessage() {
  if (gblSettings.wantCustomProgress == false) {
    return;
  }
  try {
    if( messageGlobalKeyProgress != null && messageGlobalKeyProgress.currentState != null ) {
      messageGlobalKeyProgress.currentState!.hide();
    }
  } catch (e) {

  }
}
Widget messageBodyWidget( String title, String msg, IconData? icon, Color? titleBackClr, Color? backClr, Color? borderClr, Color? iconClr, {List<Widget>? actions, bool isHtml=false }  )
{
  Widget msgWidget;

  String body = msg;
  if( msg.contains('<html>') == false){
    body = '<html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head><body>' +
        msg +
        '</body></html>';
  }

  late final WebViewController _controller;
  _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadHtmlString(body);

  if(isHtml != null && isHtml == true) {
    msgWidget = Container(
        height: 250,
        width: 500,
        child: WebViewWidget(controller: _controller
          /*initialUrl: Uri.dataFromString(
          '<html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head><body>' +
              msg +
              '</body></html>',
          mimeType: 'text/html')
          .toString(),
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },*/
        ));
  } else {
    msgWidget = Text(msg);
  }

  return AlertDialog(
    shape: alertShape(),
    titlePadding: const EdgeInsets.all(0),
    title: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: titleBackClr,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        child: Text(title,style: TextStyle(color: Colors.white),)
    ),
    content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget> [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backClr,
                border: Border.all(color: borderClr!, width: 3)
            ),
            child: Icon(icon, color: iconClr ,size: 100,),
          ),
          Padding(padding: EdgeInsets.all(5)),
          msgWidget,
        ]),
    actions: actions,
  );
}

Widget msgDialog(BuildContext context, String title, Widget content,{ List<Widget>? actions, EdgeInsets? ipad, bool wide = false }) {
  Color titleBackClr = gblSystemColors.primaryHeaderColor;
  Color borderClr = Colors.green;
  Color backClr = Colors.green;
  //Color iconClr = Colors.white;

  if( titleBackClr == Colors.white) {
    titleBackClr = gblSystemColors.primaryButtonColor;
  }
  if( actions == null ){
    actions = <Widget>[
      Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.grey.shade200,
            backgroundColor: titleBackClr) ,
            child: TrText("OK", /*style: TextStyle(backgroundColor: Colors.grey.shade200, color: Colors.black),*/),
            onPressed: () {
              //Put your code here which you want to execute on Cancel button click.
              Navigator.of(context).pop();
            },
          )),
    ];
  }

  if( ipad == null ){
    ipad = EdgeInsets.all(5);
  }

  return AlertDialog(
    shape: alertShape(),
    insetPadding: ipad!,
    contentPadding: (wide) ? EdgeInsets.all(5): EdgeInsets.all(0) ,
    titlePadding: alertTitlePadding(),
    title: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: titleBackClr,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        child: Text(title,style: TextStyle(color: Colors.white),)
    ),
    content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget> [
          Container(
            width: (wide==true) ? MediaQuery.of(context).size.width : null,
 /*           decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backClr,
                border: Border.all(color: borderClr, width: 3)
            ),*/
            child: content,
          ),
        ]),
    actions: actions,
  );
}


ShapeBorder alertShape() {
  return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0));
}
Widget alertTitle(String title, Color titleTextClr, Color  titleBackClr) {
  return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: titleBackClr,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),

      child: Text(title,style: TextStyle(color: titleTextClr),));
}
EdgeInsets alertTitlePadding() {
  return const EdgeInsets.all(0);
}

Widget getProgressMessage(String msg, String title) {
  return MessagePage(msg: msg,
      //key: messageGlobalKeyProgress,
      borderClr: Colors.green,
      backClr: Colors.green,
      iconClr: Colors.white,
      icon: Icons.check,
      titleBackClr: gblSystemColors.primaryHeaderColor,
      titleTextClr: gblSystemColors.headerTextColor,
      displayFormat: '2',
      title: title);

}