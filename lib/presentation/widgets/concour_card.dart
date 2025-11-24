// presentation/widgets/concour_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/data/models/concour.dart';

class ConcourCard extends StatelessWidget {
  final Concour concour;
  final VoidCallback onTap;
  final VoidCallback? onViewResults;

  const ConcourCard({
    Key? key,
    required this.concour,
    required this.onTap,
    this.onViewResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image avec overlay
            _buildImageSection(),
            // Contenu
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image principale
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.grey.shade200,
          ),
          child: concour.image != null && concour.image!.isNotEmpty
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: concour.fullImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(),
                  ),
                )
              : _buildImagePlaceholder(),
        ),
        // Overlay gradient
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Badge statut en haut à droite
        Positioned(
          top: 12,
          right: 12,
          child: _buildStatusBadge(),
        ),
        // Nom du concours sur l'image
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            concour.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 4, color: Colors.black54),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor.withOpacity(0.3),
            AppConstants.secondaryColor.withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.emoji_events,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (concour.description != null) ...[
            Text(
              concour.description!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          // Informations principales
          _buildMainInfo(),
          const SizedBox(height: 12),
          // Actions
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusConfig = _getStatusConfig(concour.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        statusConfig.text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      children: [
        // Ligne 1: Dates
        Row(
          children: [
            _buildInfoItem(Icons.calendar_today, concour.formattedStartDate),
            const SizedBox(width: 12),
            _buildInfoItem(Icons.event_available, concour.formattedEndDate),
            const Spacer(),
            if (concour.isCurrentlyActive && concour.endAt != null)
              _buildRemainingTime(),
          ],
        ),
        const SizedBox(height: 10),
        // Ligne 2: Stats et Prix
        Row(
          children: [
            // Candidats
            if (concour.candidatesCount != null) ...[
              _buildStatItem(Icons.people, '${concour.candidatesCount}'),
              const SizedBox(width: 12),
            ],
            // Votes
            if (concour.totalVotes != null) ...[
              _buildStatItem(Icons.how_to_vote, '${concour.totalVotes}'),
              const SizedBox(width: 12),
            ],
            const Spacer(),
            // Prix
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.accentColor,
                    AppConstants.accentColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.accentColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${PriceCalculator.formatPrice(concour.pricePerVote)} / vote',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppConstants.primaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRemainingTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 10, color: AppConstants.successColor),
          const SizedBox(width: 4),
          Text(
            concour.remainingTime,
            style: TextStyle(
              fontSize: 10,
              color: AppConstants.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: AppConstants.primaryColor.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility, size: 16),
                SizedBox(width: 6),
                Text('Voir Détails', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        if (onViewResults != null && (concour.totalVotes ?? 0) > 0) ...[
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.accentColor.withOpacity(0.3)),
            ),
            child: IconButton(
              onPressed: onViewResults,
              icon: Icon(Icons.leaderboard, size: 18, color: AppConstants.accentColor),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ],
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'EN_COURS':
        return _StatusConfig(AppConstants.successColor, 'En Cours');
      case 'TERMINE':
        return _StatusConfig(AppConstants.errorColor, 'Terminé');
      case 'A_VENIR':
        return _StatusConfig(AppConstants.accentColor, 'À Venir');
      default:
        return _StatusConfig(Colors.grey, 'Inconnu');
    }
  }
}

class _StatusConfig {
  final Color color;
  final String text;

  _StatusConfig(this.color, this.text);
}