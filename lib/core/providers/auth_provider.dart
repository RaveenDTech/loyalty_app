import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userRole = '';
  String _userId = '';
  String _userName = '';
  String _userEmail = '';
  /// Years of employment at DSI group companies (customers only). Used for loyalty tier.
  double _employmentTenureYears = 0;

  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;
  double get employmentTenureYears => _employmentTenureYears;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userRole = prefs.getString('userRole') ?? '';
    _userId = prefs.getString('userId') ?? '';
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _employmentTenureYears = prefs.getDouble('employmentTenureYears') ?? 0;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Dummy login credentials for demo - role is determined by email/credentials
      // employmentTenureYears: years at DSI group for DSI Loyalty discount tier
      final dummyUsers = {
        'customer@demo.com': {
          'password': 'Dsi123',
          'name': 'John Customer',
          'role': 'customer',
          'employmentTenureYears': 3.0,
        },
        'supplier@demo.com': {
          'password': 'Dsi123',
          'name': 'ABC Store',
          'role': 'supplier',
          'employmentTenureYears': 0.0,
        },
      };
      
      final user = dummyUsers[email.toLowerCase()];
      if (user != null && password == user['password']) {
        final prefs = await SharedPreferences.getInstance();
        final role = user['role'] as String;
        final tenure = (user['employmentTenureYears'] as num?)?.toDouble() ?? 0.0;
        
        _isAuthenticated = true;
        _userRole = role;
        _userId = role == 'customer' ? 'customer_001' : 'supplier_001';
        _userName = user['name'] as String;
        _userEmail = email.toLowerCase();
        _employmentTenureYears = tenure;
        
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userRole', role);
        await prefs.setString('userId', _userId);
        await prefs.setString('userName', _userName);
        await prefs.setString('userEmail', _userEmail);
        await prefs.setDouble('employmentTenureYears', _employmentTenureYears);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isAuthenticated = false;
    _userRole = '';
    _userId = '';
    _userName = '';
    _userEmail = '';
    _employmentTenureYears = 0;
    
    notifyListeners();
  }
}
