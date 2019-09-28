import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mine classes
import 'package:mywarehouseproject/models/user.dart';
import 'package:mywarehouseproject/models/right.dart';

class ConnectedModels extends Model {
  // FIREBASE
  final Firestore _firestoreInstance = Firestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver _analyticsObserver =
      FirebaseAnalyticsObserver(analytics: _firebaseAnalytics);

  FirebaseAnalytics get GetFirebaseAnalytics {
    return _firebaseAnalytics;
  }

  FirebaseAnalyticsObserver get GetAnalyticsObserver {
    return _analyticsObserver;
  }

  Future<Null> sendAnalytics(
      String eventName, Map<String, dynamic> eventParameters) async {
    await _firebaseAnalytics.logEvent(
        name: eventName, parameters: eventParameters);
  }

  //DEVICE INFO
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo _androidInfo;
  IosDeviceInfo _iosInfo;

  void getAndroidInfo() async {
    _androidInfo = await deviceInfo.androidInfo;
  }

  void getIosInfo() async {
    _iosInfo = await deviceInfo.iosInfo;
  }

  // OTHER STUFF
  User _authenticatedUser;
  bool _isLoading = false;

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

        await sendAnalytics("upload_image", {
          'userId': _authenticatedUser.id,
          'user': _authenticatedUser.name,
          'imageName': fileName,
          'device': _androidInfo != null
              ? _androidInfo.model
              : _iosInfo.utsname.machine,
          'systemVersion': _androidInfo != null
              ? _androidInfo.version.release
              : _iosInfo.systemVersion
        });
        return {'success': true, 'imageUrl': _imageDownloadUrl};
      } catch (e) {
        sendAnalytics("error", {
          'function': "uploadImage",
          'description': e.message,
          'device': _androidInfo != null
              ? _androidInfo.model
              : _iosInfo.utsname.machine,
          'systemVersion': _androidInfo != null
              ? _androidInfo.version.release
              : _iosInfo.systemVersion
        });
        return {'success': false, 'error': e.message};
      }
    }
    return {'success': false, 'error': "Image file is null!"};
  }
}

