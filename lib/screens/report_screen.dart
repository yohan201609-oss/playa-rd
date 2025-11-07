import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/beach_provider.dart';
import '../providers/auth_provider.dart';
import '../models/beach.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Beach? _selectedBeach;
  String _selectedCondition = BeachConditions.excellent;
  final TextEditingController _commentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (!authProvider.isAuthenticated) {
      return _buildLoginRequired(l10n);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 24),
            _buildBeachSelector(l10n),
            const SizedBox(height: 24),
            _buildConditionSelector(l10n),
            const SizedBox(height: 24),
            _buildCommentField(l10n),
            const SizedBox(height: 24),
            _buildImagePicker(l10n),
            const SizedBox(height: 32),
            _buildSubmitButton(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.profileLoginPrompt,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileLoginDescription,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navegar a pantalla de login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
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

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportHelpCommunity,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.reportHelpDescription,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildBeachSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportWhichBeach,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Consumer<BeachProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<Beach>(
                isExpanded: true,
                value: _selectedBeach,
                hint: Text(l10n.reportSelectBeach),
                underline: const SizedBox.shrink(),
                items: provider.beaches.map((beach) {
                  return DropdownMenuItem<Beach>(
                    value: beach,
                    child: Text(beach.name),
                  );
                }).toList(),
                onChanged: (beach) {
                  setState(() {
                    _selectedBeach = beach;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConditionSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportHowConditions,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildConditionChip(
              condition: BeachConditions.excellent,
              icon: Icons.check_circle,
            ),
            _buildConditionChip(
              condition: BeachConditions.good,
              icon: Icons.thumb_up,
            ),
            _buildConditionChip(
              condition: BeachConditions.moderate,
              icon: Icons.warning,
            ),
            _buildConditionChip(
              condition: BeachConditions.danger,
              icon: Icons.dangerous,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionChip({
    required String condition,
    required IconData icon,
  }) {
    final isSelected = _selectedCondition == condition;
    final color = BeachConditions.getColor(condition);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCondition = condition;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              condition,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportCommentOptional,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: l10n.reportDescriptionHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportAddPhotos,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return _buildAddPhotoButton();
                }
                return _buildImageThumbnail(index);
              },
            ),
          )
        else
          _buildAddPhotoButton(),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              'Agregar foto',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(_selectedImages[index].path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting || _selectedBeach == null
            ? null
            : () => _submitReport(authProvider, l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.reportSubmit,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _submitReport(AuthProvider authProvider, AppLocalizations l10n) async {
    if (_selectedBeach == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Por ahora, las URLs de imÃ¡genes serÃ¡n placeholders
      // En producciÃ³n, subirÃ­as las imÃ¡genes a Firebase Storage
      final List<String> imageUrls = _selectedImages
          .map((img) => 'https://placeholder.com/image.jpg')
          .toList();

      final report = BeachReport(
        id: const Uuid().v4(),
        beachId: _selectedBeach!.id,
        userId: authProvider.user!.uid,
        userName: authProvider.user!.displayName ?? 'Usuario',
        condition: _selectedCondition,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        imageUrls: imageUrls,
        timestamp: DateTime.now(),
        helpfulCount: 0,
      );

      final reportId = await FirebaseService.createReport(report);

      if (reportId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reportSuccess),
              backgroundColor: Colors.green,
            ),
          );

          // Limpiar formulario
          setState(() {
            _selectedBeach = null;
            _selectedCondition = BeachConditions.excellent;
            _commentController.clear();
            _selectedImages.clear();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reportError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error submitting report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reportError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
