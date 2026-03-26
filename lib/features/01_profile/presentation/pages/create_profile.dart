import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_creation_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';

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
    final bloc = BlocProvider.of<ProfileCreationBloc>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Crea profilo')),
      body: BlocConsumer<ProfileCreationBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileActionSuccess) {
            GoRouter.of(context).pop();
          }
          if (state is ProfileActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
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
                  final profile = ChildProfile(name: name, avatarAssetPath: avatar, age: age);
                  bloc.add(CreateProfile(profile));
                }, child: const Text('Crea Profilo'))
              ],
            ),
          );
        },
      ),
    );
  }
}
