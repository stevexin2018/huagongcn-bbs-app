import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isSigningIn = false;
  String? _errorMessage;
  String? _token;
  String? _userId;
  String? _username;
  String? _displayName;
  bool _isAdministrator = false;

  bool get isLoading => _isLoading;
  bool get isSigningIn => _isSigningIn;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null && _userId != null;
  String? get username => _username;
  String get displayName => _displayName ?? _username ?? '已登录用户';
  bool get isAdministrator => _isAdministrator;

  AuthProvider() {
    restoreSession();
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('flarum_token');
    _userId = prefs.getString('flarum_user_id');
    _username = prefs.getString('flarum_username');
    _displayName = prefs.getString('flarum_display_name');
    _isAdministrator = prefs.getBool('flarum_is_administrator') ?? false;

    if (isLoggedIn) {
      try {
        final user = await _apiService.getUserProfile(_userId!, _token!);
        _applyUser(user);
        await _saveSession();
      } catch (_) {
        // Keep the stored session. A transient network failure must not log out a user.
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String identification, String password) async {
    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final credentials = await _apiService.login(identification.trim(), password);
      if (credentials == null) {
        _errorMessage = '用户名、邮箱或密码不正确。';
        return false;
      }
      _token = credentials['token']?.toString();
      _userId = credentials['userId']?.toString();
      if (!isLoggedIn) {
        _errorMessage = '论坛未返回有效登录凭据。';
        return false;
      }
      final user = await _apiService.getUserProfile(_userId!, _token!);
      _applyUser(user);
      await _saveSession();
      return true;
    } catch (e) {
      _errorMessage = '登录失败：$e';
      return false;
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _apiService.register(
        username: username.trim(),
        email: email.trim(),
        password: password,
      );
      if (user == null) {
        _errorMessage = '注册失败：用户名或邮箱可能已被使用。';
        return false;
      }
      // Forum registration is configured for automatic activation. Sign in
      // immediately so the member can interact without waiting for an email.
      return await signIn(username.trim(), password);
    } catch (e) {
      _errorMessage = '注册失败：$e';
      return false;
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _token = null;
    _userId = null;
    _username = null;
    _displayName = null;
    _isAdministrator = false;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('flarum_token');
    await prefs.remove('flarum_user_id');
    await prefs.remove('flarum_username');
    await prefs.remove('flarum_display_name');
    await prefs.remove('flarum_is_administrator');
    notifyListeners();
  }

  void _applyUser(Map<String, dynamic> user) {
    final attributes = user['attributes'] as Map<String, dynamic>? ?? {};
    _username = attributes['username']?.toString();
    _displayName = attributes['displayName']?.toString() ?? _username;
    final relationships = user['relationships'] as Map<String, dynamic>? ?? {};
    final groups = relationships['groups']?['data'];
    _isAdministrator = groups is List && groups.any(
      (group) => group is Map<String, dynamic> && group['id']?.toString() == '1',
    );
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flarum_token', _token!);
    await prefs.setString('flarum_user_id', _userId!);
    if (_username != null) await prefs.setString('flarum_username', _username!);
    if (_displayName != null) await prefs.setString('flarum_display_name', _displayName!);
    await prefs.setBool('flarum_is_administrator', _isAdministrator);
  }
}
