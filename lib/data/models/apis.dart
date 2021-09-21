//import 'dart:convert';

import 'package:vmba/utilities/helper.dart';

class ApisModel {
  Apis apis;

  ApisModel({this.apis});

  ApisModel.fromJson(Map<String, dynamic> json) {
    apis = json['apis'] != null ? new Apis.fromJson(json['apis']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.apis != null) {
      data['apis'] = this.apis.toJson();
    }
    return data;
  }

  String toXmlString() {
    StringBuffer sb = new StringBuffer();
    try {
      sb.write(
          "<apis required=\"${this.apis.required}\" platform=\"${this.apis.platform}\" agentcity=\"${this.apis.agentcity}\" fieldSize=\"\" orientation=\"\" validation_noicons=\"\" apisformat=\"${this.apis.apisformat}\">");
      sb.write("<sections>");
      this.apis.sections.section.forEach((section) {
        sb.write(
            "<section sectionname=\"${section.sectionname}\" required=\"${section.required}\" displayable=\"${section.displayable}\">");
        sb.write("<fields>");
        section.fields.field.forEach((field) {
          sb.write(
              "<field id=\"${field.id}\" required=\"${field.required}\" displayname=\"${field.displayname}\" fieldtype=\"${field.fieldtype}\" displayable=\"${field.displayable}\" editable=\"${field.editable}\" length=\"${field.length}\" value=\"${field.value}\">");
          if (field.fieldtype == 'Choice' && field.choices != null) {
            sb.write("<choices>");
            field.choices.choice.forEach((choice) {
              sb.write(
                  "<choice value=\"${choice.value}\" description=\"${choice.description}\" ");
              if (choice.passportexpiry != null) {
                sb.write("passportexpiry=\"${choice.passportexpiry}\" ");
              }
              if (choice.docissuingcountry != null) {
                sb.write("docissuingcountry=\"${choice.docissuingcountry}\" ");
              }
              sb.write("/>");
            });
            sb.write("</choices>");
          } else {
            sb.write("<choices />");
          }
          sb.write("</field>");
        });
        sb.write("</fields>");
        sb.write("</section>");
      });

      sb.write("</sections>");
      sb.write("</apis>");
    } catch (e) {
      print(e);
    }

    return sb.toString();
  }
}

class Apis {
  String required;
  String platform;
  String agentcity;
  String apisformat;
  Sections sections;

  Apis(
      {this.required,
      this.platform,
      this.agentcity,
      this.apisformat,
      this.sections});

