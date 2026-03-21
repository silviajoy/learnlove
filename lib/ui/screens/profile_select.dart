import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../core/models/child_profile.dart';
import 'create_profile.dart';
import 'levels_overview.dart';

class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  late final ProfileBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ProfileBloc>(context);
    bloc.add(LoadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileCreationSuccess) {
          // reload profiles after creation
          bloc.add(LoadProfiles());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profilo creato')));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Scegli profilo')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateProfileScreen())),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
          if (state is ProfilesLoading) return const Center(child: CircularProgressIndicator());
          if (state is ProfilesLoaded) {
            final profiles = state.profiles;
            if (profiles.isEmpty) {
              return Center(child: TextButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateProfileScreen()));
              }, child: const Text('Crea profilo')));
            }
            return ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final p = profiles[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(p.name.isNotEmpty ? p.name[0] : '?')),
                  title: Text(p.name),
                  subtitle: Text('Età: ${p.age}'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LevelsOverviewScreen(childId: p.id)));
                  },
                );
              },
            );
          }
          if (state is ProfileActionFailure) return Center(child: Text('Errore: ${state.error}'));
          return const SizedBox.shrink();
        }),
      ),
    );
  }
}
