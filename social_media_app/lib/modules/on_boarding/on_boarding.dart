import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:social_media_app/modules/main_page/main_page.dart';
import 'package:social_media_app/shared/cache_helper.dart';
import 'package:social_media_app/shared/constants.dart';
import 'page.dart';

class OnBoarding extends StatelessWidget {
  OnBoarding({Key? key}) : super(key: key);

  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size.height * .7,
            child: PageView(
              physics: const BouncingScrollPhysics(),
              controller: controller,
              onPageChanged: (index) {},
              children: [
                MyPageView(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: size.height * 0.4,
                          width: double.infinity,
                          child: Image.asset(
                            'lib/assets/images/community.png',
                          ),
                        ),
                        const Text(
                          'Make Your Community',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                MyPageView(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: size.height * 0.4,
                          width: double.infinity,
                          child: Image.asset(
                            'lib/assets/images/communication.png',
                          ),
                        ),
                        const Text(
                          'Communicate With Your Friends',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                MyPageView(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: size.height * 0.4,
                          width: double.infinity,
                          child: Image.asset(
                            'lib/assets/images/social-network.png',
                          ),
                        ),
                        const Text(
                          'Communicate With People Arround The World',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 20,
            ),
            child: ElevatedButton(
              onPressed: () {
                CacheHelper.saveData(key: 'isOnboarding', value: true);
                navigateAndFinish(context, const MainPage());
                // navigateTo(context, LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                // primary: Colors.deepPurple,
                shadowColor: Colors.deepPurple,
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.skip_next_rounded,
                      size: 30,
                    ),
                    Text(
                      "SKIP",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),
          SmoothPageIndicator(
            controller: controller,
            count: 3,
            effect: JumpingDotEffect(
              activeDotColor: mainColor,
              dotColor: mainColor.shade100,
              dotHeight: 30,
              dotWidth: 30,
              spacing: 16,
              verticalOffset: 10,
              // jumpScale: 2,
            ),
          ),
        ],
      ),
    );
  }
}
