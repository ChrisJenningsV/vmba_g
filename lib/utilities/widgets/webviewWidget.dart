import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vmba/components/trText.dart';

class VidWebViewWidget extends StatefulWidget {
  final url;
  final title;
  final canNotClose;
VidWebViewWidget({this.url, this.title, this.canNotClose});

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<VidWebViewWidget> {
  late final WebViewController _controller;

int _stackToView = 1;
int _percentLoaded = 0;

void _handleLoad() {
  setState(() {
    _stackToView = 0;
  });
}
@override
  void initState() {

 _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('WebView is loading (progress : $progress%)');
          setState(() {
            _percentLoaded = progress;
          });
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
            _handleLoad();
          debugPrint('Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');

        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            debugPrint('blocking navigation to ${request.url}');
            return NavigationDecision.prevent;
          }
          debugPrint('allowing navigation to ${request.url}');
          return NavigationDecision.navigate;
        },
        onUrlChange: (UrlChange change) {
          debugPrint('url change to ${change.url}');
        },
      ),
    )
    ..loadRequest(Uri.parse(widget.url.toString().trim()));  //

    super.initState();
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: TrText(widget.title),
        backgroundColor: gblSystemColors.primaryHeaderColor,
        automaticallyImplyLeading: false,
       
        actions: (widget.canNotClose != null) ? <Widget>[Text(' ')] :  <Widget>[
          IconButton(icon: Icon(Icons.close
          ),
          onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body:/*       WebViewWidget(
    controller: _controller,),
*/
      Builder(builder: (BuildContext context) {
        return IndexedStack(
          index: _stackToView,
          children: <Widget>[
            WebViewWidget(
              controller: _controller,

/*initialUrl: widget.url,
              //javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },*//*

              
            
 */
/*              navigationDelegate: (NavigationRequest request) {
                 if ( gblSettings.blockedUrls != null && gblSettings.blockedUrls.contains( request.url)) {
                   print('blocking navigation to $request}');
                   return NavigationDecision.prevent;
                 }
                 print('allowing navigation to $request');
                 return NavigationDecision.navigate;
               },
              onPageFinished: (String url) {
                _handleLoad();
                print('Page finished loading: $url');
              },*/

            ),

            new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               CircularProgressIndicator(),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Text(translate('Loading') + ' '  + translate('${widget.title} ' + '${_percentLoaded}%')),
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

