import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/route/app_route.dart';
import 'package:news_app/core/utils/assets.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 2), () {
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
                child: Image.asset(
                  AppAssets.logo,
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
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
