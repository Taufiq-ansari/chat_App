import 'package:catalog_1/pages/chatpage.dart';
import 'package:catalog_1/pages/sign-in.dart';
import 'package:catalog_1/service/database.dart';
import 'package:catalog_1/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomStream;

  getthesharedpre() async {
    myName = await SharedpreHelper().getDispalyName();
    myProfilePic = await SharedpreHelper().getUserPic();
    myUserName = await SharedpreHelper().getUserName();
    print(myUserName);
    myEmail = await SharedpreHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpre();
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget ChatRoomList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.doc.length;
                    return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds["lastMessage"],
                        myUsername: myUserName!,
                        time: ds["lastMessageSendts"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.codeUnitAt(0) > b.codeUnitAt(1)) {
      return "$b\_$a";
    }
    {
      return "$a\_$b";
    }
  }

  var queryResultSet = [];
  var tempSearchStore = [];
  bool isloading = false;
  final TextEditingController searchController = TextEditingController();

  initiateSearch(String value) async {
    if (value.length == 0) {
      queryResultSet = [];
      tempSearchStore = [];
    }
    setState(() {
      search = true;
      isloading = true;
    });

    if (queryResultSet.isEmpty && value.length == 1) {
      await DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        print(docs.docs.length);
        if (docs.docs.isNotEmpty) {
          for (int i = 0; i < docs.docs.length; ++i) {
            setState(() {
              queryResultSet.add(docs.docs[i].data());
              isloading = false;
            });
          }
          queryResultSet.forEach((element) {
            if ((element['username'])
                .toString()
                .toUpperCase()
                .contains(value.toUpperCase())) {
              // setState(() {
              tempSearchStore.add(element);
              // });
            }
          });
        } else {
          setState(() {
            isloading = false;
          });
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if ((element['username'])
            .toString()
            .toUpperCase()
            .contains(value.toUpperCase())) {
          // setState(() {
          tempSearchStore.add(element);

          // });
        }
      });
      isloading = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          setState(() {
            search = false;
            searchController.clear();
          });
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignIn(),
                        ),
                        (route) => false);
                  },
                  icon: Icon(Icons.logout),
                )
              ],
            ),
            backgroundColor: Color(0xff0E2954),
            body: Container(
                child: Column(children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    search
                        ? Expanded(
                            child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              initiateSearch(value.toUpperCase());
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search",
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500)),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500),
                          ))
                        : Text(
                            "chat-up",
                            style: TextStyle(
                                color: Color(0xffC5DFF8),
                                fontSize: 30,
                                fontWeight: FontWeight.w400),
                          ),
                    GestureDetector(
                      onTap: () {
                        search = true;
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff365486),
                            borderRadius: BorderRadius.circular(20.0)),
                        child: search
                            ? GestureDetector(
                                onTap: () {
                                  search = false;
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Color(0xffC5DFF8),
                                  size: 30,
                                ),
                              )
                            : Icon(
                                Icons.search,
                                color: Color(0xffC5DFF8),
                                size: 30,
                              ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                    height: search
                        ? MediaQuery.of(context).size.height / 1.19
                        : MediaQuery.of(context).size.height / 1.172,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )),
                    child: Column(
                      children: [
                        search
                            ? isloading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : searchController.text.trim().isEmpty
                                    ? Text("search to find contact")
                                    : tempSearchStore.isEmpty
                                        ? Text("no contact found ")
                                        : ListView.builder(
                                            itemCount: tempSearchStore.length,
                                            padding: EdgeInsets.only(
                                              left: 10.0,
                                              right: 10.0,
                                            ),
                                            primary: false,
                                            shrinkWrap: true,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return buildResultCard(
                                                  tempSearchStore[index]);
                                            })
                            : ChatRoomList(),
                        // Column(
                        //                 children: [
                        //                   GestureDetector(
                        //                     onTap: () {},
                        //                     child: Row(
                        //                       crossAxisAlignment: CrossAxisAlignment.start,
                        //                       children: [
                        //                         ClipRRect(
                        //                           child: Image.asset(
                        //                             'assets/boy2.png',
                        //                             height: 60.0,
                        //                             width: 60.0,
                        //                             fit: BoxFit.cover,
                        //                           ),
                        //                           borderRadius: BorderRadius.circular(60),
                        //                         ),
                        //                         SizedBox(
                        //                           width: 20.0,
                        //                         ),
                        //                         Column(
                        //                           crossAxisAlignment:
                        //                               CrossAxisAlignment.start,
                        //                           children: [
                        //                             SizedBox(
                        //                               height: 10.0,
                        //                             ),
                        //                             Row(
                        //                               mainAxisAlignment:
                        //                                   MainAxisAlignment.spaceBetween,
                        //                               children: [
                        //                                 Text(
                        //                                   'Taufiq Ansari',
                        //                                   style: TextStyle(
                        //                                       color: Colors.black,
                        //                                       fontSize: 17.0,
                        //                                       fontWeight: FontWeight.w500),
                        //                                 ),
                        //                               ],
                        //                             ),
                        //                             Text(
                        //                               'hii whassup..!',
                        //                               style: TextStyle(
                        //                                   color: Colors.black45,
                        //                                   fontSize: 14.0,
                        //                                   fontWeight: FontWeight.w500),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                         Spacer(),
                        //                         Text(
                        //                           '10:00 PM',
                        //                           style: TextStyle(
                        //                               color: Colors.black,
                        //                               fontSize: 14.0,
                        //                               fontWeight: FontWeight.w500),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: 8.0),
                        //                   Row(
                        //                     crossAxisAlignment: CrossAxisAlignment.start,
                        //                     children: [
                        //                       ClipRRect(
                        //                         child: Image.asset(
                        //                           'assets/yash.png',
                        //                           height: 60.0,
                        //                           width: 60.0,
                        //                           fit: BoxFit.cover,
                        //                         ),
                        //                         borderRadius: BorderRadius.circular(60),
                        //                       ),
                        //                       SizedBox(
                        //                         width: 20.0,
                        //                       ),
                        //                       Column(
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment.start,
                        //                         children: [
                        //                           SizedBox(
                        //                             height: 10.0,
                        //                           ),
                        //                           Row(
                        //                             mainAxisAlignment:
                        //                                 MainAxisAlignment.spaceBetween,
                        //                             children: [
                        //                               Text(
                        //                                 'yash singh',
                        //                                 style: TextStyle(
                        //                                     color: Colors.black,
                        //                                     fontSize: 17.0,
                        //                                     fontWeight: FontWeight.w500),
                        //                               ),
                        //                             ],
                        //                           ),
                        //                           Text(
                        //                             'hii whassup..!',
                        //                             style: TextStyle(
                        //                                 color: Colors.black45,
                        //                                 fontSize: 14.0,
                        //                                 fontWeight: FontWeight.w500),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                       Spacer(),
                        //                       Text(
                        //                         '10:00 PM',
                        //                         style: TextStyle(
                        //                             color: Colors.black,
                        //                             fontSize: 14.0,
                        //                             fontWeight: FontWeight.w500),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                   SizedBox(height: 10.0),
                        //                   Row(
                        //                     crossAxisAlignment: CrossAxisAlignment.start,
                        //                     children: [
                        //                       ClipRRect(
                        //                         child: Image.asset(
                        //                           'assets/sanjay.png',
                        //                           height: 60.0,
                        //                           width: 60.0,
                        //                           fit: BoxFit.cover,
                        //                         ),
                        //                         borderRadius: BorderRadius.circular(60),
                        //                       ),
                        //                       SizedBox(
                        //                         width: 20.0,
                        //                       ),
                        //                       Column(
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment.start,
                        //                         children: [
                        //                           SizedBox(
                        //                             height: 10.0,
                        //                           ),
                        //                           Row(
                        //                             mainAxisAlignment:
                        //                                 MainAxisAlignment.spaceBetween,
                        //                             children: [
                        //                               Text(
                        //                                 'sanjay singh',
                        //                                 style: TextStyle(
                        //                                     color: Colors.black,
                        //                                     fontSize: 17.0,
                        //                                     fontWeight: FontWeight.w500),
                        //                               ),
                        //                             ],
                        //                           ),
                        //                           Text(
                        //                             'hii whassup..!',
                        //                             style: TextStyle(
                        //                                 color: Colors.black45,
                        //                                 fontSize: 14.0,
                        //                                 fontWeight: FontWeight.w500),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                       Spacer(),
                        //                       Text(
                        //                         '10:00 PM',
                        //                         style: TextStyle(
                        //                             color: Colors.black,
                        //                             fontSize: 14.0,
                        //                             fontWeight: FontWeight.w500),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ],
                        //               ),
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    )),
              ),
            ]))));
  }

  Widget buildResultCard(Map<String, dynamic> data) {
    print(data["Photo"]);
    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});

        String chatRoomId =
            getChatRoomIdbyUsername(myUserName!, data['username']);
        Map<String, dynamic> chatRoomInfoMap = <String, dynamic>{
          "users": [myUserName, data["username"]],
        };
        await DatabaseMethods().creatChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    chatroom: chatRoomId,
                    name: data["Name"],
                    profileurl: data["Photo"],
                    username: data["username"])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            padding: EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                ClipRRect(
                  child: Image.network(
                    data["Photo"],
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                SizedBox(width: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      data["username"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  ChatRoomListTile(
      {required this.chatRoomId,
      required this.lastMessage,
      required this.myUsername,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profilePicUrl == ""
              ? CircularProgressIndicator()
              : ClipRRect(
                  child: Image.network(
                    profilePicUrl,
                    height: 60.0,
                    width: 60.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
          SizedBox(
            width: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                widget.lastMessage,
                style: TextStyle(
                    color: Colors.black45,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Spacer(),
          Text(
            widget.time,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
