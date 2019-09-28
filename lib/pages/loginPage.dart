import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:mywarehouseproject/scoped_models/mainModel.dart';

class LoginPage extends StatefulWidget {

  final MainModel model;

  LoginPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void initState() {
    Platform.isAndroid ? widget.model.getAndroidInfo() : widget.model.getIosInfo();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildEmailField() {
    return Container(
        padding: EdgeInsets.only(left: 6.0, right: 6.0),
        child: TextField(
          controller: _emailController,
          cursorColor: Colors.blue,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _validationErrorEmail ? Colors.red : Colors.blue,
                      width: 1.0)),
              border: InputBorder.none,
              labelText: "E-mail",
              prefixIcon: Icon(Icons.mail)),
        ));
  }

  Widget _buildPasswordField() {
    return Container(
        padding: EdgeInsets.only(left: 6.0, right: 6.0),
        child: TextField(
          obscureText: _hidePassword,
          controller: _passwordController,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          _validationErrorPassword ? Colors.red : Colors.blue,
                      width: 1.0)),
              border: InputBorder.none,
              labelText: "Password",
              prefixIcon: Icon(Icons.vpn_key),
              suffixIcon: IconButton(
                icon: _hidePassword
                    ? Icon(Icons.remove_red_eye)
                    : Icon(Icons.lock),
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              )),
        ));
  }

  Widget _buildLoginButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonTheme(
          minWidth: 150.0,
          height: 50.0,
          child: FlatButton(
            child: model.isLoading ? CircularProgressIndicator() : Text(
              "LOGIN",
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
                if (_emailController.text.isEmpty) {
                  _validationErrorEmail = true;
                  _emailErrorMessage = "E-mail field can't be empty.";
                } else if (!RegExp(
                        r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(_emailController.text)) {
                  _validationErrorEmail = true;
                  _emailErrorMessage = "Invalid e-mail.";
                } else {
                  _validationErrorEmail = false;
                }

                _passwordController.text.isEmpty
                    ? _validationErrorPassword = true
                    : _validationErrorPassword = false;

                if (!_validationErrorEmail && !_validationErrorPassword) {
                  _submitLoginForm(model.login);
                }
              });
            },
          ));
    });
  }

  void _submitLoginForm(Function login) async {
    final Map<String, dynamic> loginResponse =
        (await login(_emailController.text, _passwordController.text));

    setState(() {
      if (!loginResponse['success']) {
        _loginError = true;
        _loginErrorMessage = loginResponse['message'];
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.blue,
        body: SingleChildScrollView(
            child: Padding(
                padding:
                    EdgeInsets.only(top: deviceHeight > 600 ? 145.0 : 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildLogoImage(context),
                    Container(
                      margin: EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 80.0),
                      width: 400,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                offset: Offset(0.0, 15.0),
                                blurRadius: 15.0),
                            BoxShadow(
                                color: Colors.black38,
                                offset: Offset(0.0, -10.0),
                                blurRadius: 15.0)
                          ]),
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                              child: Text(
                                "LOGIN",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: "Poppins",
                                    letterSpacing: 1.0,
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          _buildEmailField(),
                          _buildEmailError(),
                          SizedBox(height: 10.0),
                          _buildPasswordField(),
                          _buildPasswordError(),
                          SizedBox(height: 15.0),
                          _buildLoginButton(),
                          _buildLoginError(),
                          SizedBox(height: 15.0)
                        ],
                      ),
                    )
                  ],
                ))));
  }

  // Error handling region
  bool _validationErrorEmail = false;
  String _emailErrorMessage = '';
  bool _validationErrorPassword = false;
  bool _loginError = false;
  String _loginErrorMessage = '';

  Widget _buildLogoImage(BuildContext context) {
    return Padding(
      child: Image.asset("assets/logo-with-text.png"),
      padding: EdgeInsets.only(left: 20.0, bottom: 15.0),
    );
  }

  Widget _buildEmailError() {
    return Visibility(
        visible: _validationErrorEmail,
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(_emailErrorMessage,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.0))));
  }

  Widget _buildPasswordError() {
    return Visibility(
        visible: _validationErrorPassword,
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("Password field can't be empty.",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.0))));
  }

  Widget _buildLoginError() {
    return Visibility(
        visible: _loginError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0, top: 6.0),
            child: Text(_loginErrorMessage,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0))));
  }
}
