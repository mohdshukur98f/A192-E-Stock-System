import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:estocksystem/user.dart';
import 'package:estocksystem/welcomepage.dart';
import 'package:estocksystem/navigationpage.dart';
import 'package:estocksystem/profilepage.dart';
import 'package:estocksystem/cartpage.dart';
import 'package:estocksystem/manageproductpage.dart';
import 'package:estocksystem/historypage.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key key, this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  bool _havecart = false;
  bool _isadmin = false;

  Icon searchIcon = Icon(Icons.search, color: Colors.black, size: 25);
  Widget searchBar = Text(
    "MY E-STOCK",
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    textAlign: TextAlign.center,
  );
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCartQuantity();
    refreshKey = GlobalKey<RefreshIndicatorState>();

    if (widget.user.email == "admin") {
      _isadmin = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    TextEditingController _searchController = new TextEditingController();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.red,
        ),
        title: 'Material App',
        home: Scaffold(
          backgroundColor: Color.fromRGBO(255, 34, 34, 20),
          resizeToAvoidBottomPadding: false,
          drawer: mainDrawer(context),
          appBar: AppBar(
            // centerTitle: true,
            title: searchBar,
            iconTheme: new IconThemeData(color: Colors.black),
            // leading: IconButton(icon: Icon(Icons.search), onPressed: () {}),
            backgroundColor: Colors.white,
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
              new Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.shopping_cart,
                        color: Colors.black, size: 25),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => CartPage(
                                    user: widget.user,
                                  )));
                    },
                  ),
                  new Positioned(
                      top: 1.0,
                      right: -10.0,
                      child: Visibility(
                          visible: _havecart,
                          child: new Container(
                            decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(30.0),
                                color: Colors.red),
                            width: 30.0,
                            child: new Text(
                              widget.user.quantity,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13),
                            ),
                          )))
                ],
              ),
              SizedBox(
                width: 11,
              )
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
                    //SizedBox(height: 5.0),
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
                                    color: Colors.white),
                              ))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 0, 3),
                              child: Container(
                                  height: 40,
                                  decoration:
                                      new BoxDecoration(color: Colors.white),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(width: 5.0),
                                      Text(curtype,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            color: Colors.red,
                                            background: Paint()
                                              ..color = Colors.white,
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                childAspectRatio:
                                    (screenWidth / screenHeight) / 0.8,
                                children:
                                    List.generate(productdata.length, (index) {
                                  return Card(
                                      elevation: 10,
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () =>
                                                  _onImageDisplay(index),
                                              child: Container(
                                                height: screenHeight / 5.5,
                                                width: screenWidth / 1,
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
                                            Expanded(
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            15, 10, 15, 0),
                                                    child: Text(
                                                        productdata[index]
                                                            ['name'],
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .black)))),
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
                                              "RM" +
                                                  productdata[index]['price'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "Available: " +
                                                  productdata[index]
                                                      ['quantity'],
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            // Text(
                                            //   "Type:" + productdata[index]['type'],
                                            //   style: TextStyle(
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
                                            MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              minWidth: 100,
                                              height: 30,
                                              child: Text('Add to Cart'),
                                              color: Colors.redAccent,
                                              textColor: Colors.black,
                                              elevation: 10,
                                              onPressed: () =>
                                                  _addtocartdialog(index),
                                            ),
                                          ],
                                        ),
                                      ));
                                })),
                          ),
                  ],
                ),
              )),
          floatingActionButton: Visibility(
            visible: _isadmin,
            child: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ManageproductPage(
                              user: widget.user,
                            )));
                // _loadData();
                // _loadCartQuantity();
              },
              icon: Icon(Icons.assignment),
              label: Text("Manage Product"),
            ),
          ),
        ));
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
            ),
            onDetailsPressed: () => {},
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
                  }),
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
                  }),
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
                  }),
          Visibility(
              visible: _isadmin,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    height: 5,
                    color: Colors.black,
                  ),
                  ListTile(
                      trailing: Icon(Icons.arrow_forward),
                      leading: Icon(Icons.settings),
                      title: Text(
                        "Admin Session",
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
                          }),
                ],
              )),
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

  void _loadData() async {
    String urlLoadJobs = server + "/php/load_product.php";
    await http.post(urlLoadJobs, body: {}).then((res) {
      if (res.body == "nodata") {
        cartquantity = "0";
        titlecenter = "No product found";
        setState(() {
          productdata = null;
          cartquantity = "0";
        });
      } else {
        setState(() {
          var extractdata = json.decode(res.body);
          productdata = extractdata["products"];
          cartquantity = widget.user.quantity;
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _loadCartQuantity() async {
    String urlLoadJobs = server + "/php/load_cartquantity.php";
    await http.post(urlLoadJobs, body: {
      "username": widget.user.username,
    }).then((res) {
      if (res.body == "nodata") {
      } else {
        widget.user.quantity = res.body;
        _havecart = true;
      }
    }).catchError((err) {
      print(err);
    });
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

  _onImageDisplay(int index) {
    if (widget.user.username == "guest") {
      Toast.show("Please Login first", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, newSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                    Text(
                      "Add " + productdata[index]['name'] + " to Cart?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    MaterialButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WelcomePage()));
                        },
                        child: Text(
                          "Please Login",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        )),
                  ],
                ),
                actions: <Widget>[
                  MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )),
                ],
              );
            });
          });

      return;
    }
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
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
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      minWidth: 100,
                      height: 30,
                      child: Text(
                        'Add to Cart',
                      ),
                      color: Colors.redAccent,
                      textColor: Colors.black,
                      elevation: 10,
                      onPressed: () => _addtocartdialog(index),
                    ),
                  ],
                )));
      },
    );
  }

  _addtocartdialog(int index) {
    if (widget.user.username == "guest") {
      Toast.show("Please Login first", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, newSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                    Text(
                      "Add " + productdata[index]['name'] + " to Cart?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    MaterialButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WelcomePage()));
                        },
                        child: Text(
                          "Please Login",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        )),
                  ],
                ),
                actions: <Widget>[
                  MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )),
                ],
              );
            });
          });

      return;
    }

    quantity = 1;
    //TextEditingController _newCartAddedController = new TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, newSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                  SizedBox(height: 8),
                  Text(
                    "Add " + productdata[index]['name'] + " to Cart?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Price/unit: RM" + productdata[index]['price'],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Select quantity of product",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.keyboard_arrow_left,
                                color: Colors.black, size: 30),
                            onPressed: () => newSetState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                })),
                        SizedBox(width: 20),
                        Text(
                          quantity.toString(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                            icon: Icon(Icons.keyboard_arrow_right,
                                color: Colors.black, size: 30),
                            onPressed: () => newSetState(() {
                                  if (quantity <
                                      (int.parse(
                                              productdata[index]['quantity']) -
                                          10)) {
                                    quantity++;
                                  } else {
                                    Toast.show(
                                        "Quantity not available", context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.BOTTOM);
                                  }
                                })),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      _addtoCart(index);
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
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )),
              ],
            );
          });
        });
  }

  void _addtoCart(int index) {
    try {
      int cquantity = int.parse(productdata[index]["quantity"]);
      print(cquantity);
      print(productdata[index]["id"]);
      print(widget.user.email);
      if (cquantity > 0) {
        ProgressDialog pr = new ProgressDialog(context,
            type: ProgressDialogType.Normal, isDismissible: true);
        pr.style(message: "Adding to cart...");
        pr.show();
        String urlLoadJobs =
            "https://seriouslaa.com/myestock/php/insert_cart.php";
        http.post(urlLoadJobs, body: {
          "username": widget.user.username,
          "productid": productdata[index]["id"],
          "quantity": quantity.toString(),
        }).then((res) {
          print(res.body);
          if (res.body == "failed") {
            Toast.show("Failed add to cart", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            pr.hide();
            return;
          } else {
            List respond = res.body.split(",");
            setState(() {
              cartquantity = respond[1];
              widget.user.quantity = cartquantity;
              _havecart = true;
              _loadCartQuantity();
            });
            Toast.show("Success add to cart", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
          pr.hide();
        }).catchError((err) {
          print(err);
          pr.hide();
        });
        pr.hide();
      } else {
        Toast.show("Out of stock", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } catch (e) {
      Toast.show("Failed add to cart", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    //_getLocation();
    _loadData();
    return null;
  }
}
