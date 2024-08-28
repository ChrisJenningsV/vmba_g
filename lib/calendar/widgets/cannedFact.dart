import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:vmba/components/trText.dart';

import '../../utilities/messagePages.dart';

class CannedFactWidget extends StatelessWidget {
   List<Flt>? flt;
  CannedFactWidget({this.flt});

  @override
  Widget build(BuildContext context) {
    if (flt?.first.fltdet.canfac != null && flt?.first.fltdet.canfac?.fac != '') {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return msgDialog(context, translate('Additional Info'),
                        additionalInfoWidget(flt! ));

/*
                      return AlertDialog(
                          actions: <Widget>[
                            new TextButton(
                              child: new TrText("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                          title: new TrText('Additional Info'),
                          content: SingleChildScrollView(
                            child: Wrap(
                              children: additionalInfoWidget(
                                  flt.first.fltdet.canfac.fac.trim()),
                            ),
                          ));
*/
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: <Widget>[
                      TrText("Additional Info",
                          style: new TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w300)),
                      Icon(Icons.expand_more)
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider()
        ],
      );
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  Widget additionalInfoWidget(List<Flt> flts) {

    String text = '';
    flts.forEach((flt) {
      if(flt.fltdet.canfac != null && flt.fltdet.canfac?.fac != null){
/*
        if(text.length > 0) {
          text += '\n\n';
        }
*/
        List<String> strs =flt.fltdet.canfac!.fac.trim().split('\n');
        strs.forEach((element) {
          text += element.trim() + '\n\n';
        });
      }
    });
    if(text.endsWith('\n\n')){
      text = text.substring(0, text.length-2);
    }
    //flt?.first.fltdet.canfac?.fac.trim())


    if (text.contains('<')) {
        Widget w = Container(
          height: 200,
          width: 300,
          child: SingleChildScrollView(
          child: Html(
            data: text,
            //tagsList: Html.tags..addAll(["bird", "flutter"]),
            style: {
              "table": Style(
                backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
              ),
              "tr": Style(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              "th": Style(
               // padding: EdgeInsets.all(6),
                backgroundColor: Colors.grey,
              ),
              "td": Style(
               // padding: EdgeInsets.all(6),
                alignment: Alignment.topLeft,
              ),
              'h5': Style(maxLines: 2, textOverflow: TextOverflow.ellipsis),
            },
            /*customRender: {
              "table": (context, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:
                  (context.tree as TableLayoutElement).toWidget(context),
                );
              },
              "bird": (RenderContext context, Widget child) {
                return TextSpan(text: "🐦");
              },
              "flutter": (RenderContext context, Widget child) {
                return FlutterLogo(
                  style: (context.tree.element!.attributes['horizontal'] != null)
                      ? FlutterLogoStyle.horizontal
                      : FlutterLogoStyle.markOnly,
                  textColor: context.style.color!,
                  size: context.style.fontSize!.size! * 5,
                );
              },
            },
            customImageRenders: {
              networkSourceMatcher(domains: ["flutter.dev"]):
                  (context, attributes, element) {
                return FlutterLogo(size: 36);
              },
              networkSourceMatcher(domains: ["mydomain.com"]):
              networkImageRender(
                headers: {"Custom-Header": "some-value"},
                altWidget: (alt) => Text(alt ?? ""),
                loadingWidget: () => Text("Loading..."),
              ),
              // On relative paths starting with /wiki, prefix with a base url
                  (attr, _) =>
              attr["src"] != null && attr["src"]!.startsWith("/wiki"):
              networkImageRender(
                  mapUrl: (url) => "https://upload.wikimedia.org" + url!),
              // Custom placeholder image for broken links
              networkSourceMatcher():
              networkImageRender(altWidget: (_) => FlutterLogo()),
            },*/
           /* onLinkTap: (url, _, __, ___) {
              print("Opening $url...");
            },
            onImageTap: (src, _, __, ___) {
              print(src);
            },
            onImageError: (exception, stackTrace) {
              print(exception);
            },*/
            onCssParseError: (css, messages) {
              print("css that errored: $css");
              print("error messages:");
              messages.forEach((element) {
                print(element);
              });
              return '';
            },
          ),
        ));

        return w;
    } else {
      return Padding( padding: EdgeInsets.all(10),
          child: Text(text)
      );
    }
  }
}
