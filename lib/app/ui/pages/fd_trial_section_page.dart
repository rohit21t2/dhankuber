import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';

class FDTrialSectionPage extends StatelessWidget {
  const FDTrialSectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'FD Trial Section'),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse('https://dhan-kuber.com')),
      ),
    );
  }
}