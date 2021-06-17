import 'dart:io';

class AdMobService {

  String getAdMobAppId() {
    if (Platform.isIOS) {
      return null;
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-7716978148792169~9523636577';
    }
    return null;
  }

  String getBannerAdId() {
    if (Platform.isIOS) {
      return null;
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-7716978148792169/4065449851';
    }
    return null;
  }

}