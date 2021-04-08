import 'package:estocksystem/loginpage.dart';
import 'package:estocksystem/signuppage.dart';
import 'package:estocksystem/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'navigationpage.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePage createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Stack(
            children: <Widget>[
              backgroundimages(context),
              function(context),
              pageTitle(),
            ],
          )),
    );
  }

  Widget backgroundimages(BuildContext context) {
    return Container(
      height: screenHeight,
      color: Colors.white,
    );
  }

  Widget function(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 200),
      padding: EdgeInsets.all(70.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new SizedBox(
            height: 55.0,
            child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text('Login',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    )),
                color: Color.fromRGBO(243, 240, 240, 1),
                textColor: Colors.white,
                onPressed: _userLogin),
          ),
          SizedBox(height: 20.0),
          new SizedBox(
            height: 55.0,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text('Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              color: Color.fromRGBO(255, 34, 34, 20),
              textColor: Colors.white,
              onPressed: _userRegister,
            ),
          ),
          SizedBox(height: 25.0),
          GestureDetector(
            onTap: _guestLogin,
            child: Text(
              'Continue as Guest',
              style: TextStyle(color: Colors.red, fontSize: 17),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget pageTitle() {
    return Container(
        //color: Color.fromRGBO(255, 200, 200, 200),
        margin: EdgeInsets.only(top: 250),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.shopping_basket,
                  size: 40,
                  color: Colors.red,
                ),
                Text(
                  " My e-Stock Shop",
                  style: TextStyle(
                      fontSize: 36,
                      color: Colors.black,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
            Text(
              "-Easy To Shopping For Your Sports-",
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: Colors.black,
              ),
            )
          ],
        ));
  }

  void _userLogin() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  void _userRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => SignupPage()));
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text("Exit")),
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancel")),
            ],
          ),
        ) ??
        false;
  }

  void _guestLogin() async {
    try {
      ProgressDialog pb = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pb.style(message: "Loading");
      pb.show();

      http.post('https://seriouslaa.com/myestock/php/login_user.php', body: {
        "username": 'guest',
        "password": '123456',
      })
          //.timeout(const Duration(seconds: 4))
          .then((res) {
        print(res.body);
        var string = res.body;
        List userdata = string.split(",");
        if (userdata[0] == "success") {
          User _user = new User(
            username: userdata[1],
            name: userdata[2],
            email: userdata[3],
            phone: userdata[4],
            password: userdata[5],
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
}
