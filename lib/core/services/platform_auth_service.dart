import 'package:shared_preferences/shared_preferences.dart';

import '../models/universal_folder_models.dart';
import 'universal_folder_api.dart';

class PlatformAuthService {
  PlatformAuthService._();

  static final PlatformAuthService instance = PlatformAuthService._();

  static const _tokenKey = 'platform_auth_token';
  static const _userEmailKey = 'platform_user_email';
  static const _userNameKey = 'platform_user_name';
  static const _planKey = 'platform_user_plan';
  static const _userIdKey = 'platform_user_id';
  static const _adminKey = 'platform_user_is_admin';

  String? _token;
  PlatformUser? _user;

  String? get token => _token;
  PlatformUser? get user => _user;
  bool get isAuthenticated => (_token ?? '').isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final email = prefs.getString(_userEmailKey);
    final name = prefs.getString(_userNameKey);
    final plan = prefs.getString(_planKey);
    final userId = prefs.getInt(_userIdKey);
    final isAdmin = prefs.getBool(_adminKey);

    _token = token;
    _user = token?.isNotEmpty == true && email != null && name != null && plan != null
        ? PlatformUser(
            id: userId ?? 0,
            fullName: name,
            email: email,
            defaultPlanCode: plan,
            isAdmin: isAdmin ?? false,
          )
        : null;
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await UniversalFolderApi.instance.postJson(
      '/auth/register',
      {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );
    final session = AuthSession.fromJson(response);
    await _persistSession(session);
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await UniversalFolderApi.instance.postJson(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );
    final session = AuthSession.fromJson(response);
    await _persistSession(session);
    return session;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_planKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_adminKey);
  }

  Future<PlatformUser?> refreshUser() async {
    if ((_token ?? '').isEmpty) {
      return null;
    }
    final response = await UniversalFolderApi.instance.getJsonMap(
      '/auth/me',
      bearerToken: _token,
    );
    final user = PlatformUser.fromJson(response);
    await _persistUser(user);
    return user;
  }

  Future<void> _persistSession(AuthSession session) async {
    _token = session.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await _persistUser(session.user, prefs: prefs);
  }

  Future<void> _persistUser(
    PlatformUser user, {
    SharedPreferences? prefs,
  }) async {
    _user = user;
    final sharedPreferences = prefs ?? await SharedPreferences.getInstance();
    await sharedPreferences.setInt(_userIdKey, user.id);
    await sharedPreferences.setString(_userEmailKey, user.email);
    await sharedPreferences.setString(_userNameKey, user.fullName);
    await sharedPreferences.setString(_planKey, user.defaultPlanCode);
    await sharedPreferences.setBool(_adminKey, user.isAdmin);
  }
}
