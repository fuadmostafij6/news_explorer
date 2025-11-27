import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:news_app/core/utils/assets.dart';
import 'package:news_app/core/utils/color.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.scaffoldBgColor,
        leadingWidth: 90,
        leading: Hero(
          tag: "logo",
          child: Material(
            color: Colors.transparent,
            child: Lottie.asset(
              AppAssets.logo,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ),
        centerTitle: true,
        title: Hero(
          tag: "title",
          child: Material(
            color: Colors.transparent,
            child: Text(
              "News Explorer",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        actions: [
          PhosphorIcon(
            PhosphorIcons.magnifyingGlass(),
            color: AppColor.textColor,
          ),

          SizedBox(width: 16),
        ],
      ),
    );
  }
}
