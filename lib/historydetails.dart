import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'order.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryDetails extends StatefulWidget {
  final Order order;

  const HistoryDetails({Key key, this.order}) : super(key: key);
  @override
  _HistoryDetailsState createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  List _orderdetails;
  String titlecenter = "Loading order details...";
  double screenHeight, screenWidth;
  String server = "https://seriouslaa.com/myestock";

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('RECEIPT DETAILS'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          SizedBox(height: 8),
          Text(
            "ORDER RECEIPT ID: " + widget.order.orderid,
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _orderdetails == null
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
                          _orderdetails == null ? 0 : _orderdetails.length,
                      itemBuilder: (context, index) {
                        return Card(
                            elevation: 10,
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Row(children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: screenHeight / 8,
                                        width: screenWidth / 5,
                                        child: ClipOval(
                                            child: CachedNetworkImage(
                                          fit: BoxFit.scaleDown,
                                          imageUrl: server +
                                              "/productimage/${_orderdetails[index]['PRODUCTID']}.jpg",
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        )),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(5, 1, 10, 1),
                                      child: SizedBox(
                                          width: 2,
                                          child: Container(
                                            height: screenWidth / 3.5,
                                            color: Colors.grey,
                                          ))),
                                  Container(
                                      width: screenWidth / 1.45,
                                      //color: Colors.blue,
                                      child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.center,
                                        //mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Flexible(
                                                        child: Text(
                                                          _orderdetails[index]
                                                              ['NAME'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black),
                                                          maxLines: 2,
                                                        ),
                                                      )
                                                    ]),
                                                SizedBox(height: 7),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        "Purchase : ",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        _orderdetails[index][
                                                                'CARTQUANTITY'] +
                                                            " unit",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ]),
                                                SizedBox(height: 7),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Price/unit: ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      "RM " +
                                                          _orderdetails[index]
                                                              ['PRICE'],
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ])));
                      }))
        ]),
      ),
    );
  }

  _loadOrderDetails() async {
    String urlLoadJobs =
        "https://seriouslaa.com/myestock/php/load_carthistory.php";
    await http.post(urlLoadJobs, body: {
      "orderid": widget.order.orderid,
    }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        setState(() {
          _orderdetails = null;
          titlecenter = "No Previous Payment";
        });
      } else {
        setState(() {
          var extractdata = json.decode(res.body);
          _orderdetails = extractdata["carthistory"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }
}
