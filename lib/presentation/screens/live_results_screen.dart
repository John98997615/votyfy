// presentation/screens/live_results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/providers/candidate_provider.dart';

class LiveResultsScreen extends StatefulWidget {
  final Concour concour;

  const LiveResultsScreen({Key? key, required this.concour}) : super(key: key);

  @override
  State<LiveResultsScreen> createState() => _LiveResultsScreenState();
}

class _LiveResultsScreenState extends State<LiveResultsScreen> {
  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  void _loadCandidates() {
    final provider = Provider.of<CandidateProvider>(context, listen: false);
    provider.loadCandidatesByConcour(widget.concour.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats - ${widget.concour.name}'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCandidates,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: BackgroundContainer(
        child: Consumer<CandidateProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final candidates = provider.candidates..sort((a, b) => b.votesCount.compareTo(a.votesCount));
            final totalVotes = candidates.fold(0, (sum, candidate) => sum + candidate.votesCount);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  _buildHeader(totalVotes, candidates.length),
                  const SizedBox(height: 16),
                  // Liste des résultats
                  Expanded(
                    child: _buildResultsList(candidates, totalVotes),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int totalVotes, int candidateCount) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total des votes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  totalVotes.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Candidats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  candidateCount.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<Candidate> candidates, int totalVotes) {
    return ListView.builder(
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        final percentage = totalVotes > 0 
            ? (candidate.votesCount / totalVotes * 100) 
            : 0;
        final rank = index + 1;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rang
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Nom et votes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${candidate.votesCount} votes • ${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // Or
      case 2: return const Color(0xFFC0C0C0); // Argent
      case 3: return const Color(0xFFCD7F32); // Bronze
      default: return AppConstants.primaryColor;
    }
  }
}