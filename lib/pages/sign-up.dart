import 'package:catalog_1/pages/home.dart';
import 'package:catalog_1/service/database.dart';
import 'package:catalog_1/service/shared_pref.dart';
import 'package:catalog_1/utils/easy_loader_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "", confirmpassword = "";
  TextEditingController mailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController confirmpasswordcontroller = new TextEditingController();

  final _formkey = GlobalKey<FormState>();
  bool isloading = false;
  bool passvisible = true;
  bool uspassvisible = true;

  Future registration() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (password != null && password == confirmpassword) {
      EasyLoaderUtils.showLoader();
      setState(() {
        isloading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String Id = randomAlphaNumeric(10);
        String user = mailcontroller.text.replaceAll('@gmail.com', '');
        String updateusername = user.replaceAll(user[0], user[0].toUpperCase());
        String firstletter = user.substring(0, 1).toUpperCase();

        Map<String, dynamic> userInfoMap = {
          "Name": namecontroller.text,
          "Email": mailcontroller.text,
          "username": updateusername.toUpperCase(),
          "SearchKey": firstletter,
          "Photo":
              "https://static.vecteezy.com/system/resources/thumbnails/033/662/051/small/cartoon-lofi-young-manga-style-girl-while-listening-to-music-in-the-rain-ai-generative-photo.jpg",
          "Id": Id,
        };

        await DatabaseMethods().addUserDetails(userInfoMap, Id);
        await SharedpreHelper().saveUserId(Id);
        await SharedpreHelper().saveUserDisplayName(namecontroller.text);
        await SharedpreHelper().saveUserEmail(mailcontroller.text);
        await SharedpreHelper().saveUserPic(
          "https://static.vecteezy.com/system/resources/thumbnails/033/662/051/small/cartoon-lofi-young-manga-style-girl-while-listening-to-music-in-the-rain-ai-generative-photo.jpg",
        );
        await SharedpreHelper()
            .saveUserName(mailcontroller.text.replaceAll("@gmail.com", ""));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Registerd  Successfully",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
        EasyLoaderUtils.dismissLoader();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } on FirebaseAuthException catch (e) {
        EasyLoaderUtils.dismissLoader();
        if (e.code == "weak-password") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password is too weak",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == 'email-already-exists') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                'account already exists',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      }
      setState(() {
        isloading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            'password not matched',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3.0,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff3887BE), Color(0xff1B4242)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width,
                        103.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "Sign-Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "create a new Account",
                          style: TextStyle(
                            color: Color(0xff7FC7D9),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 30.0,
                        ),
                        child: Material(
                          elevation: 6.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            // height: MediaQuery.of(context).size.height / 1.6,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Form(
                              key: _formkey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  // SizedBox(height: 8.0),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 50.0,
                                        padding: EdgeInsets.only(left: 8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Colors.black38,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: namecontroller,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Name";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(
                                            CupertinoIcons.person,
                                            color: Color(0xff3887BE),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  // SizedBox(height: 6.0),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 50.0,
                                        padding: EdgeInsets.only(left: 10.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Colors.black38,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: mailcontroller,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter E-mail";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(
                                            CupertinoIcons.mail,
                                            color: Color(0xff3887BE),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "Password",
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  // SizedBox(height: 10.0),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: 50.0,
                                        padding: EdgeInsets.only(left: 10.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Colors.black38,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: passwordcontroller,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Please Enter Password";
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                prefixIcon: Icon(
                                                  Icons.password,
                                                  color: Color(0xff3887BE),
                                                ),
                                              ),
                                              obscureText: passvisible,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                passvisible = !passvisible;
                                              });
                                            },
                                            icon: passvisible
                                                ? Icon(Icons.visibility)
                                                : Icon(Icons.visibility_off),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Text(
                                    "Confirm Password",
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  // SizedBox(height: 10.0),
                                  Stack(
                                    // alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: 50.0,
                                        padding: EdgeInsets.only(left: 10.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Colors.black38,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  confirmpasswordcontroller,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Please Enter Confirm Password";
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                // suffixIconConstraints:
                                                //     BoxConstraints.tight(
                                                //   Size(20, 0),
                                                // ),
                                                // suffix: Icon(Icons.visibility),
                                                // suffix: IconButton(
                                                //   onPressed: () {
                                                //     setState(() {
                                                //       uspassvisible = !uspassvisible;
                                                //     });
                                                //   },
                                                //   icon: uspassvisible
                                                //       ? Icon(Icons.visibility)
                                                //       : Icon(Icons.visibility_off),
                                                // ),
                                                border: InputBorder.none,
                                                prefixIcon: Icon(
                                                  Icons.password,
                                                  color: Color(0xff3887BE),
                                                ),
                                              ),
                                              obscureText: uspassvisible,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                uspassvisible = !uspassvisible;
                                              });
                                            },
                                            icon: uspassvisible
                                                ? Icon(Icons.visibility)
                                                : Icon(Icons.visibility_off),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Dont have an account?",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Text(
                                          "Sign in Now!  ",
                                          style: TextStyle(
                                            color: Color(0xff3887BE),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = mailcontroller.text;
                              password = passwordcontroller.text;
                              name = namecontroller.text;
                              confirmpassword = confirmpasswordcontroller.text;
                            });
                            await registration();
                          }
                        },
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            width: MediaQuery.of(context).size.width,
                            child: Material(
                              elevation: 5.0,
                              child: Container(
                                width: 130,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    isloading ? "loading..." : "Sign-Up",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff3887BE),
                                      Color(0xff1B4242),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
