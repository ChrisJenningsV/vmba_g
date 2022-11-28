import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/xmlApi.dart';

import '../components/pageStyleV2.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../data/repository.dart';
import 'helper.dart';
import 'messagePages.dart';


class BlueScreenPage extends StatefulWidget {
  BlueScreenPage({
  Key key,
  this.action,
 });

  String action;

  @override
  BlueScreenPageState createState() => BlueScreenPageState();
}

class BlueScreenPageState extends State<BlueScreenPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController _inputController = TextEditingController();
  String _displayText;

  @override
  initState() {
    super.initState();
    _displayText = 'Ready';
    _inputController.text = '*R';
    }
    //errorlevel = '1';


    @override
    Widget build(BuildContext context) {
      return Scaffold(
          key: _key,
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
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          //endDrawer: DrawerMenu(),
          body: _body()

      );
    }

    Widget _body() {
      return AlertDialog(
        shape: alertShape(),
        titlePadding: const EdgeInsets.all(0),
        title: alertTitle(translate('Blue Screen'), gblSystemColors.headerTextColor, gblSystemColors.primaryHeaderColor),
        contentPadding: EdgeInsets.all(5),
        insetPadding: EdgeInsets.all(5),
        content:
        Container(


            child:
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:
        SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child:
        Column(
            //mainAxisSize: MainAxisSize.max,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            
            children: <Widget> [

              Container(
                padding: EdgeInsets.all(3),
                height: 300,
                width: 400,
                color: Colors.blue,
                child: Text(_displayText,
                  style: TextStyle(color: Colors.white, ),textScaleFactor: 0.8,),
              ),
              Padding(padding: EdgeInsets.all(5)),

            ])
        )
        )
        ),
        actions: [

          TextField(
            onChanged: (value) {

            },
            controller: _inputController,
            decoration: InputDecoration(hintText: "*r",
                suffixIcon: IconButton(
                  color: Colors.green,
                  onPressed:  () {
                    _onPressed(context);
                  },
                  icon: Icon(Icons.arrow_circle_right),
                )
            ),

          ),

        ],
        //actions: actions,
      );
    }

    Future<void> _onPressed(BuildContext context) async {

      try {
        String data = await runVrsCommand(_inputController.text);
        _displayText = data.replaceAll('\n\n', '\n');
        setState(() {

        });
      } catch(e) {
        logit('catch ${e.toString()}');
        _displayText = e.toString();
        setState(() {

        });
      }

      }

    }





void startBlueScreen(BuildContext context){
  Navigator.push(
      context, MaterialPageRoute(builder: (context) =>
      BlueScreenPage( ))
  );
}