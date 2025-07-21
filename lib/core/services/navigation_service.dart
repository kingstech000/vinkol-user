import 'package:flutter/material.dart';
import 'package:starter_codes/core/router/router.dart';

class NavigationService {
  static NavigationService get instance => _instance;
  static final NavigationService _instance = NavigationService._();
  NavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigate with a custom transition
  Future<dynamic> navigateTo(String routeName,
      {Object? argument, TransitionType transition = TransitionType.Side}) {
    return navigatorKey.currentState!.push(
      AppRouter.generateRoute(
        RouteSettings(name: routeName, arguments: argument),
        transition: transition,
      ),
    );
  }

  // Replace current view and stack new one with custom transition
  Future<dynamic> navigateToReplace(String routeName,
      {Object? argument, TransitionType transition = TransitionType.Side}) {
    return navigatorKey.currentState!.pushReplacement(
      AppRouter.generateRoute(
        RouteSettings(name: routeName, arguments: argument),
        transition: transition,
      ),
    );
  }

  // REPLACE ALL ROUTES
  Future<dynamic> navigateToReplaceAll(String routeName,
      {Object? argument, TransitionType transition = TransitionType.Side}) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      AppRouter.generateRoute(
        RouteSettings(name: routeName, arguments: argument),
        transition: transition,
      ),
      (route) => false,
    );
  }

  // Navigate back
  void goBack<T extends Object?>([T? result]) {
    Navigator.of(navigatorKey.currentState!.context).pop(result);
  }
}
