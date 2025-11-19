// presentation/screens/concour_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/core/widgets/loading_indicator.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/providers/candidate_provider.dart';
import 'package:votyfy/presentation/screens/vote_screen.dart';
import 'package:votyfy/presentation/widgets/candidate_card.dart';

class ConcourDetailScreen extends StatefulWidget {
  final Concour concour;

  const ConcourDetailScreen({
    Key? key,
    required this.concour,
  }) : super(key: key);

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
    if (!widget.concour.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce concours n\'est plus actif'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VoteScreen(
          concour: widget.concour,
          candidate: candidate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.concour.name),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            // En-tête du concours
            _buildConcourHeader(),
            // Liste des candidats
            Expanded(
              child: _buildCandidatesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConcourHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.concour.description != null) ...[
            Text(
              widget.concour.description!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prix par vote: ${PriceCalculator.formatPrice(widget.concour.pricePerVote)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Statut: ${_getStatusText(widget.concour.status)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(widget.concour.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (widget.concour.totalVotes != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.concour.totalVotes} votes',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesList() {
    return Consumer<CandidateProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CustomLoadingIndicator(
            message: 'Chargement des candidats...',
          );
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppConstants.errorColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.errorColor,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadCandidates,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Réessayer'),
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
                const Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun candidat',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucun candidat pour ce concours',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.candidates.length,
          itemBuilder: (context, index) {
            final candidate = provider.candidates[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CandidateCard(
                candidate: candidate,
                onTap: () => _onCandidateTap(candidate),
              ),
            );
          },
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'EN_COURS':
        return 'En Cours';
      case 'TERMINE':
        return 'Terminé';
      case 'A_VENIR':
        return 'À Venir';
      default:
        return 'Inconnu';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_COURS':
        return AppConstants.successColor;
      case 'TERMINE':
        return AppConstants.errorColor;
      case 'A_VENIR':
        return AppConstants.accentColor;
      default:
        return Colors.grey;
    }
  }
}