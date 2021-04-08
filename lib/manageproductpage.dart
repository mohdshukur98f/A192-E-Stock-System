import 'package:estocksystem/newproduct.dart';
import 'package:estocksystem/product.dart';
import 'package:estocksystem/updateproductpage.dart';
import 'package:flutter/material.dart';
import 'package:estocksystem/user.dart';
import 'package:estocksystem/welcomepage.dart';
import 'package:estocksystem/navigationpage.dart';
import 'package:estocksystem/profilepage.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ManageproductPage extends StatefulWidget {
  final User user;

  const ManageproductPage({Key key, this.user}) : super(key: key);
  @override
  _ManageproductPageState createState() => _ManageproductPageState();
}

class _ManageproductPageState extends State<ManageproductPage> {
  GlobalKey<RefreshIndicatorState> refreshKey;
  List productdata;
  double screenHeight, screenWidth;
  int curnumber = 1;
  String curtype = "All";
  String cartquantity = "0";
  int quantity = 1;
  String titlecenter = "Loading products...";
  String server = "https://seriouslaa.com/myestock";
  bool _sortcategory = false;

  Icon searchIcon = Icon(Icons.search, color: Colors.black, size: 25);
  Widget searchBar = Text(
    "MANAGE PRODUCT",
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    textAlign: TextAlign.center,
  );

