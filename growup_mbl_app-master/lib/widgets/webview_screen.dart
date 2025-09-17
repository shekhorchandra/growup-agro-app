import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTabPage extends StatefulWidget {
  const WebTabPage({Key? key}) : super(key: key);

  @override
  State<WebTabPage> createState() => _WebTabPageState();
}

class _WebTabPageState extends State<WebTabPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://admin-growup.onebitstore.site/'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false, // Optional: keeps the bottom edge flush if needed
      child: WebViewWidget(controller: _controller),
    );
  }
}
