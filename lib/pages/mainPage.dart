import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';

import 'package:mywarehouseproject/scoped_models/mainModel.dart';

class MainPage extends StatefulWidget {
  final MainModel model;

  MainPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  @override
  initState() {
    // widget.model.fetchRights();
    // Fatch access rights of authenticated user (or do that while login and save in scope model)
    super.initState();
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          AppBar(
            elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
            title: Row(
              children: <Widget>[
                CircleAvatar(),
                Padding(
                  child: Text(
                    widget.model.authenticatedUser.email,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  padding: EdgeInsets.only(left: 10.0),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            automaticallyImplyLeading: false,
          ),
          SizedBox(height: 10.0),
          ListTile(
              leading: Icon(Icons.add_shopping_cart),
              title: Text('Add new product')),
          ListTile(leading: Icon(Icons.category), title: Text('List products')),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Add new worker'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/newUser');
            },
          ),
          ListTile(leading: Icon(Icons.people), title: Text('List workers')),
          Divider(),
          ListTile(leading: Icon(Icons.work), title: Text('Add new sector')),
          ListTile(
              leading: Icon(Icons.store_mall_directory),
              title: Text('List sectors')),
          Divider(),
          ListTile(leading: Icon(Icons.report), title: Text('Reports')),
          ListTile(leading: Icon(Icons.bug_report), title: Text('Analytics')),
          Divider(),
          ListTile(
              leading: Icon(Icons.power_settings_new), title: Text('Logout')),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: LogoAppBar(),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      //body: add body,
    );
  }
}
