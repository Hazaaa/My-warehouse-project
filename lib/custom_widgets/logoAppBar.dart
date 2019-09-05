import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LogoAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Image.asset('assets/logo-with-text.png'),
        padding: EdgeInsets.only(top: 8.0, right: 40.0),
      ),
    );
  }
}