  @override
  void initState() {
    super.initState();
    _loadData();

    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    TextEditingController _searchController = new TextEditingController();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: mainDrawer(context),
      appBar: AppBar(
        // centerTitle: true,
        title: searchBar,
        iconTheme: new IconThemeData(color: Colors.black),
        // leading: IconButton(icon: Icon(Icons.search), onPressed: () {}),

        actions: <Widget>[
          IconButton(
            icon: searchIcon,
            onPressed: () {
              setState(() {
                if (this.searchIcon.icon == Icons.search) {
                  this.searchIcon = Icon(Icons.close);

                  this.searchBar = TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                      prefix: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _sortItembyName(_searchController.text);
                          }),
                      border: InputBorder.none,
                      hintText: "Search your product",
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  );
                } else {
                  this.searchIcon = Icon(Icons.search);
                  this.searchBar = Text(
                    "MY E-STOCK",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  );
                }
              });

              // _sortItembyName(_searchController.text);
              // _saveHistory(_searchController.text);
            },
          ),
          IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.black,
                size: 25,
              ),
              onPressed: createNewProduct),
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        color: Colors.redAccent,
        onRefresh: () async {
          await refreshList();
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 4, 0),
                  child: Row(children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                            text: TextSpan(
                          text: 'Show the selected/search result: ',
                          style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.black),
                        ))),
                    Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 0, 3),
                        child: Container(
                            height: 40,
                            decoration: new BoxDecoration(color: Colors.white),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 5.0),
                                Text(curtype,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.red,
                                      background: Paint()..color = Colors.white,
                                    )),
                                IconButton(
                                  icon: _sortcategory
                                      ? new Icon(Icons.expand_less)
                                      : new Icon(Icons.expand_more),
                                  onPressed: () {
                                    setState(() {
                                      if (_sortcategory) {
                                        _sortcategory = false;
                                      } else {
                                        _sortcategory = true;
                                      }
                                    });
                                  },
                                ),
                              ],
                            )))
                  ])),
              Visibility(
                visible: _sortcategory,
                // color: Colors.grey[100],
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            FlatButton(
                                onPressed: () => _sortItem("All"),
                                color: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(MdiIcons.update,
                                        size: 20, color: Colors.red),
                                    Text(
                                      "All",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Column(
                          children: <Widget>[
                            FlatButton(
                                onPressed: () => _sortItem("Ball"),
                                color: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.baseball,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    Text(
                                      "Ball",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Column(
                          children: <Widget>[
                            FlatButton(
                                onPressed: () => _sortItem("Badminton"),
                                color: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.badminton,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    Text(
                                      "Badminton",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Column(
                          children: <Widget>[
                            FlatButton(
                                onPressed: () => _sortItem("Ping Pong"),
                                color: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.circleOutline,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    Text(
                                      "Ping Pong",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Column(
                          children: <Widget>[
                            FlatButton(
                                onPressed: () => _sortItem("Fitness"),
                                color: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.dumbbell,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    Text(
                                      "Fitness",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              productdata == null
                  ? Flexible(
                      child: Container(
                          color: Colors.white,
                          child: Center(
                              child: Text(
                            titlecenter,
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ))))
                  : Expanded(
                      child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: (screenWidth / screenHeight) / 0.85,
                          children: List.generate(productdata.length, (index) {
                            return Card(
                                elevation: 10,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () => _onImageDisplay(index),
                                        child: Container(
                                          height: screenHeight / 5.5,
                                          width: screenWidth / 1.2,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.scaleDown,
                                            imageUrl: server +
                                                "/productimage/${productdata[index]['id']}.jpg",
                                            placeholder: (context, url) =>
                                                new CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    new Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "ID: " + productdata[index]['id'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Expanded(
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15, 10, 15, 0),
                                              child: Text(
                                                  productdata[index]['name'],
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)))),
                                      Text(
                                        "Category: " +
                                            productdata[index]['type'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "RM" + productdata[index]['price'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Available: " +
                                            productdata[index]['quantity'],
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      MaterialButton(
                                        minWidth: 100,
                                        height: 30,
                                        child: Text('Manage Item'),
                                        color: Colors.redAccent,
                                        textColor: Colors.black,
                                        elevation: 10,
                                        onPressed: () => _manageItem(index),
                                      ),
                                    ],
                                  ),
                                ));
                          })),
                    ),
            ],
          ),
        ),
      ),
      // floatingActionButton: Visibility(
      //   child: FloatingActionButton.extended(
      //     onPressed: () async {
      //       await Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (BuildContext context) => ManageproductPage(
      //                     user: widget.user,
      //                   )));
      //       // _loadData();
      //       // _loadCartQuantity();
      //     },
      //     icon: Icon(Icons.add),
      //     label: Text("Add Product"),
      //   ),
      // ),
    );
  }

  _onImageDisplay(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: new Container(
                height: screenHeight / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Product Details",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.black, size: 30),
                            onPressed: () => Navigator.of(context).pop(false),
                          )
                        ]),
                    Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 30, 5),
                        child: Text(productdata[index]['name'],
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black))),
                    Flexible(
                      child: Container(
                          height: screenWidth / 3,
                          width: screenWidth / 3,
                          decoration: BoxDecoration(
                              //border: Border.all(color: Colors.black),
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      "http://seriouslaa.com/myestock/productimage/${productdata[index]['id']}.jpg")))),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 5),
                      child: Text(
                        "Price /unit: RM " + productdata[index]['price'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    Text(
                      "Quantity available:" + productdata[index]['quantity'],
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Weight:" + productdata[index]['weigth'] + " gram",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                )));
      },
    );
  }

  void _sortItem(String type) {
    try {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Searching...");
      pr.show();
      String urlLoadJobs =
          "https://seriouslaa.com/myestock/php/load_product.php";
      http
          .post(urlLoadJobs, body: {
            "type": type,
          })
          .timeout(const Duration(seconds: 4))
          .then((res) {
            if (res.body == "nodata") {
              Toast.show("Salected categories is Empty", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              pr.hide();
              FocusScope.of(context).requestFocus(new FocusNode());
              return;
            }
            setState(() {
              _sortcategory = false;
              curtype = type;
              var extractdata = json.decode(res.body);
              productdata = extractdata["products"];
              FocusScope.of(context).requestFocus(new FocusNode());
              pr.hide();
            });
          })
          .catchError((err) {
            print(err);
            pr.hide();
          });
      pr.hide();
    } catch (e) {
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _sortItembyName(String _searchController) {
    try {
      print(_searchController);
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Searching...");
      pr.show();
      String urlLoadJobs =
          "https://seriouslaa.com/myestock/php/load_product.php";
      http
          .post(urlLoadJobs, body: {
            "name": _searchController.toString(),
          })
          .timeout(const Duration(seconds: 4))
          .then((res) {
            if (res.body == "nodata") {
              Toast.show("Product not found", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
              pr..hide();
              FocusScope.of(context).requestFocus(new FocusNode());
              return;
            }
            if (_searchController == "") {
              Toast.show("Please enter something", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
              pr..hide();
              FocusScope.of(context).requestFocus(new FocusNode());
              return;
            }
            setState(() {
              var extractdata = json.decode(res.body);
              productdata = extractdata["products"];
              FocusScope.of(context).requestFocus(new FocusNode());
              curtype = _searchController;
              pr.hide();
            });
          })
          .catchError((err) {
            pr.hide();
          });
      pr.hide();
    } on TimeoutException catch (_) {
      Toast.show("Time out", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } on SocketException catch (_) {
      Toast.show("Time out", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } catch (e) {
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Widget mainDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            arrowColor: Colors.red,
            accountName: Text(widget.user.name),
            accountEmail: Text(widget.user.email),
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
            onDetailsPressed: () => {},
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Text(
              "Admin Menu",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.assignment),
              title: Text(
                "View Products",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ManageproductPage(
                                  user: widget.user,
                                )))
                  }
              // _paymentScreen
              ),
          ListTile(
              leading: Icon(Icons.add),
              title: Text(
                "Add New Products",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: createNewProduct
              // _paymentScreen
              ),
          SizedBox(
            height: 5,
          ),
          Divider(
            height: 5,
            color: Colors.black,
          ),
          ListTile(
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.supervised_user_circle),
              title: Text(
                "Customer Session",
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
                    showDialog(
                      context: context,
                      builder: (context) => new AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        title: new Text(
                          'Logging out?',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        content: new Text(
                          'Are you sure?',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        actions: <Widget>[
                          MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            WelcomePage()));
                                //exit(0);
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              )),
                          MaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              )),
                        ],
                      ),
                    )
                  }),
        ],
      ),
    );
  }

  void _loadData() async {
    String urlLoadJobs = server + "/php/load_product.php";
    await http.post(urlLoadJobs, body: {}).then((res) {
      if (res.body == "nodata") {
        titlecenter = "No product found";
        setState(() {
          productdata = null;
        });
      } else {
        setState(() {
          var extractdata = json.decode(res.body);
          productdata = extractdata["products"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    //_getLocation();
    _loadData();
    return null;
  }

  _manageItem(index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Select item options:",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                  color: Colors.redAccent,
                  onPressed: () =>
                      {Navigator.of(context).pop(), _onProductDetail(index)},
                  elevation: 5,
                  child: Text(
                    "Update Item",
                    style: TextStyle(color: Colors.black),
                  )),
              MaterialButton(
                  color: Colors.redAccent,
                  onPressed: () => {
                        Navigator.of(context).pop(),
                        _deleteProductDialog(index)
                      },
                  elevation: 5,
                  child: Text(
                    "Delete Item",
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _deleteProductDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Delete " + productdata[index]['name'] + " from data?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content:
              new Text("Are you sure?", style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(index);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  color: Colors.red,
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

  void _deleteProduct(int index) {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Deleting product...");
    pr.show();
    http.post(server + "/php/delete_product.php", body: {
      "prodid": productdata[index]['id'],
    }).then((res) {
      print(res.body);
      pr.hide();
      if (res.body == "success") {
        Toast.show("Delete success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _loadData();
        // Navigator.of(context).pop();
      } else {
        Toast.show("Delete failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
      pr.hide();
    });
  }

  Future<void> createNewProduct() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => NewProduct()));
    _loadData();
  }

  _onProductDetail(int index) async {
    print(productdata[index]['name']);
    Product product = new Product(
        id: productdata[index]['id'],
        name: productdata[index]['name'],
        price: productdata[index]['price'],
        quantity: productdata[index]['quantity'],
        weigth: productdata[index]['weigth'],
        type: productdata[index]['type'],
        date: productdata[index]['date']);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UpdateProductPage(
                  user: widget.user,
                  product: product,
                )));
    _loadData();
  }
}
