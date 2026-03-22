import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/session_bloc.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/image_asset.dart';
import '../bloc/session_event.dart';
import '../bloc/session_state.dart';

class LearningSessionScreen extends StatelessWidget {
  const LearningSessionScreen({super.key, required this.childId, required this.levelId});
  final String childId;
  final String levelId;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SessionBloc>(context);
    bloc.add(StartSession(childId, levelId));
    return Scaffold(
      appBar: AppBar(title: const Text('Sessione')),
      body: BlocBuilder<SessionBloc, SessionState>(builder: (context, state) {
        if (state is SessionLoading) return const Center(child: CircularProgressIndicator());
        if (state is SessionInProgress) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.currentWord.text, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (state.imageRevealed)
                FutureBuilder<ImageAsset?>(
                  future: RepositoryProvider.of<LevelsRepository>(context).getImageAsset(state.currentWord.imageId),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
                    final ImageAsset? img = snap.data;
                    if (img == null) {
                      return Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                      );
                    }
                    return Image.asset(
                      img.assetPath,
                      height: 160,
                      width: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                      ),
                    );
                  },
                )
              else
                ElevatedButton(onPressed: () => bloc.add(RevealImageRequested()), child: const Text('Mostra immagine')),
              const SizedBox(height: 24),
              Text('${state.currentIndex + 1} / ${state.total}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(onPressed: () => bloc.add(SubmitAnswer(true)), child: const Text('Sì')),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () => bloc.add(SubmitAnswer(false)), child: const Text('No')),
              ])
            ],
          );
        }
        if (state is SessionCompleted) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration, size: 72, color: Colors.amber),
                const SizedBox(height: 12),
                Text('Bravo!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal:4.0), child: Icon(i < state.stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 32)))),
                const SizedBox(height: 12),
                Text('${state.correctCount}/${state.total} risposte corrette'),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () {
                  // replay same level via router
                  GoRouter.of(context).pushNamed(AppRoutes.session, params: {'childId': state.session.childId, 'levelId': state.session.levelId});
                }, child: const Text('Riprova'))
              ],
            ),
          );
        }
        if (state is SessionFailure) return Center(child: Text('Errore: ${state.message}'));
        return const SizedBox.shrink();
      }),
    );
  }
}
