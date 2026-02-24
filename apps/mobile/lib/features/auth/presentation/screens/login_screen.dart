import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final notifier = ref.read(authProvider.notifier);
    final errorMessage = await notifier.login(email: email, password: password);

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
          'Connexion',
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
                      color: isDark ? AppPalette.darkPastelTerracotta.withValues(alpha: 0.3) : AppPalette.categoryPlats,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 56,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour gérer vos recettes et votre planning',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: onMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 32),
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
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: onBg),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'votre@email.com',
                          prefixIcon: Icon(Icons.email_outlined, color: onMuted, size: 22),
                          filled: true,
                          fillColor: isDark ? AppPalette.darkPastelBackground : AppPalette.lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: onMuted),
                          hintStyle: TextStyle(color: onMuted.withValues(alpha: 0.7)),
                        ),
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
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: onBg),
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: onMuted, size: 22),
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
                          filled: true,
                          fillColor: isDark ? AppPalette.darkPastelBackground : AppPalette.lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: onMuted),
                          hintStyle: TextStyle(color: onMuted.withValues(alpha: 0.7)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _login,
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
                            : const Text('Se connecter'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style: TextStyle(fontSize: 15, color: onMuted),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppConstants.registerRoute),
                      style: TextButton.styleFrom(
                        foregroundColor: secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('S\'inscrire'),
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
}
