import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/host_listing_controller.dart';

class HostListingEditorScreen extends ConsumerStatefulWidget {
  const HostListingEditorScreen({super.key});

  @override
  ConsumerState<HostListingEditorScreen> createState() =>
      _HostListingEditorScreenState();
}

class _HostListingEditorScreenState
    extends ConsumerState<HostListingEditorScreen> {
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _priceController = TextEditingController(text: '90');
  final _guestsController = TextEditingController(text: '2');
  final _bedroomsController = TextEditingController(text: '1');
  final List<String> _amenities = <String>['Wifi', 'Air Conditioning'];
  final List<String> _imageUrls = <String>[];

  bool _syncedFromState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hostListingControllerProvider.notifier).loadDraft();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _priceController.dispose();
    _guestsController.dispose();
    _bedroomsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final controller = ref.read(hostListingControllerProvider.notifier);
    final uploadedUrl = await controller.uploadPhoto(image.path);
    if (!mounted) {
      return;
    }

    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image upload failed.')));
      return;
    }

    setState(() => _imageUrls.add(uploadedUrl));
  }

  Future<void> _saveDraft() async {
    try {
      await ref
          .read(hostListingControllerProvider.notifier)
          .saveDraft(
            title: _titleController.text.trim(),
            city: _cityController.text.trim(),
            district: _districtController.text.trim(),
            pricePerNightUsd: int.tryParse(_priceController.text.trim()) ?? 0,
            guests: int.tryParse(_guestsController.text.trim()) ?? 1,
            bedrooms: int.tryParse(_bedroomsController.text.trim()) ?? 1,
            amenities: List<String>.from(_amenities),
            imageUrls: List<String>.from(_imageUrls),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Draft saved.')));
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _publishDraft() async {
    try {
      await _saveDraft();
      await ref.read(hostListingControllerProvider.notifier).publishDraft();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing published successfully.')),
      );
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostListingControllerProvider);
    final draft = state.valueOrNull;

    if (draft != null && !_syncedFromState) {
      _syncedFromState = true;
      _titleController.text = draft.title;
      _cityController.text = draft.city;
      _districtController.text = draft.district;
      _priceController.text = '${draft.pricePerNightUsd}';
      _guestsController.text = '${draft.guests}';
      _bedroomsController.text = '${draft.bedrooms}';
      _amenities
        ..clear()
        ..addAll(draft.amenities);
      _imageUrls
        ..clear()
        ..addAll(draft.imageUrls);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Listing Editor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Listing title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _districtController,
            decoration: const InputDecoration(labelText: 'District'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (USD/night)',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _guestsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Guests'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _bedroomsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bedrooms'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities
                .map(
                  (item) => Chip(
                    label: Text(item),
                    onDeleted: () => setState(() => _amenities.remove(item)),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _amenities.add('Amenity ${_amenities.length + 1}');
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add amenity'),
          ),
          const SizedBox(height: 8),
          Text('Media Upload', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _imageUrls
                .map(
                  (url) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 110,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              setState(() => _imageUrls.remove(url)),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickAndUploadImage,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload photo from gallery'),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: state.isLoading ? null : _saveDraft,
            child: const Text('Save draft'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonal(
            onPressed: state.isLoading ? null : _publishDraft,
            child: const Text('Publish listing'),
          ),
          if (draft?.published == true) ...[
            const SizedBox(height: 10),
            const Text(
              'Status: Published',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
