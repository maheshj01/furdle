import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/provider/games_provider.dart';
import 'package:furdle/state/game_state.dart';
import 'package:furdle/utils/utility.dart';

class StreakPage extends ConsumerStatefulWidget {
  static String path = '/streak';
  const StreakPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StreakPageState();
}

class _StreakPageState extends ConsumerState<StreakPage> {
  @override
  Widget build(BuildContext context) {
    final allGames = ref.watch(gamesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Games'),
      ),
      body: allGames.when(
        data: (games) => ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) => GameTile(game: games[index]),
        ),
        error: (error, stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  final GameState game;
  const GameTile({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final grid = Utility.generateGridFromState(game);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Game #${game.id}'),
                    // Result
                    Text(game.status.name),
                  ],
                ),
                if (game.startTime != null) Text(game.startTime.toString()),
              ],
            )),
            Text(grid),
          ],
        ),
      ),
    );
  }
}
