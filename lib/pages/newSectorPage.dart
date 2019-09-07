import 'package:flutter/material.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/custom_widgets/yesNoAlertDialog.dart';
import 'package:mywarehouseproject/models/sector.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:scoped_model/scoped_model.dart';

class NewSectorPage extends StatefulWidget {
  final Sector updateSector;

  NewSectorPage([this.updateSector]);

  @override
  State<StatefulWidget> createState() {
    return _NewSectorPageState();
  }
}

class _NewSectorPageState extends State<NewSectorPage> {
  @override
  void initState() {
    if (isSectorForEdit) {
      _nameTextController.text = widget.updateSector.name;
      _descriptionTextController.text = widget.updateSector.description;
    }
    super.initState();
  }

  final _nameTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  bool get isSectorForEdit {
    if (widget.updateSector != null) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildSectorNameTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextField(
        controller: _nameTextController,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Sector name",
          prefixIcon: Icon(Icons.work),
        ),
      ),
    );
  }

  Widget _buildSectorDescriptionTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextField(
        controller: _descriptionTextController,
        minLines: 1,
        maxLines: 10,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Description (optional)",
          prefixIcon: Icon(Icons.description),
        ),
      ),
    );
  }

  Widget _buildAddSectorButton() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonTheme(
            minWidth: 150.0,
            height: 50.0,
            child: FlatButton(
              child: model.isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      isSectorForEdit ? "UPDATE SECTOR" : "ADD NEW SECTOR",
                      style: TextStyle(
                          fontSize: 15.0,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              onPressed: () {
                setState(() {
                  _nameTextController.text.isEmpty
                      ? _nameValidationError = true
                      : _nameValidationError = false;

                  if (!_nameValidationError) {
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
                            content: isSectorForEdit
                                ? Text("Are you sure you want to update '" +
                                    _nameTextController.text +
                                    "' sector?")
                                : Text("Are you sure you want to add '" +
                                    _nameTextController.text +
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
                                  if (isSectorForEdit) {
                                    _submitEditSector(model.updateSector);
                                  } else {
                                    _submitNewSector(model.addSector);
                                  }
                                  Navigator.pushReplacementNamed(
                                      context, '/sectors');
                                },
                              )
                            ],
                          );
                        });
                  }
                });
              },
            ));
      },
    );
  }

  void _submitNewSector(Function addNewSector) async {
    final Map<String, dynamic> addSectorResponse = await addNewSector(
        _nameTextController.text, _descriptionTextController.text);

    setState(() {
      if (!addSectorResponse['success']) {
        _addNewSectorError = true;
        _addNewSectorErrorMessage = addSectorResponse['message'];
      }
    });
  }

  void _submitEditSector(Function updateSector) async {
    final Map<String, dynamic> updateSectorResponse = await updateSector(
        widget.updateSector.id,
        _nameTextController.text,
        _descriptionTextController.text);

    setState(() {
      if (!updateSectorResponse['success']) {
        _addNewSectorError = true;
        _addNewSectorErrorMessage = updateSectorResponse['message'];
      }
    });
  }

  Widget _buildNewSectorForm(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(
                isSectorForEdit
                    ? "Update '" + widget.updateSector.name + "' sector"
                    : "New sector",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  _buildSectorNameTextField(),
                  _buildSectorNameError(),
                  SizedBox(height: 10.0),
                  _buildSectorDescriptionTextField(),
                  SizedBox(height: 10.0),
                  _buildAddSectorButton(),
                  _buildAddNewSectorError(),
                ],
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
            if (!_nameTextController.text.isEmpty ||
                !_descriptionTextController.text.isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return isSectorForEdit
                        ? YesNoAlertDialog(
                            "Are you sure that you don't want to update this sector and go back?",
                            "/sectors")
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
      body: _buildNewSectorForm(context),
    );
  }

  // Input errors handling

  bool _nameValidationError = false;
  bool _addNewSectorError = false;
  String _addNewSectorErrorMessage = "";

  Widget _buildAddNewSectorError() {
    return Visibility(
        visible: _addNewSectorError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0, top: 6.0),
            child: Text(_addNewSectorErrorMessage,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0))));
  }

  Widget _buildSectorNameError() {
    return Visibility(
        visible: _nameValidationError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("Sector name can't be empty.",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.0))));
  }
}
