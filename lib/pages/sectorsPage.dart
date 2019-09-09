import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/models/sector.dart';
import 'package:mywarehouseproject/pages/newSectorPage.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:scoped_model/scoped_model.dart';

class SectorsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SectorsPageState();
  }
}

class _SectorsPageState extends State<SectorsPage> {
  Widget _buildSectorListTile(
      DocumentSnapshot document, String sectorSearch, MainModel model) {
    return ListTile(
      title: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).accentColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                document['name'],
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
            GestureDetector(
              child: Icon(Icons.edit, color: Theme.of(context).accentColor),
              onTap: () {
                Sector editSector = Sector(
                    id: document.documentID,
                    name: document['name'],
                    description: document['description']);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            NewSectorPage(editSector)));
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
                          color: Theme.of(context).accentColor,
                        )),
                        content: Text("Are you sure you want to delete '" +
                            document['name'] +
                            "' sector?"),
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
                                model.deleteSector(document.documentID);
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

  Widget _buildSectorsList() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return StreamBuilder(
          stream: model.getSectorsFirestoreStream(),
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
                        itemBuilder: (context, index) => _buildSectorListTile(
                            snapshot.data.documents[index],
                            model.sectorSearch,
                            model)));
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
              labelText: "Search sector",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            onChanged: (String typed) {
              setState(() {
                model.setSectorSearch(typed);
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
        _buildSectorsList(),
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
    );
  }
}
