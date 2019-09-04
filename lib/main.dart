import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

// Mine
import 'package:mywarehouseproject/pages/loginPage.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';

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
  Brightness _themeBrightness = Brightness.light;

  void _changeThemeBrightness() {
    setState(() {
      if (_themeBrightness == Brightness.light) {
        _themeBrightness = Brightness.dark;
      } else {
        _themeBrightness = Brightness.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: MainModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: _themeBrightness,
            primarySwatch: Colors.blue,
            accentColor: Colors.white,
            fontFamily: "Poppins"),
        routes: {
          '/': (BuildContext context) => LoginPage(),
          // '/products': (BuildContext context) => ProductsPage(),
          // '/admin': (BuildContext context) => ProductsAdminPage(),
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
