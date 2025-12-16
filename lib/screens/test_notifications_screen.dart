import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

/// Pantalla de prueba para notificaciones
/// ⚠️ SOLO PARA DESARROLLO - Eliminar en producción
class TestNotificationsScreen extends StatefulWidget {
  const TestNotificationsScreen({super.key});

  @override
  State<TestNotificationsScreen> createState() =>
      _TestNotificationsScreenState();
}

class _TestNotificationsScreenState extends State<TestNotificationsScreen> {
  final _notificationService = NotificationService();
  String? _fcmToken;
  bool _notificationsEnabled = false;
  String _lastTestResult = '';
  bool _isLoadingToken = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final token = _notificationService.fcmToken;
    final enabled = await _notificationService.areNotificationsEnabled();

    setState(() {
      _fcmToken = token;
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _getFCMTokenFast() async {
    setState(() {
      _isLoadingToken = true;
      _lastTestResult = 'Obteniendo token FCM rápidamente...';
    });

    try {
      final token = await _notificationService.getFCMTokenFast();
      setState(() {
        _fcmToken = token;
        _isLoadingToken = false;
        if (token != null) {
          _lastTestResult =
              '✅ Token FCM obtenido exitosamente!\n\nToken: $token\n\nCopia este token para usarlo en Firebase Console.';
        } else {
          _lastTestResult =
              '❌ No se pudo obtener el token FCM.\n\nVerifica que:\n- Los permisos de notificación estén concedidos\n- El token APNS esté disponible (iOS)\n- La app esté correctamente configurada';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingToken = false;
        _lastTestResult = '❌ Error: $e';
      });
    }
  }

  Future<void> _prepareBackgroundTest() async {
    setState(() {
      _lastTestResult = 'Preparando prueba de notificaciones en background...';
    });

    try {
      final result = await _notificationService.prepareBackgroundTest();
      final instructions = result['instructions'] as String;
      final token = result['token'] as String?;
      final ready = result['ready'] as bool;

      setState(() {
        _fcmToken = token;
        _lastTestResult = ready
            ? '✅ Listo para probar notificaciones en background!\n\n$instructions\n\n📱 Token FCM: $token'
            : '⚠️ No está listo para probar.\n\n$instructions';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Error: $e';
      });
    }
  }

  Future<void> _getDebugInfo() async {
    setState(() {
      _lastTestResult = 'Obteniendo información de debug...';
    });

    try {
      final info = await _notificationService.getNotificationDebugInfo();
      setState(() {
        _fcmToken = info['fcmToken'] as String?;
        _lastTestResult =
            '✅ Información de debug obtenida:\n\n'
            'Plataforma: ${info['platform']}\n'
            'Inicializado: ${info['initialized']}\n'
            'Notificaciones habilitadas: ${info['notificationsEnabled']}\n'
            'Token FCM: ${info['fcmToken'] ?? 'No disponible'}\n'
            'Token APNS: ${info['apnsToken'] ?? 'No disponible'}';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Error: $e';
      });
    }
  }

  Future<void> _testLocalNotification() async {
    setState(() => _lastTestResult = 'Enviando notificación local...');

    await _notificationService.sendLocalNotification(
      title: '🏖️ Prueba de Notificación',
      body: 'Si ves esto, las notificaciones locales funcionan correctamente',
      payload: 'test',
    );

    setState(() => _lastTestResult = '✅ Notificación local enviada');
  }

  Future<void> _testBeachConditionChange() async {
    setState(() => _lastTestResult = 'Simulando cambio de condición...');

    try {
      // Obtener primera playa de Firestore
      final beachesSnapshot = await FirebaseFirestore.instance
          .collection('beaches')
          .limit(1)
          .get();

      if (beachesSnapshot.docs.isEmpty) {
        setState(() => _lastTestResult = '❌ No hay playas en la base de datos');
        return;
      }

      final beachDoc = beachesSnapshot.docs.first;
      final beachData = beachDoc.data();
      final currentCondition = beachData['condition'] ?? 'Desconocido';

      // Cambiar a una condición diferente
      String newCondition;
      switch (currentCondition) {
        case 'Excelente':
          newCondition = 'Bueno';
          break;
        case 'Bueno':
          newCondition = 'Moderado';
          break;
        case 'Moderado':
          newCondition = 'Excelente';
          break;
        default:
          newCondition = 'Excelente';
      }

      await beachDoc.reference.update({'condition': newCondition});

      setState(() {
        _lastTestResult =
            '✅ Condición cambiada de $currentCondition a $newCondition\n'
            'Playa: ${beachData['name']}\n'
            'Cloud Function debería enviar notificaciones a usuarios con esta playa en favoritos';
      });
    } catch (e) {
      setState(() => _lastTestResult = '❌ Error: $e');
    }
  }

  Future<void> _testWeatherNotification() async {
    await _notificationService.notifyWeatherChange(
      beachName: 'Playa Rincón',
      condition: 'Soleado y cálido',
    );

    setState(() => _lastTestResult = '✅ Notificación de clima enviada');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Prueba de Notificaciones'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado actual
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Estado Actual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      'Usuario autenticado',
                      authProvider.isAuthenticated,
                    ),
                    _buildStatusRow(
                      'Notificaciones habilitadas',
                      _notificationsEnabled,
                    ),
                    _buildStatusRow('FCM Token disponible', _fcmToken != null),
                    if (_fcmToken != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'FCM Token:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _fcmToken!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pruebas
            const Text(
              '🧪 Pruebas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildTestButton(
              icon: Icons.notifications,
              title: 'Notificación Local',
              description: 'Prueba las notificaciones locales',
              onPressed: _testLocalNotification,
            ),

            _buildTestButton(
              icon: Icons.beach_access,
              title: 'Cambio de Condición',
              description: 'Simula cambio en una playa (activa Cloud Function)',
              onPressed: _testBeachConditionChange,
            ),

            _buildTestButton(
              icon: Icons.wb_sunny,
              title: 'Notificación de Clima',
              description: 'Prueba notificación de cambio climático',
              onPressed: _testWeatherNotification,
            ),

            _buildTestButton(
              icon: Icons.flash_on,
              title: 'Obtener Token FCM Rápido',
              description: 'Obtiene el token FCM de forma rápida (útil en iOS)',
              onPressed: _isLoadingToken ? null : _getFCMTokenFast,
            ),

            _buildTestButton(
              icon: Icons.notifications_active,
              title: 'Probar Background/Killed',
              description:
                  'Prepara prueba de notificaciones con app en background o cerrada',
              onPressed: _prepareBackgroundTest,
            ),

            _buildTestButton(
              icon: Icons.bug_report,
              title: 'Info de Debug',
              description: 'Muestra información detallada para debugging',
              onPressed: _getDebugInfo,
            ),

            _buildTestButton(
              icon: Icons.refresh,
              title: 'Recargar Estado',
              description: 'Actualiza el estado de las notificaciones',
              onPressed: _loadNotificationStatus,
            ),

            const SizedBox(height: 16),

            // Resultado de última prueba
            if (_lastTestResult.isNotEmpty) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Resultado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_lastTestResult),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Instrucciones
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Instrucciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Asegúrate de estar autenticado\n'
                      '2. Verifica que las notificaciones estén habilitadas\n'
                      '3. Prueba primero la notificación local\n'
                      '4. Para probar Cloud Functions, agrega una playa a favoritos\n'
                      '5. Luego usa "Cambio de Condición"\n'
                      '6. Deberías recibir una notificación push',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Advertencia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ Esta pantalla es solo para desarrollo. '
                      'Elimínala antes de lanzar a producción.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_isLoadingToken &&
                              title == 'Obtener Token FCM Rápido')
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!isDisabled) const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
