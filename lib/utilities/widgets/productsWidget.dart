import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;



class ProductsWidget extends StatefulWidget {

  ProductsWidget(
      { Key key,  }) : super( key: key);

  //final LoadDataType dataType;

  ProductsWidgetState createState() =>
      ProductsWidgetState();
}

class ProductsWidgetState extends State<ProductsWidget> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text('Procucts Widget', style: new TextStyle(fontSize: 26),);
  }

}