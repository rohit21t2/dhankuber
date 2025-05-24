import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../utils/colors.dart';

class SplashScreen extends StatefulWidget {
  final Future<String> initialRouteFuture;

  const SplashScreen({super.key, required this.initialRouteFuture});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _features = [
    {'text': 'Highest FD rates from banks', 'controller': null},
    {'text': 'All RBI-licensed Banks & NBFCs', 'controller': null},
    {'text': 'FDs up to ₹5L safe (RBI DICGC)', 'controller': null},
    {'text': 'Diversify FDs across banks', 'controller': null},
    {'text': 'No bank account needed', 'controller': null},
    {'text': 'Direct deposit to bank', 'controller': null},
    {'text': 'Premature withdrawal to bank', 'controller': null},
    {'text': 'FD receipts emailed directly', 'controller': null},
    {'text': 'Open FD via UPI payment', 'controller': null},
  ];
  final List<Map<String, dynamic>> _visibleFeatures = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for each feature
    for (var feature in _features) {
      feature['controller'] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    }

    // Add features one by one with a delay
    int index = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (index < _features.length) {
        setState(() {
          _visibleFeatures.add(_features[index]);
        });
        _features[index]['controller'].forward();
        index++;
      } else {
        timer.cancel();
      }
    });

    // Navigate after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () async {
      final route = await widget.initialRouteFuture;
      Get.offAllNamed(route);
    });
  }

  @override
  void dispose() {
    for (var feature in _features) {
      feature['controller'].dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _visibleFeatures.length,
                itemBuilder: (context, index) {
                  final feature = _visibleFeatures[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feature['text'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'OpenSans',
                            fontSize: 16,
                            color: AppColors.primaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Lottie.asset(
                            'assets/lottie/tick.json',
                            controller: feature['controller'],
                            repeat: false,
                            onLoaded: (composition) {
                              feature['controller'].duration = composition.duration;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}