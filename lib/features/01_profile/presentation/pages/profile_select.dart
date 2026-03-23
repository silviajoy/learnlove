import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profiles_list_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';

class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  late final ProfilesListBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ProfilesListBloc>(context);
    bloc.add(LoadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scegli profilo')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await GoRouter.of(context).pushNamed(AppRoutes.createProfile);
          bloc.add(LoadProfiles());
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ProfilesListBloc, ProfileState>(builder: (context, state) {
          if (state is ProfilesLoading) return const Center(child: CircularProgressIndicator());
          if (state is ProfilesLoaded) {
            final profiles = state.profiles;
            if (profiles.isEmpty) {
              return Center(child: TextButton(onPressed: () {
                  GoRouter.of(context).pushNamed(AppRoutes.createProfile);
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
                  onTap: () => GoRouter.of(context).goNamed(AppRoutes.levels, params: {'childId': p.id}),
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
