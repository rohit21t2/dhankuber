import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/custom_appbar.dart';

class FDBookingPage extends StatelessWidget {
  const FDBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Book FD'),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse('https://dhan-kuber.com')),
      ),
    );
  }
}