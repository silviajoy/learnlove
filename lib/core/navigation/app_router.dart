import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/01_profile/presentation/pages/profile_select.dart';
import '../../features/02_reading/presentation/pages/levels_overview.dart';
import '../../features/02_reading/presentation/pages/learning_session.dart';
import '../../features/01_profile/presentation/pages/create_profile.dart';

class AppRoutes {
  static const profiles = 'profiles';
  static const levels = 'levels';
  static const session = 'session';
  static const createProfile = 'create_profile';
}

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          name: AppRoutes.profiles,
          path: '/',
          builder: (context, state) => const ProfileSelectScreen(),
        ),
        GoRoute(
          name: AppRoutes.levels,
          path: '/levels/:childId',
          builder: (context, state) {
            final childId = state.params['childId']!;
            return LevelsOverviewScreen(childId: childId);
          },
        ),
        GoRoute(
          name: AppRoutes.session,
          path: '/session/:childId/:levelId',
          builder: (context, state) {
            final childId = state.params['childId']!;
            final levelId = state.params['levelId']!;
            return LearningSessionScreen(childId: childId, levelId: levelId);
          },
        ),
        GoRoute(
          name: AppRoutes.createProfile,
          path: '/create-profile',
          builder: (context, state) => const CreateProfileScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Errore routing')),
        body: Center(child: Text(state.error.toString())),
      ),
    );
  }
}
