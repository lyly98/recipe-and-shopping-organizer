import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final notifier = ref.read(authProvider.notifier);
    final errorMessage = await notifier.register(
      email: email,
      username: username,
      password: password,
    );

    if (!mounted) return;
    if (errorMessage != null) {
      AppUtils.showSnackBar(
        context,
        message: errorMessage,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppPalette.darkPastelBackground : AppPalette.cream;
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.white;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final onMuted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final primary = isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange;
    final secondary = isDark ? AppPalette.darkPastelPrimaryPink : AppPalette.primaryPink;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Inscription',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: onBg,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onBg),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppPalette.darkPastelSage.withValues(alpha: 0.3) : AppPalette.categoryDesserts,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.ramen_dining_rounded,
                      size: 56,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez-nous pour sauvegarder vos recettes et planifier vos repas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: onMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark ? null : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInput(
                        context,
                        controller: _emailController,
                        label: 'Email',
                        hint: 'votre@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        onBg: onBg,
                        onMuted: onMuted,
                        isDark: isDark,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!AppUtils.isValidEmail(value)) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        context,
                        controller: _usernameController,
                        label: 'Nom d\'utilisateur',
                        hint: 'lettres et chiffres, 2–20 caractères',
                        icon: Icons.person_outline_rounded,
                        onBg: onBg,
                        onMuted: onMuted,
                        isDark: isDark,
                        autocorrect: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom d\'utilisateur';
                          }
                          final lower = value.trim().toLowerCase();
                          if (lower.length < 2 || lower.length > 20) {
                            return 'Entre 2 et 20 caractères';
                          }
                          if (!RegExp(r'^[a-z0-9]+$').hasMatch(lower)) {
                            return 'Lettres minuscules et chiffres uniquement';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        context,
                        controller: _passwordController,
                        label: 'Mot de passe',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        onBg: onBg,
                        onMuted: onMuted,
                        isDark: isDark,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: onMuted,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 8) {
                            return 'Au moins 8 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        context,
                        controller: _confirmPasswordController,
                        label: 'Confirmer le mot de passe',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        onBg: onBg,
                        onMuted: onMuted,
                        isDark: isDark,
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: onMuted,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer le mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: AppPalette.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('S\'inscrire'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: TextStyle(fontSize: 15, color: onMuted),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppConstants.loginRoute),
                      style: TextButton.styleFrom(
                        foregroundColor: secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color onBg,
    required Color onMuted,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool autocorrect = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: autocorrect,
      style: TextStyle(color: onBg),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: onMuted, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppPalette.darkPastelBackground : AppPalette.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: onMuted),
        hintStyle: TextStyle(color: onMuted.withValues(alpha: 0.7)),
      ),
      validator: validator,
    );
  }
}
