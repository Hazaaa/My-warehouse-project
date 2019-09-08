import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mywarehouseproject/models/user.dart';
import 'package:mywarehouseproject/models/right.dart';
import 'package:mywarehouseproject/models/sector.dart';

class ConnectedModels extends Model {
  final Firestore _firestoreInstance = Firestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

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

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<Map<String, dynamic>> uploadImage(
      String fileName, File _imageFile) async {
    if (_imageFile != null) {
      try {
        final fileExtension = extension(_imageFile.path);
        final StorageReference storageRef =
            _firebaseStorage.ref().child(fileName + fileExtension);

        final StorageUploadTask uploadTask = storageRef.putFile(_imageFile);

        final StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

        String _imageDownloadUrl = await taskSnapshot.ref.getDownloadURL();

        return {'success': true, 'imageUrl': _imageDownloadUrl};
      } catch (e) {
        return {'success': false, 'error': e.message};
      }
    }
    return {'success': false, 'error': "Image file is null!"};
  }

  Stream<QuerySnapshot> getWorkersStream() {
    return _firestoreInstance.collection('workers').orderBy('name').snapshots();
  }

  void getAdditionalUserInfo() async {
    if (_authenticatedUser.id != null && !_authenticatedUser.email.contains("admin")) {
      QuerySnapshot response = await _firestoreInstance
          .collection('workers').where("id", isEqualTo: _authenticatedUser.id)
          .getDocuments();

      DocumentSnapshot document = response.documents.single;

      _authenticatedUser.address = document['address'];
      _authenticatedUser.adminOrUser = document['adminOrUser'];
      _authenticatedUser.imageUrl = document['imageUrl'];
      _authenticatedUser.name = document['name'];
      _authenticatedUser.rights = document['rights'].cast<String>();
      _authenticatedUser.phone = document['phone'];
      _authenticatedUser.sector = document['sector'];    
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    bool hasError = false;
    String responseMessage = 'Something went wrong.';

    AuthResult user = await _firebaseAuth
        .signInWithEmailAndPassword(email: email.trim(), password: password)
        .catchError((error) {
      hasError = true;
      // error.code => exmpl. ERROR_USER_NOT_FOUND, error.message => Human readable error
      if (error.code == 'ERROR_INVALID_EMAIL' ||
          error.code == 'ERROR_WRONG_PASSWORD') {
        responseMessage = 'Invalid e-mail or password.';
      } else if (error.code == 'ERROR_USER_DISABLED') {
        responseMessage = 'User account has been disabled.';
      } else if (error.code == 'ERROR_USER_NOT_FOUND') {
        responseMessage = 'User not found.';
      } else if (error.code == 'ERROR_TOO_MANY_REQUESTS') {
        responseMessage =
            'There was too many unsuccessfull attempts to sign in.';
      } else if (error.code == 'ERROR_OPERATION_NOT_ALLOWED') {
        responseMessage = 'E-mail & password sign is disabled.';
      }
    });

    if (user == null) {
      _isLoading = false;
      notifyListeners();

      return {'success': !hasError, 'message': responseMessage};
    } else {
      _authenticatedUser = User(
          email: user.user.email,
          id: user.user.uid,
          token: (await user.user.getIdToken()).token);

      await getAdditionalUserInfo();

      _isLoading = false;
      notifyListeners();
      return {'success': !hasError, 'message': responseMessage};
    }

    // OLD SIGN IN WITH FIREBASE REST API (WORKS)
    // final http.Response response = await http.post(
    //     "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCbsAzSlQaDl9ii9v-8Cbh0j6koMcqLuTY",
    //     body: json.encode(requestBody),
    //     headers: {'Content-Type': 'application/json'});

    // final Map<String, dynamic> responseData = json.decode(response.body);
    // bool hasError = true;
    // String responseMessage = 'Something went wrong.';

    // if (user.user.getIdToken() != null) {
    //   hasError = false;
    //   responseMessage = 'Login successfull.';
    // } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND' ||
    //     responseData['error']['message'] == 'INVALID_PASSWORD') {
    //   responseMessage = 'Invalid e-mail or password.';
    // } else if (responseData['error']['message'] == 'USER_DISABLED') {
    //   responseMessage = 'User account has been disabled.';
    // }

    // _authenticatedUser = User(
    //     id: responseData['localId'],
    //     email: email,
    //     token: responseData['idToken']);

    // _isLoading = false;
    // notifyListeners();
    // return {'success': !hasError, 'message': responseMessage};
  }

  Future<Map<String, dynamic>> addNewUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    bool hasError = false;
    String responseMessage = 'Something went wrong.';

    AuthResult user = await _firebaseAuth
        .createUserWithEmailAndPassword(
            email: userData['email'].trim(), password: userData['password'])
        .catchError((error) {
      hasError = true;
      // error.code => exmpl. ERROR_USER_NOT_FOUND, error.message => Human readable error
      if (error.code == 'ERROR_WEAK_PASSWORD') {
        responseMessage = 'Password is too weak.';
      } else if (error.code == 'ERROR_INVALID_EMAIL') {
        responseMessage = 'Invalid e-mail.';
      } else if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        responseMessage = 'E-mail is already in use';
      }
    });

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return {'success': !hasError, 'message': responseMessage};
    } else {
      Map<String, dynamic> uploadImageResult;

      if (userData['imageFile'] != null) {
        uploadImageResult = await uploadImage(
            userData['name'] + "_image", userData['imageFile']);
      }

      if (uploadImageResult['success']) {
        await _firestoreInstance.collection('workers').add({
          'id': user.user.uid,
          'name': userData['name'],
          'address': userData['address'],
          'phone': userData['phone'],
          'sector': userData['sector'],
          'adminOrUser': userData['adminOrUser'],
          'rights': userData['rights'],
          'email': userData['email'],
          'imageUrl': uploadImageResult['imageUrl'],
        }).catchError((error) {
          hasError = true;
          responseMessage = error;
        });
      } else {
        await _firestoreInstance.collection('workers').add({
          'id': user.user.uid,
          'name': userData['name'],
          'address': userData['address'],
          'phone': userData['phone'],
          'sector': userData['sector'],
          'adminOrUser': userData['adminOrUser'],
          'rights': userData['rights'],
          'email': userData['email'],
          'imageUrl': null,
        }).catchError((error) {
          hasError = true;
          responseMessage = error;
        });
      }

      _isLoading = false;
      notifyListeners();

      return {'success': !hasError, 'message': responseMessage};
    }
  }

  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    bool hasError = false;
    String responseMessage = 'Something went wrong.';

    String imageUrl;

    try {
      if (userData['imageFile'] != null) {
        Map<String, dynamic> uploadResult = await uploadImage(
            userData['name'] + "_image", userData['imageFile']);

        if (uploadResult['success']) {
          imageUrl = uploadResult['imageUrl'];
        } else {
          hasError = true;
          responseMessage = uploadResult['error'];
          _isLoading = false;
          notifyListeners();
        }
      }

      if (imageUrl == null) {
        await _firestoreInstance.collection('workers').document(id).updateData({
          'name': userData['name'],
          'address': userData['address'],
          'adminOrUser': userData['adminOrUser'],
          'phone': userData['phone'],
          'sector': userData['sector'],
          'rights': userData['rights'],
        });
      } else {
        await _firestoreInstance.collection('workers').document(id).updateData({
          'name': userData['name'],
          'address': userData['address'],
          'adminOrUser': userData['adminOrUser'],
          'phone': userData['phone'],
          'sector': userData['sector'],
          'rights': userData['rights'],
          'imageUrl': imageUrl
        });
      }
    } catch (e) {
      _isLoading = true;
      notifyListeners();

      return {'success': !hasError, 'message': e.message};
    }

    _isLoading = false;
    notifyListeners();

    return {'success': !hasError, 'message': responseMessage};
  }

  Future<Map<String, dynamic>> deleteUser(String id,
      [String name, String imageUrl]) async {
    bool successfullUpdate = true;
    String errorMessage = "";

    if (name != null && imageUrl != null) {
      await _firebaseStorage
          .ref()
          .child(name + "_image" + extension(imageUrl).split('?')[0])
          .delete()
          .catchError((error) {
        successfullUpdate = false;
        errorMessage = error;
      });
    }

    await _firestoreInstance
        .collection('workers')
        .document(id)
        .delete()
        .catchError((error) {
      successfullUpdate = false;
      errorMessage = error;
    });

    return {'success': successfullUpdate, 'error': errorMessage};
  }
}

