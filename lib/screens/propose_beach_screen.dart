import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../l10n/app_localizations.dart';
import '../models/beach.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class ProposeBeachForm extends StatefulWidget {
  const ProposeBeachForm({super.key});

  @override
  State<ProposeBeachForm> createState() => _ProposeBeachFormState();
}

class _ProposeBeachFormState extends State<ProposeBeachForm> {
  final _nameController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  String? _selectedProvince;
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _municipalityController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(l10n),
          const SizedBox(height: 24),
          _buildNameField(l10n),
          const SizedBox(height: 20),
          _buildProvinceSelector(l10n),
          const SizedBox(height: 20),
          _buildMunicipalityField(l10n),
          const SizedBox(height: 20),
          _buildDescriptionField(l10n),
          const SizedBox(height: 20),
          _buildLocationSection(l10n),
          const SizedBox(height: 20),
          _buildImagePicker(l10n),
          const SizedBox(height: 32),
          _buildSubmitButton(l10n),
          const SizedBox(height: 16),
          _buildPendingNote(l10n),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposeHelpCommunity,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.proposeHelpDescription,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposeBeachName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.proposeBeachNameHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            prefixIcon: const Icon(Icons.beach_access),
          ),
        ),
      ],
    );
  }

  Widget _buildProvinceSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposeProvince,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedProvince,
            hint: Text(l10n.proposeSelectProvince),
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.arrow_drop_down),
            items: DominicanProvinces.provinces.map((province) {
              return DropdownMenuItem<String>(
                value: province,
                child: Text(province),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMunicipalityField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposeMunicipality,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _municipalityController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.proposeMunicipalityHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            prefixIcon: const Icon(Icons.location_city),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposeDescription,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 800,
          decoration: InputDecoration(
            hintText: l10n.proposeDescriptionHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposeLocation,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  hintText: l10n.proposeLatHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _lonController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  hintText: l10n.proposeLonHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposeAddPhotos,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return _buildAddPhotoButton(l10n);
                }
                return _buildImageThumbnail(index);
              },
            ),
          )
        else
          _buildAddPhotoButton(l10n),
      ],
    );
  }

  Widget _buildAddPhotoButton(AppLocalizations l10n) {
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
              l10n.reportAddPhotos,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
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

  Widget _buildSubmitButton(AppLocalizations l10n) {
    final authProvider = context.read<AuthProvider>();
    final canSubmit = !_isSubmitting &&
        _nameController.text.trim().isNotEmpty &&
        _selectedProvince != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submit(authProvider, l10n) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
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
                l10n.proposeSubmit,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildPendingNote(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700], size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.proposePendingBadge,
              style: TextStyle(color: Colors.amber[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reportAddPhotos),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(l10n.reportTakePhoto),
              onTap: () => Navigator.of(dialogContext).pop(ImageSource.camera),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(l10n.reportSelectFromGallery),
              onTap: () => Navigator.of(dialogContext).pop(ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (source == null || !mounted) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null && mounted) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorPhotoLibrary),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submit(AuthProvider authProvider, AppLocalizations l10n) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.proposeNameRequired), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.proposeProvinceRequired), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      double? lat;
      double? lon;
      if (_latController.text.isNotEmpty) {
        lat = double.tryParse(_latController.text.trim());
      }
      if (_lonController.text.isNotEmpty) {
        lon = double.tryParse(_lonController.text.trim());
      }

      // Subir las fotos a Firebase Storage (beach_proposals/{userId}/...)
      final List<String> imageUrls = _selectedImages.isEmpty
          ? const []
          : await FirebaseService.uploadImages(
              images: _selectedImages.map((img) => File(img.path)).toList(),
              folder: 'beach_proposals',
              userId: authProvider.user!.uid,
            );

      final proposal = BeachProposal(
        id: const Uuid().v4(),
        beachName: name,
        province: _selectedProvince!,
        municipality: _municipalityController.text.trim().isEmpty
            ? null
            : _municipalityController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        latitude: lat,
        longitude: lon,
        imageUrls: imageUrls,
        userId: authProvider.user!.uid,
        userName: authProvider.user!.displayName ?? 'Usuario',
        timestamp: DateTime.now(),
      );

      final id = await FirebaseService.createBeachProposal(proposal);

      if (!mounted) return;

      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proposeSuccess), backgroundColor: Colors.green),
        );
        setState(() {
          _nameController.clear();
          _municipalityController.clear();
          _descriptionController.clear();
          _latController.clear();
          _lonController.clear();
          _selectedProvince = null;
          _selectedImages.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proposeError), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proposeError), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
