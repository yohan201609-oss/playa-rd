import 'package:flutter/material.dart';
import '../utils/migration_utils.dart';

/// Widget para ejecutar la migración de imágenes desde la app
/// 
/// Uso: Puedes añadirlo a un panel de administrador o a las configuraciones de desarrollador
class MigrationDialog extends StatefulWidget {
  const MigrationDialog({super.key});

  @override
  State<MigrationDialog> createState() => _MigrationDialogState();
}

class _MigrationDialogState extends State<MigrationDialog> {
  bool _isRunning = false;
  String _status = '';
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Migración de Imágenes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta herramienta migra todas las fotos de Google Places a Firebase Storage para:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✓ Evitar que las imágenes salgan rotas'),
                  Text('✓ Reducir costos de Google Maps'),
                  Text('✓ Mejorar rendimiento de la app'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isRunning) ...[
              const Text(
                '⚠️ Migrando... Este proceso puede tomar varios minutos',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                style: const TextStyle(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ] else
              const Text(
                '⚠️ Esta acción es irreversible. Asegúrate de tener una copia de seguridad.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isRunning ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isRunning ? null : _runMigration,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Iniciar Migración'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _runMigration() async {
    setState(() {
      _isRunning = true;
      _status = 'Iniciando migración...';
      _progress = 0.0;
    });

    try {
      // Ejecutar la migración con callbacks de progreso
      await MigrationUtils.runMigration();

      if (mounted) {
        setState(() {
          _status = '✅ Migración completada exitosamente';
          _progress = 1.0;
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Migración completada. Las imágenes ya no saldrán rotas.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Cerrar el diálogo después de 2 segundos
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = '❌ Error: $e';
          _isRunning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

/// Widget para botón que abre el diálogo de migración
class MigrationButton extends StatelessWidget {
  final bool hidden;

  const MigrationButton({
    super.key,
    this.hidden = true,
  });

  @override
  Widget build(BuildContext context) {
    if (hidden) return const SizedBox.shrink();

    return FloatingActionButton(
      backgroundColor: Colors.red,
      tooltip: 'Migrar imágenes a Firebase',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const MigrationDialog(),
        );
      },
      child: const Icon(Icons.cloud_upload),
    );
  }
}
