// presentation/widgets/concour_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/data/models/concour.dart';

class ConcourCard extends StatelessWidget {
  final Concour concour;
  final VoidCallback onTap;

  const ConcourCard({
    Key? key,
    required this.concour,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du concours
              _buildConcourImage(),
              const SizedBox(width: 16),
              // Informations du concours
              Expanded(
                child: _buildConcourInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConcourImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: concour.image != null && concour.image!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: concour.fullImageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                placeholder: (context, url) => _buildLoadingPlaceholder(),
              ),
            )
          : _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.emoji_events,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
      ),
    );
  }

  Widget _buildConcourInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom du concours
        Text(
          concour.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Statut
        _buildStatusBadge(),
        const SizedBox(height: 8),
        // Prix par vote
        Row(
          children: [
            const Icon(
              Icons.attach_money,
              size: 16,
              color: AppConstants.accentColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${PriceCalculator.formatPrice(concour.pricePerVote)} / vote',
              style:  const TextStyle(
                fontSize: 14,
                color: AppConstants.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Nombre de candidats
        if (concour.candidatesCount != null) ...[
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${concour.candidatesCount} candidat${concour.candidatesCount! > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (concour.status) {
      case 'EN_COURS':
        statusColor = AppConstants.successColor;
        statusText = 'En Cours';
        break;
      case 'TERMINE':
        statusColor = AppConstants.errorColor;
        statusText = 'Terminé';
        break;
      case 'A_VENIR':
        statusColor = AppConstants.accentColor;
        statusText = 'À Venir';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}