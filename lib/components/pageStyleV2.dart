import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';



Widget v2BorderBox(BuildContext context, String label, Widget child, {IconData icon, double height, EdgeInsets padding}) {
  double w = MediaQuery.of(context).size.width -30 ;
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
                style: TextStyle(color: gblSystemColors.textEditIconColor, fontSize: 14),
              ),
            )),
      ]
  );

}


InputDecoration v2Decoration() {
  return InputDecoration( enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0),
  ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    counterText: '',
  );
}


class V2TextWidget extends StatefulWidget {
  //final void Function(BuildContext context) flightSelected;

  TextEditingController controller;
  String Function(String ) validator;
  void Function(String) onFieldSubmitted;
  void Function(String) onSaved;
  List<TextInputFormatter> inputFormatters;
  TextInputAction textInputAction;
  TextInputType keyboardType;
  InputDecoration decoration;
  //String title;
  int maxLength;

  V2TextWidget({Key key, this.decoration, this.controller, this.validator, this.onFieldSubmitted, this.onSaved,
    this.inputFormatters, this.textInputAction, this.maxLength, this.keyboardType})
      : super(key: key);


  _V2TextWidgetState createState() => _V2TextWidgetState();
}

class _V2TextWidgetState extends State<V2TextWidget> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if( wantPageV2()) {
      return v2BorderBox(context, ' ' + translate(widget.decoration.labelText),
        TextFormField(
          decoration: v2Decoration(),
          maxLength: widget.maxLength,
          controller: widget.controller,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          onSaved: widget.onSaved,
          keyboardType: widget.keyboardType,

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
            keyboardType: widget.keyboardType,

        );
    }
  }
}