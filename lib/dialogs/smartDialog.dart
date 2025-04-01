


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/components/vidAppBar.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/dialogs/smartDropDown.dart';

import '../Helpers/settingsHelper.dart';
import '../Managers/imageManager.dart';
import '../components/pageStyleV2.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/dialog.dart';
import '../menu/menu.dart';
import '../utilities/helper.dart';
import '../v3pages/fields/Pax.dart';
import 'dialogActions.dart';

bool _isHidden = true;

class smartDialogPage extends StatefulWidget {
  smartDialogPage({this.content, this.reload = false});

  _smartDialogPageState createState() => _smartDialogPageState();
  Widget? content;
  bool reload ;
}

class _smartDialogPageState extends State<smartDialogPage> {

//Widget smartDialogPage( BuildContext context, DialogDef dialog, Widget? content, void Function() doUpdate) {


  late final formKey;

  @override
  initState() {
    super.initState();
    formKey = new GlobalKey<FormState>();
    gblActionBtnDisabled = false;

    if( gblCurDialog! != null ) {
      gblCurDialog!.fields.forEach((f) {
        initField( f);
      });
      commonPageInit(gblCurDialog!.formname);
    } else {
      commonPageInit('DIALOGPAGE');
    }

  }
  @override
  Widget build(BuildContext context) {
  Widget flexibleSpace = Padding(padding: EdgeInsets.all(30,));
  double? width;
 //gblActionBtnDisabled = false;

  logit('sd build');

  /*if( widget.content == null || widget!.reload)*/
  widget.content = getDialogContent(context, gblCurDialog!, () {
    setState(() {  });
  });

    return  Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: gblCurDialog!.wantAppBar ?
        vidAppBar(titleText: gblCurDialog!.caption , backgroundColor: gblSystemColors.primaryHeaderColor,) :
        null, //
      endDrawer: DrawerMenu(),
      backgroundColor: v2PageBackgroundColor(),
        body: ImageManager.getBodyWithBackground(context, gblCurPage,_body(), gblCurDialog)

    );

  }


Widget _body() {
  Color titleBackClr = gblSystemColors.dialogHeaderColor as Color;
  Widget flexibleSpace = Padding(padding: EdgeInsets.all(30,));
  if (gblSettings.pageImageMap != null && gblSettings.pageImageMap != '') {
    Map pageMap = json.decode(gblSettings.pageImageMap.toUpperCase());
    if (gblCurDialog != null && gblCurDialog!.formname == 'FQTVLOGIN' && pageMap['FQTV'] != null) {
      String pageImage = pageMap['FQTV'];

      if (pageImage != null && pageImage.isNotEmpty) {
        NetworkImage backgroundImage = NetworkImage(
            '${gblSettings.gblServerFiles}/pageImages/$pageImage.png');
        flexibleSpace = Image(
          image:
          backgroundImage,
          fit: BoxFit.cover,);
      }
    }
  }
  double hPad = 30;
  if( gblCurDialog!.width == 'full') {
    hPad = 5;
    flexibleSpace = Container();
  }
  if( gblCurDialog!.wantAppBar == false ){
    flexibleSpace = Padding(padding: EdgeInsets.all(15));
  }

    return Padding(padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 10),
        child: Column(
            children: [
              flexibleSpace,
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: titleBackClr,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),)),
                        padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                        child:
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //Padding(padding: EdgeInsets.all(20)),
                              Text(gblCurDialog!.caption,
                                textScaler: TextScaler.linear(1.25),
                                style: TextStyle(color: gblSystemColors
                                    .dialogHeaderTextColor),),
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Stack(
                                    children: [
                                      Icon(Icons.circle_outlined,
                                        color: Colors.white, size: 34,),
                                      Padding(padding: EdgeInsets.only(
                                          left: 5, top: 5),
                                          child: Icon(
                                            Icons.close, color: gblSystemColors
                                              .dialogHeaderTextColor,)),
                                    ],
                                  ))
                            ])
                    ),
                    widget.content as Widget,
                  ],
                ),

                //actions: <Widget>[)    ]
              ),
            ])
    );
  }

}


