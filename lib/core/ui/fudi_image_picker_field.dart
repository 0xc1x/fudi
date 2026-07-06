import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'fudi_colors.dart';
import 'fudi_theme.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiImagePickerField extends StatefulWidget {
  const FudiImagePickerField({
    this.existingImageUrl,
    this.height = 180,
    this.placeholderTitle = 'Subir foto del producto',
    this.placeholderSubtitle = 'Opcional, pero ayuda a vender más',
    required this.onChanged,
    super.key,
  });

  final String? existingImageUrl;
  final double height;
  final String placeholderTitle;
  final String placeholderSubtitle;
  final void Function(XFile? file, String? existingUrl) onChanged;

  @override
  State<FudiImagePickerField> createState() => _FudiImagePickerFieldState();
}

class _FudiImagePickerFieldState extends State<FudiImagePickerField> {
  XFile? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _existingImageUrl = widget.existingImageUrl;
  }

  void setImageFile(XFile? file) {
    setState(() => _imageFile = file);
  }

  bool get _hasNewImage => _imageFile != null;
  bool get _hasExistingImage =>
      _existingImageUrl != null && _existingImageUrl!.isNotEmpty;
  bool get _showImage => _hasNewImage || _hasExistingImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Imagen del producto', style: FudiTypography.h4),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Cámara',
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _SourceOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Galería',
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() => _imageFile = image);
        widget.onChanged(_imageFile, _existingImageUrl);
      }
    }
  }

  void _removeImage() {
    if (mounted) {
      setState(() {
        _imageFile = null;
        _existingImageUrl = null;
      });
      widget.onChanged(_imageFile, _existingImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();

    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeExt?.cardBg ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(FudiRadius.xl),
              border: Border.all(color: FudiColors.borderSolid),
            ),
            child: _showImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(FudiRadius.xl),
                    child: _hasNewImage
                        ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                        : Image.network(
                            _existingImageUrl!,
                            fit: BoxFit.cover,
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: FudiColors.mutedForeground,
                      ),
                      const SizedBox(height: FudiSpacing.sm),
                      Text(
                        widget.placeholderTitle,
                        style: FudiTypography.labelSmall,
                      ),
                      Text(
                        widget.placeholderSubtitle,
                        style: FudiTypography.bodySmall,
                      ),
                    ],
                  ),
          ),
        ),
        if (_showImage)
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _ImageActionButton(
                  icon: Icons.edit_rounded,
                  onTap: _pickImage,
                ),
                const SizedBox(width: 8),
                _ImageActionButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: _removeImage,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: FudiColors.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ImageActionButton extends StatelessWidget {
  const _ImageActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: FudiColors.foreground.withValues(alpha: 0.54),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: FudiColors.background),
      ),
    );
  }
}