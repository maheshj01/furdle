import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  static const String routeName = '/privacy';

  final String title;
  final String url;

  const WebViewPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _NewPageState();
}

class _NewPageState extends State<WebViewPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController();

    if (!kIsWeb) {
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }

    controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.title),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
