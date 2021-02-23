import 'package:cnc_flutter_app/connections/db_helper.dart';
import 'package:cnc_flutter_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

const users = const {
  'test@gmail.com': 'test1234',
  'hunter@gmail.com': 'hunter',
  '': '',
};

class LoginScreen extends StatelessWidget {
  var db = new DBHelper();

  Duration get loginTime => Duration(milliseconds: 2000);

  Future<String> _authUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      //user doesn't exist in db
      if (await db.isEmailValid(data.name) == false) {
        return 'Username does not exist';
      }
      //password doesn't match username in db
      if (await db.login(data.name, data.password) == false) {
        return 'Incorrect password';
      }
      print('Authorization successful.');
      //auth was successful
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', '${data.name}');
      return null;
    });
  }

  Future<String> _registerUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      //check if username is already taken
      if (await db.isEmailValid(data.name) == true) {
        return 'Username is already taken.';
      }
      UserModel userModel = new UserModel(data.name, data.password);
      var response = db.registerNewUser(userModel);
      print(response.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', '${data.name}');
      return null;
      // return 'Error registering.';
    });
  }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    //TODO add in logic to recover password
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'ENACT',
      logo: 'assets/placeholder_logo.png',
      onLogin: _authUser,
      onSignup: _registerUser,
      onSubmitAnimationCompleted: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
