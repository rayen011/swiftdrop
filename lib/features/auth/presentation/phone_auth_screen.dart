import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// OTP-based login/signup — step 1: phone number entry.
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _controller = TextEditingController();
  static const _dialCode = '+216'; // Tunisia

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final local = _controller.text.replaceAll(RegExp(r'\s+'), '');
    if (local.length < 8) return;
    context.read<AuthCubit>().sendOtp('$_dialCode$local');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Enter your number', style: text.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'We’ll text you a code to verify. No passwords, no email.',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('🇹🇳 $_dialCode',
                            style: AppTypography.mono(fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          style: AppTypography.mono(fontSize: 16),
                          decoration:
                              const InputDecoration(hintText: '55 123 456'),
                        ),
                      ),
                    ],
                  ),
                  if (state.status == AuthStatus.error && state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(state.error!,
                          style: text.bodySmall
                              ?.copyWith(color: context.colors.error)),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed:
                        state.isBusy ? null : () => _submit(context),
                    child: state.isBusy
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: context.colors.onEmber),
                          )
                        : const Text('Send code'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
