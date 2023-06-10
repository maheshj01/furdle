import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
  const WebViewPage({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  State<WebViewPage> createState() => _NewPageState();
}

class _NewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: WebView(
          initialUrl: widget.url,
        ));
  }
}
