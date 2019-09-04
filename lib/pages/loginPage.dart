import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildUsernameField() {
    return Container(
        padding: EdgeInsets.only(left: 6.0, right: 6.0),
        child: TextField(
          controller: _usernameController,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          _validationErrorUsername ? Colors.red : Colors.blue,
                      width: 1.0)),
              border: InputBorder.none,
              labelText: "Username",
              prefixIcon: Icon(Icons.account_circle)),
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

  bool _login(String username, String password) {
    return false;
  }

  Widget _buildLoginButton() {
    return ButtonTheme(
        minWidth: 150.0,
        height: 50.0,
        child: FlatButton(
          child: Text(
            "LOGIN",
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
              _usernameController.text.isEmpty
                  ? _validationErrorUsername = true
                  : _validationErrorUsername = false;

              _passwordController.text.isEmpty
                  ? _validationErrorPassword = true
                  : _validationErrorPassword = false;

              if (!_validationErrorUsername && !_validationErrorPassword) {
                if (!_login(_usernameController.text, _passwordController.text)) {
                  _loginError = true;
                }
              }
            });
          },
        ));
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
                                    fontFamily: "Poppins",
                                    letterSpacing: 1.0,
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          _buildUsernameField(),
                          _buildUsernameError(),
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
  bool _validationErrorUsername = false;
  bool _validationErrorPassword = false;
  bool _loginError = false;

  Widget _buildLogoImage(BuildContext context) {
    return Padding(
      child: Image.asset("assets/logo-with-text.png"),
      padding: EdgeInsets.only(left: 20.0, bottom: 15.0),
    );
  }

  Widget _buildUsernameError() {
    return Visibility(
        visible: _validationErrorUsername,
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("Username field can't be empty.",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
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
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                    fontSize: 12.0))));
  }

  Widget _buildLoginError() {
    return Visibility(
        visible: _loginError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0, top: 6.0),
            child: Text("Incorrect username or password!",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                    fontSize: 16.0))));
  }
}
