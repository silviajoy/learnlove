import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';
import '../bloc/profiles_list_bloc.dart';
import '../bloc/profile_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/age_verification_dialog.dart';

class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  bool _manageProfiles = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli profilo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showActionsMenu,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showActionsMenu,
        child: const Icon(Icons.settings),
      ),
      body: BlocBuilder<ProfilesListCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfilesLoading) return const Center(child: CircularProgressIndicator());
          if (state is ProfilesLoaded) {
            final profiles = state.profiles;
            return Column(
              children: [
                if (_manageProfiles)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.tune),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Modalità gestione attiva',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _manageProfiles = false),
                          child: const Text('Fine'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: profiles.isEmpty
                      ? Center(
                          child: TextButton(
                            onPressed: _startCreateProfile,
                            child: const Text('Crea profilo'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            final profile = profiles[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text(profile.name.isNotEmpty ? profile.name[0] : '?')),
                              title: Text(profile.name),
                              subtitle: Text('Età: ${profile.age}'),
                              onTap: _manageProfiles
                                  ? null
                                  : () => GoRouter.of(context).goNamed(AppRoutes.levels, params: {'childId': profile.id}),
                              trailing: _manageProfiles
                                  ? Wrap(
                                      spacing: 4,
                                      children: [
                                        IconButton(
                                          tooltip: 'Modifica',
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () => _showEditProfileSheet(profile),
                                        ),
                                        IconButton(
                                          tooltip: 'Elimina',
                                          icon: const Icon(Icons.delete_outline),
                                          color: Theme.of(context).colorScheme.error,
                                          onPressed: () => _confirmDelete(profile),
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          }
          if (state is ProfileActionFailure) {
            return Center(child: Text('Errore: ${state.error}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showActionsMenu() async {
    final action = await showModalBottomSheet<_ProfileMenuAction>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1),
                title: const Text('Crea nuovo'),
                onTap: () => Navigator.of(sheetContext).pop(_ProfileMenuAction.createNew),
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: Text(_manageProfiles ? 'Nascondi gestione' : 'Gestisci profili'),
                onTap: () => Navigator.of(sheetContext).pop(_ProfileMenuAction.manageProfiles),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _ProfileMenuAction.createNew:
        await _startCreateProfile();
        break;
      case _ProfileMenuAction.manageProfiles:
        if (_manageProfiles) {
          setState(() => _manageProfiles = false);
        } else {
          await _startManageProfiles();
        }
        break;
    }
  }

  Future<void> _startCreateProfile() async {
    final ageVerification = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => const AgeVerification(),
    );
    if (!mounted) return;

    if (ageVerification == true) {
      await GoRouter.of(context).pushNamed(AppRoutes.createProfile);
      if (!mounted) return;
      context.read<ProfilesListCubit>().loadProfiles();
    }
  }

  Future<void> _startManageProfiles() async {
    final ageVerification = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => const AgeVerification(),
    );

    if (ageVerification == true && mounted) {
      setState(() => _manageProfiles = true);
    }
  }

  Future<void> _showEditProfileSheet(ChildProfile profile) async {
    final pageContext = context;
    var editedName = profile.name;
    var editedAgeText = profile.age.toString();
    var editedAvatar = profile.avatarAssetPath;

    final updatedProfile = await showModalBottomSheet<ChildProfile>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Theme.of(pageContext).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
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
                    Text('Modifica profilo', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('edit_profile_name_field'),
                      initialValue: profile.name,
                      onChanged: (value) => editedName = value,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('edit_profile_age_field'),
                      initialValue: profile.age.toString(),
                      onChanged: (value) => editedAgeText = value,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Età'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('edit_profile_avatar_field'),
                      initialValue: profile.avatarAssetPath,
                      onChanged: (value) => editedAvatar = value,
                      decoration: const InputDecoration(labelText: 'Avatar asset path'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final name = editedName.trim();
                              final age = int.tryParse(editedAgeText.trim()) ?? 0;
                              final avatar = editedAvatar.trim();
                              if (name.isEmpty || age <= 0) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(pageContext).showSnackBar(
                                  const SnackBar(content: Text('Inserisci nome ed età validi')),
                                );
                                return;
                              }
                              Navigator.of(sheetContext).pop(
                                ChildProfile(
                                  id: profile.id,
                                  name: name,
                                  avatarAssetPath: avatar,
                                  age: age,
                                ),
                              );
                            },
                            child: const Text('Salva'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (updatedProfile != null && mounted) {
      await context.read<ProfilesListCubit>().updateProfile(updatedProfile);
    }
  }

  Future<void> _confirmDelete(ChildProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elimina profilo'),
        content: Text('Vuoi eliminare "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await context.read<ProfilesListCubit>().deleteProfile(profile.id);
    }
  }
}

enum _ProfileMenuAction {
  createNew,
  manageProfiles,
}
