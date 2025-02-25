import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  final bool kDebugMode = true;

  const CustomError({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // debugDumpRenderTree();
    String serror = '';
    serror = kDebugMode
        ? errorDetails.summary.toString()
        : 'Oops! Something went wrong!';

    if( kDebugMode) {
      serror += '\n';
      if (errorDetails.stack != null) {
        serror += errorDetails.stack.toString();
      }
    }
    if( serror.length > 300 ) serror = serror.substring(0,300);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
/*
            Image.asset(
                'assets/images/error_illustration.png'),
*/
            Text(serror,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.red ,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              kDebugMode
                  ? 'https://docs.flutter.dev/testing/errors'
                  : "We encountered an error and we've notified our engineering team about it. Sorry for the inconvenience caused.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}