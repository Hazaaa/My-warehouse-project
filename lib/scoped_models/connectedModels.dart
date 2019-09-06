import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mywarehouseproject/models/user.dart';
import 'package:mywarehouseproject/models/right.dart';
import 'package:mywarehouseproject/models/sector.dart';

class ConnectedModels extends Model {
  User _authenticatedUser;
  bool _isLoading = false;
  List<Right> _rights;
  List<Sector> _sectors;
  String sectorSearch = "";
}

class UserModel extends ConnectedModels {
  User get authenticatedUser {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final http.Response response = await http.post(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCbsAzSlQaDl9ii9v-8Cbh0j6koMcqLuTY",
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'});

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String responseMessage = 'Something went wrong.';

    if (responseData.containsKey('idToken')) {
      hasError = false;
      responseMessage = 'Login successfull.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND' ||
        responseData['error']['message'] == 'INVALID_PASSWORD') {
      responseMessage = 'Invalid e-mail or password.';
    } else if (responseData['error']['message'] == 'USER_DISABLED') {
      responseMessage = 'User account has been disabled.';
    }

    _authenticatedUser = User(
        id: responseData['localId'],
        email: email,
        token: responseData['idToken']);

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': responseMessage};
  }
}

class ProductModel extends ConnectedModels {}

class RightsModel extends ConnectedModels {
  List<Right> get getRights {
    return List<Right>.from(_rights);
  }

  Stream<QuerySnapshot> getRightsFirestoreStream() {
    return Firestore.instance.collection('rights').orderBy('order').snapshots();
  }

  Future<bool> fetchRights() async {
    _isLoading = true;
    notifyListeners();
    var responseRightsDocuments =
        await Firestore.instance.collection('rights').orderBy('order').getDocuments();

    if(responseRightsDocuments.documents.length == 0) {
      return false;
    }
    List<Right> tempRightsList = [];
    for (var i = 0; i < responseRightsDocuments.documents.length; i++) {
      final Right newRight = Right(
          id: responseRightsDocuments.documents[i].documentID,
          name: responseRightsDocuments.documents[i].data['name'],
          order: responseRightsDocuments.documents[i].data['order']);
      tempRightsList.add(newRight);
    }
    _rights = tempRightsList;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}

class SectorModel extends ConnectedModels {
  List<Sector> get getSectors {
    return List<Sector>.from(_sectors);
  }

  void setSectorSearch(String val) {
    sectorSearch = val;
    notifyListeners();
  }

  Stream<QuerySnapshot> getSectorsFirestoreStream() {
    return Firestore.instance.collection('sectors').orderBy('name').snapshots();
  }

  Future<Map<String, dynamic>> addSector(String name, String description) async {
    _isLoading = true;
    notifyListeners();

    bool successfullAdd = true;
    String errorMessage = "";

    await Firestore.instance.collection('sectors').add({'name': name, 'description': description}).catchError((error) {
      successfullAdd = false;
      errorMessage = error;
    });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullAdd, 'error': errorMessage};
  }

  Future<Map<String, dynamic>> updateSector(String id, String name, String description) async {
    _isLoading = true;
    notifyListeners();

    bool successfullUpdate = true;
    String errorMessage = "";

    await Firestore.instance.collection('sectors').document(id).setData({'name': name, 'description': description}).catchError((error) {
      successfullUpdate = false;
      errorMessage = error;
    });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullUpdate, 'error': errorMessage};
  }

  Future<Map<String, dynamic>> deleteSector(String id) async {
    bool successfullUpdate = true;
    String errorMessage = "";

    await Firestore.instance.collection('sectors').document(id).delete().catchError((error) {
      successfullUpdate = false;
      errorMessage = error;
    });
    return {'success': successfullUpdate, 'error': errorMessage};
  }

  Future<bool> fetchSectors() async {
    _isLoading = true;
    notifyListeners();
    var responseSectorsDocuments =
        await Firestore.instance.collection('sectors').orderBy('name').getDocuments();

    if(responseSectorsDocuments.documents.length == 0) {
      return false;
    }
    List<Sector> tempSectorsList = [];
    for (var i = 0; i < responseSectorsDocuments.documents.length; i++) {
      final Sector newRight = Sector(
          id: responseSectorsDocuments.documents[i].documentID,
          name: responseSectorsDocuments.documents[i].data['name'],
          description: responseSectorsDocuments.documents[i].data['description']);
      tempSectorsList.add(newRight);
    }
    _sectors = tempSectorsList;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}

class UtilityModel extends ConnectedModels {
  bool get isLoading {
    return _isLoading;
  }
}
