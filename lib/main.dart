import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/storage/workspace_preferences.dart';
import 'package:pharmacy_saas_mobile/core/theme/app_theme.dart';
import 'package:pharmacy_saas_mobile/features/auth/presentation/business_branch_flow.dart';
import 'package:pharmacy_saas_mobile/features/auth/presentation/login_screen.dart';
import 'package:pharmacy_saas_mobile/features/auth/presentation/welcome_screen.dart';
import 'package:pharmacy_saas_mobile/features/home/presentation/app_shell.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';
import 'package:pharmacy_saas_mobile/features/workspace/domain/workspace_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await WorkspacePreferences.load();
  runApp(PharmacySaasMobileApp(preferences: preferences));
}

enum _AuthStep { welcome, login, selectBusiness, selectBranch, authenticated }

class PharmacySaasMobileApp extends StatefulWidget {
  const PharmacySaasMobileApp({
    super.key,
    required this.preferences,
  });

  final WorkspacePreferences preferences;

  @override
  State<PharmacySaasMobileApp> createState() => _PharmacySaasMobileAppState();
}

class _PharmacySaasMobileAppState extends State<PharmacySaasMobileApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late _AuthStep _step;
  WorkspaceSession? _pendingSession;
  WorkspaceSession? _activeSession;

  @override
  void initState() {
    super.initState();
    final savedToken = widget.preferences.authToken;
    final savedEmail = widget.preferences.rememberedEmail;
    if (savedToken != null &&
        savedToken.isNotEmpty &&
        savedEmail != null &&
        savedEmail.isNotEmpty) {
      var restored = PharmacyDirectory.resolveSessionForLogin(savedEmail);
      final savedDomain = widget.preferences.tenantDomain;
      for (final ws in restored.availableWorkspaces) {
        if (ws.domain == savedDomain) {
          final firstBranch = ws.branches.first;
          restored = restored.copyWith(
            tenantDomain: ws.domain,
            tenantName: ws.name,
            licenseNumber: ws.licenseNumber,
            planName: ws.planName,
            currencySymbol: ws.currencySymbol,
            branchId: firstBranch.id,
            branchName: firstBranch.name,
            branchShortName: _shortBranchName(firstBranch.name),
            branchCode: firstBranch.code,
          );
          break;
        }
      }
      final savedBranchId = widget.preferences.branchId;
      if (savedBranchId != null) {
        for (final branch in restored.currentBranches) {
          if (branch.id == savedBranchId) {
            restored = restored.copyWith(
              branchId: branch.id,
              branchName: branch.name,
              branchShortName: _shortBranchName(branch.name),
              branchCode: branch.code,
            );
            break;
          }
        }
      }
      _activeSession = restored;
      _step = _AuthStep.authenticated;
    } else {
      _step = _AuthStep.welcome;
    }
  }

  static String _shortBranchName(String fullName) {
    final cleaned = fullName.replaceAll(' (Head Office)', '').trim();
    return cleaned.isEmpty ? fullName : cleaned;
  }

  void _handleAuthenticated(WorkspaceSession session) {
    setState(() {
      _pendingSession = session;
      if (session.availableWorkspaces.length > 1) {
        _step = _AuthStep.selectBusiness;
      } else if (session.currentBranches.length > 1) {
        _step = _AuthStep.selectBranch;
      } else {
        _completeWorkspaceSelection(session);
      }
    });
  }

  void _handleBusinessSelected(TenantWorkspace workspace) {
    final current = _pendingSession;
    if (current == null) {
      return;
    }
    final defaultBranch = workspace.branches.first;
    final updated = current.copyWith(
      tenantDomain: workspace.domain,
      tenantName: workspace.name,
      licenseNumber: workspace.licenseNumber,
      planName: workspace.planName,
      currencySymbol: workspace.currencySymbol,
      branchId: defaultBranch.id,
      branchName: defaultBranch.name,
      branchShortName: _shortBranchName(defaultBranch.name),
      branchCode: defaultBranch.code,
    );
    setState(() {
      _pendingSession = updated;
      if (workspace.branches.length > 1) {
        _step = _AuthStep.selectBranch;
      } else {
        _completeWorkspaceSelection(updated);
      }
    });
  }

  void _handleBranchSelected(BranchInfo branch) {
    final current = _pendingSession;
    if (current == null) {
      return;
    }
    final completed = current.copyWith(
      branchId: branch.id,
      branchName: branch.name,
      branchShortName: _shortBranchName(branch.name),
      branchCode: branch.code,
    );
    setState(() {
      _completeWorkspaceSelection(completed);
    });
  }

  void _completeWorkspaceSelection(WorkspaceSession finalSession) {
    widget.preferences.saveTenantDomain(finalSession.tenantDomain);
    widget.preferences.saveBranchId(finalSession.branchId);
    widget.preferences.saveAuthToken(
      'session_${finalSession.userEmail}_${finalSession.tenantDomain}',
    );
    widget.preferences.saveRememberedEmail(finalSession.userEmail);
    _activeSession = finalSession;
    _pendingSession = null;
    _step = _AuthStep.authenticated;
  }

  Future<void> _handleSignOut() async {
    await widget.preferences.clearSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _activeSession = null;
      _pendingSession = null;
      _step = _AuthStep.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_step) {
      case _AuthStep.welcome:
        return WelcomeScreen(
          onGetStarted: () => setState(() => _step = _AuthStep.login),
        );
      case _AuthStep.login:
        return LoginScreen(
          initialEmail: widget.preferences.rememberedEmail,
          onBack: () => setState(() => _step = _AuthStep.welcome),
          onAuthenticated: _handleAuthenticated,
        );
      case _AuthStep.selectBusiness:
        final session = _pendingSession!;
        return SelectBusinessScreen(
          session: session,
          onBack: () => setState(() => _step = _AuthStep.login),
          onContinue: _handleBusinessSelected,
        );
      case _AuthStep.selectBranch:
        final session = _pendingSession!;
        final workspace =
            session.currentWorkspace ?? session.availableWorkspaces.first;
        return SelectBranchScreen(
          workspace: workspace,
          initialBranchId: session.branchId,
          onBack: () => setState(() {
            _step = session.availableWorkspaces.length > 1
                ? _AuthStep.selectBusiness
                : _AuthStep.login;
          }),
          onContinue: _handleBranchSelected,
        );
      case _AuthStep.authenticated:
        return AppShell(
          session: _activeSession!,
          preferences: widget.preferences,
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
          onSignOut: _handleSignOut,
        );
    }
  }
}
