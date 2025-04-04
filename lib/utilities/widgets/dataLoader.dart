import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
//import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/providers.dart';
import '../../Helpers/networkHelper.dart';
import '../../data/models/flightPrices.dart';
import '../helper.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/Products/widgets/productsWidget.dart';
import 'package:vmba/utilities/messagePages.dart';


class DataLoaderWidget extends StatefulWidget {
  NewBooking? newBooking;
  final PnrModel pnrModel;
  final Function(PnrModel pnrModel) onComplete;
  DateTime? selectedDate;

  DataLoaderWidget(
  { Key key= const Key("dload_key"), required this.dataType, this.newBooking, required this.pnrModel, required this.onComplete, this.selectedDate }) : super( key: key);

  final LoadDataType dataType;

  DataLoaderWidgetState createState() =>
      DataLoaderWidgetState();
  }

class DataLoaderWidgetState extends State<DataLoaderWidget> {
  bool _displayProcessingIndicator = false;
  bool _displayFinalError = false;
  String _displayProcessingText ='';
  String _dataName ='';
  String _msg = '';
  String _url = '';
  String _error = '';
  bool _fullLogging = false;

  @override void initState() {
    // TODO: implement initState
    super.initState();
    _displayProcessingIndicator = false;
    _displayFinalError = false;
    _fullLogging = true;
    _displayProcessingText = '';
    gblPnrModel = widget.pnrModel;
    _initData();
    _loadData();

  }


