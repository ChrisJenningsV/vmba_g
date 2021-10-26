import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
//import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vmba/data/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import '../helper.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/Products/widgets/productsWidget.dart';


class DataLoaderWidget extends StatefulWidget {
  final NewBooking newBooking;
  final PnrModel pnrModel;
  final Function(PnrModel pnrModel) onComplete;

  DataLoaderWidget(
  { Key key, this.dataType, this.newBooking, this.pnrModel, this.onComplete  }) : super( key: key);

  final LoadDataType dataType;

  DataLoaderWidgetState createState() =>
      DataLoaderWidgetState();
  }

class DataLoaderWidgetState extends State<DataLoaderWidget> {
  bool _displayProcessingIndicator;
  bool _displayFinalError;
  String _displayProcessingText;
  String _dataName;
  String _msg;
  String _url;
  String _error;

  @override void initState() {
    // TODO: implement initState
    super.initState();
    _displayProcessingIndicator = false;
    _displayFinalError = false;
    _displayProcessingText = '';
    _initData();
    _loadData();

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_displayFinalError || (_error != null && _error.isNotEmpty)) {
      return TrText(_displayProcessingText + _error,style: TextStyle(fontSize: 14.0));
    } else if (gblNoNetwork == true) {
      noInternetSnackBar(context);
      return Container();
    } else if (_displayProcessingIndicator) {
      final snackBar = SnackBar(
        content: Text(
          _displayProcessingText, style: TextStyle(color: Colors.red),),
        duration: const Duration(hours: 1),
        action: SnackBarAction(
          label: translate('OK'),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // Some code to undo the change.
          },
        ),
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
      /*
      return Scaffold(
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Image.asset('lib/assets/$gblAppTitle/images/loader.png'),
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText(_displayProcessingText),
                  ),
                ],
              ),
            ),
          ));

       */
      return TrText(_dataName);
    } else {
      switch(widget.dataType){
        case LoadDataType.cities:
          break;
        case LoadDataType.products:
          return ProductsWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel, onComplete: widget.onComplete,  );
          break;
        case LoadDataType.routes:
          break;
        case LoadDataType.settings:
          break;
        case LoadDataType.language:
          break;
      }
      return Container();
    }
  }


  _loadData() async {
    setLoadState(LoadState.loading);
    _displayProcessingIndicator = true;
    final http.Response response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: _msg);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _displayProcessingIndicator = false;
      print('message send successfully: $_msg' );
      saveData(response.body.trim());
      setLoadState(LoadState.loaded);
      setState(() {

      });
      return response.body.trim();
    } else {
      _displayFinalError = true;
      _error = response.body;
      if(response.body.startsWith('{')){
        try {
          Map m = jsonDecode(response.body);
          if(m['errors'] != null ){
            _error = m['errors'].values.toList()[0][0];
          }
        } catch(e) {
          logit(e.toString());
        }

      }
      print('failed: $_msg');
      try{
        print (response.body);
        setLoadState(LoadState.loadFailed);
        setState(() {

        });
      } catch(e){}

    }
    }

    void _initData() {

      switch(widget.dataType){
        case LoadDataType.cities:
          _dataName = 'Cities';
          break;
        case LoadDataType.products:
          _dataName = 'Travel Extras';
          _url = '${gblSettings.apiUrl}/product/getproducts';
          String currency = gblSettings.currency;
          if( currency == null || currency.isEmpty) {
            currency = widget.pnrModel.pNR.basket.outstanding.cur;
          }
          _msg = json.encode(GetProductsMsg(currency, cityCode: gblOrigin, arrivalCityCode: gblDestination ).toJson());  // , arrivalCityCode: gblDestination

          break;
        case LoadDataType.routes:
          _dataName = 'Routes';
          break;
        case LoadDataType.settings:
          _dataName = 'Settings';
          break;
        case LoadDataType.language:
          _dataName = 'language';
          break;
      }
      _displayProcessingText = '${translate('Loading')} $_dataName ...';
    }

    void setLoadState(var newState) {
      switch(widget.dataType){
        case LoadDataType.cities:
          gblCitiesState = newState;
          break;
        case LoadDataType.products:
          gblProductsState = newState;
          break;
        case LoadDataType.routes:
          gblRoutesState = newState;
          break;
        case LoadDataType.settings:
          gblSettings = newState;
          break;
        case LoadDataType.language:
          gblLanguage = newState;
          break;
      }
    }

  void saveData(String data) {
    switch(widget.dataType){
      case LoadDataType.cities:
        break;
      case LoadDataType.products:
        try {
          gblProducts = ProductCategorys.fromJson(data);
        } catch(e) {
          logit(e.toString());
        }
        break;
      case LoadDataType.routes:
        break;
      case LoadDataType.settings:
        break;
      case LoadDataType.language:
        break;
    }
  }

  }