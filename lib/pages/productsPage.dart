import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mywarehouseproject/custom_widgets/floatingAddActionButton.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/models/product.dart';
import 'package:mywarehouseproject/pages/newProductPage.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  Widget _buildProductListTile(DocumentSnapshot document, MainModel model) {
    return ListTile(
      title: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).accentColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            (document['imageUrl'] != "" && document['imageUrl'] != null)
                ? FadeInImage(
                    fit: BoxFit.cover,
                    height: 55.0,
                    width: 55.0,
                    image: NetworkImage(document['imageUrl']),
                    placeholder:
                        AssetImage('assets/Images/default-product-picture.jpg'),
                  )
                : Image.asset(
                    'assets/Images/default-product-picture.jpg',
                    fit: BoxFit.cover,
                    height: 55.0,
                    width: 55.0,
                  ),
            SizedBox(
              width: 15.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  document['name'],
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                Text(
                  "Quantity left: ${document['quantity']} ${document['measurementUnit']}",
                  style: TextStyle(
                      color: Theme.of(context).accentColor, fontSize: 10.0),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              child: Icon(Icons.edit, color: Theme.of(context).accentColor),
              onTap: () {
                // Make user and send to newUserPage
                Product editUser = Product(
                  id: document.documentID,
                  name: document['name'],
                  description: document['description'],
                  whereIsStored: document['whereIsStored'],
                  measurementUnit: document['measurementUnit'],
                  quantity: document['quantity'],
                  barcode: document['barcode'],
                  imageUrl: document['imageUrl'],
                );
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            NewProductPage(model, editUser)));
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
                            "Are you sure you want to permently delete product '${document['name']}' ?"),
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
                                  model.deleteProduct(document.documentID,
                                      document['name'], document['imageUrl']);
                                } else {
                                  model.deleteProduct(document.documentID);
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

  Widget _buildProductsList() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return StreamBuilder(
          stream: model.getProductsStream(),
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
                return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => _buildProductListTile(
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
              labelText: "Search for product",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            onChanged: (String typed) {
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[_buildSearchEngine(), Divider(), _buildProductsList()],
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
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: _buildBody(),
        floatingActionButton: FloatingAddActionButton("/newProduct"));
  }
}
