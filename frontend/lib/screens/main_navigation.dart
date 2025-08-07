import 'package:flutter/material.dart';
import '../components/custom_bottom_nav_bar.dart';
import 'tab_screens/home_screen.dart';
import 'tab_screens/explore_screen.dart';
import 'tab_screens/my_access_screen.dart';
import 'tab_screens/settings_screen.dart';
import 'tab_screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    MyAccessScreen(),
    const ProfileScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_currentIndex]
            .currentState!
            .maybePop();

        // If not on the first route, pop that route
        if (!isFirstRouteInCurrentTab) return false;

        // If on the first route and not on the first tab, go back to first tab
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }

        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(_screens.length, (index) {
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(builder: (_) => _screens[index]);
              },
            );
          }),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) {
              // Pop to root if same tab
              _navigatorKeys[index].currentState!.popUntil(
                (route) => route.isFirst,
              );
            } else {
              // Pop current tab stack to root before switching tab
              _navigatorKeys[_currentIndex].currentState!.popUntil(
                (route) => route.isFirst,
              );
              setState(() => _currentIndex = index);
            }
          },
        ),
      ),
    );
  }
}
