import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FloatingAddActionButton extends StatelessWidget {
  final String navigateTo;

  FloatingAddActionButton(this.navigateTo);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add, color: Colors.white),
      tooltip: "Add new product",
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(navigateTo);
      },
    );
  }
}
