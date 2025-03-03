


import 'package:flutter/material.dart';

import '../../utilities/helper.dart';

class DialogDef {
  String caption = '';
  String action = '';
  String actionText = '';
  String width = '';
  bool wantClose = true;
  List<DialogFieldDef> fields = [];
  List<DialogFieldDef> foot = [];
  List<TextEditingController> editingControllers = [];

  DialogDef({this.caption = '', this.actionText='', this.action = '', this.width=''});

  DialogDef.fromJson(Map<String, dynamic> json)  {
    try {
      if (json['caption'] != null) caption = json['caption'];
      if (json['actionText'] != null) caption = json['actionText'];
      if (json['action'] != null) action = json['action'];

      if (json['wantClose'] != null) wantClose = parseBool(json['wantClose']);

      if (json['fields'] != null) {
        fields = [];
        //new List<Country>();
        if (json['fields'] is List) {
          json['fields'].forEach((v) {
            fields.add(new DialogFieldDef.fromJson(v));
          });
        } else {
          fields.add(new DialogFieldDef.fromJson(json['fields']));
        }
      }

      if (json['foot'] != null) {
        foot = [];
        //new List<Country>();
        if (json['foot'] is List) {
          json['foot'].forEach((v) {
            foot.add(new DialogFieldDef.fromJson(v));
          });
        } else {
          foot.add(new DialogFieldDef.fromJson(json['foot']));
        }
      }

    } catch(e) {
      logit('Dialog.fromJ ${e.toString()}');
    }
  }
}


  class DialogFieldDef {
    // INPUTS
    String field_type = '';
    String field_id = '';
    // opts name, phone, email, password, text, textWithLink, number, image
    String caption = '';
    String actionText = '';
    List<String>? options =[];

    String action = '';
    bool required = true;
    bool isMenuOpen = false;
    String value = '';
    String valueKey = '';

    TextEditingController? controller;


    DialogFieldDef({this.field_type='', this.caption='',
      this.actionText='', this.action = '',
      this.valueKey='false', this.isMenuOpen=false,
      this.options
      });

    DialogFieldDef.fromJson(Map<String, dynamic> json) {
      try {
        if (json['field_type'] != null) field_type = json['field_type'];
        if (json['caption'] != null) caption = json['caption'];
        if (json['actionText'] != null) actionText = json['actionText'];
        if (json['action'] != null) action = json['action'];

        if (json['required'] != null) required = parseBool(json['required']);

      } catch(e) {
        logit('DialogField.fromJ ${e.toString()}');
      }

    }

  }