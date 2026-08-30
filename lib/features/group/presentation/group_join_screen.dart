import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/group_order_repository.dart';
import '../../auth/cubit/auth_cubit.dart';

class GroupJoinScreen extends StatefulWidget {
  const GroupJoinScreen({super.key});

  @override
  State<GroupJoinScreen> createState() => _GroupJoinScreenState();
}

class _GroupJoinScreenState extends State<GroupJoinScreen> {
  final _controller = TextEditingController();
  bool _joining = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length != 6 || _joining) return;
    final auth = context.read<AuthCubit>().state.user;
    if (auth == null) return;

    setState(() {
      _joining = true;
      _error = null;
    });
    final repo = sl<GroupOrderRepository>();
    final router = GoRouter.of(context);
    try {
      final group = await repo.findByShareCode(code);
      if (group == null) {
        setState(() {
          _joining = false;
          _error = 'No group found for that code';
        });
        return;
      }
      await repo.joinGroup(
        groupId: group.id,
        userId: auth.uid,
        name: auth.name.isEmpty ? 'Guest' : auth.name,
      );
      router.pushReplacement('${Routes.groupLobby}/${group.id}', extra: group);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _joining = false;
        _error = 'Could not join: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Join a group')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter invite code', style: text.headlineMedium),
              const SizedBox(height: 8),
              Text('Ask the host for their 6-character code.',
                  style: text.bodyMedium),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                autofocus: true,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  UpperCaseFormatter(),
                ],
                style: AppTypography.mono(
                    fontSize: 28, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'ABC123',
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!,
                      style:
                          text.bodySmall?.copyWith(color: context.colors.error)),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    (_controller.text.trim().length == 6 && !_joining)
                        ? _join
                        : null,
                child: _joining
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.colors.onEmber),
                      )
                    : const Text('Join group'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Forces typed text to uppercase as it's entered.
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
