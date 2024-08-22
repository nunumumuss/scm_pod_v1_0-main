import 'dart:convert';

import 'package:fec_corp_app/models/account/account.dart';
import 'package:fec_corp_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AccountProvider extends ChangeNotifier {
  final authService = AuthService();

  // Account State
  Account? _account;
  Account? get account => _account;

  // Loding Profile State
  bool _isProfileLoading = false;
  bool get isProfileLoading => _isProfileLoading;

  Future<void> getAccount() async {
      _isProfileLoading = true;

      var responseAccount = await authService.getProfileFromLocal();
      _account = responseAccount;
    
      _isProfileLoading = false;
      notifyListeners();
  }

  Future<void> updateAccount(String name) async {
    _isProfileLoading = true;

    var response = await authService.updateProfile(name);
    if (response.statusCode == 200) {
        var profile = json.decode(response.body);
        _account = Account.fromJson(profile['data']['user']);
    }

    _isProfileLoading = false;
    notifyListeners();
  }

}