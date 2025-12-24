import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';
import '../services/admob_service.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUp;

  const LoginScreen({super.key, this.isSignUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _acceptedPrivacyPolicy = false;
  bool _acceptedTermsOfService = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientTop,
              AppColors.gradientTop.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.25, 0.5],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  // Tarjeta blanca con formulario
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_isSignUp) ...[
                          _buildNameField(),
                          const SizedBox(height: 16),
                        ],
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        if (!_isSignUp) ...[
                          const SizedBox(height: 12),
                          _buildForgotPassword(),
                        ],
                        if (_isSignUp) ...[
                          const SizedBox(height: 20),
                          _buildAcceptanceCheckboxes(),
                        ],
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                        _buildToggleMode(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSocialButtons(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Anuncio banner
                  _buildAdBanner(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: const BannerAdWidget(
        adSize: AdSize.banner,
        useHotelRestaurantTargeting: true,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón de retroceso moderno
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: 24),
        // Logo con sombra (más grande)
        Center(
          child: Hero(
            tag: 'app_logo',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const AppLogo(height: 140),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Título moderno
        Center(
          child: Column(
            children: [
              Text(
                _isSignUp ? 'Crear cuenta' : '¡Bienvenido!',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Regístrate para guardar tus playas favoritas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Nombre completo',
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu nombre';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.email_rounded, color: AppColors.primary, size: 20),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu correo';
        }
        if (!value.contains('@')) {
          return 'Correo inválido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.lock_rounded, color: AppColors.primary, size: 20),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (_isSignUp && value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          _showForgotPasswordDialog();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: authProvider.isLoading
                  ? [Colors.grey[400]!, Colors.grey[400]!]
                  : [
                      AppColors.gradientTop,
                      AppColors.gradientTop.withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: authProvider.isLoading
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isSignUp ? 'Crear cuenta' : 'Iniciar sesión',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? '¿Ya tienes cuenta? ' : '¿No tienes cuenta? ',
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSignUp = !_isSignUp;
              // Resetear checkboxes al cambiar de modo
              _acceptedPrivacyPolicy = false;
              _acceptedTermsOfService = false;
            });
          },
          child: Text(
            _isSignUp ? 'Iniciar sesión' : 'Crear cuenta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[100]!],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O continúa con',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[300]!],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: _buildSocialButton(
              icon: Icons.g_mobiledata,
              label: 'Google',
              onTap: () async {
                final success = await context
                    .read<AuthProvider>()
                    .signInWithGoogle();
                if (success && mounted) {
                  Navigator.of(context).pop();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.read<AuthProvider>().errorMessage ??
                            'Error al iniciar sesión con Google',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
          // Botón de Apple Sign In (solo mostrar en iOS)
          if (Platform.isIOS) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                backgroundColor: Colors.black,
                iconColor: Colors.white,
                onTap: () async {
                  final success = await context
                      .read<AuthProvider>()
                      .signInWithApple();
                  if (success && mounted) {
                    Navigator.of(context).pop();
                  } else if (mounted) {
                    final error = context.read<AuthProvider>().errorMessage;
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor ?? Colors.grey[700], size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptanceCheckboxes() {
    return Column(
      children: [
        _buildCheckboxTile(
          value: _acceptedPrivacyPolicy,
          onChanged: (value) {
            setState(() {
              _acceptedPrivacyPolicy = value ?? false;
            });
          },
          title: 'Acepto la',
          linkText: 'Política de Privacidad',
          onLinkTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildCheckboxTile(
          value: _acceptedTermsOfService,
          onChanged: (value) {
            setState(() {
              _acceptedTermsOfService = value ?? false;
            });
          },
          title: 'Acepto los',
          linkText: 'Términos y Condiciones',
          onLinkTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsOfServiceScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: '$title '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: onLinkTap,
                        child: Text(
                          linkText,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar aceptación de políticas solo en registro
    if (_isSignUp) {
      if (!_acceptedPrivacyPolicy || !_acceptedTermsOfService) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Debes aceptar la Política de Privacidad y los Términos y Condiciones para registrarte',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isSignUp) {
      success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    } else {
      success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientTop, AppColors.gradientBottom],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Restablecer contraseña',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.email_rounded, color: AppColors.primary),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientTop,
                  AppColors.gradientTop.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  final success = await context
                      .read<AuthProvider>()
                      .resetPassword(emailController.text.trim());

                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Email enviado. Revisa tu bandeja de entrada.',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Enviar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