  @override
  Widget build(BuildContext context) {
    if( widget.dataType == LoadDataType.calprices){
      if( gblCalPriceState == LoadState.loaded){
        widget.onComplete(widget.pnrModel);
        gblCalPriceState = LoadState.none;
      }
      return Container(width: 10, height: 10,);
    }
    if(_fullLogging) logit('dataLoader build (${widget.dataType.toString()}) ');

    if (_displayFinalError || (_error != null && _error.isNotEmpty)) {
      return TrText(_displayProcessingText + _error,style: TextStyle(fontSize: 14.0));
    } else if (gblNoNetwork == true) {
      //noInternetSnackBar(context);
      return Container();
    } else if (_displayProcessingIndicator) {
/*
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
*/
      SchedulerBinding.instance.addPostFrameCallback((_) {
       // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
      List <Widget> list = [];

      list.add( new Transform.scale(
        scale: 0.5,
        child: CircularProgressIndicator(),
      ));
      list.add( Text(translate('Loading') + ' ' + translate(_dataName)));
      return Row(children: list,);
    } else {
      switch(widget.dataType){
        case LoadDataType.cities:
          break;
        case LoadDataType.products:
          if( widget.newBooking == null ) widget.newBooking = NewBooking();
          return ProductsWidget(newBooking: widget.newBooking!, pnrModel: widget.pnrModel, onComplete: widget.onComplete, wantTitle: true,isMMB: true, );
        case LoadDataType.providers:
          //return ProductsWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel, onComplete: widget.onComplete,  );
          widget.onComplete(widget.pnrModel);
          break;
        case LoadDataType.calprices:
        //return ProductsWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel, onComplete: widget.onComplete,  );
          widget.onComplete(widget.pnrModel);
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
        headers: widget.dataType == LoadDataType.calprices ? getApiHeadersReferer() : getApiHeaders(),
        body: _msg);
    if(_fullLogging) logit('dataLoader load data (${widget.dataType.toString()}) result ${response.statusCode}');
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _displayProcessingIndicator = false;
      logit('message send successfully 3: $_msg' );
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
      print('failed to get $_dataName: ${response.body}');
      try{
        print (response.body);
        _displayFinalError = true;
         _displayProcessingText = 'failed to get $_dataName';

         criticalErrorPage(context, 'failed to get $_dataName', title: 'Data error');
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
          if( currency == null || currency.isEmpty){
            currency = gblSelectedCurrency;
          }

          /*if(  widget.pnrModel.pNR!= null &&  widget.pnrModel.pNR.basket != null &&
              widget.pnrModel.pNR.basket.outstanding != null && widget.pnrModel.pNR.basket.outstanding.cur != null ) {
            currency = widget.pnrModel.pNR.basket.outstanding.cur;
          }*/
          gblBookingCurrency =currency;
          _msg = json.encode(GetProductsMsg(currency, currency: currency, cityCode: gblOrigin,
              arrivalCityCode: gblDestination ).toJson());  // , arrivalCityCode: gblDestination

          break;
        case LoadDataType.providers:
          _dataName = 'Providers';
          _url = '${gblSettings.apiUrl}/provider/getpaymentproviderlist';
          gblLastProviderCurrecy =gblSelectedCurrency;
          String currency = gblSelectedCurrency; // gblSettings.currency;
          if( currency == null || currency.isEmpty) {
            currency = widget.pnrModel.pNR.basket.outstanding.cur;
          }
          _msg = json.encode(GetProvidersMsg("BSIA9992AW/EB", currency).toJson());  // , arrivalCityCode: gblDestination

          break;
        case LoadDataType.calprices:
          _dataName = 'Prices';
          _url = '${gblSettings.apiUrl}/flightcalendar/GetFlightPrices';
          //gblLastProviderCurrecy =gblSelectedCurrency;
          String currency = gblSelectedCurrency; // gblSettings.currency;
          if( currency == null || currency.isEmpty) {
            currency = widget.pnrModel.pNR.basket.outstanding.cur;
          }
          DateTime startDate = DateTime(widget.selectedDate!.year,widget.selectedDate!.month, 1 );
          DateTime endDate = DateTime(widget.selectedDate!.year,widget.selectedDate!.month+1, 1 );
          
          _msg = json.encode(FlightSearchRequest(departCity: gblOrigin,arrivalCity: gblDestination, flightDateStart: DateFormat('yyyy-MM-dd').format(startDate), //'2023-11-01'
              flightDateEnd: DateFormat('yyyy-MM-dd').format(endDate),    isReturnJourney: 0,  selectedCurrency: gblSelectedCurrency,
          isADS: false, showFlightPrices: true).toJson());  // , arrivalCityCode: gblDestination

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
        case LoadDataType.providers:
          gblProductsState = newState;
          break;
        case LoadDataType.calprices:
          gblCalPriceState = newState;
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
    logit('save data type ${widget.dataType.toString()}');
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
      case LoadDataType.providers:
        try {
          gblProviders = Providers.fromJson(data);
          if(gblLogPayment) logit('loaded providers ' + data );
        } catch(e) {
          logit(e.toString());
        }
        break;
      case LoadDataType.calprices:
        try {
          gblFlightPrices = FlightPrices.fromJson(data);
          if(gblLogPayment) logit('loaded flight prices ' + data );
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


  Future<void> LoadCalendarData(BuildContext context, DateTime dt, Function() onComplete) async
  {
    if( gblSettings.wantPriceCalendar== false) {
      return ;
    }
    DateTime startDate = DateTime(dt.year,dt.month, 1 );
    DateTime endDate = DateTime(dt.year,dt.month+1, 1 );

    // do we have this month already ?
    if( gblFlightPrices != null && gblFlightPrices!.months[dt.month] == true ){
      return ;
    }

    // same route ?
    if( gblFlightPrices != null && (gblFlightPrices!.from != gblOrigin || gblFlightPrices!.to != gblDestination) ){
      // clear old cache
      gblFlightPrices = null;
    }


    try {
      gblSnackBarShowing = true;
      Timer(Duration(milliseconds: 10), () {
        showSnackBar('Loading ...', context, label: 'X', duration: Duration(seconds: 25));
      });
    } catch(e) {

    }

    String _url = '${gblSettings.apiUrl}/flightcalendar/GetFlightPrices';
  String           _msg = json.encode(FlightSearchRequest(departCity: gblOrigin,arrivalCity: gblDestination,
      flightDateStart: DateFormat('yyyy-MM-dd').format(startDate), //'2023-11-01'
      flightAvailabilityStartDate: DateFormat('yyyy-MM-dd').format(startDate), //'2023-11-01'
      flightDateEnd: DateFormat('yyyy-MM-dd').format(endDate),    isReturnJourney: 0,  selectedCurrency: gblSelectedCurrency,
      isADS: false, showFlightPrices: true).toJson());  // , arrivalCityCode: gblDestination

    logit( 'LCD $_msg');

  final http.Response response = await http.post(
        Uri.parse(_url),
      headers: getApiHeadersReferer() ,
        body: _msg);
    logit('dataLoader load data  result ${response.statusCode}');
    if (response.statusCode == 200) {
      logit('message send successfully 3: $_msg' );
      try {
        String data = response.body;

        FlightPrices fp = FlightPrices.fromJson(data);
        if( gblFlightPrices == null ) {
          gblFlightPrices = fp;
        } else {
          // add to existing
          fp.flightPrices.forEach((element) { 
            DateTime dt = DateTime.parse(element.FlightDate);
            if( dt.isAfter(startDate.add(Duration(days: -1))) && dt.isBefore(endDate.add(Duration(days: 1))) ) {
              gblFlightPrices!.flightPrices.add(element);
            }
          });
        }
        // mark this date loaded
        gblFlightPrices!.months[dt.month] = true;


        if(gblLogPayment) logit('loaded flight prices ' + data );
        onComplete();
      } catch(e) {
        logit(e.toString());
      }
      Timer(Duration(milliseconds: 500), ()
      {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    } else {
      if(response.body.startsWith('{')){
        try {
          Map m = jsonDecode(response.body);
          if(m['errors'] != null ){
          }
        } catch(e) {
          logit(e.toString());
        }
     }
      print('failed to get  ${response.body}');
      try{
        print (response.body);
      } catch(e){}
      Timer(Duration(milliseconds: 500), ()
      {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }

  }