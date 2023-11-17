import 'dart:convert';

import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';

import '../../calendar/bookingFunctions.dart';
import '../../data/globals.dart';



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



Future saveProduct(Product product, PNR pnr, {void Function(PnrModel pntModel, dynamic p)? onComplete, void Function(String msg)? onError} ) async {
  if( gblLogProducts) logit('save product');
  String msg = '';
  String _error = '';
  msg = '*${pnr.rLOC}^';
  String pCmd = buildSaveProductCmd(product, pnr);
  if( pCmd.isEmpty){
    onComplete!( PnrModel(), product);
    return;
  }
  msg += pCmd;
  msg += '^FSM^E*R~X';

  logit(msg);
  String data = await runVrsCommand(msg);

  try {
  //  bool flightsConfirmed = true;
    if (data.contains('ERROR - ') ||
        data.contains('ERROR:')) {
      _error = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '')
          .replaceAll('ERROR - ', '')
          .trim(); // 'Please check your details';

      //_dataLoaded();
      print('saveProduct $_error');
      onError!(_error);
      //_showDialog();
      //_gotoPreviousPage();
      return;
    } else {

      String pnrJson = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      print(pnrJson);
      Map<String, dynamic> map = json.decode(pnrJson);

      PnrModel  pnrModel = new PnrModel.fromJson(map);
      if( pnrModel.pNR != null ) {
        pnrModel.pNR.dumpProducts('after *r');
        gblPnrModel = pnrModel;
        refreshStatusBar();
        refreshMmbBooking();
      }
      onComplete!( pnrModel, product);
    }
  } catch(e) {
    logit(e.toString());
  }
}
  String buildSaveProductCmd(Product product, PNR pnr) {
    String cmd = '';
    int noFound = 0;
    // check booking for this product
    if( pnr.mPS != null && pnr.mPS.mP != null ){
      //pnr.mPS.mP.forEach((element) {
      // loop in reverse order, so multi deletes work
      if( gblLogProducts) logit('delete unwanted products');
      for( int i=pnr.mPS.mP.length-1; i >= 0 ; i--) {
        if( gblLogProducts ) { logit('i=$i');}
         MP element = pnr.mPS.mP[i];
        if( element.mPID == product.productCode) {
          // check if this still wanted
          if( product.curProducts == null || product.curProducts!.length == 0 ){
            // remove
            if( gblLogProducts) logit('remove 1 ${element.text }');
            if (cmd.isNotEmpty) cmd += '^';
            cmd += '7X${element.line}';

          } else {
            //bool found = false;

            noFound = 0;
            product.curProducts!.forEach((p) {
              int paxNo = int.parse(p.key.split(':')[0]);
              int segNo = int.parse(p.key.split(':')[1]);

              if (int.parse(element.pax) == paxNo &&
                  int.parse(element.seg) == segNo) {
                  //found = true;
                if(p.count >  noFound) {
                  noFound += 1;
                } else {
                  //remove it
                  if (cmd.isNotEmpty) cmd += '^';
                  if( gblLogProducts) logit('remove ${element.text }');
                  cmd += '7X${element.line}';
                }
/*
              } else {
                // remove

*/
              }
            });
            if( noFound == 0 ){
              if (cmd.isNotEmpty) cmd += '^';
              if( gblLogProducts) logit('remove ${element.text }');
              cmd += '7X${element.line}';
            }
          }
        }
      }
    }

    List<int> nlist =[];
    product.curProducts!.forEach((element) {
      int paxNo = int.parse(element.key.split(':')[0]);
      int segNo = int.parse(element.key.split(':')[1]);
//      int count = element.count;
      noFound = 0;
      bool alreadyAdded = false;
      if( pnr.mPS != null && pnr.mPS.mP != null ){
        pnr.mPS.mP.forEach((p) {
         // if( gblLogProducts) logit('check ${p.mPID} v ${product.productCode}');
          if (p.mPID == product.productCode) {
            // check if already in PNR
            if (( int.parse(p.seg) == segNo ) && (int.parse(p.pax) == paxNo))
              {
                //alreadyAdded = true;
                noFound +=1;
              }
          }
          } );
      }


      if(noFound < element.count)
      {
        while (noFound < element.count) {
          if (cmd.isNotEmpty) cmd += '^';

          if (paxNo != 0) {
            // pax related
            if (segNo != 0) {
              // pax and seg related
              // eg   7-1=1Fxxxx         Passenger 1, flight 1.   (xxxx = unique product code)
              //      7-3=2Fxxxx         Passenger 3, flight 2
              cmd += '7-$paxNo=${segNo}F${product.productCode}';
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
          noFound += 1;
        }
      }
      else  if (noFound > element.count){
        while (noFound > element.count){

          for( int i=pnr.mPS.mP.length-1; i >= 0 ; i--) {
            MP mp = pnr.mPS.mP[i];
            //seg and pax related product
            if((noFound > element.count) &&  mp.mPID == product.productCode && int.parse(mp.pax) == paxNo && int.parse(mp.seg) == segNo) {
               nlist.add(int.parse(mp.line));
              noFound -= 1;
            }
          }
        }
      }
    });

    // sort lines to delete into desc order to prevent errors
    if( nlist.length > 0) {
      nlist.sort((b, a) => a.compareTo(b));
      nlist.forEach((element) {
        if (cmd.isNotEmpty) cmd += '^';
        if (gblLogProducts) logit('remove ${element }');
        cmd += '7X${element}';
      });

    }
    if( gblLogProducts) logit('sent $cmd');
    return cmd;
  }