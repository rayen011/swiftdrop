import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// OTP-based login/signup — step 2: enter the 6-digit SMS code.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.read<AuthCubit>().resetToPhone(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verify your number', style: text.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Enter the code sent to ${state.phone}',
                      style: text.bodyMedium),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTypography.mono(
                        fontSize: 28, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                    ),
                    onChanged: (v) {
                      if (v.length == 6) {
                        context.read<AuthCubit>().verifyOtp(v);
                      }
                    },
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
                    onPressed: state.isBusy
                        ? null
                        : () => context
                            .read<AuthCubit>()
                            .verifyOtp(_controller.text),
                    child: state.isBusy
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: context.colors.onEmber),
                          )
                        : const Text('Verify'),
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
