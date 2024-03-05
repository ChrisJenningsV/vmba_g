
import 'package:flutter/material.dart';

import '../../components/trText.dart';
import '../../utilities/helper.dart';

class V3TextFormField extends StatefulWidget  {
  String label = '';
  String? hintText ;
  TextEditingController controller;
  TextInputType? keyboardType;
  void Function(String?)? onSaved;
  IconData? icon;
  bool obscureText;
  String obscuringCharacter;

  V3TextFormField(this.label, this.controller,
      {
        this.hintText,
        this.keyboardType,
        this.onSaved,
        this.icon,
        this.obscureText = false,
        this.obscuringCharacter = "*",
    }
  );

  V3TextFormFieldState createState() => V3TextFormFieldState();
}
class V3TextFormFieldState extends State<V3TextFormField> {
  Color _colorText = Colors.black54;
  Color _backColor = Colors.black12;

  @override
  Widget build(BuildContext context) {
    const _defaultColor = Colors.black54;
    const _focusColor = Colors.purple;

    return Container(
      //padding: EdgeInsets.symmetric(vertical: 15),
      child: Focus(
        onFocusChange: (hasFocus) {
          logit('focus change focus = $hasFocus');
          setState(() {
              _colorText = hasFocus ? _focusColor : _defaultColor;
              _backColor = hasFocus ? Colors.white : Colors.black12;
            });
        },

        child: TextField(
          //decoration: getV3Decoration(label              ),
          // Validate input Email
          keyboardType: TextInputType.emailAddress,
          controller: widget.controller,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscuringCharacter,

          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: _backColor,
            focusColor: Colors.white,
            labelText: widget.label,
            labelStyle: TextStyle(color: _colorText),

            // Default Color underline
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),

            // Focus Color underline
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            icon: widget.icon == null ? null : Icon(
              widget.icon as IconData,
              color: _colorText,
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration getV3Decoration(String label, {String hintText='', Widget? prefixIcon, bool hasFocus = false}) {
  return InputDecoration(
    fillColor:  hasFocus ? Colors.white : Colors.grey.shade300,
    filled: true,
    counterText: '',
    hintText: hintText,
    prefixIcon: prefixIcon,

    labelStyle: TextStyle(color: Colors.grey),
    labelText: translate(label),

  );

}
