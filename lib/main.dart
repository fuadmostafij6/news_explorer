import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/utils/color.dart';

import 'core/route/app_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.scaffoldBgColor,
        textTheme: TextTheme(
          displayLarge: TextStyle(color: AppColor.textColor),
          displayMedium: TextStyle(color: AppColor.textColor),
          displaySmall: TextStyle(color: AppColor.textColor),
          titleLarge: TextStyle(color: AppColor.textColor),
          titleMedium: TextStyle(color: AppColor.textColor),
          titleSmall: TextStyle(color: AppColor.textDimColor),
          headlineLarge: TextStyle(color: AppColor.textColor),
          headlineMedium: TextStyle(color: AppColor.textColor),
          headlineSmall: TextStyle(color: AppColor.textColor),
          labelLarge: TextStyle(color: AppColor.textColor),
          labelMedium: TextStyle(color: AppColor.textColor),
          labelSmall: TextStyle(color: AppColor.textColor),
          bodyLarge: TextStyle(color: AppColor.textColor),
          bodyMedium: TextStyle(color: AppColor.textColor),
          bodySmall: TextStyle(color: AppColor.textColor),
        ),
      ),

      onGenerateRoute: AppRoute.generateRoute,
      initialRoute: AppRoute.splash,
    );
  }
}