void showSmartDialog( BuildContext context, Widget? content, void Function() doUpdate){
  Color titleBackClr = gblSystemColors.dialogHeaderColor as Color;
  gblActionBtnDisabled = false;
  if( gblCurDialog! != null ) {
    gblCurDialog!.fields.forEach((f) {
      if( f.controller == null ) {
        initField(f);
      }
    });
  }

 // if( content == null ) content = getDialogContent(context, gblCurDialog!, (){ doUpdate(); });
  if( content == null ) content = DialogContent(gblCurDialog!);

  showDialog(
      context: context,
      builder: (BuildContext context)
  {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      titlePadding: EdgeInsets.only(top: 0),
      contentPadding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 0),
      title: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: titleBackClr,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
          padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
          child:
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(padding: EdgeInsets.all(20)),
                Text(gblCurDialog!.caption,
                  style: TextStyle(color: Colors.white),),
                IconButton(onPressed: () => Navigator.pop(context),
                    icon: Stack(
                      children: [
                        Icon(Icons.circle_outlined, color: Colors.white, size: 34,),
                        Padding( padding: EdgeInsets.only(left: 5, top: 5), child: Icon(Icons.close, color: Colors.white,)),
                      ],
                    ))
              ] )
      ),
      content: content,
      //actions: <Widget>[)    ]
    );
  } );

}


class DialogContent extends StatefulWidget {
  DialogDef dialog;
  DialogContent(this.dialog);

  @override
  DialogContentState createState()  => new DialogContentState();
}

class DialogContentState extends State<DialogContent> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return getDialogContent(context, widget.dialog, doSetState) as Widget ;
  }

  void doSetState() {
    setState(() {

    });
  }

}

//List<TextEditingController> editingControllers = [];

Widget? getDialogContent(BuildContext context, DialogDef dialog, void Function() doUpdate ){
  List<Widget> fields=[];
//  List<Widget> foot=[];

  dialog.fields.forEach((f) {
    fields.add(getField(context, dialog, f, false, doUpdate ));
  });

  if( dialog.actionText == ''){
    dialog.actionText = translate('Continue');
  }

  fields.add(
    Padding(padding: EdgeInsets.all(10),
      child: vidWideActionButton(context, dialog.actionText, (c, d){
        // button pressed
        if( gblActionBtnDisabled == false ){
          gblActionBtnDisabled = true;
          logit('d action d:$gblActionBtnDisabled');
          doUpdate();
          doDialogAction(context, null, doUpdate);
        }
    }, pad: 5 , disabled: gblActionBtnDisabled ),  ));

  dialog.dialogFoot.forEach((f) {
    fields.add(wrapFootField(context, dialog, f, doUpdate));
  });


  return
    SizedBox(
        width: MediaQuery.of(context).size.width,
        child:
        Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: fields
            )
          ],
        )
    );
}
Widget wrapFootField(BuildContext context,DialogDef dialog, DialogFieldDef f, void Function() doUpdate, {bool isPageBottom = false}){
  return Container(
      decoration: BoxDecoration(
      color: f.backgroundColor ?? Colors.black12 ,
      borderRadius: isPageBottom ? null : BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0),)),
  margin: EdgeInsets.all(0),
  height: 35,
  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
  width: MediaQuery.of(context).size.width,
  child:  getField(context, dialog, f, true, doUpdate)
  );

}


