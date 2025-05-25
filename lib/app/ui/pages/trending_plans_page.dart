import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/custom_appbar.dart';

class TrendingPlansPage extends StatelessWidget {
  const TrendingPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Trending FD Plans'),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse('https://dhan-kuber.com')),
      ),
    );
  }
}