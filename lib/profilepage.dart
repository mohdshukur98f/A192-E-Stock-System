import 'dart:convert';
// import 'dart:html';
import 'dart:io';

import 'package:estocksystem/navigationpage.dart';
import 'package:estocksystem/cartpage.dart';
import 'package:estocksystem/historypage.dart';
import 'package:estocksystem/loginpage.dart';
import 'package:estocksystem/reloadCreditPage.dart';
import 'package:estocksystem/signuppage.dart';
import 'package:estocksystem/user.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:recase/recase.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  double screenHeight, screenWidth;
  String server = "https://seriouslaa.com/myestock";

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: mainDrawer(context),
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Colors.black,
          title: Text('Profile Page'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                MdiIcons.cameraPlusOutline,
                color: Colors.redAccent,
              ),
              iconSize: 35,
              onPressed: _takePicture,
            ),
          ],
          bottom: new TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.orangeAccent]),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.black),
              tabs: [
                new Tab(
                  icon: Icon(Icons.person),
                  text: "PROFILE INFORMATION",
                ),
                new Tab(
                  icon: Icon(Icons.settings),
                  text: "PROFILE SETTING",
                ),
              ]),
          flexibleSpace: GestureDetector(
              // onTap: _displaypicture,
              child: CachedNetworkImage(
                  fit: BoxFit.fitWidth,
                  imageUrl: server + "/profileimages/${widget.user.email}.jpg",
                  errorWidget: (context, url, error) => Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Icon(
                          Icons.people,
                          size: 100.0,
                        ),
                      ))),
        ),
        preferredSize: Size.fromHeight(230.0),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          Stack(
            children: <Widget>[
              upperHalf(context),
              lowerHalf(context),
            ],
          ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    // Container(
                    //   child: Text(
                    //     "Set up your Profile",
                    //     style: TextStyle(
                    //         fontSize: 20, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    Container(
                        child: ListView(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                            shrinkWrap: true,
                            children: <Widget>[
                          MaterialButton(
                              onPressed: changeName,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("CHANGE YOUR NAME"),
                                ],
                              )),
                          Divider(
                            height: 5,
                            color: Colors.black,
                          ),
                          MaterialButton(
                              // color: Colors.redAccent,
                              onPressed: changePassword,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("CHANGE YOUR PASSWORD"),
                                ],
                              )),
                          Divider(
                            height: 5,
                            color: Colors.black,
                          ),
                          MaterialButton(
                              // color: Colors.redAccent,
                              onPressed: changePhone,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("CHANGE YOUR PHONE"),
                                ],
                              )),
                          Divider(
                            height: 5,
                            color: Colors.black,
                          ),
                          MaterialButton(
                              // color: Colors.redAccent,
                              onPressed: _reloadCredit,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("RELOAD CREDIT"),
                                ],
                              )),
                          Divider(
                            height: 5,
                            color: Colors.black,
                          ),
                          MaterialButton(
                              // color: Colors.redAccent,
                              onPressed: _gotologinPage,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("CONTINUE TO LOG IN"),
                                ],
                              )),
                          Divider(
                            height: 5,
                            color: Colors.black,
                          ),
                          MaterialButton(
                              // color: Colors.redAccent,
                              onPressed: _createAccount,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("CREATE NEW ACCOUNT"),
                                ],
                              )),
                          Divider(
                            height: 5,
                            color: Colors.black,
                          ),
                        ])),
                  ],
                )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget upperHalf(BuildContext context) {
    return Container(
      height: screenHeight / 2,
      child: Image.asset(
        'assets/images/login.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget lowerHalf(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Card(
            elevation: 5,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                Text("User Details",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                SizedBox(height: 10),
                Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                    //color: Colors.red,
                    child: Table(
                        defaultColumnWidth: FlexColumnWidth(1.0),
                        columnWidths: {
                          0: FlexColumnWidth(2.5),
                          1: FlexColumnWidth(3),
                        },

                        //border: TableBorder.all(color: Colors.white),
                        children: [
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 30,
                                  child: Text("Name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(widget.user.name,
                                        style: TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Container(

                                  // height: 30,
                                  alignment: Alignment.centerLeft,
                                  // height: 20,
                                  child: Text("Username",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: Text(widget.user.username,
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text("Email",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(widget.user.email,
                                        style: TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text("Phone Number",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: Text(widget.user.phone,
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text("Gender",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: Text(widget.user.gender,
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text("Registered Date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(widget.user.dateregister,
                                        style: TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  )),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text("Account Status",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: Text(widget.user.verify,
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 20,
                                  child: Text("Credit Balance",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: Text(widget.user.credit,
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ),
                          ]),
                        ])),
              ],
            )));
  }

  void _takePicture() async {
    if (widget.user.email == "guest") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    File _image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 300);
    //print(_image.lengthSync());
    if (_image == null) {
      Toast.show("Please take image first", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } else {
      String base64Image = base64Encode(_image.readAsBytesSync());
      print(base64Image);
      http.post(server + "/php/upload_image.php", body: {
        "encoded_string": base64Image,
        "email": widget.user.email,
      }).then((res) {
        print(res.body);
        if (res.body == "success") {
          setState(() {
            DefaultCacheManager manager = new DefaultCacheManager();
            manager.emptyCache();
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ProfilePage(
                        user: widget.user,
                      )));
        } else {
          Toast.show("Tidak berjaya", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        print(err);
      });
    }
  }

  void changeName() {
    if (widget.user.email == "guest") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (widget.user.email == "admin") {
      Toast.show("This is Admin Mode!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    TextEditingController nameController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: new Text(
                "Change your name?",
                style: TextStyle(color: Colors.black),
              ),
              content: new TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    icon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  )),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () =>
                        _changeName(nameController.text.toString())),
                new FlatButton(
                  child: new Text(
                    "No",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
              ]);
        });
  }

  _changeName(String name) {
    if (widget.user.email == "guest") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (name == "" || name == null) {
      Toast.show("Please enter your new name", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    ReCase rc = new ReCase(name);
    print(rc.titleCase.toString());
    http.post(server + "/php/update_profile.php", body: {
      "email": widget.user.email,
      "name": rc.titleCase.toString(),
    }).then((res) {
      if (res.body == "success") {
        print('in success');

        setState(() {
          widget.user.name = rc.titleCase;
        });
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.of(context).pop();
        return;
      } else {}
    }).catchError((err) {
      print(err);
    });
  }

  void changePassword() {
    if (widget.user.email == "guest") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    TextEditingController passController = TextEditingController();
    TextEditingController pass2Controller = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: new Text(
                "Change your password?",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              content: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                      style: TextStyle(color: Colors.black),
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        icon: Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                      )),
                  TextField(
                      style: TextStyle(color: Colors.black),
                      obscureText: true,
                      controller: pass2Controller,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        icon: Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                      )),
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => updatePassword(
                        passController.text, pass2Controller.text)),
                new FlatButton(
                  child: new Text(
                    "No",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
              ]);
        });
  }

  updatePassword(String pass1, String pass2) {
    if (pass1 == "" || pass2 == "") {
      Toast.show("Please enter your password", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }

    http.post(server + "/php/update_profile.php", body: {
      "email": widget.user.email,
      "oldpassword": pass1,
      "newpassword": pass2,
    }).then((res) {
      if (res.body == "success") {
        print('in success');
        setState(() {
          widget.user.password = pass2;
        });
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.of(context).pop();
        return;
      } else {
        Toast.show("Failed! Your old password maybe Wrong,", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        // Navigator.of(context).pop();
      }
    }).catchError((err) {
      print(err);
    });
  }

  void changePhone() {
    if (widget.user.email == "guest") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    TextEditingController phoneController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: new Text(
                "Change your name?",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              content: new TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'New Phone Number',
                    icon: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                  )),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () =>
                        _changePhone(phoneController.text.toString())),
                new FlatButton(
                  child: new Text(
                    "No",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
              ]);
        });
  }

  _changePhone(String phone) {
    if (phone == "" || phone == null || phone.length < 9) {
      Toast.show("Please enter correct number", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    http.post(server + "/php/update_profile.php", body: {
      "email": widget.user.email,
      "phone": phone,
    }).then((res) {
      if (res.body == "success") {
        print('in success');

        setState(() {
          widget.user.phone = phone;
        });
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.of(context).pop();
        return;
      } else {}
    }).catchError((err) {
      print(err);
    });
  }

  void _gotologinPage() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Are you sure?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        content: new Text(
          'Do you want to Log out?',
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
                        builder: (BuildContext context) => LoginPage()));
              },
              child: Text(
                "Confirm",
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
      ),
    );
  }

  void _createAccount() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Create new account',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        content: new Text(
          'Continue to Register?',
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
                        builder: (BuildContext context) => SignupPage()));
              },
              child: Text(
                "Confirm",
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
      ),
    );
  }

  void _reloadCredit() {
    if (widget.user.email == "guest") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    TextEditingController creditController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: new Text(
                "Buy Store Credit?",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              content: new TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: creditController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter RM',
                    icon: Icon(
                      Icons.credit_card,
                      color: Colors.black,
                    ),
                  )),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () =>
                        _buyCredit(creditController.text.toString())),
                new FlatButton(
                  child: new Text(
                    "No",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
              ]);
        });
  }

  _buyCredit(String cr) {
    print("RM " + cr);
    if (cr.length <= 0) {
      Toast.show("Please enter correct amount", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Buy store credit RM ' + cr,
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
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ReloadCreditPage(
                              user: widget.user,
                              val: cr,
                            )));
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  color: Colors.black,
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              )),
        ],
      ),
    );
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
