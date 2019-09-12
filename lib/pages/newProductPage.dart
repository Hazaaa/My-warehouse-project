import 'dart:io';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/custom_widgets/yesNoAlertDialog.dart';
import 'package:mywarehouseproject/models/product.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';

class NewProductPage extends StatefulWidget {
  final MainModel _model;
  final Product productForUpdate;

  NewProductPage(this._model, [this.productForUpdate]);

  @override
  State<StatefulWidget> createState() {
    return _NewProductPageState();
  }
}

class _NewProductPageState extends State<NewProductPage> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _barcodeTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {
    'name': null,
    'description': null,
    'quantity': null,
    'measurementUnit': null,
    'whereIsStored': null,
    'imageFile': null,
    'barcode': null
  };
  String selectedSector;
  File _imageFile;
  String barcodeForShow;

  @override
  void dispose() {
    _nameTextController.dispose();
    _barcodeTextController.dispose();
    super.dispose();
  }

  @override
  initState() {
    isProductForEdit
        ? barcodeForShow = widget.productForUpdate.barcode
        : barcodeForShow = null;
    isProductForEdit
        ? _barcodeTextController.text = widget.productForUpdate.barcode
        : "";
    isProductForEdit
        ? _nameTextController.text = widget.productForUpdate.name
        : "";
    super.initState();
  }

  bool get isProductForEdit {
    if (widget.productForUpdate != null) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildNameTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        controller: _nameTextController,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Product name",
          prefixIcon: Icon(Icons.unarchive),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "Product name field shouldn't be empty.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['name'] = typed;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        initialValue:
            isProductForEdit ? widget.productForUpdate.description : "",
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "More description [optional]",
          prefixIcon: Icon(Icons.description),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "Product description field shouldn't be empty.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['description'] = typed;
        },
      ),
    );
  }

  Widget _buildQuantityTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        initialValue:
            isProductForEdit ? widget.productForUpdate.quantity.toString() : "",
        keyboardType: TextInputType.number,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Quantity",
          prefixIcon: Icon(Icons.filter_9_plus),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "Quantity field shouldn't be empty or set at 0.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['quantity'] = typed;
        },
      ),
    );
  }

  Widget _buildMeasurementUnitTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        initialValue:
            isProductForEdit ? widget.productForUpdate.measurementUnit : "",
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Measurement unit",
          prefixIcon: Icon(Icons.more),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "Measurement unit field shouldn't be empty.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['measurementUnit'] = typed;
        },
      ),
    );
  }

  Widget _buildSectorPicker() {
    return StreamBuilder(
      stream: widget._model.getSectorsFirestoreStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
                children: <Widget>[CircularProgressIndicator()],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center),
          );
        } else {
          List<DropdownMenuItem> sectorsList = [];
          for (var i = 0; i < snapshot.data.documents.length; i++) {
            DocumentSnapshot document = snapshot.data.documents[i];
            sectorsList.add(
              DropdownMenuItem(
                child: Text(document['name']),
                value: document.documentID,
              ),
            );
          }
          return Container(
            margin: EdgeInsets.only(left: 15.0, right: 15.0),
            padding: EdgeInsets.only(left: 12.0, right: 15.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              children: <Widget>[
                Icon(Icons.work, color: Colors.grey),
                DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      hint: Text("Sector where is stored"),
                      value: (isProductForEdit && selectedSector == null)
                          ? widget.productForUpdate.whereIsStored
                          : selectedSector,
                      items: sectorsList,
                      onChanged: (sector) {
                        setState(() {
                          selectedSector = sector;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ButtonTheme(
      minWidth: 150.0,
      height: 50.0,
      child: FlatButton(
        child: widget._model.isLoading
            ? CircularProgressIndicator()
            : Text(
                isProductForEdit ? "UPDATE PRODUCT" : "ADD NEW PRODUCT",
                style: TextStyle(
                    fontSize: 15.0,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        onPressed: () {
          setState(() {
            if (!_formKey.currentState.validate()) {
              return;
            }

            if (selectedSector == null) {
              if (isProductForEdit) {
                selectedSector = widget.productForUpdate.whereIsStored;
                _validationSectorError = false;
              } else {
                _validationSectorError = true;
              }
            }

            if (!_validationSectorError) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      contentTextStyle: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 20.0),
                      backgroundColor: Theme.of(context).primaryColor,
                      content: _buildWarningForImage(),
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
                            _formKey.currentState.save();
                            _formData['whereIsStored'] = selectedSector;
                            _formData['imageFile'] = _imageFile;
                            if (isProductForEdit) {
                              _submitEditProduct(widget._model.updateProduct);
                            } else {
                              _submitNewProduct(widget._model.addNewProduct);
                            }
                          },
                        )
                      ],
                    );
                  });
            }
          });
        },
      ),
    );
  }

  Widget _buildProductAndUploadPicture(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0, left: 50.0),
          child: _imageFile == null
              ? (isProductForEdit &&
                      widget.productForUpdate.imageUrl != "" &&
                      widget.productForUpdate.imageUrl != null)
                  ? Image.network(
                      widget.productForUpdate.imageUrl,
                      height: 110,
                      width: 110,
                    )
                  : Image.asset(
                      "assets/Images/default-product-picture.jpg",
                      height: 110,
                      width: 110,
                    )
              : Image.file(
                  _imageFile,
                  fit: BoxFit.cover,
                  height: 110.0,
                  width: 110.0,
                ),
        ),
        IconButton(
          icon: Icon(
            Icons.photo_camera,
            color: Colors.grey,
          ),
          padding: EdgeInsets.only(top: 80.0, right: 20.0),
          splashColor: Colors.transparent,
          onPressed: () {
            _openImagePicker(context);
          },
        ),
      ],
    );
  }

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = image;
    });
    Navigator.pop(context);
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).primaryColor,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 115.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Upload product image",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                Divider(),
                // FlatButton.icon(
                //   textColor: Theme.of(context).accentColor,
                //   label: Text("Use Camera"),
                //   icon: Icon(Icons.add_a_photo),
                //   onPressed: () {
                //     _getImage(context, ImageSource.camera);
                //   },
                // ),
                // SizedBox(
                //   height: 5.0,
                // ),
                FlatButton.icon(
                  textColor: Theme.of(context).accentColor,
                  label: Text("Choose from Gallery"),
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _submitNewProduct(Function addNewProduct) async {
    setState(() {
      Navigator.of(context).pop();
    });
    final Map<String, dynamic> addProductResponse =
        await addNewProduct(_formData);

    setState(() {
      if (!addProductResponse['success']) {
        _addNewProductError = true;
        _addNewProductErrorMessage = addProductResponse['message'];
      } else {
        Navigator.pushReplacementNamed(context, '/products');
      }
    });
  }

  void _submitEditProduct(Function updateProduct) async {
    setState(() {
      Navigator.of(context).pop();
    });
    final Map<String, dynamic> updateSectorResponse =
        await updateProduct(widget.productForUpdate.id, _formData);

    setState(() {
      if (!updateSectorResponse['success']) {
        _addNewProductError = true;
        _addNewProductErrorMessage = updateSectorResponse['message'];
      } else {
        Navigator.pushReplacementNamed(context, '/products');
      }
    });
  }

  Widget _buildBarcodeTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        controller: _barcodeTextController,
        keyboardType: TextInputType.number,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Barcode",
          prefixIcon: Icon(Icons.chrome_reader_mode),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "Product name field shouldn't be empty.";
          } else if (typed.length != 13) {
            return "Barcode should be 13 characters long.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['barcode'] = typed;
        },
      ),
    );
  }

  Widget _buildBarcodeScanButton() {
    return ButtonTheme(
        minWidth: 100.0,
        height: 50.0,
        child: FlatButton(
          child: Text(
            "GENERATE",
            style: TextStyle(
                fontSize: 9.0,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          onPressed: () {
            if (_barcodeTextController.text.length != 13) {
              _formKey.currentState.validate();
            } else {
              setState(() {
                barcodeForShow = _barcodeTextController.text;
              });
            }
          },
        ));
  }

  Widget _showBarcodeImage() {
    return Visibility(
      visible: barcodeForShow != null ? true : false,
      child: BarCodeImage(
        data: barcodeForShow,
        codeType: BarCodeType.CodeEAN13,
        hasText: true,
        barHeight: 90.0,
        lineWidth: 2.0,
      ),
    );
  }

  Widget _buildNewUserForm(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildProductAndUploadPicture(context),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
              child: Text(
                isProductForEdit
                    ? "Update ${widget.productForUpdate.name}"
                    : "New product",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildNameTextField(context),
                    SizedBox(height: 10.0),
                    _buildQuantityTextField(context),
                    SizedBox(height: 10.0),
                    _buildMeasurementUnitTextField(context),
                    SizedBox(height: 10.0),
                    _buildSectorPicker(),
                    SizedBox(height: 5.0),
                    _buildSectorError(),
                    SizedBox(height: 10.0),
                    _buildDescriptionTextField(context),
                    SizedBox(height: 10.0),
                    _buildBarcodeTextField(),
                    SizedBox(height: 5.0),
                    _buildBarcodeScanButton(),
                    _showBarcodeImage(),
                    SizedBox(height: 10.0),
                    _buildSubmitButton(context),
                    SizedBox(height: 10.0),
                    _buildAddNewProductError(),
                  ],
                ),
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
            if (!_nameTextController.text.isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return isProductForEdit
                        ? YesNoAlertDialog(
                            "Are you sure that you don't want to update '${widget.productForUpdate.name}' and go back?",
                            "/products")
                        : YesNoAlertDialog(
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
      body: _buildNewUserForm(context),
    );
  }

  bool _validationSectorError = false;
  bool _addNewProductError = false;
  String _addNewProductErrorMessage = "";

  Widget _buildAddNewProductError() {
    return Visibility(
        visible: _addNewProductError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0, top: 6.0),
            child: Text(_addNewProductErrorMessage,
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                    fontSize: 16.0))));
  }

  Widget _buildSectorError() {
    return Visibility(
        visible: _validationSectorError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("Sector where product is stored must be picked.",
                style: TextStyle(color: Colors.red[600], fontSize: 12.0))));
  }

  Widget _buildWarningForImage() {
    bool missingImage = false;

    String missingImageMessage = "Product image isn't picked.";

    if (_imageFile == null && !isProductForEdit) {
      missingImage = true;
    }

    return isProductForEdit
        ? Text(
            "Are you sure you want to update product '${widget.productForUpdate.name}' ? ${(missingImage) ? " \n\n Warning:" : ""} ${missingImage ? "\n\n- " + missingImageMessage : ""}")
        : Text(
            "Are you sure you want to add product '${_nameTextController.text}' ? ${(missingImage) ? " \n\n Warning:" : ""} ${missingImage ? "\n\n- " + missingImageMessage : ""}");
  }
}
