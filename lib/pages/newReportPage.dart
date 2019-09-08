import 'package:flutter/material.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/custom_widgets/yesNoAlertDialog.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:scoped_model/scoped_model.dart';

class NewReportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewReportPageState();
  }
}

class _NewReportPageState extends State<NewReportPage> {
  @override
  void initState() {
    super.initState();
  }

  final _nameTextController = TextEditingController();

  Widget _buildReportTextField() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextField(
        controller: _nameTextController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Describe problem",
          prefixIcon: Icon(Icons.report),
        ),
      ),
    );
  }

  Widget _buildAddReportButton() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonTheme(
            minWidth: 150.0,
            height: 50.0,
            child: FlatButton(
              child: model.isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      "SEND REPORT",
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
                  if(_nameTextController.text.isEmpty) {
                    _addNewReportError = true;
                    _addNewReportErrorMessage = "You can't send empty report.";
                  } else {
                     _addNewReportError = false;
                  }

                  if (!_addNewReportError) {
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
                                Text("Are you sure you want to send report?"),
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
                                  _submitNewReport(model.addNewReport);
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

  void _submitNewReport(Function addNewReport) async {
    final Map<String, dynamic> addReportResponse = await addNewReport(
        _nameTextController.text);

    setState(() {
      if (!addReportResponse['success']) {
        _addNewReportError = true;
        _addNewReportErrorMessage = addReportResponse['message'];
        print(addReportResponse['message']);
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  Widget _buildNewReportForm() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(
                "New report",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  _buildReportTextField(),
                  SizedBox(height: 10.0),
                  _buildAddReportButton(),
                  _buildAddNewReportError(),
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
            if (!_nameTextController.text.isEmpty) {
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
      body: _buildNewReportForm(),
    );
  }

  // Input errors handling
  bool _addNewReportError = false;
  String _addNewReportErrorMessage = "";

  Widget _buildAddNewReportError() {
    return Visibility(
        visible: _addNewReportError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0, top: 6.0),
            child: Text(_addNewReportErrorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16.0))));
  }
}
