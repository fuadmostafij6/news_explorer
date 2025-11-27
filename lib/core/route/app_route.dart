import 'package:flutter/material.dart';
import 'package:news_app/features/news/presentation/pages/news_page.dart';
import 'package:news_app/features/news/presentation/pages/splash.dart';

class AppRoute {
  AppRoute._();
  static const String splash = "/";
  static const String home = "/home";
  static String search = "/search";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const Splash(),
          settings: settings,
        );
      case home:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const NewsPage(),
          transitionDuration: const Duration(milliseconds: 1200),
          reverseTransitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
