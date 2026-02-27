import 'package:flutter/material.dart';

import '../../../core/constants/roles.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/auth_exception.dart';
import '../../../core/auth/role_access.dart';
import '../../../core/network/api_config.dart';
import '../../../app/app_routes.dart';
import 'auth_theme.dart';

/// Log In credentials page. Shown after selecting a role on the first page.
/// User can log in with either Email or 5-digit ID Number, and password.
class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key, this.selectedRole});

  /// Role selected on the previous (role selection) page.
  final AppRole? selectedRole;

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _loginError;

  AppRole get _role =>
      ModalRoute.of(context)?.settings.arguments as AppRole? ??
      widget.selectedRole ??
      AppRole.member;


  @override
  void dispose() {
    _emailOrIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.login(
        _emailOrIdController.text.trim(),
        _passwordController.text,
        useRoleForMock: apisHandicapped ? _role : null,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);

      final r = AuthService.instance.role;
      if (r != null) {
        if (r != _role) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You selected ${_role.label} portal. Your account is ${r.label} — redirecting to ${r.label} dashboard.',
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        final route = RoleAccess.defaultRouteForRole(r);
        Navigator.of(context).pushReplacementNamed(route);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login succeeded but session could not be restored. Please try again.')),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      const warningMsg = 'Wrong email, ID number, or password. Please check and try again.';
      setState(() {
        _isLoading = false;
        _loginError = warningMsg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(warningMsg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loginError = 'Wrong email, ID number, or password. Please check and try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Wrong email, ID number, or password. Please check and try again.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)?.settings.arguments as AppRole? ??
        widget.selectedRole ??
        AppRole.member;
    final isMobile = AuthLayout.isMobile(context);

    return Scaffold(
        backgroundColor: AuthTheme.background(context),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AuthLayout.horizontalPadding(context),
                vertical: isMobile ? 16 : 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AuthLayout.maxFormWidth(context),
                ),
                child: Container(
                  padding: EdgeInsets.all(AuthLayout.cardPadding(context)),
                  decoration: BoxDecoration(
                    color: AuthTheme.cardBackground(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                                }
                              },
                              icon: const Icon(Icons.arrow_back),
                              color: AuthTheme.textPrimary(context),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Log In',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AuthTheme.textPrimary(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back to Taker',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AuthTheme.textSecondary(context)),
                        ),
                        if (_loginError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade700, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red.shade300, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _loginError!,
                                    style: TextStyle(
                                      color: Colors.red.shade200,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AuthTheme.primaryBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AuthTheme.primaryBlue.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 18, color: AuthTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You are logging in to the ${role.label} portal',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AuthTheme.textPrimary(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                                style: TextButton.styleFrom(
                                  foregroundColor: AuthTheme.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Change role'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildInput(
                          controller: _emailOrIdController,
                          label: 'Email or ID Number',
                          hint: 'Enter your email or 5-digit ID number',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.text,
                          onChanged: (_) => setState(() => _loginError = null),
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.isEmpty) return 'Email or ID number is required';
                            final id = int.tryParse(s);
                            if (id != null && (s.length != 5 || id < 10000 || id > 99999)) {
                              return 'ID number must be 5 digits (e.g. 10001)';
                            }
                            if (id == null && (!s.contains('@') || !s.contains('.'))) {
                              return 'Enter a valid email or 5-digit ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(role, onChanged: () => setState(() => _loginError = null)),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isLoading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: AuthTheme.primaryBlue,
                            foregroundColor: AuthTheme.background(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Log In'),
                        ),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSocialButtons(isMobile),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AuthTheme.textPrimary(context)),
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AuthTheme.textSecondary(context), size: 22),
      ),
    );
  }

  Widget _buildPasswordField(AppRole role, {VoidCallback? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: AuthTheme.textPrimary(context)),
          textInputAction: TextInputAction.done,
          onChanged: onChanged != null ? (_) => onChanged() : null,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.trim().isEmpty) return 'Password cannot be only spaces';
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AuthTheme.textSecondary(context),
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AuthTheme.textSecondary(context),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
            },
            style: TextButton.styleFrom(
              foregroundColor: AuthTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Forgot Password?'),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child:
                Divider(color: AuthTheme.textSecondary(context).withValues(alpha: 0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(color: AuthTheme.textSecondary(context), fontSize: 12),
          ),
        ),
        Expanded(
            child:
                Divider(color: AuthTheme.textSecondary(context).withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildSocialButtons(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.g_mobiledata,
                    size: 24, color: AuthTheme.textPrimary(context)),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AuthTheme.textPrimary(context),
                  side: BorderSide(color: AuthTheme.textSecondary(context)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.apple, color: AuthTheme.textPrimary(context)),
                label: const Text('Apple'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AuthTheme.textPrimary(context),
                  side: BorderSide(color: AuthTheme.textSecondary(context)),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.g_mobiledata,
                      size: 24, color: AuthTheme.textPrimary(context)),
                  label: const Text('Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AuthTheme.textPrimary(context),
                    side: BorderSide(color: AuthTheme.textSecondary(context)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.apple, color: AuthTheme.textPrimary(context)),
                  label: const Text('Apple'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AuthTheme.textPrimary(context),
                    side: BorderSide(color: AuthTheme.textSecondary(context)),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'First time? ',
          style: TextStyle(color: AuthTheme.textSecondary(context)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(
            AppRoutes.signUp,
          ),
          style: TextButton.styleFrom(
            foregroundColor: AuthTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Sign up here'),
        ),
      ],
    );
  }
}
