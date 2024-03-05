
import 'package:flutter/material.dart';

import '../../components/trText.dart';

class V3TextFormField extends StatefulWidget  {
  String label = '';
  String? hintText ;
  TextEditingController controller;
  TextInputType? keyboardType;
  void Function(String?)? onSaved;
  IconData? icon;

  V3TextFormField(this.label, this.controller,
      {
        this.hintText,
        this.keyboardType,
        this.onSaved,
        this.icon,
    }
  );

  V3TextFormFieldState createState() => V3TextFormFieldState();
}
class V3TextFormFieldState extends State<V3TextFormField> {
  Color _colorText = Colors.black54;

  @override
  Widget build(BuildContext context) {
    const _defaultColor = Colors.black54;
    const _focusColor = Colors.purple;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Focus(
        onFocusChange: (hasFocus) {
          // When you focus on input email, you need to notify the color change into the widget.
          setState(() => _colorText = hasFocus ? _focusColor : _defaultColor);
        },
        child: TextField(
          //decoration: getV3Decoration(label              ),
          // Validate input Email
          keyboardType: TextInputType.emailAddress,
          controller: widget.controller,

          decoration: InputDecoration(
            hintText: widget.hintText,
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
              color: Colors.deepPurpleAccent,
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
