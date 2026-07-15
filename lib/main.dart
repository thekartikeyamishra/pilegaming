import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/purchases.dart';
import 'services/store.dart';
import 'services/toolbox.dart';
import 'theme.dart';

import 'services/gamification_engine.dart';
import 'services/review_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PileStore.instance.init();

  GamificationEngine.instance.init();
  ReviewService.instance.init();

  Purchases.init();
  Notify.rescheduleAll();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const PileApp());
}

class PileApp extends StatelessWidget {
  const PileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pile',
      debugShowCheckedModeBanner: false,
      theme: pileTheme(),
      home: PileStore.instance.onboarded
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
