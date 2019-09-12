import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/custom_widgets/yesNoAlertDialog.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';

class NewShipmentPage extends StatefulWidget {
  final MainModel _model;

  NewShipmentPage(this._model);

  @override
  State<StatefulWidget> createState() {
    return _NewShipmentPageState();
  }
}

class _NewShipmentPageState extends State<NewShipmentPage> {
  final TextEditingController _fromTextFieldController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> pickedProducts;

  Widget _buildFromTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        controller: _fromTextFieldController,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "From",
          prefixIcon: Icon(Icons.store_mall_directory),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "From field shouldn't be empty.";
          }
          return null;
        },
        onSaved: (String typed) {},
      ),
    );
  }

  Widget _buildProductTile(DocumentSnapshot document) {
    return ListTile(
      title: Container(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).accentColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child:
              Text("${document['name']}       Left:${document['quantity']}")),
    );
  }

  Widget _buildPickProductButton() {
    return ListTile(
      leading: ButtonTheme(
        minWidth: 10,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: FlatButton(
          color: Theme.of(context).primaryColor,
          child: Icon(
            Icons.add,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            showDialog(
              builder: (BuildContext context) {
                return SimpleDialog(
                  backgroundColor: Theme.of(context).primaryColor,
                  title: Center(
                    child: Text(
                      "Pick product",
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  titlePadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  children: <Widget>[
                    StreamBuilder(
                      stream: widget._model.getProductsStream(),
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
                                "No products",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              )),
                            );
                          } else {
                            return ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (context, index) =>
                                        _buildProductTile(
                                          snapshot.data.documents[index],
                                        ));
                          }
                        }
                      },
                    ),
                  ],
                );
              },
              context: context,
            );
          },
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Text(
          "Products arrived",
          style: TextStyle(
              color: Colors.grey, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
              child: Text(
                "New shipment",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  _buildFromTextField(),
                  SizedBox(height: 10.0),
                  _buildPickProductButton()
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!_fromTextFieldController.text.isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return YesNoAlertDialog(
                        "Are you sure that you want to discard all inputs and go back?",
                        "/main");
                  });
            } else {
              Navigator.of(context).pushReplacementNamed('/main');
            }
          },
        ),
        title: LogoAppBar(),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: _buildBody(),
    );
  }
}
