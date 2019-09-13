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
  final TextEditingController _quantityAddTextFieldController =
      TextEditingController();
  final TextEditingController _priceAddTextFieldController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> pickedProducts = [];
  bool sortAscending = false;
  int sortColumn = 0;
  int totalPrice = 0;

  @override
  void dispose() {
    _fromTextFieldController.dispose();
    _quantityAddTextFieldController.dispose();
    _priceAddTextFieldController.dispose();
    super.dispose();
  }

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
        child: Text(
          "${document['name']}                Left: ${document['quantity']} ${document['measurementUnit']}",
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "Add",
                      style: TextStyle(
                          fontSize: 18.0, color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      setState(() {
                        pickedProducts
                            .removeWhere((x) => x['id'] == document.documentID);
                        pickedProducts.add({
                          'id': document.documentID,
                          'name': document['name'],
                          'quantity': document['quantity'],
                          'measurementUnit': document['measurementUnit'],
                          'arrivedQuantity':
                              _quantityAddTextFieldController.text.isEmpty
                                  ? 0
                                  : int.parse(_quantityAddTextFieldController.text),
                          'pricePerUnit':
                              _priceAddTextFieldController.text.isEmpty
                                  ? 0
                                  : int.parse(_priceAddTextFieldController.text)
                        });
                        countTotalPrice();
                        _addNewShipmentError = false;
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(
                  "Quantity",
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Container(
                        padding: EdgeInsets.only(left: 6.0, right: 6.0),
                        child: TextField(
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                          controller: _quantityAddTextFieldController,
                          cursorColor: Theme.of(context).accentColor,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Quantity",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            prefixIcon: Icon(
                              Icons.filter_9_plus,
                              color: Theme.of(context).accentColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 1.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 1.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        padding: EdgeInsets.only(left: 6.0, right: 6.0),
                        child: TextField(
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                          controller: _priceAddTextFieldController,
                          cursorColor: Theme.of(context).accentColor,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Price per unit",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Theme.of(context).accentColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 1.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 1.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).whenComplete(() {
          _quantityAddTextFieldController.text = "";
          _priceAddTextFieldController.text = "";
        });
      },
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
            showModalBottomSheet(
              backgroundColor: Theme.of(context).primaryColor,
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.only(top: 10.0),
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: StreamBuilder(
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
                          for (var product in pickedProducts) {
                            final getData = snapshot.data.documents.singleWhere(
                                (x) => x.documentID == product['id']);
                            if (getData != null) {
                              product['quantity'] = getData['quantity'];
                            }
                          }
                          return ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                return _buildProductTile(
                                  snapshot.data.documents[index],
                                );
                              });
                        }
                      }
                    },
                  ),
                );
              },
            ).whenComplete(() {
              setState(() {});
            });
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

  void sortDataTableColumns(int columnIndex, bool ascending) {
    setState(() {
      sortColumn = columnIndex;
      sortAscending = ascending;
      switch (columnIndex) {
        case 0:
          {
            if (ascending) {
              pickedProducts.sort((a, b) => a['name'].compareTo(b['name']));
            } else {
              pickedProducts.sort((a, b) => b['name'].compareTo(a['name']));
            }
          }
          break;
        case 1:
          {
            if (ascending) {
              pickedProducts
                  .sort((a, b) => a['quantity'].compareTo(b['quantity']));
            } else {
              pickedProducts
                  .sort((a, b) => b['quantity'].compareTo(a['quantity']));
            }
          }
          break;
        case 2:
          {
            if (ascending) {
              pickedProducts.sort((a, b) =>
                  a['arrivedQuantity'].compareTo(b['arrivedQuantity']));
            } else {
              pickedProducts.sort((a, b) =>
                  b['arrivedQuantity'].compareTo(a['arrivedQuantity']));
            }
          }
          break;
        case 3:
          {
            if (ascending) {
              pickedProducts.sort(
                  (a, b) => a['pricePerUnit'].compareTo(b['pricePerUnit']));
            } else {
              pickedProducts.sort(
                  (a, b) => b['pricePerUnit'].compareTo(a['pricePerUnit']));
            }
          }
          break;
        default:
      }
    });
  }

  void countTotalPrice() {
    totalPrice = 0;
    for (var product in pickedProducts) {
      totalPrice += product['arrivedQuantity'] *
          product['pricePerUnit'];
    }
  }

  Widget _buildDataTableWithProducts() {
    return FittedBox(
      child: DataTable(
          sortAscending: sortAscending,
          sortColumnIndex: sortColumn,
          columnSpacing: 20.0,
          columns: <DataColumn>[
            DataColumn(
                label: Text("Product: "),
                onSort: (columnIndex, ascending) {
                  sortDataTableColumns(columnIndex, ascending);
                }),
            DataColumn(
                label: Text("Quantity: "),
                numeric: true,
                onSort: (columnIndex, ascending) {
                  sortDataTableColumns(columnIndex, ascending);
                }),
            DataColumn(
                label: Text("Arrived: "),
                numeric: true,
                onSort: (columnIndex, ascending) {
                  sortDataTableColumns(columnIndex, ascending);
                }),
            DataColumn(
                label: Text("Price: "),
                numeric: true,
                onSort: (columnIndex, ascending) {
                  sortDataTableColumns(columnIndex, ascending);
                }),
            DataColumn(label: Text(""))
          ],
          rows: _getDataRows()),
    );
  }

  List<DataRow> _getDataRows() {
    List<DataRow> rows = [];

    for (var product in pickedProducts) {
      rows.add(DataRow(cells: <DataCell>[
        DataCell(Text(product['name'])),
        DataCell(Text(product['quantity'].toString())),
        DataCell(Text(product['arrivedQuantity'].toString())),
        DataCell(Text(product['pricePerUnit'].toString() + " \$")),
        DataCell(
            Icon(
              Icons.remove,
              color: Colors.red,
            ), onTap: () {
          setState(() {
            pickedProducts.remove(product);
            countTotalPrice();
          });
        })
      ]));
    }

    return rows;
  }

  Widget _buildAddNewShipmentButton() {
    return ButtonTheme(
        minWidth: 150.0,
        height: 50.0,
        child: FlatButton(
          child: widget._model.isLoading
              ? CircularProgressIndicator()
              : Text(
                  "CREATE RECEIPT",
                  style: TextStyle(
                      fontSize: 15.0,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          onPressed: () {
            setState(() {
              if (pickedProducts.isEmpty) {
                _addNewShipmentError = true;
                _addNewShipmentErrorMessage =
                    "You can't create new shipment without added products.";
                return;
              }
              if (_fromTextFieldController.text.isEmpty) {
                _addNewShipmentError = true;
                _addNewShipmentErrorMessage = "From text field can't be empty.";
                return;
              }

              _addNewShipmentError = false;
              _addNewShipmentErrorMessage = "";

              if (!_addNewShipmentError) {
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
                        content:
                            Text("Are you sure you want to create receipt?"),
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
                              Navigator.of(context).pop();
                              submitShipment();
                            },
                          )
                        ],
                      );
                    });
              }
            });
          },
        ));
  }

  void submitShipment() async {
    final Map<String, dynamic> addShipmentResponse =
        await widget._model.addNewShipment({
      'from': _fromTextFieldController.text,
      'productsArrived': pickedProducts,
      'totalPrice': totalPrice
    });

    setState(() {
      if (!addShipmentResponse['success']) {
        _addNewShipmentError = true;
        _addNewShipmentErrorMessage = addShipmentResponse['message'];
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
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
                  _buildPickProductButton(),
                  _buildDataTableWithProducts(),
                  SizedBox(height: 10.0),
                  Visibility(
                      child: Text("Total price: ${totalPrice} \$"),
                      visible: (pickedProducts != null &&
                          pickedProducts.isNotEmpty)),
                  SizedBox(height: 5.0),
                  _buildAddNewShipmentButton(),
                  _buildAddNewShipmentError(),
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
            if (!_fromTextFieldController.text.isEmpty ||
                pickedProducts.isNotEmpty) {
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

  bool _addNewShipmentError = false;
  String _addNewShipmentErrorMessage = "";

  Widget _buildAddNewShipmentError() {
    return Visibility(
        visible: _addNewShipmentError,
        child: FittedBox(
            child: Container(
                padding: EdgeInsets.only(left: 8.0, top: 6.0),
                child: Text(_addNewShipmentErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16.0)))));
  }
}
