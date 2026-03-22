import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/entities/child_profile.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _avatarController = TextEditingController(text: 'assets/images/avatar_default.png');
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _avatarController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Crea profilo')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileCreationSuccess) {
            GoRouter.of(context).pop();
          }
          if (state is AgeVerificationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.reason)));
          }
        },
        builder: (context, state) {
          if (state is CreateProfileInProgress) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(state.verificationQuestion, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  TextField(controller: _answerController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Risposta')),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () {
                    final ans = int.tryParse(_answerController.text.trim()) ?? -9999;
                    bloc.add(SubmitAgeVerification(ans));
                  }, child: const Text('Conferma')),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome')),
                const SizedBox(height: 8),
                TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Età')),
                const SizedBox(height: 8),
                TextField(controller: _avatarController, decoration: const InputDecoration(labelText: 'Avatar asset path')),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () {
                  final name = _nameController.text.trim();
                  final age = int.tryParse(_ageController.text.trim()) ?? 0;
                  final avatar = _avatarController.text.trim();
                  if (name.isEmpty || age <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inserisci nome ed età validi')));
                    return;
                  }
                  final temp = ChildProfile(name: name, avatarAssetPath: avatar, age: age);
                  bloc.add(StartCreateProfile(temp));
                }, child: const Text('Inizia verifica età'))
              ],
            ),
          );
        },
      ),
    );
  }
}
