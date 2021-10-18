import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/utilities/helper.dart';



/* from Vicki

Entries for products:

7-1=1Fxxxx         Passenger 1, flight 1.   (xxxx = unique product code)
7-3=2Fxxxx         Passenger 3, flight 2
7-1Fxxxx              Passenger 1 – no segment relation

When adding to an existing fare –
FSM                       Add product to existing fare price (without changing pricing)

If product is being sold at the same time as the E-ticket being issued, EZT*R will issue both ETKT and MPD (Product)
If product is being sold on its own, after E-tickets have already been issued, entry to issue: EMT*R


cancel msp
7X<lineno>

 */



Future saveProduct(Product product, PNR pnr, {void Function(PnrModel pntModel) onComplete, void Function(String msg) onError} ) async {
  String msg = '';
  String _error;
  msg = '*${pnr.rLOC}^';
  String pCmd = buildSaveProductCmd(product, pnr);
  if( pCmd.isEmpty){
    onComplete( null);
  }
  msg += pCmd;
  msg += '^FSM^E*R~X';

  logit(msg);
  http.Response response = await http
      .get(Uri.parse(
      "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
      .catchError((resp) {});

  if (response == null) {
/*    setState(() {
      _displayProcessingIndicator = false;
    });
    //showSnackBar(translate('Please, check your internet connection'));
    noInternetSnackBar(context);

 */
    onError('Bad response from server');
    return null;
  }

  //If there was an error return an empty list
  if (response.statusCode < 200 || response.statusCode >= 300) {
    /*
    setState(() {
      _displayProcessingIndicator = false;
    });
    noInternetSnackBar(context);

     */
    onError('No iternet, try again later');
    return null;
    // return new ParsedResponse(response.statusCode, []);
  }
  try {
  //  bool flightsConfirmed = true;
    if (response.body.contains('ERROR - ') ||
        response.body.contains('ERROR:')) {
      _error = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '')
          .replaceAll('ERROR - ', '')
          .trim(); // 'Please check your details';

      //_dataLoaded();
      print('saveProduct $_error');
      onError(_error);
      //_showDialog();
      //_gotoPreviousPage();
      return;
    } else {
      String pnrJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      Map map = json.decode(pnrJson);

      PnrModel  pnrModel = new PnrModel.fromJson(map);
      onComplete( pnrModel);
    }
  } catch(e) {
    logit(e);
  }
}
  String buildSaveProductCmd(Product product, PNR pnr) {
    String cmd = '';

    // check booking for this product
    if( pnr.mPS != null && pnr.mPS.mP != null ){
      pnr.mPS.mP.forEach((element) {
        if( element.mPID == product.productCode) {
          // check if this still wanted
          product.curProducts.forEach((p) {
            int paxNo = int.parse(p.split(':')[0]);
            int segNo = int.parse(p.split(':')[1]);

            if (int.parse(element.pax) == paxNo && int.parse(element.seg) == segNo) {

            } else {
              // remove
              if(cmd.isNotEmpty) cmd += '^';
              cmd += '7X${element.line}';
            }
          });
        }
      });
    }


    product.curProducts.forEach((element) {
      int paxNo = int.parse(element.split(':')[0]);
      int segNo = int.parse(element.split(':')[1]);

      bool alreadyAdded = false;
      if( pnr.mPS != null && pnr.mPS.mP != null ){
        pnr.mPS.mP.forEach((p) {
          if (p.mPID == product.productCode) {
            // check if already in PNR
            if (( int.parse(p.seg) == segNo ) && (int.parse(p.pax) == paxNo))
              {
                alreadyAdded = true;
              }
          }
          } );
      }

      if( alreadyAdded == false) {
      if(cmd.isNotEmpty) cmd += '^';

      if (paxNo != 0) {
        // pax related
        if (segNo != 0) {
          // pax and seg related
          // eg   7-1=1Fxxxx         Passenger 1, flight 1.   (xxxx = unique product code)
          //      7-3=2Fxxxx         Passenger 3, flight 2
          cmd += '7-${paxNo}=${segNo}F${product.productCode}';
        } else {
          // just pax related
          //  7-1Fxxxx              Passenger 1 – no segment relation
          cmd += '7-${paxNo}F${product.productCode}';
        }
      } else {
        if (segNo != 0) {
          // just seg related
          cmd += '7-1=${segNo}F${product.productCode}';
        } else {
          // neither pax or seg related
          cmd += '7-1F${product.productCode}';
        }
      }
      }
    });
    return cmd;
  }