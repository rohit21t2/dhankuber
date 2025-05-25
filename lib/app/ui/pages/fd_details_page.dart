import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/custom_appbar.dart';

class FDDetailsPage extends StatelessWidget {
  const FDDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'FD Details'),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse('https://dhan-kuber.com')),
      ),
    );
  }
}