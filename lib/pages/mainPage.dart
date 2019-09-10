import 'package:flutter/material.dart';

// Mine classes/widgets
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/models/user.dart';

class MainPage extends StatefulWidget {
  final MainModel model;

  MainPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  User authUser;

  @override
  initState() {
    authUser = widget.model.authenticatedUser;
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
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (widget.model.authenticatedUser.imageUrl ==
                          null)
                      ? AssetImage('assets/Images/default-user-picture.png')
                      : NetworkImage(widget.model.authenticatedUser.imageUrl),
                ),
                Padding(
                  child: Text(
                    (widget.model.authenticatedUser.name != null)
                        ? widget.model.authenticatedUser.name
                        : widget.model.authenticatedUser.email,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  padding: EdgeInsets.only(left: 13.0),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            automaticallyImplyLeading: false,
          ),
          SizedBox(height: 10.0),
          Visibility(
            child: ListTile(
                leading: Icon(Icons.transit_enterexit),
                title: Text('New shipment')),
            visible: authUser.adminOrUser == "Admin" ||
                    (authUser.rights != null &&
                        authUser.rights.contains("New shipment"))
                ? true
                : false,
          ),
          Visibility(
            child: Divider(),
            visible: (authUser.adminOrUser == "Admin" ||
                    (authUser.rights != null &&
                        authUser.rights.contains("New shipment")))
                ? true
                : false,
          ),
          Visibility(
            child: ListTile(
                leading: Icon(Icons.add_shopping_cart),
                title: Text('Add new product')),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("Add new product"))),
          ),
          Visibility(
            child: ListTile(
                leading: Icon(Icons.category), title: Text('List products')),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("List products"))),
          ),
          Visibility(
            child: Divider(),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    (authUser.rights.contains("New shipment") ||
                        authUser.rights.contains("List products")))),
          ),
          Visibility(
            child: ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Add new worker'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/newUser');
              },
            ),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("Add new worker"))),
          ),
          Visibility(
            child: ListTile(
              leading: Icon(Icons.people),
              title: Text('List workers'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/workers');
              },
            ),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("List workers"))),
          ),
          Visibility(
            child: Divider(),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    (authUser.rights.contains("List workers") ||
                        authUser.rights.contains("Add new worker")))),
          ),
          Visibility(
            child: ListTile(
              leading: Icon(Icons.work),
              title: Text('Add new sector'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/newSector');
              },
            ),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("Add new sector"))),
          ),
          Visibility(
            child: ListTile(
                leading: Icon(Icons.store_mall_directory),
                title: Text('List sectors'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/sectors');
                }),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("List sectors"))),
          ),
          Visibility(
            child: Divider(),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    (authUser.rights.contains("List sectors") ||
                        authUser.rights.contains("Add new sector")))),
          ),
          Visibility(
            child: ListTile(
                leading: Icon(Icons.report),
                title: Text('Send report'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/newReport');
                }),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("Send report"))),
          ),
          Visibility(
            child: ListTile(
                leading: Icon(Icons.report_problem), title: Text('Reports'), onTap: () {
                  Navigator.of(context).pushReplacementNamed('/reports');
                },),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("Reports"))),
          ),
          Visibility(
            child: ListTile(
                leading: Icon(Icons.bug_report), title: Text('Analytics')),
            visible: (authUser.adminOrUser == "Admin" ||
                (authUser.rights != null &&
                    authUser.rights.contains("Analytics"))),
          ),
          Visibility(
            child: Divider(),
            visible: authUser.rights == null ||
                (authUser.rights.contains("Analytics") ||
                    authUser.rights.contains("Reports") ||
                    authUser.rights.contains("Send report")),
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Logout'),
            onTap: () {
              widget.model.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildMainPageBody() {
    return Center(
      child: Text(
        "News feed",
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: LogoAppBar(),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: _buildMainPageBody());
  }
}
