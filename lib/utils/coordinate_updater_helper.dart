import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/beach_provider.dart';
import '../services/google_geocoding_service.dart';
import '../models/beach.dart';

/// Utilidad para actualizar coordenadas de playas y mostrar progreso
class CoordinateUpdaterHelper {
  /// Mostrar diálogo de actualización de coordenadas
  static Future<void> showUpdateCoordinatesDialog(BuildContext context) async {
    final beachProvider = Provider.of<BeachProvider>(context, listen: false);
    
    // Verificar si la API key está configurada y es válida
    print('🔍 Verificando API Key...');
    final apiKey = GoogleGeocodingService.apiKey;
    
    if (apiKey == null || apiKey.isEmpty) {
      _showErrorDialog(
        context,
        'API Key no encontrada',
        'No se encontró la API Key de Google Maps en el archivo .env.\n\n'
        'Por favor, agrega:\n'
        'GOOGLE_MAPS_API_KEY=tu_api_key\n\n'
        'O:\n'
        'MAPS_API_KEY=tu_api_key',
      );
      return;
    }
    
    // Verificar que no sea un placeholder
    if (apiKey.contains('tu_api_key') || apiKey.contains('placeholder') || apiKey == 'tu_api_key_aqui') {
      _showErrorDialog(
        context,
        'API Key no configurada',
        'La API Key en el archivo .env es un placeholder.\n\n'
        'Por favor, reemplaza "tu_api_key_aqui" con tu API Key real de Google Maps.\n\n'
        'Obtén tu API Key en:\n'
        'https://console.cloud.google.com/',
      );
      return;
    }
    
    // Verificar que la API key sea válida haciendo una llamada a Google
    final apiKeyValid = await GoogleGeocodingService.verifyApiKey();
    if (!apiKeyValid) {
      _showErrorDialog(
        context,
        'API Key inválida',
        'La API Key de Google Maps no es válida o no tiene los permisos necesarios.\n\n'
        'Verifica que:\n'
        '1. La API Key sea correcta\n'
        '2. Las APIs estén habilitadas en Google Cloud Console:\n'
        '   - Geocoding API\n'
        '   - Places API (opcional)\n'
        '3. No haya restricciones que bloqueen las solicitudes\n\n'
        'Revisa la consola para más detalles.',
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Coordenadas'),
        content: const Text(
          '¿Deseas actualizar las coordenadas de todas las playas usando Google Geocoding API?'
          '\n\nEsto puede tomar varios minutos y utilizará créditos de la API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar diálogo de progreso
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UpdateProgressDialog(
        beachProvider: beachProvider,
      ),
    );
  }

  /// Actualizar coordenadas de una playa específica
  static Future<bool> updateSingleBeachCoordinates(
    BuildContext context,
    Beach beach,
  ) async {
    final beachProvider = Provider.of<BeachProvider>(context, listen: false);
    
    // Verificar API key
    final apiKeyValid = await GoogleGeocodingService.verifyApiKey();
    if (!apiKeyValid) {
      _showErrorDialog(
        context,
        'API Key no configurada',
        'Por favor, configura tu API Key de Google Maps en el archivo .env',
      );
      return false;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await beachProvider.updateBeachCoordinates(beach);
      Navigator.pop(context); // Cerrar diálogo de carga

      if (success) {
        _showSuccessDialog(
          context,
          'Coordenadas actualizadas',
          'Las coordenadas de ${beach.name} han sido actualizadas exitosamente.',
        );
        return true;
      } else {
        _showErrorDialog(
          context,
          'Error',
          'No se pudieron actualizar las coordenadas de ${beach.name}.',
        );
        return false;
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo de carga
      _showErrorDialog(
        context,
        'Error',
        'Error al actualizar coordenadas: $e',
      );
      return false;
    }
  }

  static void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Buscar e importar playas desde Google Places API
  static Future<void> showImportBeachesDialog(BuildContext context) async {
    final beachProvider = Provider.of<BeachProvider>(context, listen: false);
    
    // Verificar API key
    final apiKey = GoogleGeocodingService.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      _showErrorDialog(
        context,
        'API Key no encontrada',
        'No se encontró la API Key de Google Maps en el archivo .env.',
      );
      return;
    }
    
    if (apiKey.contains('tu_api_key') || apiKey == 'tu_api_key_aqui') {
      _showErrorDialog(
        context,
        'API Key no configurada',
        'Por favor, configura tu API Key de Google Maps en el archivo .env.',
      );
      return;
    }
    
    // Verificar que la API key sea válida
    final apiKeyValid = await GoogleGeocodingService.verifyApiKey();
    if (!apiKeyValid) {
      _showErrorDialog(
        context,
        'API Key inválida',
        'La API Key de Google Maps no es válida o no tiene los permisos necesarios.\n\n'
        'Verifica que las APIs estén habilitadas en Google Cloud Console.',
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Playas desde Google'),
        content: const Text(
          '¿Deseas buscar e importar playas desde Google Places API?\n\n'
          'Esto buscará playas en República Dominicana y las agregará a tu base de datos.\n\n'
          '⚠️ Esto puede tomar varios minutos y utilizará créditos de la API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar diálogo de progreso
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImportBeachesProgressDialog(
        beachProvider: beachProvider,
      ),
    );
  }

  /// Actualizar fotos de todas las playas desde Google Places API
  static Future<void> showUpdatePhotosDialog(BuildContext context) async {
    final beachProvider = Provider.of<BeachProvider>(context, listen: false);
    
    // Verificar API key
    final apiKey = GoogleGeocodingService.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      _showErrorDialog(
        context,
        'API Key no encontrada',
        'No se encontró la API Key de Google Maps en el archivo .env.',
      );
      return;
    }
    
    if (apiKey.contains('tu_api_key') || apiKey == 'tu_api_key_aqui') {
      _showErrorDialog(
        context,
        'API Key no configurada',
        'Por favor, configura tu API Key de Google Maps en el archivo .env.',
      );
      return;
    }
    
    // Verificar que la API key sea válida
    final apiKeyValid = await GoogleGeocodingService.verifyApiKey();
    if (!apiKeyValid) {
      _showErrorDialog(
        context,
        'API Key inválida',
        'La API Key de Google Maps no es válida o no tiene los permisos necesarios.\n\n'
        'Verifica que las APIs estén habilitadas en Google Cloud Console.',
      );
      return;
    }

    // Mostrar diálogo de opciones
    final option = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Fotos'),
        content: const Text(
          '¿Qué playas deseas actualizar?\n\n'
          '• Solo playas sin fotos: Más rápido, solo actualiza playas que no tienen fotos.\n'
          '• Todas las playas: Actualiza todas las playas, incluyendo las que ya tienen fotos.\n\n'
          '⚠️ Esto puede tomar varios minutos y utilizará créditos de la API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'missing'),
            child: const Text('Solo sin fotos'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'all'),
            child: const Text('Todas'),
          ),
        ],
      ),
    );

    if (option == null) return;

    final onlyMissing = option == 'missing';

    // Mostrar diálogo de progreso
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UpdatePhotosProgressDialog(
        beachProvider: beachProvider,
        onlyMissingPhotos: onlyMissing,
      ),
    );
  }
}

