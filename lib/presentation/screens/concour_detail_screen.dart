import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/core/widgets/loading_indicator.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/providers/candidate_provider.dart';
import 'package:votyfy/presentation/screens/live_results_screen.dart';
import 'package:votyfy/presentation/screens/vote_screen.dart';
import 'package:votyfy/presentation/widgets/candidate_card.dart';

class ConcourDetailScreen extends StatefulWidget {
  final Concour concour;

  const ConcourDetailScreen({Key? key, required this.concour}) : super(key: key);

  @override
  State<ConcourDetailScreen> createState() => _ConcourDetailScreenState();
}

class _ConcourDetailScreenState extends State<ConcourDetailScreen> {
  late CandidateProvider _candidateProvider;

  @override
  void initState() {
    super.initState();
    _candidateProvider = Provider.of<CandidateProvider>(context, listen: false);
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    await _candidateProvider.loadCandidatesByConcour(widget.concour.id);
  }

  void _onCandidateTap(Candidate candidate) {
    if (!widget.concour.isCurrentlyActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ce concours n\'est plus actif'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VoteScreen(concour: widget.concour, candidate: candidate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.concour.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.backgroundColor,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          if (widget.concour.totalVotes != null && widget.concour.totalVotes! > 0)
            IconButton(
              icon: const Icon(Icons.leaderboard, size: 22),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LiveResultsScreen(concour: widget.concour),
                  ),
                );
              },
              tooltip: 'Voir les résultats',
            ),
        ],
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            // ✅ EN-TÊTE COMPACT
            _buildCompactHeader(),
            // ✅ ZONE CANDIDATS ÉLARGIE
            _buildExpandedCandidatesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      margin: const EdgeInsets.all(12), // ✅ Marge réduite
      padding: const EdgeInsets.all(16), // ✅ Padding réduit
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // ✅ Border réduit
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ DESCRIPTION COMPACTE
          if (widget.concour.description != null) ...[
            Text(
              widget.concour.description!,
              style: const TextStyle(
                fontSize: 13, // ✅ Taille réduite
                color: AppConstants.textColor,
                height: 1.4, // ✅ Hauteur réduite
              ),
              maxLines: 2, // ✅ Limite à 2 lignes
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12), // ✅ Espace réduit
          ],
          // ✅ STATS ULTRA COMPACTES
          _buildUltraCompactStats(),
          const SizedBox(height: 12), // ✅ Espace réduit
          // ✅ DATES COMPACTES
          _buildCompactDateSection(),
        ],
      ),
    );
  }

  Widget _buildUltraCompactStats() {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ Padding réduit
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.05),
            AppConstants.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12), // ✅ Border réduit
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Statut
          _buildCompactStatItem(
            'Statut',
            _getStatusText(widget.concour.status),
            _getStatusColor(widget.concour.status),
            Icons.circle,
          ),
          // Prix
          _buildCompactStatItem(
            'Prix/vote',
            PriceCalculator.formatPrice(widget.concour.pricePerVote),
            AppConstants.accentColor,
            Icons.attach_money,
          ),
          // Votes (si disponibles)
          if (widget.concour.totalVotes != null)
            _buildCompactStatItem(
              'Votes',
              '${widget.concour.totalVotes}',
              AppConstants.primaryColor,
              Icons.how_to_vote,
            ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32, // ✅ Taille réduite
          height: 32, // ✅ Taille réduite
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color), // ✅ Icône réduite
        ),
        const SizedBox(height: 4), // ✅ Espace réduit
        Text(
          value,
          style: TextStyle(
            fontSize: 11, // ✅ Taille réduite
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9, // ✅ Taille réduite
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDateSection() {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ Padding réduit
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12), // ✅ Border réduit
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactDateItem('Début', widget.concour.formattedStartDate, Icons.play_arrow),
          _buildDateDivider(),
          _buildCompactDateItem('Fin', widget.concour.formattedEndDate, Icons.stop),
          if (widget.concour.isCurrentlyActive && widget.concour.endAt != null) ...[
            _buildDateDivider(),
            _buildCompactDateItem('Restant', widget.concour.remainingTime, Icons.access_time),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactDateItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28, // ✅ Taille réduite
            height: 28, // ✅ Taille réduite
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: AppConstants.primaryColor), // ✅ Icône réduite
          ),
          const SizedBox(height: 4), // ✅ Espace réduit
          Text(
            value,
            style: const TextStyle(
              fontSize: 10, // ✅ Taille réduite
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9, // ✅ Taille réduite
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider() {
    return Container(
      width: 1,
      height: 24, // ✅ Hauteur réduite
      color: Colors.grey.shade300,
    );
  }

  Widget _buildExpandedCandidatesSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ✅ EN-TÊTE CANDIDATS COMPACT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // ✅ Padding réduit
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'Candidats',
                    style: TextStyle(
                      fontSize: 16, // ✅ Taille réduite
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Consumer<CandidateProvider>(
                    builder: (context, provider, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // ✅ Padding réduit
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10), // ✅ Border réduit
                        ),
                        child: Text(
                          '${provider.candidates.length}',
                          style: const TextStyle(
                            fontSize: 11, // ✅ Taille réduite
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // ✅ LISTE CANDIDATS AVEC ZONE ÉLARGIE
            Expanded(child: _buildOptimizedCandidatesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedCandidatesList() {
    return Consumer<CandidateProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CustomLoadingIndicator(message: 'Chargement des candidats...');
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppConstants.errorColor), // ✅ Taille réduite
                const SizedBox(height: 12), // ✅ Espace réduit
                const Text(
                  'Erreur de chargement',
                  style: TextStyle(fontSize: 14), // ✅ Taille réduite
                ),
                const SizedBox(height: 16), // ✅ Espace réduit
                ElevatedButton(
                  onPressed: _loadCandidates,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // ✅ Padding réduit
                  ),
                  child: const Text('Réessayer', style: TextStyle(fontSize: 13)), // ✅ Taille réduite
                ),
              ],
            ),
          );
        }

        if (provider.candidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400), // ✅ Taille réduite
                const SizedBox(height: 12), // ✅ Espace réduit
                const Text(
                  'Aucun candidat',
                  style: TextStyle(fontSize: 14, color: Colors.grey), // ✅ Taille réduite
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8), // ✅ Padding latéral réduit
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16), // ✅ Padding vertical optimisé
            itemCount: provider.candidates.length,
            itemBuilder: (context, index) {
              final candidate = provider.candidates[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4), // ✅ Marge verticale réduite
                child: CandidateCard(
                  candidate: candidate,
                  onTap: () => _onCandidateTap(candidate),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'EN_COURS': return 'Actif';
      case 'TERMINE': return 'Terminé';
      case 'A_VENIR': return 'À Venir';
      default: return 'Inconnu';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_COURS': return AppConstants.successColor;
      case 'TERMINE': return AppConstants.errorColor;
      case 'A_VENIR': return AppConstants.accentColor;
      default: return Colors.grey;
    }
  }
}