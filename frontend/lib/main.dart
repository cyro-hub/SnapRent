// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap_rent/providers/auth_provider.dart';

// import 'screens/main_navigation.dart';
// import 'screens/onboarding_screen.dart';
// import 'core/themes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

//   // Force dark icons globally
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarIconBrightness: Brightness.dark, // Android icons
//       statusBarBrightness: Brightness.dark, // // background color of nav bar
//       systemNavigationBarIconBrightness: Brightness.dark, // Android nav icons
//       systemNavigationBarDividerColor: Colors.white,
//     ),
//   );

//   final prefs = await SharedPreferences.getInstance();
//   final seen = prefs.getBool('seenOnboarding') ?? false;

//   runApp(
//     ProviderScope(
//       overrides: [onboardingSeenProvider.overrideWithValue(seen)],
//       child: const MyApp(),
//     ),
//   );
// }

// final onboardingSeenProvider = Provider<bool>((ref) => false);

// class MyApp extends ConsumerStatefulWidget {
//   const MyApp({super.key});

//   @override
//   ConsumerState<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends ConsumerState<MyApp> {
//   Timer? _refreshTimer;
//   bool _isRefreshing = false;

//   @override
//   void initState() {
//     super.initState();
//     _startRefreshTimer();
//   }

//   void _startRefreshTimer() {
//     _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
//       if (_isRefreshing) return;
//       _isRefreshing = true;

//       try {
//         await ref.read(authProvider.notifier).refreshIfNeeded();
//       } catch (e) {
//         debugPrint('Error refreshing token: $e');
//       } finally {
//         _isRefreshing = false;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final seenOnboarding = ref.watch(onboardingSeenProvider);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'SnapRent',
//       theme: lightTheme,
//       home: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent, // top status bar
//           statusBarIconBrightness: Brightness.dark, // icons on top bar
//           systemNavigationBarColor: Colors.transparent, // bottom nav bar
//           systemNavigationBarIconBrightness: Brightness.dark, // icons on bottom
//           systemNavigationBarDividerColor: Colors.transparent,
//         ),
//         child: Scaffold(
//           // backgroundColor: Colors.transparent, // matches top and bottom bars
//           body: seenOnboarding
//               ? const MainNavigation()
//               : const OnboardingScreen(),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_rent/providers/auth_provider.dart';
import 'screens/main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'core/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow content behind system bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Force dark icons globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    ProviderScope(
      overrides: [onboardingSeenProvider.overrideWithValue(seen)],
      child: const MyApp(),
    ),
  );
}

final onboardingSeenProvider = Provider<bool>((ref) => false);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (_isRefreshing) return;
      _isRefreshing = true;

      try {
        await ref.read(authProvider.notifier).refreshIfNeeded();
      } catch (e) {
        debugPrint('Error refreshing token: $e');
      } finally {
        _isRefreshing = false;
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seenOnboarding = ref.watch(onboardingSeenProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapRent',
      theme: lightTheme,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          extendBody: true, // allows content to go behind bottom nav bar
          extendBodyBehindAppBar: true, // allows content behind status bar
          backgroundColor: Colors.transparent,
          body: seenOnboarding
              ? const MainNavigation()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}