/// Diálogo de progreso para actualizar fotos de playas
class _UpdatePhotosProgressDialog extends StatefulWidget {
  final BeachProvider beachProvider;
  final bool onlyMissingPhotos;

  const _UpdatePhotosProgressDialog({
    required this.beachProvider,
    required this.onlyMissingPhotos,
  });

  @override
  State<_UpdatePhotosProgressDialog> createState() => _UpdatePhotosProgressDialogState();
}

class _UpdatePhotosProgressDialogState extends State<_UpdatePhotosProgressDialog> {
  int _current = 0;
  int _total = 0;
  String _currentBeach = '';
  bool _completed = false;
  int _updated = 0;
  int _skipped = 0;
  int _failed = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startUpdate();
  }

  Future<void> _startUpdate() async {
    final result = await widget.beachProvider.updateAllBeachesPhotos(
      onlyMissingPhotos: widget.onlyMissingPhotos,
      onProgress: (current, total, name) {
        setState(() {
          _current = current;
          _total = total;
          _currentBeach = name;
        });
      },
    );

    setState(() {
      _completed = true;
      if (result['success']) {
        _updated = result['updated'] ?? 0;
        _skipped = result['skipped'] ?? 0;
        _failed = result['failed'] ?? 0;
      } else {
        _error = result['error'] ?? 'Error desconocido';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizando Fotos'),
      content: SizedBox(
        width: double.maxFinite,
        child: _completed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null) ...[
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                  ] else ...[
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    const Text('Actualización completada'),
                    const SizedBox(height: 8),
                    Text('✅ Actualizadas: $_updated'),
                    Text('⏭️ Omitidas: $_skipped'),
                    if (_failed > 0) Text('❌ Fallidas: $_failed'),
                  ],
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Obteniendo fotos...'),
                  if (_currentBeach.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Procesando: $_currentBeach'),
                  ],
                  const SizedBox(height: 8),
                  Text('$_current / $_total'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _total > 0 ? _current / _total : 0,
                  ),
                ],
              ),
      ),
      actions: [
        if (_completed)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
      ],
    );
  }
}

