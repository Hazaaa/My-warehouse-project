import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/models/right.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:scoped_model/scoped_model.dart';

class NewUserPage extends StatefulWidget {
  final MainModel _model;

  NewUserPage(this._model);

  @override
  State<StatefulWidget> createState() {
    return _NewUserPageState();
  }
}

class _NewUserPageState extends State<NewUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isChecked = true;
  List<String> selectedRights;
  var selectedSector;

  @override
  initState() {
    // Fetch rights
    // Fetch sectors
    super.initState();
    widget._model.fetchRights();
  }

  Widget _buildNameAndSurenameTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Name and Surename",
          prefixIcon: Icon(Icons.person),
        ),
      ),
    );
  }

  Widget _buildAddressTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Address",
          prefixIcon: Icon(Icons.home),
        ),
      ),
    );
  }

  Widget _buildNumberTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Phone number",
          prefixIcon: Icon(Icons.phone),
        ),
      ),
    );
    ;
  }

  Widget _buildEmailTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "E-mail",
          prefixIcon: Icon(Icons.email),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Password",
          prefixIcon: Icon(Icons.vpn_key),
        ),
      ),
    );
  }

  Widget _buildPicturePicker() {
    return null;
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
                      hint: Text("Choose sector"),
                      value: selectedSector,
                      items: sectorsList,
                      onChanged: (sector) {
                        final snackBar = SnackBar(
                          content: Text(sector),
                        );
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

  Widget _buildRightsPicker() {
    return StreamBuilder(
        stream: widget._model.getRightsFirestoreStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                  children: <Widget>[CircularProgressIndicator()],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center),
            );
          } else {
            List<String> rightsList = [];
            for (var i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot document = snapshot.data.documents[i];
              rightsList.add(document['name']);
            }
            return Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0)),
                height: 300.0,
                child: SingleChildScrollView(
                  child: CheckboxGroup(
                      // disabled: rightsList,
                      checkColor: Theme.of(context).primaryColor,
                      labels: rightsList,
                      onSelected: (List<String> checked) =>
                          selectedRights = checked),
                ),
              ),
            );
          }
        });
  }

  Widget _buildNewUserForm(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: CircleAvatar(
                maxRadius: 40.0,
                backgroundImage:
                    AssetImage("assets/Images/default-user-picture.png"),
                backgroundColor: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
              child: Text(
                "New worker",
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
                    _buildNameAndSurenameTextField(),
                    SizedBox(height: 10.0),
                    _buildAddressTextField(),
                    SizedBox(height: 10.0),
                    _buildNumberTextField(),
                    SizedBox(height: 10.0),
                    _buildEmailTextField(),
                    SizedBox(height: 10.0),
                    _buildPasswordTextField(),
                    SizedBox(height: 10.0),
                    _buildSectorPicker(),
                    SizedBox(height: 10.0),
                    Text(
                      "Rights",
                      style: TextStyle(color: Colors.grey, fontSize: 18.0),
                    ),
                    _buildRightsPicker(),
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
            Navigator.of(context).pushReplacementNamed('/main');
          },
        ),
        title: LogoAppBar(),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: _buildNewUserForm(context),
    );
  }
}
