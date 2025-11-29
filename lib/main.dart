import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/core/di/app_providers.dart';
import 'package:news_app/core/utils/color.dart';

import 'core/route/app_route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  final newsBox = await Hive.openBox(newsCacheBoxName);

  runApp(
    ProviderScope(
      overrides: [hiveNewsBoxProvider.overrideWithValue(newsBox)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Explorer',
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
