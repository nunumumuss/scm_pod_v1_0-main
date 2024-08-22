import 'dart:convert';

import 'package:fec_corp_app/models/account/account.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

 Future<http.Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    var url = Uri.parse('https://api.codingthailand.com/api/register');
    var response = await http.post(url, body: {
      'name': name,
      'email': email,
      'password': password
    });
    return response;
  }

  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    var url = Uri.parse('https://api.codingthailand.com/api/login');
    var response = await http
        .post(url, body: {'email': email, 'password': password});

    if (response.statusCode == 200) {
      final SharedPreferences prefs = await _prefs;
      await prefs.setString('token', response.body);
    }

    return response;
  }

  Future<void> logout() async {
      final SharedPreferences prefs = await _prefs;
      prefs.remove('token');
      prefs.remove('profile');
  }

  Future<void> getProfile() async {
    final SharedPreferences prefs = await _prefs;
    var token = json.decode(prefs.getString('token')!);
    var accessToken = token['access_token'];

    var profileUrl = Uri.parse('https://api.codingthailand.com/api/profile');
    var response = await http.get(profileUrl, headers: {
       'Authorization': 'Bearer $accessToken'
    });

    var profileData = json.decode(response.body);
    var profile = profileData['data']['user']; // {id:1, name: 'John'...}
    await prefs.setString('profile', json.encode(profile));
  }

  Future<Account> getProfileFromLocal() async {
    final SharedPreferences prefs = await _prefs;
    var account = Account.fromJson(json.decode(prefs.getString('profile')!));
    return account;
  }

  Future<bool> checkIsLogin() async {
    final SharedPreferences prefs = await _prefs;
    var tokenString = prefs.getString('token');
    if (tokenString == "") {
      return false;
    }
    return true;
  }

  Future<http.Response> updateProfile(String name) async {
    final SharedPreferences prefs = await _prefs;
    var token = json.decode(prefs.getString('token')!);
    var accessToken = token['access_token'];

    var profileUrl = Uri.parse('https://api.codingthailand.com/api/editprofile');
    var response = await http
        .post(
          profileUrl, 
          headers: {'Authorization': 'Bearer $accessToken'},
          body: {
            'name': name
          }
        );

    return response;
  }

}