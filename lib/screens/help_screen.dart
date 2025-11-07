import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileHelp,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientTop, AppColors.gradientTop.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Preguntas Frecuentes',
            icon: Icons.help_outline_rounded,
            children: [
              _buildFAQItem(
                question: '¿Cómo puedo marcar una playa como favorita?',
                answer: 'Simplemente toca el ícono de corazón en cualquier tarjeta de playa. Tus favoritos se guardarán automáticamente y podrás acceder a ellos desde tu perfil.',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFFF4081),
              ),
              _buildFAQItem(
                question: '¿Cómo reporto las condiciones de una playa?',
                answer: 'Ve a la pestaña "Reportar" en el menú inferior, selecciona la playa, indica las condiciones actuales (Excelente, Bueno, Moderado o Peligroso), y opcionalmente añade un comentario y fotos.',
                icon: Icons.add_circle_outline,
                color: AppColors.secondary,
              ),
              _buildFAQItem(
                question: '¿Qué significan las condiciones de las playas?',
                answer: '• Excelente: Condiciones ideales para nadar y disfrutar.\n• Bueno: Condiciones aceptables con precauciones menores.\n• Moderado: Se requiere precaución al nadar.\n• Peligroso: No se recomienda entrar al agua.',
                icon: Icons.info_outline,
                color: AppColors.primary,
              ),
              _buildFAQItem(
                question: '¿Cómo funciona el clima en tiempo real?',
                answer: 'La aplicación muestra datos meteorológicos actualizados para cada playa, incluyendo temperatura, condiciones del clima, humedad y velocidad del viento.',
                icon: Icons.wb_sunny_rounded,
                color: Colors.orange,
              ),
              _buildFAQItem(
                question: '¿Puedo usar la app sin crear cuenta?',
                answer: 'Sí, puedes explorar todas las playas, ver el mapa y consultar información sin registrarte. Sin embargo, para marcar favoritos y enviar reportes necesitas iniciar sesión.',
                icon: Icons.person_outline,
                color: Colors.purple,
              ),
              _buildFAQItem(
                question: '¿Mis datos están seguros?',
                answer: 'Sí, utilizamos Firebase Authentication para proteger tu cuenta y tus datos personales se almacenan de forma segura siguiendo las mejores prácticas de seguridad.',
                icon: Icons.security_rounded,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Características',
            icon: Icons.stars_rounded,
            children: [
              _buildFeatureItem(
                title: 'Explorar Playas',
                description: 'Descubre más de 150 playas de República Dominicana con descripciones detalladas, fotos y ubicación.',
                icon: Icons.beach_access_rounded,
                color: AppColors.secondary,
              ),
              _buildFeatureItem(
                title: 'Mapa Interactivo',
                description: 'Visualiza todas las playas en un mapa interactivo y encuentra las más cercanas a tu ubicación.',
                icon: Icons.map_rounded,
                color: Colors.blue,
              ),
              _buildFeatureItem(
                title: 'Reportes Comunitarios',
                description: 'Contribuye con la comunidad reportando las condiciones actuales de las playas que visitas.',
                icon: Icons.groups_rounded,
                color: Colors.green,
              ),
              _buildFeatureItem(
                title: 'Filtros Avanzados',
                description: 'Filtra playas por provincia, condición actual o búsqueda por nombre.',
                icon: Icons.filter_alt_rounded,
                color: Colors.purple,
              ),
              _buildFeatureItem(
                title: 'Información Climática',
                description: 'Consulta el clima actual y las condiciones meteorológicas antes de visitar una playa.',
                icon: Icons.cloud_outlined,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Soporte',
            icon: Icons.support_agent_rounded,
            children: [
              _buildContactItem(
                title: 'Centro de Ayuda',
                description: 'Visita nuestro centro de ayuda en línea',
                icon: Icons.help_center_rounded,
                onTap: () {
                  // Abrir URL del centro de ayuda
                },
              ),
              _buildContactItem(
                title: 'Reportar un Problema',
                description: 'Envíanos tus comentarios o reporta problemas',
                icon: Icons.bug_report_rounded,
                onTap: () {
                  // Abrir formulario de reporte
                },
              ),
              _buildContactItem(
                title: 'Sugerencias',
                description: 'Comparte tus ideas para mejorar la app',
                icon: Icons.lightbulb_outline_rounded,
                onTap: () {
                  // Abrir formulario de sugerencias
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTipsCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientTop.withOpacity(0.1),
            AppColors.gradientBottom.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.help_outline_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Necesitas Ayuda?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encuentra respuestas a tus preguntas o contáctanos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[600],
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                color: AppColors.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Consejos Útiles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTip('Revisa siempre el clima antes de visitar una playa'),
          _buildTip('Respeta las señalizaciones y banderas de advertencia'),
          _buildTip('Comparte tus reportes para ayudar a otros usuarios'),
          _buildTip('Mantén las playas limpias y cuida el medio ambiente'),
          _buildTip('Usa protector solar y mantente hidratado'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

