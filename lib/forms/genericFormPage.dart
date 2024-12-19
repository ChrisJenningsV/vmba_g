


import 'package:flutter/material.dart';

import '../Helpers/settingsHelper.dart';
import '../data/globals.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/controls/V3Constants.dart';
import 'fqtvRegisterFields.dart';

class FormParams {
  String formName='';
  String formTitle='';

  FormParams({required this.formName, required this.formTitle});
}


class GenericFormPageWidget extends StatefulWidget {
  GenericFormPageWidget({ required this.formParams});
  // : super(key: key);
  final FormParams formParams;

  GenericFormPageWidgetState createState() =>
      GenericFormPageWidgetState();
}

class GenericFormPageWidgetState extends State<GenericFormPageWidget> {
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return

      new Scaffold(
        backgroundColor: v2PageBackgroundColor(),
        appBar: appBar(context, widget.formParams.formTitle, PageEnum.editPax,
          imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        extendBodyBehindAppBar: gblSettings.wantPageImages,
        //endDrawer: DrawerMenu(),
        body: _body(),
      );
  }

  Widget _body() {
    return SafeArea(
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
                child: Padding(
                  padding: v2FormPadding(),
                  child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: v2BorderColor()),
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                      clipBehavior: Clip.antiAlias,
                      child: Column(
                          children: [
/*
                            ListTile(
                              tileColor: gblSystemColors.primaryHeaderColor ,
                              leading: Icon(Icons.person, size: 50.0, color: gblSystemColors.headerTextColor   ,),
                              title: Text(translate('Passenger') + ' ' + widget.passengerDetail.paxNumber + ' (' + translate(paxTypeName) + ')'  ,
                                style: TextStyle(color: gblSystemColors.headerTextColor, fontWeight: FontWeight.bold),),
                            ),
*/
                            Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 0, 15, 15),
                                child: Column(
                                  children:  renderFields(context),

                                )),
                          ])
                  ),
                )
            )
        ));
  }

  List <Widget> renderFields(BuildContext context ) {
    switch (widget.formParams.formName.toUpperCase()) {
      case 'FQTVREGISTER':
        return renderFqtvRegFields(context);

      default:
        List <Widget> list = [];
        list.add(Text('no render for ${widget.formParams.formName}'));
        return list;
    }
/*

    List <Widget> list = [];
    ThemeData theme = new ThemeData(
      primaryColor: Colors.blueAccent,
      primaryColorDark: Colors.blue,
    );


    return list;
*/
  }



  }