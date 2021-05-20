import 'package:flutter/material.dart';

Widget snackbar(String message) => SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'X',
      onPressed: () {},
    ));
