import 'package:catalog_1/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .doc(id)
        .set(userInfoMap);
  }

  Future<QuerySnapshot> getUserbyemail(String email) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .where("Email", isEqualTo: email)
        .get();
  }

  Future<QuerySnapshot> Search(String username) async {
    print(username);
    return await FirebaseFirestore.instance
        .collection("user")
        .where("SearchKey", isEqualTo: username.substring(0, 1).toUpperCase())
        .get();
  }

  creatChatRoom(String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future addMessage(
    String chatRoomId,
    String messageId,
    Map<String, dynamic> messageInfoMap,
  ) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
    String chatRoomId,
    Map<String, dynamic> lastMessageInfoMap,
  ) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<void> deleteMessage(
      {required String chatRoomId, required String docId}) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .doc(docId)
        .delete();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .where("username", isEqualTo: username)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUsername = await SharedpreHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("time", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }
}