class UserModel extends ConnectedModels {
  User get authenticatedUser {
    return _authenticatedUser;
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (!result.isNotEmpty && !result[0].rawAddress.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on SocketException catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    return true;
  }

  Stream<QuerySnapshot> getWorkersStream() {
    return _firestoreInstance.collection('workers').orderBy('name').snapshots();
  }

  Future<bool> getAdditionalUserInfo() async {
    if (_authenticatedUser.id != null) {
      QuerySnapshot response = await _firestoreInstance
          .collection('workers')
          .where("id", isEqualTo: _authenticatedUser.id)
          .getDocuments();

      DocumentSnapshot document = response.documents.single;

      if (document.data == null) {
        print(document.data);
        print(_authenticatedUser.email);
        return false;
      }

      _authenticatedUser.address = document['address'];
      _authenticatedUser.adminOrUser = document['adminOrUser'];
      _authenticatedUser.imageUrl = document['imageUrl'];
      _authenticatedUser.name = document['name'];
      _authenticatedUser.rights =
          document['rights'] != null ? document['rights'].cast<String>() : null;
      _authenticatedUser.phone = document['phone'];
      _authenticatedUser.sector = document['sector'];

      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    bool connectedToInternet = await checkInternetConnection();

    if (!connectedToInternet) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': "No internet connection."};
    }

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

      await sendAnalytics("login_attempt", {
        'error': responseMessage,
        'device': _androidInfo != null
            ? _androidInfo.model
            : _iosInfo.utsname.machine,
        'systemVersion': _androidInfo != null
            ? _androidInfo.version.release
            : _iosInfo.systemVersion
      });

      return {'success': !hasError, 'message': responseMessage};
    } else {
      _authenticatedUser = User(
          email: user.user.email,
          id: user.user.uid,
          token: (await user.user.getIdToken()).token);

      bool gotAditionalInfo = await getAdditionalUserInfo();
      if (!gotAditionalInfo) {
        _firebaseAuth.signOut();
        hasError = true;
        responseMessage = 'User not found.';
        _isLoading = false;
        notifyListeners();
      }

      await sendAnalytics("login", {
        'userId': _authenticatedUser.id,
        'user': _authenticatedUser.name,
        'device': _androidInfo != null
            ? _androidInfo.model
            : _iosInfo.utsname.machine,
        'systemVersion': _androidInfo != null
            ? _androidInfo.version.release
            : _iosInfo.systemVersion
      });
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

  void signOut() async {
    await _firebaseAuth.signOut();
    _authenticatedUser = null;
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
      await sendAnalytics("new_worker_error", {
        'error': responseMessage,
        'device': _androidInfo != null
            ? _androidInfo.model
            : _iosInfo.utsname.machine,
        'systemVersion': _androidInfo != null
            ? _androidInfo.version.release
            : _iosInfo.systemVersion
      });

      _isLoading = false;
      notifyListeners();
      return {'success': !hasError, 'message': responseMessage};
    } else {
      Map<String, dynamic> uploadImageResult;

      if (userData['imageFile'] != null) {
        uploadImageResult = await uploadImage(
            userData['name'] + "_image", userData['imageFile']);

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

      await sendAnalytics("new_worker", {
        'device': _androidInfo != null
            ? _androidInfo.model
            : _iosInfo.utsname.machine,
        'systemVersion': _androidInfo != null
            ? _androidInfo.version.release
            : _iosInfo.systemVersion
      });

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
      await sendAnalytics("update_worker_attempt", {
        'error': e.message,
        'device': _androidInfo != null
            ? _androidInfo.model
            : _iosInfo.utsname.machine,
        'systemVersion': _androidInfo != null
            ? _androidInfo.version.release
            : _iosInfo.systemVersion
      });

      _isLoading = true;
      notifyListeners();

      return {'success': !hasError, 'message': e.message};
    }

    await sendAnalytics("update_worker", {
      'userId': id,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

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

    await sendAnalytics("delete_worker", {
      'userId': id,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    return {'success': successfullUpdate, 'error': errorMessage};
  }
}

class ProductModel extends ConnectedModels {
  Stream<QuerySnapshot> getProductsStream() {
    return _firestoreInstance
        .collection('products')
        .orderBy('name')
        .snapshots();
  }

  Future<Map<String, dynamic>> addNewProduct(
      Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    bool hasError = false;
    String responseMessage = 'Something went wrong.';

    Map<String, dynamic> uploadImageResult;

    if (productData['imageFile'] != null) {
      uploadImageResult = await uploadImage(
          productData['name'] + "_image", productData['imageFile']);

      if (uploadImageResult['success']) {
        await _firestoreInstance.collection('products').add({
          'name': productData['name'],
          'description': productData['description'],
          'quantity': productData['quantity'],
          'whereIsStored': productData['whereIsStored'],
          'measurementUnit': productData['measurementUnit'],
          'imageUrl': uploadImageResult['imageUrl'],
          'barcode': productData['barcode']
        }).catchError((error) {
          hasError = true;
          responseMessage = error;
          _isLoading = true;
          notifyListeners();
          return {'success': !hasError, 'message': responseMessage};
        });
      } else {
        await _firestoreInstance.collection('products').add({
          'name': productData['name'],
          'description': productData['description'],
          'quantity': productData['quantity'],
          'whereIsStored': productData['whereIsStored'],
          'measurementUnit': productData['measurementUnit'],
          'imageUrl': null,
          'barcode': productData['barcode']
        }).catchError(
          (error) {
            hasError = true;
            responseMessage = error;
            _isLoading = true;
            notifyListeners();
            return {'success': !hasError, 'message': responseMessage};
          },
        );
      }
    } else {
      await _firestoreInstance.collection('products').add({
        'name': productData['name'],
        'description': productData['description'],
        'quantity': productData['quantity'],
        'whereIsStored': productData['whereIsStored'],
        'measurementUnit': productData['measurementUnit'],
        'imageUrl': null,
        'barcode': productData['barcode']
      }).catchError(
        (error) {
          hasError = true;
          responseMessage = error;
          _isLoading = true;
          notifyListeners();
          return {'success': !hasError, 'message': responseMessage};
        },
      );
    }

    await sendAnalytics("new_product", {
      'productName': productData['name'],
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    _isLoading = false;
    notifyListeners();

    return {'success': !hasError, 'message': responseMessage};
  }

  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    bool hasError = false;
    String responseMessage = 'Something went wrong.';

    String imageUrl;

    try {
      if (productData['imageFile'] != null) {
        Map<String, dynamic> uploadResult = await uploadImage(
            productData['name'] + "_image", productData['imageFile']);

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
        await _firestoreInstance
            .collection('products')
            .document(id)
            .updateData({
          'name': productData['name'],
          'description': productData['description'],
          'quantity': productData['quantity'],
          'whereIsStored': productData['whereIsStored'],
          'measurementUnit': productData['measurementUnit'],
          'barcode': productData['barcode']
        });
      } else {
        await _firestoreInstance
            .collection('products')
            .document(id)
            .updateData({
          'name': productData['name'],
          'description': productData['description'],
          'quantity': productData['quantity'],
          'whereIsStored': productData['whereIsStored'],
          'measurementUnit': productData['measurementUnit'],
          'imageUrl': imageUrl,
          'barcode': productData['barcode']
        });
      }
    } catch (e) {
      _isLoading = true;
      notifyListeners();

      return {'success': !hasError, 'message': e.message};
    }

    await sendAnalytics("update_product", {
      'productName': productData['name'],
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    _isLoading = false;
    notifyListeners();

    return {'success': !hasError, 'message': responseMessage};
  }

  Future<Map<String, dynamic>> deleteProduct(String id,
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
        .collection('products')
        .document(id)
        .delete()
        .catchError((error) {
      successfullUpdate = false;
      errorMessage = error;
    });

    await sendAnalytics("delete_product", {
      'productId': id,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    return {'success': successfullUpdate, 'error': errorMessage};
  }
}

class RightsModel extends ConnectedModels {
  Stream<QuerySnapshot> getRightsFirestoreStream() {
    return _firestoreInstance.collection('rights').orderBy('order').snapshots();
  }

  Future<List<Right>> fetchRights() async {
    _isLoading = true;
    notifyListeners();
    var responseRightsDocuments = await _firestoreInstance
        .collection('rights')
        .orderBy('order')
        .getDocuments();

    if (responseRightsDocuments.documents.length == 0) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
    List<Right> tempRightsList = [];
    for (var i = 0; i < responseRightsDocuments.documents.length; i++) {
      final Right newRight = Right(
          id: responseRightsDocuments.documents[i].documentID,
          name: responseRightsDocuments.documents[i].data['name'],
          order: responseRightsDocuments.documents[i].data['order']);
      tempRightsList.add(newRight);
    }
    _isLoading = false;
    notifyListeners();
    return tempRightsList;
  }
}

class SectorModel extends ConnectedModels {
  Future<String> getSectorNameById(String sectorId) async {
    DocumentSnapshot document =
        await _firestoreInstance.collection('sectors').document(sectorId).get();
    if (document != null) {
      return document.data['name'];
    } else {
      return null;
    }
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

    await sendAnalytics("new_sector", {
      'sectorName': name,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullAdd, 'error': errorMessage};
  }

  Future<Map<String, dynamic>> updateSector(
      String id, String oldName, String newName, String description) async {
    _isLoading = true;
    notifyListeners();

    bool successfullUpdate = true;
    String errorMessage = "";

    await _firestoreInstance.collection('sectors').document(id).updateData(
        {'name': newName, 'description': description}).catchError((error) {
      successfullUpdate = false;
      errorMessage = error;
      _isLoading = false;
      notifyListeners();
      return {'success': successfullUpdate, 'error': errorMessage};
    });

    await sendAnalytics("update_sector", {
      'sectorId': id,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
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

    await sendAnalytics("delete_sector", {
      'sectorId': id,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    return {'success': successfullUpdate, 'error': errorMessage};
  }
}

class ReportModel extends ConnectedModels {
  Stream<QuerySnapshot> getReportsStream() {
    return _firestoreInstance
        .collection('reports')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>> deleteReport(String id) async {
    bool successfullUpdate = true;
    String errorMessage = "";

    await _firestoreInstance
        .collection('reports')
        .document(id)
        .delete()
        .catchError((PlatformException error) {
      successfullUpdate = false;
      errorMessage = error.message;
    });

    await sendAnalytics("delete_report", {
      'reportId': id,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    return {'success': successfullUpdate, 'error': errorMessage};
  }

  Future<Map<String, dynamic>> addNewReport(String reportText) async {
    _isLoading = true;
    notifyListeners();

    bool successfullAdd = true;
    String errorMessage = "";

    await _firestoreInstance.collection('reports').add({
      'userReported': _authenticatedUser.name,
      'description': reportText.trim(),
      'time': Timestamp.now()
    }).catchError((error) {
      successfullAdd = false;
      errorMessage = error;
    });

    await sendAnalytics("new_report", {
      'user': _authenticatedUser.name,
      'device':
          _androidInfo != null ? _androidInfo.model : _iosInfo.utsname.machine,
      'systemVersion': _androidInfo != null
          ? _androidInfo.version.release
          : _iosInfo.systemVersion
    });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullAdd, 'error': errorMessage};
  }
}

class UtilityModel extends ConnectedModels {
  String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}:${date.second}";
  }

  bool get isLoading {
    return _isLoading;
  }
}

class UsageModel extends ConnectedModels {
  Future<Map<String, dynamic>> addNewShipment(
      Map<String, dynamic> shipmentData) async {
    _isLoading = true;
    notifyListeners();

    bool successfullAdd = true;
    String errorMessage = "";
    for (var product in shipmentData['productsArrived']) {
      print(product['arrivedQuantity']);
      await _firestoreInstance
          .collection('products')
          .document(product['id'])
          .updateData({
        'quantity': FieldValue.increment(product['arrivedQuantity'])
      }).catchError((error) {
        successfullAdd = false;
        errorMessage = error;

        _isLoading = false;
        notifyListeners();
        return {'success': successfullAdd, 'error': errorMessage};
      });
    }

    await _firestoreInstance.collection('receipt').add({
      'userCreated': _authenticatedUser.name,
      'from': shipmentData['from'],
      'productsArrived': shipmentData['productsArrived'],
      'totalPrice': shipmentData['totalPrice'],
      'time': Timestamp.now()
    }).catchError((error) {
      successfullAdd = false;
      errorMessage = error;

      _isLoading = false;
      notifyListeners();
      return {'success': successfullAdd, 'error': errorMessage};
    });

    await sendAnalytics("new_shipment", {
        'user': _authenticatedUser.name,
        'device': _androidInfo != null
            ? _androidInfo.model
            : _iosInfo.utsname.machine,
        'systemVersion':
            _androidInfo != null ? _androidInfo.version.release : _iosInfo.systemVersion
      });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullAdd, 'error': errorMessage};
  }

  Future<Map<String, dynamic>> addNewUsage(
      Map<String, dynamic> shipmentData) async {
    _isLoading = true;
    notifyListeners();

    bool successfullAdd = true;
    String errorMessage = "";

    for (var product in shipmentData['productsPicked']) {
      await _firestoreInstance
          .collection('products')
          .document(product['id'])
          .updateData({
        'quantity': FieldValue.increment(product['usageQuantity'] * -1)
      }).catchError((error) {
        successfullAdd = false;
        errorMessage = error;

        _isLoading = false;
        notifyListeners();
        return {'success': successfullAdd, 'error': errorMessage};
      });
    }

    await _firestoreInstance.collection('receipt').add({
      'userCreated': _authenticatedUser.name,
      'description': shipmentData['description'],
      'productsPicked': shipmentData['productsPicked'],
      'time': Timestamp.now()
    }).catchError((error) {
      successfullAdd = false;
      errorMessage = error;

      _isLoading = false;
      notifyListeners();
      return {'success': successfullAdd, 'error': errorMessage};
    });

    await sendAnalytics("new_usage", {
        'user': _authenticatedUser.name,
        'device': _androidInfo != null
            ? _androidInfo.model
            : _iosInfo.utsname.machine,
        'systemVersion':
            _androidInfo != null ? _androidInfo.version.release : _iosInfo.systemVersion
      });

    _isLoading = false;
    notifyListeners();
    return {'success': successfullAdd, 'error': errorMessage};
  }
}
