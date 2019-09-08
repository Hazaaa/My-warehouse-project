import 'package:flutter/material.dart';
import 'package:mywarehouseproject/pages/workersPage.dart';
import 'package:scoped_model/scoped_model.dart';

// Mine
import 'package:mywarehouseproject/pages/loginPage.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:mywarehouseproject/pages/mainPage.dart';
import 'package:mywarehouseproject/pages/newSectorPage.dart';
import 'package:mywarehouseproject/pages/newUserPage.dart';
import 'package:mywarehouseproject/pages/sectorsPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            accentColor: Colors.white,
            fontFamily: "Poppins"),
        routes: {
          '/': (BuildContext context) => LoginPage(),
          '/main': (BuildContext context) => MainPage(_model),
          '/newUser': (BuildContext context) => NewUserPage(null, _model),
          '/newSector': (BuildContext context) => NewSectorPage(),
          '/sectors': (BuildContext context) => SectorsPage(),
          '/workers': (BuildContext context) => WorkersPage()
        },
        // onGenerateRoute: (RouteSettings settings) {
        //   final List<String> pathElements = settings.name.split('/');
        //   if (pathElements[0] != '') {
        //     return null;
        //   }
        //   if (pathElements[1] == 'product') {
        //     final int index = int.parse(pathElements[2]);
        //     return MaterialPageRoute<bool>(
        //       builder: (BuildContext context) => ProductPage(index),
        //     );
        //   }
        //   return null;
        // },
        // onUnknownRoute: (RouteSettings settings) {
        //   return MaterialPageRoute(
        //       builder: (BuildContext context) => ProductsPage());
        // },
      ),
    );
  }
}
