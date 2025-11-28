import 'package:faker/faker.dart' as f;
import 'package:figma_squircle/figma_squircle.dart';
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
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, index) => Container(
                width: double.infinity,
                height: 100,
                decoration: ShapeDecoration(
                  color: AppColor.scaffoldDimBgColor,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Column(
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            f.faker.lorem.sentences(2).join(" "),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "${f.faker.date.month()} 10 ${f.faker.date.year()}",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),

                    // 🔥 This makes the image match container height
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: Image.network(
                          f.faker.image.loremPicsum(),
                          fit: BoxFit.cover,
                          height: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: 16),
            ),
          ),
        ],
      ),
    );
  }
}
