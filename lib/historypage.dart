import 'dart:convert';

import 'package:estocksystem/historydetails.dart';
import 'package:estocksystem/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:estocksystem/user.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:estocksystem/navigationpage.dart';
import 'package:estocksystem/profilepage.dart';
import 'package:estocksystem/cartpage.dart';

import 'package:estocksystem/order.dart';

class HistoryPage extends StatefulWidget {
  final User user;

  const HistoryPage({Key key, this.user}) : super(key: key);
  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  GlobalKey<RefreshIndicatorState> refreshKey;
  List _paymentdata;

  String titlecenter = "Loading payment history...";
  final f = new DateFormat('dd-MM-yyyy hh:mm a');
  var parsedDate;
  double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: mainDrawer(context),
        appBar: AppBar(
          centerTitle: true,
          title: Text('PAYMENT'),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          color: Colors.redAccent,
          onRefresh: () async {
            await refreshList();
          },
          child: Center(
            child: Column(children: <Widget>[
              SizedBox(height: 8),
              Text(
                "Receipt History",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Card(
                  elevation: 10,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 12),
                        Expanded(
                            flex: 1,
                            child: Text(
                              "BIL",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                        Expanded(
                            flex: 3,
                            child: Text(
                              "TOTAL",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                        Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "ORDER ID",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                        Expanded(
                          child: Text(
                            "DATE/TIME",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          flex: 2,
                        ),
                        SizedBox(width: 15),
                      ])),
              _paymentdata == null
                  ? Flexible(
                      child: Container(
                          child: Center(
                              child: Text(
                      titlecenter,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ))))
                  : Expanded(
                      child: ListView.builder(
                          //Step 6: Count the data
                          itemCount:
                              _paymentdata == null ? 0 : _paymentdata.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onLongPress: () => deletereceipt(index),
                                onTap: () => loadOrderDetails(index),
                                child: Card(
                                    elevation: 10,
                                    child: Column(children: <Widget>[
                                      SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(width: 12),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                (index + 1).toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                          Expanded(
                                              flex: 3,
                                              child: Text(
                                                "RM " +
                                                    _paymentdata[index]
                                                        ['TOTAL'],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          Expanded(
                                              flex: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    _paymentdata[index]
                                                        ['ORDERID'],
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              )),
                                          Expanded(
                                            child: Text(
                                              f.format(DateTime.parse(
                                                  _paymentdata[index]['DATE'])),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            flex: 2,
                                          ),
                                          SizedBox(width: 15),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                    ])));
                          }))
            ]),
          ),
        ));
  }

  Future<void> _loadPaymentHistory() async {
    String urlLoadJobs =
        "https://seriouslaa.com/myestock/php/load_paymenthistory.php";
    await http.post(urlLoadJobs, body: {"username": widget.user.username}).then(
        (res) {
      print(res.body);
      if (res.body == "nodata") {
        setState(() {
          _paymentdata = null;
          titlecenter = "No Receipt Available";
        });
      } else {
        setState(() {
          var extractdata = json.decode(res.body);
          _paymentdata = extractdata["payment"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  loadOrderDetails(int index) {
    Order order = new Order(
        billid: _paymentdata[index]['BILLID'],
        orderid: _paymentdata[index]['ORDERID'],
        total: _paymentdata[index]['TOTAL'],
        dateorder: _paymentdata[index]['DATE']);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => HistoryDetails(
                  order: order,
                )));
  }

  deletereceipt(int index) {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Row(
          children: <Widget>[
            Flexible(
                child: Text(
              'Delete Receipt: ' + _paymentdata[index]['ORDERID'] + " ?",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontSize: 15),
              maxLines: 2,
            )),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post(
                    "https://seriouslaa.com/myestock/php/delete_receipt.php",
                    body: {
                      "username": widget.user.username,
                      "orderid": _paymentdata[index]['ORDERID'],
                    }).then((res) {
                  if (res.body == "success") {
                    _loadPaymentHistory();
                  } else {
                    Toast.show("DELETE FAILED", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                }).catchError((err) {
                  print(err);
                });
              },
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.black),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              )),
        ],
      ),
    );
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    //_getLocation();
    _loadPaymentHistory();
    return null;
  }

  Widget mainDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.name),
            accountEmail: Text(widget.user.email),
            otherAccountsPictures: <Widget>[
              Text("RM " + widget.user.credit,
                  style: TextStyle(fontSize: 16.0, color: Colors.white)),
            ],
            currentAccountPicture: CircleAvatar(
              backgroundColor:
                  Theme.of(context).platform == TargetPlatform.android
                      ? Colors.white
                      : Colors.white,
              child: Text(
                widget.user.name.toString().substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
              // backgroundImage: NetworkImage(
              //     server + "/profileimages/${widget.user.email}.jpg?"),
            ),
            onDetailsPressed: () => {
              // Navigator.pop(context),
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => ProfilePage(
              //               user: widget.user,
              //             )))
            },
          ),
          ListTile(
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.home),
              title: Text(
                "Main Manu",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => NavigationPage(
                                  user: widget.user,
                                )))
                  }
              // _paymentScreen
              ),
          ListTile(
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.assignment),
              title: Text(
                "Purchase History",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HistoryPage(
                                  user: widget.user,
                                )))
                  }
              // _paymentScreen
              ),
          ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text(
                "My Cart",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => CartPage(
                                  user: widget.user,
                                )))
                  }
              // _paymentScreen
              ),
          ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "User Profile",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ProfilePage(
                                  user: widget.user,
                                )))
                  }),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage()))
                  }),
        ],
      ),
    );
  }
}
