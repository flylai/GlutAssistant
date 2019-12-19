import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Faq extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'file:///android_asset/flutter_assets/assets/faq.html',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
