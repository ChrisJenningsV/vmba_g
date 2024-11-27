

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/data/models/pnr.dart';

import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/products.dart';
import '../utilities/helper.dart';

Image? getProductImage(Product product, double? width){
  try {
    String name;
    if( gblSettings.productImageMode == 'index') {
      if( product.productImageURL != '' && product.productImageURL.isNotEmpty) {
          // format ../CustomerFiles/HiSky/images/bag.png

        // get server from gblServerFiles
        if( product.productImageURL.startsWith('http')){
          name = product.productImageURL;

        } else {
          name = gblSettings.gblServerFiles.replaceAll('AppFiles/', 'Public');
          if( name.contains('/VARS' )) {
            name = name.replaceAll('AppFiles', 'Public');
          } else {
            name = name.replaceAll('AppFiles', 'VARS/Public');
          }
          name +=  product.productImageURL.replaceAll('..', '');
        }
      } else {
/*
        if (product.productImageIndex == null) {
          name = 'default';
        } else {
*/
          name = product.productImageIndex.toString();
//        }
      }
    } else {
      name = product.productCode;
    }

    Map pageMap = json.decode(gblSettings.productImageMap.toUpperCase());
    String pageImage = '';
    if( pageMap[name.toUpperCase()] != null ) {
      pageImage = pageMap[name.toUpperCase()];
  }
    if(  pageImage == '') {
      pageImage = name;
    }
    if( pageImage == '') {
      pageImage = 'blank';
    }
    if( gblLogProducts ) { logit('getProductImage: $name'); }

    if( name.contains('http')){

        return Image.network(name, width: width,
          errorBuilder: (BuildContext context,Object obj,  StackTrace? stackTrace) {
            return Text('', style: TextStyle(color: Colors.red)); // Image Error.
          });
 /*     return Image.network(name, errorBuilder: (BuildContext context, Object ex, StackTrace? st ){
        return Text('');
      },);*/
      } else {
        return Image.network(
            '${gblSettings.gblServerFiles}/productImages/$pageImage.png', width: width,
            errorBuilder: (BuildContext context,Object obj,  StackTrace? stackTrace) {
          return Text('', style: TextStyle(color: Colors.red),); // Image Error.
        });
 /*     return Image.network('${gblSettings.gblServerFiles}/productImages/$pageImage.png', errorBuilder: (BuildContext context, Object ex, StackTrace? st ){
        return Text('');
      },);
 */     }
  } catch(e) {
    logit(e.toString());
  }
  return null;
  //return Never;
}

List <String> getSeatsForFlt(int fltNo){
  List <String> list = [];

    if( gblPnrModel != null /*&& gblPnrModel!.pNR != null && gblPnrModel!.pNR.aPFAX != null && gblPnrModel!.pNR.aPFAX.aFX != null */ ) {
      gblPnrModel!.pNR.aPFAX.aFX.forEach((af) {
        if (af.aFXID == 'SEAT' && af.seg == (fltNo+1).toString()) {
            list.add(af.seat);
        }
      });
    }

  return list;
}

String getDuration(int minutes){
  String tranTime = '';
  if( /*minutes != null &&*/ minutes != 0 ) {
    int days = (minutes / (24 * 60)).floor();
    if (days > 0) {
      if( days > 1) {
        tranTime = '$days ' + translate('days') + ' ';
      } else {
        tranTime = '$days ' + translate('day') + ' ';
      }
      minutes -= days * 24 * 60;
    }
    int hours = (minutes / 60).floor();
    if (hours > 0) {
      if( hours > 1) {
        tranTime += '$hours ' + translate('hours') + ' ';
      } else {
        tranTime += '$hours ' + translate('hour') + ' ';
      }
      minutes -= hours  * 60;
    }
    if( minutes > 1) {
      tranTime += '$minutes ' + translate('mins');
    } else {
      tranTime += '$minutes ' + translate('min');
    }

  }
  return tranTime;
}

bool isThisProductSegmentFixed(PnrModel pnrModel, Product p) {
  if (p.cityCode != '' && p.cityCode.isNotEmpty) {
    return true;
  }
  if (p.cityCode != '' && p.cityCode.isNotEmpty) {
    return true;
  }
  return false;

}

bool isThisProductValid(PnrModel pnrModel, Product p, int segNo) {
  bool isValid = false;
  if( p.applyToClasses == '' || p.applyToClasses.isEmpty) {
    isValid = true;
  } else {
  //  if (pnrModel != null) {
      pnrModel.pNR.itinerary.itin.forEach((element) {
        if (p.applyToClasses.contains(element.xclass)) {
          isValid = true;
        }
      });
  //  }
  }
  // setNo =0 is initial check
  if( p.segmentRelate && segNo != 0 ) {
    if( pnrModel.pNR.itinerary.itin.length < segNo){
      return false;
    }
    if (p.cityCode != '' && p.cityCode.isNotEmpty) {
      if( pnrModel.pNR.itinerary.itin[segNo].depart != p.cityCode){
        return false;
      }
      if (p.arrivalCityCode != '' && p.arrivalCityCode.isNotEmpty) {
        if( pnrModel.pNR.itinerary.itin[segNo].arrive != p.arrivalCityCode){
          return false;
        }
      }

    } else if ( p.arrivalCityCode.isNotEmpty &&
        (p.cityCode.isNotEmpty)) {
      if( pnrModel.pNR.itinerary.itin[segNo].arrive != p.arrivalCityCode){
        return false;
      }
    }

  } else {
    // need depart city match, with or without arrival city
    if ( p.cityCode.isNotEmpty) {
      if ( p.arrivalCityCode.isNotEmpty) {
        // match just depart
        bool bfound = false;
        pnrModel.pNR.itinerary.itin.forEach((element) {
          if (element.depart == p.cityCode) {
            bfound = true;
          }
        });
        if (!bfound) {
          return false;
        }
      } else {
        // match depart and arrive
        bool bfound = false;
        pnrModel.pNR.itinerary.itin.forEach((element) {
          if (element.depart == p.cityCode &&
              element.arrive == p.arrivalCityCode) {
            bfound = true;
          }
        });
        if (!bfound) {
          return false;
        }
      }
    }
    // only arrival matches
    if ( p.arrivalCityCode.isNotEmpty &&
        ( p.cityCode.isNotEmpty)) {
      // match arrive only
      bool bfound = false;
      pnrModel.pNR.itinerary.itin.forEach((element) {
        if (element.arrive == p.arrivalCityCode) {
          bfound = true;
        }
      });
      if (!bfound) {
        return false;
      }
    }
  }
  return isValid;
}
