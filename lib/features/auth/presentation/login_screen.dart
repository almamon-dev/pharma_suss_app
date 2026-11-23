import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/widgets/brand_logo.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';
import 'package:pharmacy_saas_mobile/features/workspace/domain/workspace_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onAuthenticated,
    this.onBack,
    this.initialEmail,
  });

  final ValueChanged<WorkspaceSession> onAuthenticated;
  final VoidCallback? onBack;
  final String? initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(
      text: widget.initialEmail ?? '',
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isSubmitting) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (!mounted) {
      return;
    }

    final session = PharmacyDirectory.resolveSessionForLogin(
      _identifierController.text,
    );

    setState(() => _isSubmitting = false);
    widget.onAuthenticated(session);
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset Account Password',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in using your registered email or phone number—no domain entry is needed. Ask your Pharmacy Store Owner to reset staff passwords from Team Settings.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBusinessCodeAndQuickAccessSheet() {
    final codeController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Login with Business Code or Role',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Optional fast staff login or select a demo pharmacy role.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Staff Business Code',
                  hintText: 'e.g. MAMON-01',
                  prefixIcon: Icon(Icons.qr_code_2_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'QUICK DEMO ROLES',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PharmacyDirectory.demoAccounts.map((preset) {
                  return ActionChip(
                    avatar: const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: AppConfig.brandPrimary,
                    ),
                    label: Text('${preset.label} (${preset.badge})'),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      setState(() {
                        _identifierController.text = preset.email;
                        _passwordController.text = preset.password;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final code = codeController.text.trim();
                  Navigator.of(sheetContext).pop();
                  if (code.isNotEmpty) {
                    setState(() {
                      _identifierController.text = 'mamon@pharmacy.com';
                      _passwordController.text = 'password';
                    });
                    _handleSignIn();
                  }
                },
                child: const Text('Continue with Code'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.canvasDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: BrandLogo(
                              size: 56,
                              vertical: true,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Sign In to Your Account',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Email or Phone',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _identifierController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            decoration: const InputDecoration(
                              hintText: 'mamon@pharmacy.com',
                            ),
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty || trimmed.length < 4) {
                                return 'Enter your email or phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Password',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _handleSignIn(),
                            decoration: InputDecoration(
                              hintText: '••••••••••••',
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AppConfig.brandPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              _rememberMe = val ?? true;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember me',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _showForgotPasswordSheet,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: AppConfig.brandPrimary,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: _isSubmitting ? null : _handleSignIn,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Sign In'),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _showBusinessCodeAndQuickAccessSheet,
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 18,
                            ),
                            label: const Text('Login with Business Code'),
                          ),
                          const SizedBox(height: 14),
                          // Compact quick demo chips for 1-tap login testing
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6,
                            runSpacing: 6,
                            children: PharmacyDirectory.demoAccounts
                                .take(3)
                                .map((preset) {
                              return SurfaceCard(
                                elevated: false,
                                borderRadius: 999,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  setState(() {
                                    _identifierController.text = preset.email;
                                    _passwordController.text = preset.password;
                                  });
                                },
                                child: Text(
                                  preset.label,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Powered by ${AppConfig.appName}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
