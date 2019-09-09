import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:scoped_model/scoped_model.dart';

class ReportsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportsPageState();
  }
}

class _ReportsPageState extends State<ReportsPage> {
  Widget _buildReportListTile(DocumentSnapshot document, MainModel model) {
    return ListTile(
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            model.formatDate(document['time'].toDate().toLocal()),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          _buildDeleteIcon(model, document)
        ],
      ),
      title: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).accentColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ExpansionTile(
          title: Text(
            document['userReported'] != null
                ? document['userReported']
                : "Unknown",
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 18.0,
                letterSpacing: 1.0),
          ),
          children: <Widget>[
            Text(
              document['description'],
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteIcon(MainModel model, DocumentSnapshot document) {
    return GestureDetector(
      child: Icon(Icons.delete_forever, color: Theme.of(context).accentColor),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                contentTextStyle: TextStyle(
                    color: Theme.of(context).accentColor, fontSize: 20.0),
                backgroundColor: Theme.of(context).primaryColor,
                title: Center(
                    child: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).accentColor,
                )),
                content:
                    Text("Are you sure you want to permanently delete report?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "No",
                      style: TextStyle(
                          fontSize: 18.0, color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                          fontSize: 18.0, color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      setState(() {
                        model.deleteReport(document.documentID);
                        Navigator.of(context).pop();
                      });
                    },
                  )
                ],
              );
            });
      },
    );
  }

  Widget _buildReportList() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return StreamBuilder(
          stream: model.getReportsStream(),
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
                        itemBuilder: (context, index) => _buildReportListTile(
                            snapshot.data.documents[index], model)));
              }
            }
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        SizedBox(height: 10.0,),
        _buildReportList(),
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
