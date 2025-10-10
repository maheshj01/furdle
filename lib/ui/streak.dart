import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/provider/games_provider.dart';
import 'package:furdle/state/game_state.dart';
import 'package:furdle/utils/extensions.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text('All Games'),
      ),
      body: allGames.when(
        data: (games) {
          final reversedGames = games.reversed.toList();
          return Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: isDesktop ? 600 : screenSize.width,
              child: ListView.builder(
                itemCount: reversedGames.length,
                itemBuilder: (context, index) => GameTile(game: reversedGames[index]),
              ),
            ),
          );
        },
        error: (error, stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  final GameState game;
  const GameTile({super.key, required this.game});

  Color _getStatusColor(GameStatus status) {
    switch (status) {
      case GameStatus.win:
        return Colors.green;
      case GameStatus.lose:
        return Colors.red;
      case GameStatus.inprogress:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(GameStatus status) {
    switch (status) {
      case GameStatus.win:
        return 'Won';
      case GameStatus.lose:
        return 'Lost';
      case GameStatus.inprogress:
        return 'In Progress';
      default:
        return 'Not Started';
    }
  }

  IconData _getGameTypeIcon(GameType gameType) {
    switch (gameType) {
      case GameType.daily:
        return Icons.calendar_today;
      case GameType.random:
        return Icons.shuffle;
    }
  }

  Widget _buildStatRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats() {
    Duration completedDuration = Duration.zero;
    if (game.endTime != null && game.startTime != null) {
      completedDuration = game.endTime!.difference(game.startTime!);
    }
    return Column(
      children: [
        // Attempts
        if (game.submittedWords.isNotEmpty)
          _buildStatRow(
            Icons.format_list_numbered,
            'Attempts',
            '${game.submittedWords.length}/${game.size.height}',
          ),

        // // Difficulty
        // if (game.difficulty != null)
        //   _buildStatRow(
        //     Icons.speed,
        //     'Difficulty',
        //     game.difficulty!.name.toUpperCase(),
        //   ),

        // Hints used
        if (game.hintsUsed > 0)
          _buildStatRow(
            Icons.lightbulb_outline,
            'Hints Used',
            '${game.hintsUsed}',
            valueColor: Colors.amber[700],
          ),

        // Duration
        if (completedDuration != Duration.zero)
          _buildStatRow(
            Icons.timer_outlined,
            'Duration',
            completedDuration.formatDuration(),
          ),

        // Start time
        if (game.startTime != null)
          _buildStatRow(
            Icons.access_time,
            'Played',
            game.startTime!.formatDateTime(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final grid = Utility.generateGridFromState(game);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getGameTypeIcon(game.gameType), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Game #${game.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(_getStatusText(game.status)),
                  backgroundColor: _getStatusColor(game.status),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildGameStats()),
                // Grid visualization
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    grid,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
