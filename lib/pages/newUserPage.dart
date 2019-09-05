import 'package:flutter/material.dart';
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

  @override
  initState() {
    // Fetch rights
    // Fetch sectors
    super.initState();
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
    return DropdownButton<String>(
      hint: Text("Please choose worker sector"),
      items: widget._model.getRights.map((Right right) {
        return DropdownMenuItem<String>(
          value: right.name,
          child: Text(right.name),
        );
      }).toList(),
      onChanged: (newVal) {
        setState(() {});
      },
    );
  }

  Widget _buildRightsPicker() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: widget._model.getRights
              .map((Right right) => CheckboxListTile(
                    title: Text(right.name),
                    value: isChecked,
                    onChanged: (val) {
                      setState(() {
                        isChecked = val;
                      });
                    },
                  ))
              .toList(),
        ),
      ),
    );
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
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
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
            elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          ),
          body: _buildNewUserForm(context),
        );
      },
    );
  }
}
