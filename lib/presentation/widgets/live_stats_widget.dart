// presentation/widgets/live_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:votyfy/core/constants/app_constants.dart';

class LiveStatsWidget extends StatefulWidget {
  final int totalVotes;
  final int totalConcours;
  final int totalCandidates;

  const LiveStatsWidget({
    Key? key,
    required this.totalVotes,
    required this.totalConcours,
    required this.totalCandidates,
  }) : super(key: key);

  @override
  State<LiveStatsWidget> createState() => _LiveStatsWidgetState();
}

class _LiveStatsWidgetState extends State<LiveStatsWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.how_to_vote, 'Votes', widget.totalVotes),
              _buildStatItem(Icons.emoji_events, 'Concours', widget.totalConcours),
              _buildStatItem(Icons.people, 'Candidats', widget.totalCandidates),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, int value) {
    return Column(
      children: [
        Icon(icon, size: 30, color: AppConstants.primaryColor),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}