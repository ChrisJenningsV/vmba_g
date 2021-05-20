import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vmba/components/trText.dart';

class WebViewWidget extends StatefulWidget {
  final url;
  final title;
WebViewWidget({this.url, this.title});

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();


num _stackToView = 1;

void _handleLoad() {
  setState(() {
    _stackToView = 0;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TrText(widget.title),
        automaticallyImplyLeading: false,
       
        actions: <Widget>[
          IconButton(icon: Icon(Icons.close
          ),
          onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return IndexedStack(
          index: _stackToView,
          children: <Widget>[
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              
            
              // navigationDelegate: (NavigationRequest request) {
              //   if (request.url.startsWith('https://www.youtube.com/')) {
              //     print('blocking navigation to $request}');
              //     return NavigationDecision.prevent;
              //   }
              //   print('allowing navigation to $request');
              //   return NavigationDecision.navigate;
              // },
              onPageFinished: (String url) {
                _handleLoad();
                print('Page finished loading: $url');
              },
            ),

            new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               CircularProgressIndicator(),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Text('Loading ${widget.title}'),
              ),
            ],
          ),
        ),
          ],
        );
      }),
    //  floatingActionButton: favoriteButton(),
    );
  }
}

