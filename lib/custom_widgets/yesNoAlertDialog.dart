import 'package:flutter/material.dart';

class YesNoAlertDialog extends StatelessWidget {
  final String _contentText;
  final Function _yesFunction;
  final String _gotoPage;

  YesNoAlertDialog(this._contentText, this._gotoPage, [this._yesFunction]);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      contentTextStyle:
          TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
      backgroundColor: Theme.of(context).primaryColor,
      content: Text(_contentText),
      actions: <Widget>[
        FlatButton(
          child: Text(
            "No",
            style:
                TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            "Yes",
            style:
                TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor),
          ),
          onPressed: () {
            if (_gotoPage.isNotEmpty) {
              Navigator.pushReplacementNamed(context, _gotoPage);
            } else {
              if (_yesFunction != null) {
                _yesFunction();
              }
            }
          },
        )
      ],
    );
  }
}
