class ImageAsset {
  static const String imagePath = "assets/images";
  static const String splash = '$imagePath/splash.png';
  // onboarding Images
  static const String onboarding1 = "$imagePath/onboarding1.png";
  static const String onboarding = "$imagePath/onboarding.svg";
  // others
  static const String riderBike = "$imagePath/rider_bike.png";
  static const String riderBikeImg = "$imagePath/rider-image.png";
  static const String expressBadge = "$imagePath/express-badge.png";
  static const String regularBadge = "$imagePath/regular-badge.png";
  static const String logout = "$imagePath/logout.png";
  static const String speechBubble = "$imagePath/speech.png";

  /// The gift box that bleeds off the end corner of the reward card. A cut-out with a real
  /// alpha channel — it sits straight on the card tint with no plate behind it.
  static const String giftBox = "$imagePath/gift-box.png";
  static const String logo = '$imagePath/logo.png';

  /// Artwork for the three bookable services on the home card. Each is optional: the tile
  /// falls back to its glyph when the file is absent, so dropping the illustration in at
  /// this path is the whole integration.
  static const String serviceSingleDrop = "$imagePath/service-single-drop.png";
  static const String serviceMultiDrop = "$imagePath/service-multi-drop.png";
  static const String serviceBatchRun = "$imagePath/service-batch-run.png";
}

class LottieAssets {
  static const String lottiePath = "assets/lottie";
}

class SvgAsset {
  static const String svgPath = "assets/svgs";
}

class PngAsset {
  static const String pnggPath = "assets/pngs";
}
