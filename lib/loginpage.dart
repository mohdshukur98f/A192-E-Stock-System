import 'dart:async';
import 'package:estocksystem/navigationpage.dart';
import 'package:estocksystem/signuppage.dart';
import 'package:estocksystem/welcomepage.dart';
import 'package:estocksystem/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter/services.dart';

bool rememberMe = false;

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController _usernameEditingController =
      new TextEditingController();
  TextEditingController _passwordEditingController =
      new TextEditingController();
  String urlLogin = "https://seriouslaa.com/myestock/php/login_user.php";
  @override
  void initState() {
    super.initState();
    print("Hello i'm in INITSTATE");
    this.loadPref();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 34, 34, 20),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Login',
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
                          //color: Color.fromRGBO(255, 34, 34, 20),
                          color: Colors.black,
                          fontWeight: FontWeight.w900),
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
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              icon: Icon(Icons.person),
                            )),
                        TextField(
                          controller: _passwordEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            icon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: rememberMe,
                              onChanged: (bool value) {
                                _onRememberMeChanged(value);
                              },
                            ),
                            Text('Remember Me ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                        GestureDetector(
                          onTap: _forgotPassword,
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        SizedBox(
                          height: 43.0,
                          width: 230,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Text('Log In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                )),
                            color: Color.fromRGBO(255, 34, 34, 20),
                            onPressed: _userLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                GestureDetector(
                  onTap: _gotoSignup,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Create an account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
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
            ),
          ),
        ),
      ),
    );
  }

  void _userLogin() async {
    try {
      ProgressDialog pb = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pb.style(message: "Log in...");
      pb.show();
      String _username = _usernameEditingController.text;
      String _password = _passwordEditingController.text;
      http.post(urlLogin, body: {
        "username": _username,
        "password": _password,
      })
          //.timeout(const Duration(seconds: 4))
          .then((res) {
        print(res.body);
        var string = res.body;
        List userdata = string.split(",");
        if (userdata[0] == "success") {
          User _user = new User(
            username: _username,
            name: userdata[2],
            email: userdata[3],
            phone: userdata[4],
            password: _password,
            credit: userdata[6],
            verify: userdata[7],
            dateregister: userdata[8],
            quantity: userdata[9],
            gender: userdata[10],
          );
          pb.hide();
          //pr.dismiss();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NavigationPage(
                        user: _user,
                      )));
        } else {
          pb.hide();
          Toast.show("Login failed", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        print(err);
        pb.hide();
      });
    } on Exception catch (_) {
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _onRememberMeChanged(bool newValue) => setState(() {
        rememberMe = newValue;
        print(rememberMe);
        if (rememberMe) {
          savepref(true);
        } else {
          savepref(false);
        }
      });

  void savepref(bool value) async {
    String username = _usernameEditingController.text;
    String password = _passwordEditingController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //save preference
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      Toast.show("Preferences have been saved", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      //delete preference
      await prefs.setString('username', '');
      await prefs.setString('password', '');
      setState(() {
        _usernameEditingController.text = '';
        _passwordEditingController.text = '';
        rememberMe = false;
      });
      Toast.show("Preferences have removed", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  void _forgotPassword() {
    TextEditingController phoneController = TextEditingController();
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Forgot Password?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content: new Container(
            height: 100,
            child: Column(
              children: <Widget>[
                Text(
                  "Enter your recovery email",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                TextField(
                    decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                ))
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                print(
                  phoneController.text,
                );
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _gotoSignup() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => SignupPage()));
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = (prefs.getString('username')) ?? '';
    String password = (prefs.getString('password')) ?? '';
    if (username.length > 0) {
      setState(() {
        _usernameEditingController.text = username;
        _passwordEditingController.text = password;
        rememberMe = true;
      });
    }
  }

  void _gotoWelcome() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomePage()));
  }
}
