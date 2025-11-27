import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:news_app/core/route/app_route.dart';
import 'package:news_app/core/utils/assets.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    // Pause animation at the end for smooth Hero transition
    _controller.stop();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoute.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: Size(0, 0),
      //   child: AppBar(
      //     systemOverlayStyle: SystemUiOverlayStyle(
      //       // Status bar color
      //
      //
      //       // Status bar brightness (optional)
      //       statusBarIconBrightness:
      //           Brightness.light, // For Android (dark icons)
      //       statusBarBrightness: Brightness.dark, // For iOS (dark icons)
      //     ),
      //     backgroundColor: AppColor.scaffoldBgColor,
      //   ),
      // ),
      body: Center(
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Hero(
              tag: "logo",
              createRectTween: (begin, end) {
                return Tween<Rect>(begin: begin, end: end);
              },
              child: Material(
                color: Colors.transparent,
                child: Lottie.asset(
                  AppAssets.logo,
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward().then((_) {
                        _navigateToHome();
                      });
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 35,
              child: Hero(
                tag: "title",
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    "News Explorer",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),

            // SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
