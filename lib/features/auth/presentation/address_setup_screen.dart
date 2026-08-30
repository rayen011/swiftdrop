import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/address.dart';
import '../../../core/theme/app_palette.dart';
import '../cubit/auth_cubit.dart';

/// First-login setup: capture name + default delivery address.
/// Map picker is stubbed (defaults to Tunis center) until google_maps is wired.
class AddressSetupScreen extends StatefulWidget {
  const AddressSetupScreen({super.key});

  @override
  State<AddressSetupScreen> createState() => _AddressSetupScreenState();
}

class _AddressSetupScreenState extends State<AddressSetupScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _label = 'Home';

  static const _labels = ['Home', 'Work', 'Other'];
  // Tunis center — replaced by a real map pin in a later pass.
  static const _defaultLat = 36.8065;
  static const _defaultLng = 10.1815;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;

  void _confirm() {
    if (!_valid) return;
    final address = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _label,
      lat: _defaultLat,
      lng: _defaultLng,
      fullAddress: _addressController.text.trim(),
    );
    context.read<AuthCubit>().completeOnboarding(
          name: _nameController.text.trim(),
          address: address,
        );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to SwiftDrop')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Let’s set you up', style: text.headlineMedium),
              const SizedBox(height: 8),
              Text('Tell us your name and where to deliver.',
                  style: text.bodyMedium),
              const SizedBox(height: 28),
              Text('Name', style: text.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Your name'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Text('Address label', style: text.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _labels
                    .map((l) => ChoiceChip(
                          label: Text(l),
                          selected: _label == l,
                          onSelected: (_) => setState(() => _label = l),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('Delivery address', style: text.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Street, building, neighborhood…',
                  prefixIcon: Icon(Icons.location_on_outlined,
                      color: context.colors.inkSoft),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _valid ? _confirm : null,
                child: const Text('Confirm & continue'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
