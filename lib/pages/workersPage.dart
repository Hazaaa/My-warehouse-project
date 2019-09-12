import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mywarehouseproject/custom_widgets/floatingAddActionButton.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/models/user.dart';
import 'package:mywarehouseproject/pages/newUserPage.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:scoped_model/scoped_model.dart';

class WorkersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WorkersPageState();
  }
}

class _WorkersPageState extends State<WorkersPage> {
  Widget _buildWorkerListTile(DocumentSnapshot document, MainModel model) {
    return ListTile(
      title: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).accentColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              child: (document['imageUrl'] != "" &&
                      document['imageUrl'] != null)
                  ? FadeInImage(
                      fit: BoxFit.cover,
                      height: 55.0,
                      width: 55.0,
                      image: NetworkImage(document['imageUrl']),
                      placeholder:
                          AssetImage('assets/Images/default-user-picture.png'),
                    )
                  : Image.asset(
                      'assets/Images/default-user-picture.png',
                      fit: BoxFit.cover,
                      height: 55.0,
                      width: 55.0,
                    ),
              borderRadius: BorderRadius.circular(50.0),
            ),
            SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: Text(
                document['name'],
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
            GestureDetector(
              child: Icon(Icons.edit, color: Theme.of(context).accentColor),
              onTap: () {
                // Make user and send to newUserPage
                User editUser = User(
                  id: document.documentID,
                  name: document['name'],
                  address: document['address'],
                  adminOrUser: document['adminOrUser'],
                  email: document['email'],
                  imageUrl: document['imageUrl'],
                  phone: document['phone'],
                  rights: (document['rights'] == null)
                      ? []
                      : document['rights'].cast<String>(),
                  sector: document['sector'],
                );
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            NewUserPage(model,editUser)));
              },
            ),
            SizedBox(width: 20.0),
            GestureDetector(
              child: Icon(Icons.delete_forever,
                  color: Theme.of(context).accentColor),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        contentTextStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 20.0),
                        backgroundColor: Theme.of(context).primaryColor,
                        title: Center(
                            child: Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        )),
                        content: Text(
                            "Are you sure you want to permently delete worker '${document['name']}' ?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              "No",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Theme.of(context).accentColor),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Theme.of(context).accentColor),
                            ),
                            onPressed: () {
                              setState(() {
                                if (document['imageUrl'] != null &&
                                    document['imageUrl'] != "") {
                                  model.deleteUser(document.documentID,
                                      document['name'], document['imageUrl']);
                                } else {
                                  model.deleteUser(document.documentID);
                                }
                                Navigator.of(context).pop();
                              });
                            },
                          )
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return StreamBuilder(
          stream: model.getWorkersStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                    children: <Widget>[CircularProgressIndicator()],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center),
              );
            } else {
              if (snapshot.data.documents.isEmpty) {
                return Container(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Center(
                      child: Text(
                    "No reports",
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  )),
                );
              } else {
                return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => _buildWorkerListTile(
                            snapshot.data.documents[index], model)));
              }
            }
          },
        );
      },
    );
  }

  Widget _buildSearchEngine() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
          child: TextField(
            cursorColor: Colors.white,
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: Colors.white,
              disabledBorder: InputBorder.none,
              border: InputBorder.none,
              labelText: "Search worker",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            onChanged: (String typed) {
              setState(() {
                
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        _buildSearchEngine(),
        Divider(),
        _buildWorkersList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/main');
          },
        ),
        title: LogoAppBar(),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingAddActionButton("/newUser"),
    );
  }
}