void initField( DialogFieldDef f){
  switch (f.field_type.toUpperCase()){
    case 'SCROLLTEXT':
      break;
    case 'FQTVNUMBER':
      TextEditingController _fqtvTextEditingController = new TextEditingController();
      f.controller = _fqtvTextEditingController;
      if(f.value != ''){
        f.controller!.text = f.value as String;
      }
      gblCurDialog!.editingControllers.add(_fqtvTextEditingController);
      break;

    case 'EMAIL':
      TextEditingController _emailEditingController = new TextEditingController();
      f.controller = _emailEditingController;
      gblCurDialog!.editingControllers.add(_emailEditingController);
      break;
    case 'PIN':
      TextEditingController te1 = new TextEditingController();
      gblCurDialog!.editingControllers.add(te1);
      TextEditingController te2 = new TextEditingController();
      gblCurDialog!.editingControllers.add(te2);
      TextEditingController te3 = new TextEditingController();
      gblCurDialog!.editingControllers.add(te3);
      TextEditingController te4 = new TextEditingController();
      gblCurDialog!.editingControllers.add(te4);
      TextEditingController te5 = new TextEditingController();
      gblCurDialog!.editingControllers.add(te5);
      TextEditingController te6 = new TextEditingController();
      gblCurDialog!.editingControllers.add(te6);
      //List<TextEditingController> faEditingController = [te1,te2,te3,te4,te5,te6];
      break;

    case 'NUMBER':
      TextEditingController _numEditingController = new TextEditingController();
      f.controller = _numEditingController;
      gblCurDialog!.editingControllers.add(_numEditingController);
      break;
    case 'PASSWORD':
      TextEditingController _passwordEditingController = new TextEditingController();
      f.controller = _passwordEditingController;
      if(f.value != ''){
        f.controller!.text = f.value as String;
      }
      gblCurDialog!.editingControllers.add(_passwordEditingController);
      break;
    case 'EDITTEXT':
      TextEditingController _textEditingController = new TextEditingController(text: getGblValue(f.valueKey));
      f.controller = _textEditingController;
      gblCurDialog!.editingControllers.add(_textEditingController);
      break;
    case 'DROPDOWN':
      TextEditingController _textEditingController = new TextEditingController(text: f.options![0]);
      f.controller = _textEditingController;
      gblCurDialog!.editingControllers.add(_textEditingController);
      break;
    case 'LIST':
      f.value = getGblValue(f.valueKey);
      TextEditingController _textEditingController = new TextEditingController(text: getGblValue(f.valueKey));
      f.controller = _textEditingController;
      gblCurDialog!.editingControllers.add(_textEditingController);
      break;


    case 'SWITCH':
      if( f.controller == null ) {
        f.value = getGblValue(f.valueKey);
        TextEditingController _textEditingController = new TextEditingController(text: f.valueKey);
        f.controller = _textEditingController;
        gblCurDialog!.editingControllers.add(_textEditingController);
      }
      break;
    case 'TITLE':
      f.value = getGblValue(f.valueKey);
      TextEditingController _textEditingController = new TextEditingController(text: f.valueKey);
      f.controller = _textEditingController;
      gblCurDialog!.editingControllers.add(_textEditingController);
      break;
    case 'TEXT':
//      return Padding(padding: EdgeInsets.only(left: 10 ), child:TrText(f.caption));
      break;
    case 'ACTION':
      break;
    case 'SPACE':
      break;
    default:
      logit('ERROR unknown field type ${f.field_type}');
      break;
  }

}

