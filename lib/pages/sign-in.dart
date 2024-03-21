import 'package:catalog_1/pages/home.dart';
import 'package:catalog_1/service/database.dart';
import 'package:catalog_1/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = "", password = "", name = "", pic = "", username = "", id = "";
  TextEditingController usermailcontroller = new TextEditingController();
  TextEditingController userpasswordcontroller = new TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool ispassvisible = true;
  bool isloading = false;

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserbyemail(email);

      name = "${querySnapshot.docs[0]["Name"]}";
      username = "${querySnapshot.docs[0]["username"]}";
      pic = "${querySnapshot.docs[0]["Photo"]}";
      id = querySnapshot.docs[0].id;
      print(username);

      await SharedpreHelper().saveUserDisplayName(name);
      await SharedpreHelper().saveUserName(username);
      await SharedpreHelper().saveUserId(id);
      await SharedpreHelper().saveUserPic(pic);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orange,
            content: Text("no user found for that email",
                style: TextStyle(fontSize: 18.0, color: Colors.black))));
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "wrong password",
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ));
      } else {
        print(e);
      }
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3.0,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xff3887BE), Color(0xff1B4242)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width, 100.0))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              children: [
                Center(
                    child: Text(
                  "Sign-In",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )),
                Center(
                    child: Text(
                  "welcome to the Login-page",
                  style: TextStyle(
                      color: Color(0xff7FC7D9),
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                )),
                SizedBox(height: 20.0),
                Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                  child: Material(
                    elevation: 6.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        height: MediaQuery.of(context).size.height / 2.4,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email",
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0)),
                              Stack(children: [
                                Container(
                                  height: 50.0,
                                  padding: EdgeInsets.only(left: 10.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.5,
                                        color: Colors.black38,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                TextFormField(
                                  controller: usermailcontroller,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your E-mail";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        CupertinoIcons.mail,
                                        color: Color(0xff3887BE),
                                      )),
                                ),
                              ]),
                              Text("Password",
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0)),
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
                                            BorderRadius.circular(10)),
                                  ),
                                  TextFormField(
                                    controller: userpasswordcontroller,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your password";
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
                                    obscureText: true,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_formkey.currentState!.validate()) ;
                                  setState(() {
                                    email = usermailcontroller.text;
                                    password = userpasswordcontroller.text;
                                  });
                                  userLogin();
                                },
                                child: Center(
                                  child: Container(
                                    width: 130,
                                    child: Material(
                                      elevation: 5.0,
                                      child: Container(
                                        width: 130,
                                        padding: EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(
                                            isloading
                                                ? "loading..."
                                                : "Sign-in",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff3887BE),
                                                Color(0xff1B4242)
                                              ],
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont have an account?",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      "Sign Up Now?",
                      style: TextStyle(color: Color(0xff3887BE)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
