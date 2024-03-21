import 'package:shared_preferences/shared_preferences.dart';

class SharedpreHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USER";
  static String userEmailKey = "USEREMAILKEY";
  static String userPicKey = "USERPICKEY";
  static String DisplayName = "USERDISPLAYNAME";

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserPic(String getUserPic) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userPicKey, getUserPic);
  }

  Future<bool> saveUserDisplayName(String getUserDisplayName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(DisplayName, getUserDisplayName);
  }

  Future<String?> getUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userEmailKey);
  }

  Future<String?> getUserPic() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userPicKey);
  }

  Future<String?> getDispalyName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(DisplayName);
  }
}
