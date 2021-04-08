import 'dart:async';
// import 'package:estocksystem/homepage.dart';
// import 'package:estocksystem/profilepage.dart';
import 'package:estocksystem/navigationpage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

import 'package:estocksystem/user.dart';

class PaymentPage extends StatefulWidget {
  final User user;
  final String orderid, val;
  PaymentPage({this.user, this.orderid, this.val});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('PAYMENT'),
          // backgroundColor: Colors.deepOrange,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: WebView(
                initialUrl:
                    'http://seriouslaa.com/myestock/php/payment.php?email=' +
                        widget.user.email +
                        '&username=' +
                        widget.user.username +
                        '&mobile=' +
                        widget.user.phone +
                        '&name=' +
                        widget.user.name +
                        '&amount=' +
                        widget.val +
                        '&orderid=' +
                        widget.orderid,
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
                    color: Colors.white,
                    fontSize: 20,
                  )),
              color: Colors.redAccent,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => NavigationPage(
                              user: widget.user,
                            )));
              },
            ),
          ],
        ));
  }
}
