import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_buttons.dart';

const pharmacyAccent = Color(0xFF3BAFDA);

/// "Can't find your medicine? Send a photo" — a **local mock** for screenshots.
///
/// No image is uploaded and nothing is stored: attaching a photo just flips a
/// UI flag, and sending shows a confirmation. A real version would push the
/// image to storage and open a pharmacist request; that needs a backend, so the
/// sheet says plainly that it's a demo.
Future<void> showMedicineRequestSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _MedicineRequestSheet(),
  );
}

class _MedicineRequestSheet extends StatefulWidget {
  const _MedicineRequestSheet();

  @override
  State<_MedicineRequestSheet> createState() => _MedicineRequestSheetState();
}

class _MedicineRequestSheetState extends State<_MedicineRequestSheet> {
  final _note = TextEditingController();
  bool _attached = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _send() {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.requestSent;
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(context.l10n.cantFindMedicine, style: text.titleLarge),
                const SizedBox(height: 4),
                Text(context.l10n.requestSheetBody, style: text.bodyMedium),
                const SizedBox(height: 18),
                _AttachBox(
                  attached: _attached,
                  onTap: () => setState(() => _attached = !_attached),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.noteOptional, style: text.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _note,
                  minLines: 2,
                  maxLines: 4,
                  decoration:
                      InputDecoration(hintText: context.l10n.noteHint),
                ),
                const SizedBox(height: 18),
                AppPrimaryButton(
                  onPressed: _attached ? _send : null,
                  child: Text(_attached
                      ? context.l10n.sendRequest
                      : context.l10n.attachToContinue),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 13, color: context.colors.inkSoft),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(context.l10n.demoNoUpload,
                          style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tapping toggles between the empty upload prompt and a mock "attached" tile.
class _AttachBox extends StatelessWidget {
  const _AttachBox({required this.attached, required this.onTap});

  final bool attached;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: attached
              ? pharmacyAccent.withValues(alpha: 0.10)
              : context.colors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: attached ? pharmacyAccent : context.colors.line,
          ),
        ),
        child: attached
            ? Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: pharmacyAccent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medication_outlined,
                        color: pharmacyAccent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('prescription.jpg',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(context.l10n.photoAttached,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded,
                      color: pharmacyAccent),
                ],
              )
            : Column(
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: pharmacyAccent, size: 28),
                  const SizedBox(height: 10),
                  Text(context.l10n.addPhoto,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(context.l10n.addPhotoSubtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
      ),
    );
  }
}
