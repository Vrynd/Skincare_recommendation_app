import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/features/account/screens/account_screen.dart';
import 'package:recommendation_app/features/history/presentation/screens/history_screen.dart';
import 'package:recommendation_app/features/home/screens/home_screen.dart';
import 'package:recommendation_app/features/navigations/provider/navigation_provider.dart';
import 'package:recommendation_app/features/navigations/widgets/floating_dock.dart';
import 'package:recommendation_app/features/navigations/widgets/add_dock.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    final List<Widget> screens = [
      const HomeScreen(),
      const HistoryScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: navProvider.currentIndex, children: screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: const [FloatingDock(), AddDock()],
            ),
          ),
        ],
      ),
    );
  }
}
