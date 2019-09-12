import 'package:flutter/material.dart';
import 'package:mywarehouseproject/pages/newShipmentPage.dart';
import 'package:scoped_model/scoped_model.dart';

// Mine
import 'package:mywarehouseproject/pages/loginPage.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';
import 'package:mywarehouseproject/pages/mainPage.dart';
import 'package:mywarehouseproject/pages/newSectorPage.dart';
import 'package:mywarehouseproject/pages/newUserPage.dart';
import 'package:mywarehouseproject/pages/sectorsPage.dart';
import 'package:mywarehouseproject/pages/newReportPage.dart';
import 'package:mywarehouseproject/pages/workersPage.dart';
import 'package:mywarehouseproject/pages/newProductPage.dart';
import 'package:mywarehouseproject/pages/productsPage.dart';
import 'package:mywarehouseproject/pages/reportsPage.dart';

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
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.green[400]),
            primaryColor: Colors.blue,
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            accentColor: Colors.white,
            fontFamily: "Poppins"),
        routes: {
          '/': (BuildContext context) => LoginPage(),
          '/main': (BuildContext context) => MainPage(_model),
          '/newUser': (BuildContext context) => NewUserPage(_model, null),
          '/newSector': (BuildContext context) => NewSectorPage(),
          '/newReport': (BuildContext context) => NewReportPage(),
          '/newProduct': (BuildContext context) => NewProductPage(_model, null),
          '/newShipment': (BuildContext context) => NewShipmentPage(_model),
          '/sectors': (BuildContext context) => SectorsPage(),
          '/workers': (BuildContext context) => WorkersPage(),
          '/reports': (BuildContext context) => ReportsPage(),
          '/products': (BuildContext context) => ProductsPage()
        },
      ),
    );
  }
}
