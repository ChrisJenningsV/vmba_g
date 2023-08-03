import 'package:flutter/material.dart';

SnackBar snackbar(String message) => SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'X',
      onPressed: () {},
    ));