  Apis.fromJson(Map<String, dynamic> json) {
    required = json['required'];
    platform = json['platform'];
    agentcity = json['agentcity'];
    apisformat = json['apisformat'];
    sections = json['sections'] != null
        ? new Sections.fromJson(json['sections'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['required'] = this.required;
    data['platform'] = this.platform;
    data['agentcity'] = this.agentcity;
    data['apisformat'] = this.apisformat;
    if (this.sections != null) {
      data['sections'] = this.sections.toJson();
    }
    return data;
  }
}

class Sections {
  List<Section> section;

  Sections(this.section);

  Sections.fromJson(Map<String, dynamic> json) {
    if (json['section'] != null) {
      section = [];
      //new List<Section>();
      json['section'].forEach((v) {
        section.add(new Section.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.section != null) {
      data['section'] = this.section.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Section {
  String sectionname;
  String required;
  String displayable;
  Fields fields;

  Section({this.sectionname, this.required, this.displayable, this.fields});

  Section.fromJson(Map<String, dynamic> json) {
    sectionname = json['sectionname'];
    required = json['required'];
    displayable = json['displayable'];
    fields =
        //json['fields'] != null ? new Field.fromJson(json['fields']) : null;
        json['fields'] != null ? new Fields.fromJson(json['fields']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sectionname'] = this.sectionname;
    data['displayable'] = this.displayable;
    data['required'] = this.required;

    if (this.fields != null) {
      data['fields'] = this.fields.toJson();
    }
    return data;
  }
}

class Fields {
  List<Field> field;

  Fields({this.field});

  Fields.fromJson(Map<String, dynamic> json) {
    try {
    if (json['field'] != null) {
      field = [];
      // new List<Field>();
      if (json['field'] is List) {
        json['field'].forEach((v) {

          Field f = new Field.fromJson(v);
//          logit('Adding field ${f.displayname}');
          field.add(f);
  //        logit('Added field ${f.displayname}');
        });
      } else {
        field.add(new Field.fromJson(json['field']));
        print('not a list');
      }
    }
    } catch(e) {
      logit(e.toString());
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.field != null) {
      data['field'] = this.field.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Field {
  String required;
  String id;
  String displayname;
  String fieldtype;
  String length;
  String displayable;
  String editable;
  String value;
  Choices choices;

  Field(
      {this.required,
      this.id,
      this.displayname,
      this.fieldtype,
      this.length,
      this.displayable,
      this.editable,
      this.value,
      this.choices});

  Field.fromJson(Map<String, dynamic> json) {
    required = json['required'] != null ? json['required'] : null;
    id = json['id'] != null ? json['id'] : null;
    displayname = json['displayname'] != null ? json['displayname'] : null;
    fieldtype = json['fieldtype'] != null ? json['fieldtype'] : null;
    length = json['length'] != null ? json['length'] : null;
    displayable = json['displayable'] != null ? json['displayable'] : null;
    editable = json['editable'] != null ? json['editable'] : null;
    value = json['value'] != null ? json['value'] : null;
    choices = _getChoices(json['choices']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['required'] = this.required;
    data['id'] = this.id;
    data['displayname'] = this.displayname;
    data['fieldtype'] = this.fieldtype;
    data['length'] = this.length;
    data['displayable'] = this.displayable;
    data['editable'] = this.editable;
    data['value'] = this.value;
    if (this.choices != null) {
      data['choices'] = this.choices.toJson();
    }
    return data;
  }
}

Choices _getChoices(Map<String, dynamic> json  ) {
  Choices choices;
  if( json == null) return null;

  choices = Choices.fromJson(json);

  return choices;
}


class Choices {
  List<Choice> choice;

  Choices({this.choice});

  Choices.fromJson(Map<String, dynamic> json) {

    try {
      if (json['choice'] != null) {
        String asStr = json.toString();
        bool isArray = asStr.contains('choice: [');

        choice = [];
    //    choice.add( new Choice(value: 't',description: 'first'  ));

//        Type ty = json['choice'].runtimeType;
        // check if single only one entry!
        if ( isArray == false ) { //ty.toString() != 'List<dynamic>') {
          try {
            choice.add(new Choice.fromJson(json['choice']));
          } catch (e) {
            choice.add( new Choice(value: 'e',description: 'e1:' + e.toString()  ));
            logit(e.toString());
          }
        } else {
          json['choice'].forEach((v) {
            try {
              choice.add(new Choice.fromJson(v));
            } catch (e) {
              choice.add( new Choice(value: 'e',description: 'e2:' + e.toString()  ));
              logit(e.toString());
            }
          });
        }
      }
    } catch(e) {
      logit(e.toString());
      choice.add( new Choice(value: 'e',description: 'e3:' + e.toString()  ));

    }
  //  choice.add( new Choice(value: 'e',description: 'end'));

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.choice != null) {
      data['choice'] = this.choice.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Choice {
  String value;
  String description;
  String docissuingcountry;
  String passportexpiry;

  Choice(
      {this.value,
      this.description,
      this.docissuingcountry,
      this.passportexpiry});

  Choice.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    description = json['description'];
    if(  json['docissuingcountry'] != null ) {
      docissuingcountry = json['docissuingcountry'];
    }
    if( json['passportexpiry'] != null ) {
      passportexpiry = json['passportexpiry'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[value] = this.value;
    data[description] = this.description;
    data[docissuingcountry] = this.docissuingcountry;
    data[passportexpiry] = this.passportexpiry;
    return data;
  }
}
