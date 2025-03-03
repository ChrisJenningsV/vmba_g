
import 'package:flutter/material.dart';

import '../data/globals.dart';

class ImageManager{
  static DecorationImage getNetworkImage(String url, {double? opacity}){
    return DecorationImage(
      opacity: 0.7,
      image: NetworkImage(url),
      fit: BoxFit.cover,
    );
  }
}