import 'package:estocksystem/welcomepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
// import 'package:progress_dialog/progress_dialog.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPage createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  double screenHeight;
  bool _isChecked = false;
  TextEditingController _usernameEditingController =
      new TextEditingController();
  TextEditingController _emailEditingController = new TextEditingController();
  TextEditingController _phoneditingController = new TextEditingController();
  TextEditingController _passwordEditingController =
      new TextEditingController();
  String urlSignup = "https://seriouslaa.com/myestock/php/signup_user.php";
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 34, 34, 20),
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(fontSize: 22.5, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(255, 34, 34, 20),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Card(
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.shopping_basket,
                      size: 40,
                      color: Colors.red,
                    ),
                    Text(
                      " My e-Stock",
                      style: TextStyle(
                          fontSize: 36,
                          color: Colors.black,
                          fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Card(
                    margin: EdgeInsets.fromLTRB(5, 40, 5, 0),
                    elevation: 10,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                        child: Column(
                          children: <Widget>[
                            TextField(
                                controller: _usernameEditingController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  icon: Icon(Icons.person),
                                )),
                            TextField(
                              controller: _emailEditingController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                icon: Icon(Icons.email),
                              ),
                            ),
                            TextField(
                                controller: _phoneditingController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  icon: Icon(Icons.phone_iphone),
                                )),
                            TextField(
                              controller: _passwordEditingController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                icon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Checkbox(
                                  value: _isChecked,
                                  onChanged: (bool value) {
                                    _onChange(value);
                                  },
                                ),
                                GestureDetector(
                                  onTap: _showEULA,
                                  child: Text('I Agree to Terms  ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 43.0,
                              width: 230,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Text('Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    )),
                                color: Color.fromRGBO(255, 34, 34, 20),
                                onPressed: _signUp,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            GestureDetector(
                              onTap: _gotoWelcome,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'Back to menu',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() {
    // ProgressDialog pb = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false);
    // pb.style(message: "Loading...");
    // pb.show();

    String username = _usernameEditingController.text;
    String email = _emailEditingController.text;
    String phone = _phoneditingController.text;
    String password = _passwordEditingController.text;
    if (!_isChecked) {
      Toast.show("Please Accept Term", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      // pb.hide();
      return;
    } else
      http.post(urlSignup, body: {
        "username": username,
        "email": email,
        "password": password,
        "phone": phone,
      }).then((res) {
        print(res);
        // pb.hide();
        if (res.body == "success") {
          Navigator.pop(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => WelcomePage()));
          Toast.show("Registration success", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        print(err);
      });
  }

  void _onChange(bool value) {
    setState(() {
      _isChecked = value;
      //savepref(value);
    });
  }

  void _showEULA() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("EULA"),
          content: new Container(
            height: screenHeight / 2,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: new SingleChildScrollView(
                    child: RichText(
                        softWrap: true,
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              //fontWeight: FontWeight.w500,
                              fontSize: 12.0,
                            ),
                            text:
                                "This End-User License Agreement is a legal agreement between you and Slumberjer This EULA agreement governs your acquisition and use of our MY E-STOCK software (Software) directly from Slumberjer or indirectly through a Slumberjer authorized reseller or distributor (a Reseller).Please read this EULA agreement carefully before completing the installation process and using the MY E-STOCK software. It provides a license to use the MY E-STOCK software and contains warranty information and liability disclaimers. If you register for a free trial of the MY E-STOCK software, this EULA agreement will also govern that trial. By clicking accept or installing and/or using the MY E-STOCK software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement. If you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement.This EULA agreement shall apply only to the Software supplied by Slumberjer herewith regardless of whether other software is referred to or described herein. The terms also apply to any Slumberjer updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply. This EULA was created by EULA Template for MY E-STOCK. Slumberjer shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Slumberjer. Slumberjer reserves the right to grant licences to use the Software to third parties"
                            //children: getSpan(),
                            )),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Close",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _gotoWelcome() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomePage()));
  }
}
