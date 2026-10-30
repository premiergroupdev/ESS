import 'package:ess/Ess_App/generated/assets.dart';
import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/app_theme.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/menu/menu_view.dart';
import 'package:ess/Ess_App/src/views/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(AppTheme.lightStatusBar);

    return MaterialApp(
      title: Constants.appTitle,
      key: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: NavService.onGenerateRoute,
      navigatorKey: NavService.key,
      theme: AppTheme.light(),
      home: SplashView(),
      builder: (context, child) {
        return Navigator(
          onGenerateRoute: (setting) => MaterialPageRoute(
            builder: (_) => Scaffold(
              drawer: MenuView(),
              drawerEnableOpenDragGesture: false,
              body: Stack(
                children: [child!],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: context.screenSize().width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.imagesConnectionLost,
              width: context.screenSize().width * 0.7,
              height: context.screenSize().width * 0.7,
            ),
            const VerticalSpacing(20),
            Text(
              "No Internet Found",
              style: TextStyling.title.copyWith(color: AppColors.primary),
            ),
            const VerticalSpacing(6),
            Text(
              "Check your connection and try again.",
              style: TextStyling.body,
            ),
          ],
        ),
      ),
    );
  }
}
