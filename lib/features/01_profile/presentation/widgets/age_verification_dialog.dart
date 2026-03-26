
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/age_verification_cubit.dart';

class AgeVerification extends StatelessWidget {
  const AgeVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgeVerificationCubit()..generateQuestion(),
      child: const _AgeVerificationContent(),
    );
  }
}

class _AgeVerificationContent extends StatefulWidget {
  const _AgeVerificationContent();

  @override
  State<_AgeVerificationContent> createState() => _AgeVerificationContentState();
}

class _AgeVerificationContentState extends State<_AgeVerificationContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AgeVerificationCubit, AgeVerificationState>(
      listener: (context, state) {
        if (state.isVerified == true) {
          Navigator.of(context).pop(true);
        } else if (state.isVerified == false) {
          // Optionally shake or focus
        }
      },
      builder: (context, state) {
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifica età',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Risposta', errorText: state.error),
                    onChanged: (_) => context.read<AgeVerificationCubit>().reset(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Annulla'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final ans = int.tryParse(_controller.text.trim());
                            if (ans != null) {
                              context.read<AgeVerificationCubit>().verify(ans);
                            } else {
                              context.read<AgeVerificationCubit>().reset();
                            }
                          },
                          child: const Text('Conferma'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
