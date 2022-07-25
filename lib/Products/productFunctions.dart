

import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/globals.dart';
import '../data/models/products.dart';
import '../utilities/helper.dart';

NetworkImage getBagImage(Product product){
  try {
    String name;
    if( gblSettings.productImageMode == 'index') {
      if( product.productImageURL != null && product.productImageURL.isNotEmpty) {
          // format ../CustomerFiles/HiSky/images/bag.png

        // get server from gblServerFiles
        name = gblSettings.gblServerFiles.replaceAll('AppFiles/', 'Public') + product.productImageURL.replaceAll('..', '');
      } else {
        if (product.productImageIndex == null) {
          name = 'default';
        } else {
          name = product.productImageIndex.toString();
        }
      }
    } else {
      name = product.productCode;
    }

    Map pageMap = json.decode(gblSettings.productImageMap.toUpperCase());
    String pageImage = pageMap[name.toUpperCase()];
    if( pageImage == null || pageImage.isEmpty) {
      pageImage = name;
    }
    if( pageImage == null) {
      pageImage = 'blank';
    }
      if( name.contains('http')){
        return NetworkImage(name);
      } else {
        return NetworkImage(
            '${gblSettings.gblServerFiles}/productImages/$pageImage.png');
      }
  } catch(e) {
    logit(e);
  }
  return null;
}
