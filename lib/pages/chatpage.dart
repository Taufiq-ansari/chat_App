import 'package:catalog_1/pages/home.dart';
import 'package:catalog_1/service/database.dart';
import 'package:catalog_1/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  String name, profileurl, username, chatroom;
  ChatPage({
    required this.name,
    required this.profileurl,
    required this.username,
    required this.chatroom,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messagecontroller = new TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  gettheSharedpre() async {
    myUserName = await SharedpreHelper().getUserName();
    myProfilePic = await SharedpreHelper().getUserPic();
    myName = await SharedpreHelper().getDispalyName();
    myEmail = await SharedpreHelper().getUserEmail();
    chatRoomId = widget.chatroom;

    getChatRoomIdbyUsername(widget.username, myUserName!);
    setState(() {});
  }

  ontheload() async {
    await gettheSharedpre();
    await getAndSetMessage();
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    }
    {
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendbyMe) {
    return Row(
      mainAxisAlignment:
          sendbyMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight:
                    sendbyMe ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: sendbyMe ? Radius.circular(24) : Radius.circular(0),
              ),
              color: sendbyMe
                  ? Color.fromARGB(255, 225, 234, 236)
                  : Color.fromARGB(255, 225, 234, 236),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 10.0, top: 90.0),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                    ds["message"],
                    myUserName == ds["sendBy"],
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  addMessage(bool sendClick) {
    if (messagecontroller.text != "") {
      String message = messagecontroller.text;
      messagecontroller.text = "";

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myProfilePic,
      };

      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendby": myUserName,
          "receivedUserName": widget.name,
          "receivedUserProfile": widget.profileurl,
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClick) {
          messageId = null;
        }
      });
    }
  }

  getAndSetMessage() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xff0E2954),
        body: Container(
          padding: EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.arrow_back_outlined,
                        color: Color.fromARGB(255, 122, 164, 203),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                      width: 150.0,
                    ),
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Color(0xffC5DFF8),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  margin: EdgeInsets.only(top: 30.0),
                  // width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height / 1.09,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: chatMessage(),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Material(
                  elevation: 5.0,
                  // borderRadius: BorderRadius.circular(40.0),
                  child: Container(
                    margin:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60.0),
                    ),
                    child: TextField(
                      controller: messagecontroller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "type here...",
                        hintStyle: TextStyle(color: Colors.black45),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            addMessage(true);
                          },
                          child: Icon(Icons.send_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
