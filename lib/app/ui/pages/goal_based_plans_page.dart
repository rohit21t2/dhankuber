import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/custom_appbar.dart';

class GoalBasedPlansPage extends StatelessWidget {
  const GoalBasedPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Goal-Based FD Plans'),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse('https://dhan-kuber.com')),
      ),
    );
  }
}