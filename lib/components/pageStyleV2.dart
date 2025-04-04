import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';



Widget v2BorderBox(BuildContext context, String label, Widget child, {IconData? icon, double? height, EdgeInsets? padding, bool? titleText}) {
  double w = MediaQuery.of(context).size.width -30 ;
  TextStyle textStyle = TextStyle(color: gblSystemColors.textEditIconColor, fontSize: 14);
  if( titleText != null && titleText){
    textStyle = TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey);
  }

  if( padding == null ){
    padding = EdgeInsets.all(10.0);
  }
  return Stack(
      children: <Widget>[
/*
        IntrinsicWidth(
  child:
*/
        Container(
          width: w,
          height: height,
          //margin: const EdgeInsets.all(15.0),
          margin: EdgeInsets.fromLTRB(0, 6, 0, 10),
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: gblSystemColors.textEditBorderColor ),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //                 <--- border radius here
            ),
          ),
          child: child,
        ),
        Positioned(
            left: 15,
            top: 0,
            child: Container(
              padding: EdgeInsets.only(top: 0, bottom: 1, left: 0, right: 10),
              color: Colors.white,
              child: Text(
                label,
                style: textStyle,
              ),
            )),
      ]
  );

}

EdgeInsets containerMargins({String location = ''}){
  if( location == 'day'){
    return EdgeInsets.all(0);
  }
  if( location == 'top'){
    return EdgeInsets.all(0);
  }
  if( location == 'middle'){
    return EdgeInsets.all(0);
  }

  return EdgeInsets.all(0);
}

Decoration? containerDecoration({String location = ''}) {
  return  null;
}

Decoration v2ContainerDecoration({String location = ''})
{
  BorderRadiusGeometry? br;
  Color bgColor = Colors.white;
  if(location == 'top') {
    br = BorderRadius.only(
      topLeft: Radius.circular(10.0),
      topRight: Radius.circular(10.0),
    );
  } else if(location=='middle'){
    br = null;
  } else {
    br = BorderRadius.all(Radius.circular(10.0));
  }
  Color lineClr = v2BorderColor();
  double lineWidth = v2BorderWidth();
  if( location == 'selected'){
    bgColor = gblSystemColors.primaryHeaderColor;
    lineClr = Colors.black;
    lineWidth = v2BorderWidth() * 2;
  }
  return BoxDecoration(
      borderRadius: br,
      color: bgColor,
      border: Border(top: (location=='middle')? BorderSide.none : BorderSide(color: lineClr, width: lineWidth),
        left: BorderSide(color: lineClr, width: lineWidth,),
        right:  BorderSide(color: lineClr, width: lineWidth),
        bottom:  BorderSide(color: lineClr, width: lineWidth)
      ));
}
InputDecoration v2Decoration() {
  return InputDecoration( enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0),
  ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    counterText: '',
    fillColor: gblSystemColors.inputFillColor,
  );
}


class V2TextWidget extends StatefulWidget {
  //final void Function(BuildContext context) flightSelected;

   TextEditingController? controller;
   String? Function(String? )? validator;
   void Function(String)? onFieldSubmitted;
   void Function(String?)? onSaved;
   void Function(String?)? onChanged;
   List<TextInputFormatter>? inputFormatters;
   TextInputAction? textInputAction;
   TextInputType? keyboardType;
   InputDecoration? decoration;
   AutovalidateMode? autovalidateMode;
   FocusNode? focusNode;
   TextAlign textAlign;
   int styleVer;
   bool autofocus;
  //String title;
  final int? maxLength;
  final int? maxlines;
   final int? minlines;

  V2TextWidget({//Key key= const Key("t2text_key"),
    this.decoration, this.controller, this.validator, this.onFieldSubmitted, this.onSaved,this.onChanged,
    this.inputFormatters, this.textInputAction, this.maxLength, this.keyboardType, this.autovalidateMode,
    this.styleVer = 1,this.textAlign =TextAlign.start, this.autofocus = false, this.focusNode, this.maxlines,
    this.minlines
  });
      //: super(key: key);


  _V2TextWidgetState createState() => _V2TextWidgetState();
}

class _V2TextWidgetState extends State<V2TextWidget> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if( gblSettings.inputStyle == 'V2'){
      EdgeInsetsGeometry _padding = EdgeInsets.fromLTRB(0, 2, 0, 2);
      ThemeData theme = new ThemeData(
        primaryColor: Colors.blueAccent,
        primaryColorDark: Colors.blue,
      );

      return Padding(
          padding: _padding,
          child: new Theme(
              data: theme ,
              child: TextFormField(
                maxLines: widget.maxlines,
                decoration: widget.decoration,
                maxLength: widget.maxLength,
                controller: widget.controller,
                validator: widget.validator,
                onFieldSubmitted: widget.onFieldSubmitted,
                inputFormatters: widget.inputFormatters,
                textInputAction: widget.textInputAction,
                onSaved: widget.onSaved,
                onChanged: widget.onChanged,
                keyboardType: widget.keyboardType,
                autovalidateMode: widget.autovalidateMode,
                textAlign: widget.textAlign,
                autofocus: widget.autofocus,
                focusNode: widget.focusNode,
                minLines: widget.minlines,
 //               initialValue: widget.initialValue,
              )
          )
      );
    }

    if( wantPageV2() || widget.styleVer == 2) {
      return v2BorderBox(context, ' ' + translate(widget.decoration?.labelText as String),
        TextFormField(
          decoration: v2Decoration(),
          maxLength: widget.maxLength,
          controller: widget.controller,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          onSaved: widget.onSaved,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          autovalidateMode: widget.autovalidateMode,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
        ),
        padding: EdgeInsets.only(left: 10, right: 10),
      );
    } else {
      return
        TextFormField(
            decoration: widget.decoration,
            maxLength: widget.maxLength,
            controller: widget.controller,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction,
            onSaved: widget.onSaved,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
          autovalidateMode: widget.autovalidateMode,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,

        );
    }
  }
}