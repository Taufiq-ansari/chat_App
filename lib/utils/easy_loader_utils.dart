import 'package:flutter_easyloading/flutter_easyloading.dart';

class EasyLoaderUtils {
  static showLoader() {
    EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.black);
  }

  static dismissLoader() {
    EasyLoading.dismiss();
  }
}
