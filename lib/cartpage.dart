// import 'dart:async';
import 'dart:async';

import 'package:estocksystem/loginpage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';

import 'dart:convert';
import 'package:estocksystem/navigationpage.dart';
import 'package:estocksystem/paymentpage.dart';
import 'package:flutter/material.dart';
import 'package:estocksystem/user.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:estocksystem/profilepage.dart';
import 'package:estocksystem/historypage.dart';

class CartPage extends StatefulWidget {
  final User user;

  const CartPage({Key key, this.user}) : super(key: key);
  @override
  _CartPage createState() => _CartPage();
}

class _CartPage extends State<CartPage> {
  //IMPORTANT
  List cartData;
  double screenHeight, screenWidth;
  String server = "https://seriouslaa.com/myestock";
  String titlecenter = "Loading your cart";

  //CUSTOM
  double _weight = 0.0, _totalprice = 0.0;
  double deliverycharge;
  double amountpayable;
  bool _selfPickup = true;
  // bool _storeCredit = false;
  bool _homeDelivery = false;
  String curaddress;
  Position _currentPosition;
  double latitude, longitude;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _userpos;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();

    //_getCurrentLocation();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: mainDrawer(context),
      resizeToAvoidBottomPadding: false,
      appBar:
          AppBar(title: Center(child: Text('SHOPPING CART')), actions: <Widget>[
        IconButton(
          icon: Icon(MdiIcons.deleteAlert),
          onPressed: () {
            _deleteAll();
          },
        ),
      ]),
      body: Container(
        child: Column(
          children: <Widget>[
            cartData == null
                ? Flexible(
                    child: Center(
                        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Your cart empty.",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // FlatButton(
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(30.0)),
                      //   child: Text('    Go Shopping Now   ',
                      //       style:
                      //           TextStyle(color: Colors.white, fontSize: 20)),
                      //   color: Color.fromRGBO(255, 34, 34, 20),
                      //   textColor: Colors.white,
                      //   onPressed: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (BuildContext context) =>
                      //                 NavigationPage(
                      //                   user: widget.user,
                      //                 )));
                      //   },
                      // ),
                    ],
                  )))
                : Expanded(
                    child: ListView.builder(
                        itemCount: cartData == null ? 1 : cartData.length + 1,
                        itemBuilder: (context, index) {
                          if (index == cartData.length) {
                            return Container(
                                height: screenHeight / 2.4,
                                width: screenWidth / 2.5,
                                child: InkWell(
                                  onLongPress: () => {print("Delete")},
                                  child: Card(
                                    //color: Colors.yellow,
                                    elevation: 5,
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text("Delivery Option",
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        Text(
                                            "Weight:" +
                                                _weight.toString() +
                                                " KG",
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        Expanded(
                                            child: Row(
                                          children: <Widget>[
                                            Container(
                                              // color: Colors.red,
                                              width: screenWidth / 2,
                                              // height: screenHeight / 3,
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Checkbox(
                                                        value: _selfPickup,
                                                        onChanged:
                                                            (bool value) {
                                                          _onSelfPickUp(value);
                                                        },
                                                      ),
                                                      Text(
                                                        "Self Pickup",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    2, 1, 2, 1),
                                                child: SizedBox(
                                                    width: 2,
                                                    child: Container(
                                                      // height: screenWidth / 2,
                                                      color: Colors.grey,
                                                    ))),
                                            Expanded(
                                                child: Container(
                                              //color: Colors.blue,
                                              width: screenWidth / 2,
                                              //height: screenHeight / 3,
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Checkbox(
                                                        value: _homeDelivery,
                                                        onChanged:
                                                            (bool value) {
                                                          _onHomeDelivery(
                                                              value);
                                                        },
                                                      ),
                                                      Text(
                                                        "Home Delivery",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Visibility(
                                                      visible: _homeDelivery,
                                                      child: Column(
                                                        children: <Widget>[
                                                          FlatButton(
                                                            color: Colors
                                                                .orangeAccent,
                                                            onPressed: () => {
                                                              _loadMapDialog()
                                                            },
                                                            child: Icon(
                                                              MdiIcons.earth,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          Text(
                                                              "Current Address:",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black)),
                                                          Row(
                                                            children: <Widget>[
                                                              Text("  "),
                                                              Flexible(
                                                                child: Text(
                                                                  curaddress ??
                                                                      "Address not set",
                                                                  maxLines: 3,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ))
                                                ],
                                              ),
                                            )),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                ));
                          }
                          index -= 0;
                          return Card(
                              elevation: 10,
                              child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          height: screenHeight / 8,
                                          width: screenWidth / 5,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            imageUrl: server +
                                                "/productimage/${cartData[index]['PRODUCTID']}.jpg",
                                            placeholder: (context, url) =>
                                                new CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    new Icon(Icons.error),
                                          ),
                                        ),
                                        Text(
                                          "RM " + cartData[index]['PRICE'],
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "/unit",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 1, 10, 1),
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
                                                  Text(
                                                    cartData[index]['NAME'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    "Available " +
                                                        cartData[index]
                                                            ['QUANTITY'] +
                                                        " unit",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Your Quantity " +
                                                        cartData[index]
                                                            ['CARTQUANTITY'],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Container(
                                                      height: 20,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          FlatButton(
                                                            onPressed: () => {
                                                              _updateCart(
                                                                  index, "add")
                                                            },
                                                            child: Icon(
                                                                MdiIcons.plus,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Text(
                                                            cartData[index][
                                                                'CARTQUANTITY'],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          FlatButton(
                                                            onPressed: () => {
                                                              _updateCart(index,
                                                                  "remove")
                                                            },
                                                            child: Icon(
                                                                MdiIcons.minus,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      )),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                          "Total Price: RM " +
                                                              cartData[index]
                                                                  ['YOURPRICE'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black)),
                                                      FlatButton(
                                                        onPressed: () => {
                                                          _deleteCart(index)
                                                        },
                                                        child: Icon(
                                                            MdiIcons.delete,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                  ])));
                        })),
            Container(

                //height: screenHeight / 3,
                child: Card(
              elevation: 5,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text("Payment",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(height: 10),
                  Container(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      //color: Colors.red,
                      child: Table(
                          defaultColumnWidth: FlexColumnWidth(1.0),
                          columnWidths: {
                            0: FlexColumnWidth(7),
                            1: FlexColumnWidth(3),
                          },
                          //border: TableBorder.all(color: Colors.white),
                          children: [
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    height: 20,
                                    child: Text("Delivery charge ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text("Free",
                                      // "RM" + _totalprice.toStringAsFixed(2) ??
                                      //     "0.0",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black)),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    height: 20,
                                    child: Text("Total Amount ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text(
                                      "RM" + amountpayable.toStringAsFixed(2) ??
                                          "0.0",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                              ),
                            ]),
                          ])),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton(
                    onPressed: makePayment,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.redAccent, Colors.orangeAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 40.0),
                        alignment: Alignment.center,
                        child: Text(
                          "Checkout",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  void _loadCart() {
    _weight = 0.0;
    _totalprice = 0.0;
    amountpayable = 0.0;
    deliverycharge = 0.0;
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Updating cart...");
    pr.show();
    String urlLoadJobs = server + "/php/load_cart.php";
    http.post(urlLoadJobs, body: {
      "username": widget.user.username,
    }).then((res) {
      print(res.body);
      pr.hide();
      if (res.body == "Cart Empty") {
        //Navigator.of(context).pop(false);

        setState(() {
          widget.user.quantity = "0";
        });
        widget.user.quantity = "0";

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => NavigationPage(
                      user: widget.user,
                    )));
      }
      setState(() {
        var extractdata = json.decode(res.body);
        cartData = extractdata["cart"];
        for (int i = 0; i < cartData.length; i++) {
          _weight = double.parse(cartData[i]['WEIGHT']) *
                  int.parse(cartData[i]['CARTQUANTITY']) +
              _weight;
          _totalprice = double.parse(cartData[i]['YOURPRICE']) + _totalprice;
        }
        _weight = _weight / 1000;
        amountpayable = _totalprice;
      });
    }).catchError((err) {
      print(err);
      pr.hide();
    });
    pr.hide();
  }

  _updateCart(int index, String op) {
    int curquantity = int.parse(cartData[index]['QUANTITY']);
    int quantity = int.parse(cartData[index]['CARTQUANTITY']);
    if (op == "add") {
      quantity++;
      if (quantity > (curquantity - 2)) {
        Toast.show("Quantity not available", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
    }
    if (op == "remove") {
      quantity--;
      if (quantity == 0) {
        _deleteCart(index);
        return;
      }
    }
    String loadCart = server + "/php/update_cart.php";
    http.post(loadCart, body: {
      "username": widget.user.username,
      "productid": cartData[index]['PRODUCTID'],
      "quantity": quantity.toString()
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        print(res.body);
        Toast.show("Cart Updated", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _loadCart();
      } else {
        print(res.body);
        print("print in else ");
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
    });
  }

  _deleteCart(int index) {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Row(
          children: <Widget>[
            Flexible(
              child: Text(
                'Delete ' + cartData[index]['NAME'] + "?",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 15),
                maxLines: 2,
              ),
            )
          ],
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post(server + "/php/delete_cart.php", body: {
                  "username": widget.user.username,
                  "productdid": cartData[index]['PRODUCTID'],
                }).then((res) {
                  if (res.body == "success") {
                    _loadCart();
                  } else {
                    Toast.show("failed", context,
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

  _deleteAll() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Row(
          children: <Widget>[
            Text(
              'Delete all item in cart?',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post(server + "/php/delete_cart.php", body: {
                  "username": widget.user.username,
                }).then((res) {
                  if (res.body == "success") {
                    _loadCart();
                  } else {
                    Toast.show("failed", context,
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

  Future<void> makePayment() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('ddMMyyyy');
    String orderid = formatter.format(now) + randomAlphaNumeric(6);
    print(orderid);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PaymentPage(
                  user: widget.user,
                  val: _totalprice.toStringAsFixed(2),
                  orderid: orderid,
                )));
    _loadCart();
  }

  _loadMapDialog() {
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Location not available. Please wait...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation(); //_getCurrentLocation();
        return;
      }
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.4746,
      );

      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'Delivery Location',
          )));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              return AlertDialog(
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Text(
                  "Select New Delivery Location",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                titlePadding: EdgeInsets.all(5),
                //content: Text(curaddress),
                actions: <Widget>[
                  Text(
                    curaddress,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: screenHeight / 2 ?? 600,
                    width: screenWidth ?? 360,
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _userpos,
                        markers: markers.toSet(),
                        onMapCreated: (controller) {
                          _controller.complete(controller);
                        },
                        onTap: (newLatLng) {
                          _loadLoc(newLatLng, newSetState);
                        }),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    //minWidth: 200,
                    height: 30,
                    child: Text('Close'),
                    color: Color.fromRGBO(101, 255, 218, 50),
                    textColor: Colors.black,
                    elevation: 10,
                    onPressed: () =>
                        {markers.clear(), Navigator.of(context).pop(false)},
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  void _loadLoc(LatLng loc, newSetState) async {
    newSetState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, newSetState);
      _home = CameraPosition(
        target: loc,
        zoom: 14,
      );
      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: curaddress,
          )));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );
    _newhomeLocation();
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
    //Navigator.of(context).pop(false);
    //_loadMapDialog();
  }

  void _onSelfPickUp(bool newValue) => setState(() {
        _selfPickup = newValue;
        if (_selfPickup) {
          _homeDelivery = false;
          // _updatePayment();
        } else {
          //_homeDelivery = true;
          // _updatePayment();
        }
      });

  // void _onStoreCredit(bool newValue) => setState(() {
  //       _storeCredit = newValue;
  //       if (_storeCredit) {
  //         // _updatePayment();
  //       } else {
  //         // _updatePayment();
  //       }
  //     });

  void _onHomeDelivery(bool newValue) {
    //_getCurrentLocation();
    _getLocation();
    setState(() {
      _homeDelivery = newValue;
      if (_homeDelivery) {
        // _updatePayment();
        _selfPickup = false;
      } else {
        // _updatePayment();
      }
    });
  }

  _getLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates =
        new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
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