/// Diálogo de progreso para importar playas desde Google Places
class _ImportBeachesProgressDialog extends StatefulWidget {
  final BeachProvider beachProvider;

  const _ImportBeachesProgressDialog({
    required this.beachProvider,
  });

  @override
  State<_ImportBeachesProgressDialog> createState() => _ImportBeachesProgressDialogState();
}

class _ImportBeachesProgressDialogState extends State<_ImportBeachesProgressDialog> {
  int _current = 0;
  int _total = 0;
  String _currentBeach = '';
  bool _completed = false;
  int _imported = 0;
  int _updated = 0;
  int _skipped = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  Future<void> _startImport() async {
    final result = await widget.beachProvider.searchAndImportBeachesFromGoogle(
      maxResults: 100, // Buscar hasta 100 playas
      onProgress: (current, total, name) {
        setState(() {
          _current = current;
          _total = total;
          _currentBeach = name;
        });
      },
    );

    setState(() {
      _completed = true;
      if (result['success']) {
        _imported = result['imported'] ?? 0;
        _updated = result['updated'] ?? 0;
        _skipped = result['skipped'] ?? 0;
      } else {
        _error = result['error'] ?? 'Error desconocido';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importando Playas'),
      content: SizedBox(
        width: double.maxFinite,
        child: _completed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null) ...[
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                  ] else ...[
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    const Text('Importación completada'),
                    const SizedBox(height: 8),
                    Text('✅ Importadas: $_imported'),
                    Text('🔄 Actualizadas: $_updated'),
                    Text('⏭️ Omitidas: $_skipped'),
                    Text('📊 Total: ${widget.beachProvider.allBeaches.length}'),
                  ],
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Buscando playas...'),
                  if (_currentBeach.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Procesando: $_currentBeach'),
                  ],
                  const SizedBox(height: 8),
                  Text('$_current / $_total'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _total > 0 ? _current / _total : 0,
                  ),
                ],
              ),
      ),
      actions: [
        if (_completed)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
      ],
    );
  }
}

/// Diálogo de progreso para actualización de coordenadas
class _UpdateProgressDialog extends StatefulWidget {
  final BeachProvider beachProvider;

  const _UpdateProgressDialog({
    required this.beachProvider,
  });

  @override
  State<_UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<_UpdateProgressDialog> {
  int _current = 0;
  int _total = 0;
  String _currentBeach = '';
  bool _completed = false;
  int _updated = 0;
  int _failed = 0;

  @override
  void initState() {
    super.initState();
    _startUpdate();
  }

  Future<void> _startUpdate() async {
    // Obtener todas las playas (sin filtros)
    final allBeaches = widget.beachProvider.beaches;
    _total = allBeaches.length;

    final result = await widget.beachProvider.updateAllBeachesCoordinates(
      onProgress: (current, total, beach) {
        setState(() {
          _current = current;
          _total = total;
          _currentBeach = beach.name;
        });
      },
    );

    setState(() {
      _completed = true;
      if (result['success']) {
        _updated = result['updated'] ?? 0;
        _failed = result['failed'] ?? 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizando Coordenadas'),
      content: SizedBox(
        width: double.maxFinite,
        child: _completed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  Text('Actualización completada'),
                  const SizedBox(height: 8),
                  Text('Actualizadas: $_updated'),
                  Text('Sin cambios: $_failed'),
                  Text('Total: $_total'),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Procesando: $_currentBeach'),
                  const SizedBox(height: 8),
                  Text('$_current / $_total'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _total > 0 ? _current / _total : 0,
                  ),
                ],
              ),
      ),
      actions: [
        if (_completed)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
      ],
    );
  }
}