Widget getField(BuildContext context, DialogDef dialog, DialogFieldDef f, bool isFoot, void Function() doUpdate){
  EdgeInsets _padding = EdgeInsets.only(left: 10, right: 10);

  switch (f.field_type.toUpperCase()){
    case 'SCROLLTEXT':
      return Container(
        height: 300,
        child: Expanded(
        flex: 1,
        child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,//.horizontal
          child: new Text( f.caption,
            style: new TextStyle(
               color: Colors.black,
            ),
          ),
        ),
      ));
  case 'FQTVNUMBER':
/*
      TextEditingController _fqtvTextEditingController = new TextEditingController();
      dialog.editingControllers.add(_fqtvTextEditingController);
*/
      return Padding(padding: _padding, child: TextFormField(
        decoration: getDecoration( f.caption),
        controller: f.controller,
        keyboardType: TextInputType.number,
        onSaved: (value) {
          if (value != null) {
            //.contactInfomation.phonenumber = value.trim()
          }
        },
      )  );

    case 'EMAIL':
    return Padding(padding: _padding, child: V2TextWidget(
        maxLength: 50,
        styleVer: gblSettings.styleVersion,
        decoration: getDecoration('Email'),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: f.controller,
        //autofocus: autofocus,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp("[#'!£^&*(){},|]"))
        ],
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          String er = validateEmail(value!.trim());
          if(er != '' ) return er;
          return null;

        },
      ));

    case 'PIN':
      if( gblCurDialog != null && gblCurDialog!.editingControllers.length > 5 ) {
        List<TextEditingController> faEditingController = [
          gblCurDialog!.editingControllers[0],
          gblCurDialog!.editingControllers[1],
          gblCurDialog!.editingControllers[2],
          gblCurDialog!.editingControllers[3],
          gblCurDialog!.editingControllers[4],
          gblCurDialog!.editingControllers[5]
        ];

        return new Padding(padding: _padding,
            child: pax2faNumber(
                context, faEditingController, onFieldSubmitted: (value) {},
                onSaved: (value) {}, autofocus: true));
      }
      break;

    case 'EDITTEXT':
      List<TextInputFormatter>? iputFormatter = null;
      if( f.formatRegex != ''){
        iputFormatter =[];
        iputFormatter.add(FilteringTextInputFormatter.allow(RegExp(f.formatRegex)));
      }
      return Padding(padding: _padding,
          child: V2TextWidget(
        maxLength: f.maxLen,
        inputFormatters: iputFormatter,
        styleVer: gblSettings.styleVersion,
        decoration: getDecoration(f.caption),
        controller: f.controller,
        minlines: 1,
        maxlines: f.maxLines,
        validator: (value) {
          return null;
        },
      ));
    case 'SWITCH':
      return Padding(padding: _padding,
        child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(f.caption),
          Switch(
            value:  parseBool(getGblValue(f.valueKey)), // sw1,
            activeColor: Color(0xFF6200EE),
            onChanged: (bool value) {
              logit('switch click val $value');
              setGblValue(f.valueKey, value.toString());
              f.controller!.value = f.controller!.value.copyWith(
                text: value.toString(),
                //selection: TextSelection.collapsed(offset: updatedText.length),
              );
              doUpdate();
/*
              setState(() {
              });
*/

            },
          ),
        ],
      ));

    case 'DROPDOWN':
      //String _currentSelectedValue = f.options![0];
      return Padding(padding: _padding,
          child:FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
           /* decoration: InputDecoration(
                labelStyle: TextStyle(color: gblSystemColors.plainTextButtonTextColor),
                errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                hintText: 'Please select expense',
            //    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
            ),*/
            decoration:getDecoration(f.caption),
            isEmpty: (f.controller == null || f.controller!.text == ''),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (f.controller == null ) ? '' : f.controller!.text,
                isDense: true,
                onChanged: (String? newValue){
                  f.controller!.text = newValue as String;
                  doUpdate();
                  },
                items: f.options!.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ));
          break;



    case 'LIST':
      return Padding(padding: _padding,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(f.caption),
              SmartDropDownMenu(
                    controller: f.controller,
                          options: f.options!,
                          iconColor: Colors.white,
                          onChange: (index) {
                          print(index);
                            f.controller!.text = f.options![index];
                            f.value = f.options![index];
                            setGblValue(f.valueKey, f.options![index]);
                            doUpdate();
                          },
                ),
              ],
          ));

    case 'NUMBER':
      return new Padding(padding: _padding,
          //child:V3TextFormField(
          child: TextFormField(
            decoration:getDecoration(f.caption),
             controller: f.controller as TextEditingController,
            keyboardType: TextInputType.number,
            ),
          );

  case 'PASSWORD':
      return Padding(padding: _padding, child:  TextFormField(
      obscureText: _isHidden,
      obscuringCharacter: "*",
      controller: f.controller ,
      decoration:getDecoration(f.caption),
      keyboardType: TextInputType.visiblePassword,
      onSaved: (value) {
      if (value != null) {
      }
      },
      ));
    case 'TEXT':
      return Padding(padding: _padding, child:TrText(f.caption));
    case 'ACTION':
        if( f.caption == '') {
          return
            TextButton(child: TrText(f.actionText,
              style: TextStyle(color: gblSystemColors.plainTextButtonTextColor),
                ),
                // style: TextButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300, width: 2)),
                onPressed: () {
                  if(gblActionBtnDisabled == false ) {
                    gblActionBtnDisabled = true;
                    doUpdate();
                    if( f.popOnAction) {
                      Navigator.of(context).pop();
                    }
                    doDialogAction(context, f, doUpdate);
                  }
                }
            );
        } else {
          return
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
                TrText(f.caption),
            TextButton(child: new TrText(f.actionText,
              style: TextStyle(color: gblSystemColors.plainTextButtonTextColor),
            ),
                // style: TextButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300, width: 2)),
                onPressed: () {
                  if(gblActionBtnDisabled == false ) {
                    gblActionBtnDisabled = true;
                    doUpdate();

                    Navigator.of(context).pop();
                    doDialogAction(context, f, doUpdate);
                  }
                /*
            navToGenericFormPage(context, new FormParams(formName: 'FQTVREGISTER',
            formTitle: '${gblSettings.fqtvName} Registration'));
            */
                }
            )]
            );
        }
    case 'SPACE':
      return SizedBox(height: 15,);
    case 'TITLE':

      return  Padding(
        padding: _padding,
        child:
        paxGetTitle(context, f.controller as TextEditingController , (val) {
          doUpdate();
          })
        );
  }
  return Container();
}

