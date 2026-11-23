import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';

class WorkspacePreferences {
  const WorkspacePreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyTenantDomain = 'workspace_tenant_domain';
  static const String _keyBranchId = 'workspace_branch_id';
  static const String _keyAuthToken = 'workspace_auth_token';
  static const String _keyRememberedEmail = 'workspace_remembered_email';

  static Future<WorkspacePreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkspacePreferences(prefs);
  }

  String get tenantDomain =>
      _prefs.getString(_keyTenantDomain) ?? AppConfig.defaultTenantDomain;

  int? get branchId => _prefs.getInt(_keyBranchId);

  String? get authToken => _prefs.getString(_keyAuthToken);

  String? get rememberedEmail => _prefs.getString(_keyRememberedEmail);

  Future<void> saveTenantDomain(String domain) async {
    await _prefs.setString(_keyTenantDomain, domain.trim());
  }

  Future<void> saveBranchId(int? branchId) async {
    if (branchId == null) {
      await _prefs.remove(_keyBranchId);
      return;
    }
    await _prefs.setInt(_keyBranchId, branchId);
  }

  Future<void> saveAuthToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _prefs.remove(_keyAuthToken);
      return;
    }
    await _prefs.setString(_keyAuthToken, token);
  }

  Future<void> saveRememberedEmail(String? email) async {
    final trimmed = email?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _prefs.remove(_keyRememberedEmail);
      return;
    }
    await _prefs.setString(_keyRememberedEmail, trimmed);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyBranchId);
  }
}
