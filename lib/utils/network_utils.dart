import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'auth_utils.dart';

class NetworkUtils {
  static final String host = 'http://dev.autocred.cl/api';

  static dynamic authenticateUser(String dni, String password) async {
    var uri = host + '/auth/login';

    try {
      Map data = {'dni': dni, 'password': password};
      final response = await http.post(uri,
          headers: {"accept": "application/json"}, body: data);
      final responseJson = json.decode(response.body);
      return responseJson;
    } catch (exception) {
      print(exception);
      if (exception.toString().contains('SocketException')) {
        return 'Error de Red';
      } else {
        return null;
      }
    }
  }

  static logoutUser(BuildContext context, SharedPreferences prefs) {
    prefs.setString(AuthUtils.accessTokenKey, null);
  }

  static showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message ?? 'Sin Conexión'),
    ));
  }
}
