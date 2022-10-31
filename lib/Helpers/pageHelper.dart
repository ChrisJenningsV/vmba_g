
import 'package:flutter/material.dart';

void reloadPage(BuildContext context) {
  (context as Element).reassemble();
}