class ProductModel extends ConnectedModels {}

class RightsModel extends ConnectedModels {
  List<Right> get getRights {
    return List<Right>.from(_rights);
  }

  Stream<QuerySnapshot> getRightsFirestoreStream() {
    return _firestoreInstance.collection('rights').orderBy('order').snapshots();
  }

  Future<bool> fetchRights() async {
    _isLoading = true;
    notifyListeners();
    var responseRightsDocuments = await _firestoreInstance
        .collection('rights')
        .orderBy('order')
        .getDocuments();

    if (responseRightsDocuments.documents.length == 0) {
      _isLoading = false;
      notifyListeners();
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
    return _firestoreInstance.collection('sectors').orderBy('name').snapshots();
  }

  Future<Map<String, dynamic>> addSector(
      String name, String description) async {
    _isLoading = true;
    notifyListeners();

    bool successfullAdd = true;
    String errorMessage = "";

    await _firestoreInstance
        .collection('sectors')
        .add({'name': name, 'description': description}).catchError((error) {
      successfullAdd = false;
      errorMessage = error;
    });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullAdd, 'error': errorMessage};
  }

  Future<Map<String, dynamic>> updateSector(
      String id, String name, String description) async {
    _isLoading = true;
    notifyListeners();

    bool successfullUpdate = true;
    String errorMessage = "";

    await _firestoreInstance.collection('sectors').document(id).updateData(
        {'name': name, 'description': description}).catchError((error) {
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

    await _firestoreInstance
        .collection('sectors')
        .document(id)
        .delete()
        .catchError((error) {
      successfullUpdate = false;
      errorMessage = error;
    });
    return {'success': successfullUpdate, 'error': errorMessage};
  }

  Future<bool> fetchSectors() async {
    _isLoading = true;
    notifyListeners();
    var responseSectorsDocuments = await _firestoreInstance
        .collection('sectors')
        .orderBy('name')
        .getDocuments();

    if (responseSectorsDocuments.documents.length == 0) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    List<Sector> tempSectorsList = [];
    for (var i = 0; i < responseSectorsDocuments.documents.length; i++) {
      final Sector newRight = Sector(
          id: responseSectorsDocuments.documents[i].documentID,
          name: responseSectorsDocuments.documents[i].data['name'],
          description:
              responseSectorsDocuments.documents[i].data['description']);
      tempSectorsList.add(newRight);
    }
    _sectors = tempSectorsList;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}

class ReportModel extends ConnectedModels {
  String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}. ${date.hour}:${date.minute}";
  }

  Future<Map<String, dynamic>> addNewReport(String reportText) async {
    _isLoading = true;
    notifyListeners();

    bool successfullAdd = true;
    String errorMessage = "";

    await _firestoreInstance.collection('reports').add({
      'userReported': _authenticatedUser.name,
      'description': reportText.trim(),
      'time': formatDate(DateTime.now())
    }).catchError((error) {
      successfullAdd = false;
      errorMessage = error;
    });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullAdd, 'error': errorMessage};
  }
}

class UtilityModel extends ConnectedModels {
  bool get isLoading {
    return _isLoading;
  }
}
