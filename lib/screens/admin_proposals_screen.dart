import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/beach.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class AdminProposalsScreen extends StatelessWidget {
  const AdminProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propuestas de Playas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<BeachProposal>>(
        stream: FirebaseService.getPendingBeachProposals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar propuestas: ${snapshot.error}'),
            );
          }

          final proposals = snapshot.data ?? [];

          if (proposals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 80, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin propuestas pendientes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todas las propuestas han sido revisadas',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildHeader(proposals.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: proposals.length,
                  itemBuilder: (context, index) =>
                      _ProposalCard(proposal: proposals[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.primary.withOpacity(0.08),
      child: Text(
        '$count propuesta${count != 1 ? 's' : ''} pendiente${count != 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ProposalCard extends StatefulWidget {
  const _ProposalCard({required this.proposal});
  final BeachProposal proposal;

  @override
  State<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<_ProposalCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.proposal;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre y fecha
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_location_alt,
                      color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.beachName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.province}${p.municipality != null ? ' · ${p.municipality}' : ''}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (p.description != null && p.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                p.description!,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ],

            if (p.latitude != null && p.longitude != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'GPS: ${p.latitude!.toStringAsFixed(4)}, ${p.longitude!.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  p.userName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(p.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            if (p.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${p.imageUrls.length} foto${p.imageUrls.length != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Botones de acción
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reject(context),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approve(context),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Aprobar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    final confirm = await _showConfirm(
      context,
      title: 'Aprobar playa',
      message:
          '¿Confirmas agregar "${widget.proposal.beachName}" al mapa de la app?',
      confirmLabel: 'Aprobar',
      confirmColor: Colors.green,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    final beachId =
        await FirebaseService.approveBeachProposal(widget.proposal);
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(beachId != null
            ? '✅ "${widget.proposal.beachName}" agregada a la app'
            : '❌ Error al aprobar la propuesta'),
        backgroundColor: beachId != null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final confirm = await _showConfirm(
      context,
      title: 'Rechazar propuesta',
      message: '¿Confirmas rechazar "${widget.proposal.beachName}"?',
      confirmLabel: 'Rechazar',
      confirmColor: Colors.red,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    final ok =
        await FirebaseService.rejectBeachProposal(widget.proposal.id);
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Propuesta rechazada'
            : '❌ Error al rechazar la propuesta'),
        backgroundColor: ok ? Colors.orange : Colors.red,
      ),
    );
  }

  Future<bool> _showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmLabel,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
