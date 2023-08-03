
import 'package:flutter/material.dart';

import 'package:vmba/data/models/models.dart';

//ignore: must_be_immutable
class TrTitleControl extends IgnorePointer {
  final PassengerDetail passengerDetail;

  TextEditingController _titleTextEditingController = TextEditingController();

  TrTitleControl(  this.passengerDetail);

  build(BuildContext context) {
    return IgnorePointer(
      child: TextFormField(
        decoration: new InputDecoration(
          contentPadding:
          new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          labelText: 'Title',
          fillColor: Colors.white,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(25.0),
            borderSide: new BorderSide(),
          ),
        ),
        controller: _titleTextEditingController,
        validator: (value) =>
        value!.isEmpty ? 'Title can\'t be empty' : null,
        onSaved: (value) {
          if (value != null) {
            passengerDetail.title = value.trim();
          }
        },
      ),
    );
  }
}
