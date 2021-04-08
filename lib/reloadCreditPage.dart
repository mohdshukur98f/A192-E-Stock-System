import 'dart:async';
import 'package:estocksystem/profilepage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:estocksystem/user.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

class ReloadCreditPage extends StatefulWidget {
  final User user;
  final String val;
  ReloadCreditPage({this.user, this.val});

  @override
  _StoreCreditScreenState createState() => _StoreCreditScreenState();
}

class _StoreCreditScreenState extends State<ReloadCreditPage> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    String urlLogin = "https://seriouslaa.com/myestock/php/refresh_profile.php";
    return Scaffold(
        appBar: AppBar(
          title: Text('BUY STORE CREDIT'),
          // backgroundColor: Colors.deepOrange,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: WebView(
                initialUrl:
                    'http://seriouslaa.com/myestock/php/buycredit.php?email=' +
                        widget.user.email +
                        '&mobile=' +
                        widget.user.phone +
                        '&name=' +
                        widget.user.name +
                        '&amount=' +
                        widget.val +
                        '&csc=' +
                        widget.user.credit,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
              ),
            ),
            Text(
              "Don't close untill you got the receipt!",
              style: TextStyle(color: Colors.red),
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text('Complete the Payment',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
              color: Color.fromRGBO(255, 34, 34, 20),
              onPressed: () {
                try {
                  ProgressDialog pb = new ProgressDialog(context,
                      type: ProgressDialogType.Normal, isDismissible: false);
                  pb.style(message: "Log in...");
                  pb.show();
                  String _username = widget.user.username;
                  http.post(urlLogin, body: {
                    "username": _username,
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
                              builder: (BuildContext context) => ProfilePage(
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
              },
            ),
          ],
        ));
  }
}
