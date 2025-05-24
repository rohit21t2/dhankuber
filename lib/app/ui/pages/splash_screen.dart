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
  final List<AnimationController> _tickControllers = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Initialize 9 tick animation controllers (one for each feature)
    for (int i = 0; i < 9; i++) {
      final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
      _tickControllers.add(controller);
    }

    // Start tick animations sequentially with a delay
    for (int i = 0; i < _tickControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          _tickControllers[i].forward();
        }
      });
    }

    // Navigate after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () async {
      final route = await widget.initialRouteFuture;
      Get.offAllNamed(route);
    });
  }

  @override
  void dispose() {
    for (var controller in _tickControllers) {
      controller.dispose();
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
            Text(
              'Why Dhankuber',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildFeatureRow('Highest FD rates from banks', 0),
            _buildFeatureRow('All RBI-licensed Banks & NBFCs', 1),
            _buildFeatureRow('FDs up to ₹5L safe (RBI DICGC)', 2),
            _buildFeatureRow('Diversify FDs across banks', 3),
            _buildFeatureRow('No bank account needed', 4),
            _buildFeatureRow('Direct deposit to bank', 5),
            _buildFeatureRow('Premature withdrawal to bank', 6),
            _buildFeatureRow('FD receipts emailed directly', 7),
            _buildFeatureRow('Open FD via UPI payment', 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
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
              controller: _tickControllers[index],
              repeat: false,
              onLoaded: (composition) {
                _tickControllers[index].duration = composition.duration;
              },
            ),
          ),
        ],
      ),
    );
  }
}