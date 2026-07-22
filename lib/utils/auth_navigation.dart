import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

/// Navegación a login desde CTAs de la app.
Future<void> openLoginScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}

/// Estado vacío cuando hace falta sesión (Favoritos, Visitadas, Reportes, etc.).
Widget buildLoginRequiredView({
  required BuildContext context,
  required AppLocalizations l10n,
  required String description,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.profileLoginPrompt,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => openLoginScreen(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              l10n.profileLogin,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
