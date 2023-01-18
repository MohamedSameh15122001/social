import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/modules/main_page/main_page.dart';
import 'package:social_media_app/modules/on_boarding/on_boarding.dart';
import 'package:social_media_app/shared/cache_helper.dart';
import 'package:social_media_app/shared/constants.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: mainColor[200],
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return SplashScreenView(
      navigateRoute: CacheHelper.getData('isOnboarding') ?? false
          ? const MainPage()
          : OnBoarding(),
      backgroundColor: mainColor[200],
      duration: 4000,
      imageSize: 200,
      imageSrc: "lib/assets/images/splash_image.png",
      text: " Social App",
      textType: TextType.ColorizeAnimationText,
      textStyle: const TextStyle(
        fontSize: 38.0,
        // color: Colors.deepOrange,
        fontWeight: FontWeight.w900,
      ),
      pageRouteTransition: PageRouteTransition.CupertinoPageRoute,
      colors: const [
        Colors.blue,
        Colors.yellow,
        Colors.red,
        Color.fromRGBO(179, 157, 219, 1)
      ],
    );
  }
}
