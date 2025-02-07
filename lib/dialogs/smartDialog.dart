


import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';

import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/dialog.dart';
import '../utilities/helper.dart';
import '../v3pages/cards/v3FormFields.dart';
import '../v3pages/fields/Pax.dart';
import 'dialogActions.dart';

bool _isHidden = true;

Widget smartDialogPage( BuildContext context, DialogDef dialog, Widget? content, void Function() doUpdate) {
  Color titleBackClr = gblSystemColors.primaryHeaderColor;
  Widget flexibleSpace = Padding(padding: EdgeInsets.all(30,));
  double? width;
  gblActionBtnDisabled = false;
  logit('get smart dialog');

  if( content == null ) content = getDialogContent(context, dialog, (){ doUpdate(); });

  if( dialog.width == 'full') {
    width = MediaQuery.of(context).size.width;
    content = Container(width: width,
      child: content,);
  }

    return  Scaffold(
        body: /*InkWell(
          onTap: () {
            logit('clicked out');
          },
        child:*/
        Column (
            children: [
              flexibleSpace,
              AlertDialog(
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
                          Text(dialog.caption,
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
              ),
            ])
    //)
    );

}

void showSmartDialog( BuildContext context, DialogDef dialog, Widget? content, void Function() doUpdate){
  Color titleBackClr = gblSystemColors.primaryHeaderColor;
  gblActionBtnDisabled = false;
  if( content == null ) content = getDialogContent(context, dialog, (){ doUpdate(); });

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
                Text(dialog.caption,
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
        gblActionBtnDisabled = true;
        doUpdate();

        doDialogAction(context, dialog, null, doUpdate );
    }, pad: 5 , disabled: gblActionBtnDisabled ),  ));

  dialog.foot.forEach((f) {
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
Widget wrapFootField(BuildContext context,DialogDef dialog, DialogFieldDef f, void Function() doUpdate){
  return Container(
      decoration: BoxDecoration(
      color: Colors.black12 ,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0),)),
  margin: EdgeInsets.all(0),
  height: 35,
  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
  width: MediaQuery.of(context).size.width,
  child:  getField(context, dialog, f, true, doUpdate)
  );

}


Widget getField(BuildContext context, DialogDef dialog, DialogFieldDef f, bool isFoot, void Function() doUpdate){
  switch (f.field_type.toUpperCase()){
    case 'FQTVNUMBER':
      TextEditingController _fqtvTextEditingController = new TextEditingController();
      dialog.editingControllers.add(_fqtvTextEditingController);
      return Padding(padding: EdgeInsets.only(left: 10, right: 10), child: TextFormField(
        decoration: getDecoration( f.caption),
        controller: _fqtvTextEditingController,
        keyboardType: TextInputType.number,
        onSaved: (value) {
          if (value != null) {
            //.contactInfomation.phonenumber = value.trim()
          }
        },
      )  );
      break;

    case 'EMAIL':
      TextEditingController _emailEditingController = new TextEditingController();
      dialog.editingControllers.add(_emailEditingController);

      return new Padding(padding: EdgeInsets.only(left: 10, right: 10),
          child:V3TextFormField(
      translate('Email'),
      _emailEditingController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => validateEmail(value!.trim()),
      ));

    case 'PIN':
      TextEditingController te1 = new TextEditingController();
      dialog.editingControllers.add(te1);
      TextEditingController te2 = new TextEditingController();
      dialog.editingControllers.add(te2);
      TextEditingController te3 = new TextEditingController();
      dialog.editingControllers.add(te3);
      TextEditingController te4 = new TextEditingController();
      dialog.editingControllers.add(te4);
      TextEditingController te5 = new TextEditingController();
      dialog.editingControllers.add(te5);
      TextEditingController te6 = new TextEditingController();
      dialog.editingControllers.add(te6);
      List<TextEditingController> faEditingController = [te1,te2,te3,te4,te5,te6];

      return new Padding(padding: EdgeInsets.only(left: 10, right: 10),
          child: pax2faNumber(
          context, faEditingController, onFieldSubmitted: (value) {},
          onSaved: (value) {}, autofocus: true));



    case 'NUMBER':
      TextEditingController _emailEditingController = new TextEditingController();
      dialog.editingControllers.add(_emailEditingController);

      return new Padding(padding: EdgeInsets.only(left: 10, right: 10),
          child:V3TextFormField(
            translate(f.caption),
            _emailEditingController,
            keyboardType: TextInputType.number,
            ),
          );

  case 'PASSWORD':
      TextEditingController _passwordEditingController = new TextEditingController();
      dialog.editingControllers.add(_passwordEditingController);

      return Padding(padding: EdgeInsets.only(left: 10, right: 10), child:  TextFormField(
      obscureText: _isHidden,
      obscuringCharacter: "*",
      controller: _passwordEditingController ,
      decoration:getDecoration(f.caption),
      keyboardType: TextInputType.visiblePassword,
      onSaved: (value) {
      if (value != null) {
      }
      },
      ));
      break;
    case 'TEXT':
      return Padding(padding: EdgeInsets.only(left: 10 ), child:TrText(f.caption));
    case 'ACTION':
        if( f.caption == '') {
          return
            TextButton(child: TrText(f.actionText,
              style: TextStyle(color: gblSystemColors.plainTextButtonTextColor),
                ),
                // style: TextButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300, width: 2)),
                onPressed: () {
                  gblActionBtnDisabled = true;
                  doUpdate();

                  Navigator.of(context).pop();
                  doDialogAction(context, dialog, f, doUpdate);
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
                  gblActionBtnDisabled = true;
                  doUpdate();

                  Navigator.of(context).pop();
                  doDialogAction(context, dialog, f, doUpdate);
                  /*
            navToGenericFormPage(context, new FormParams(formName: 'FQTVREGISTER',
            formTitle: '${gblSettings.fqtvName} Registration'));
            */
                }
            )]
            );
        }
break;
    case 'SPACE':
      return SizedBox(height: 15,);
      break;
  }
  return Container();
}