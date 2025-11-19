// presentation/widgets/candidate_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/data/models/candidate.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback onTap;

  const CandidateCard({
    Key? key,
    required this.candidate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo du candidat
              _buildCandidateImage(),
              const SizedBox(width: 16),
              // Informations du candidat
              Expanded(
                child: _buildCandidateInfo(),
              ),
              // Votes count
              _buildVotesBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: CachedNetworkImage(
          imageUrl: candidate.fullProfilePhotoUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _buildPlaceholderIcon(),
          placeholder: (context, url) => _buildLoadingPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.person,
        size: 30,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
      ),
    );
  }

  Widget _buildCandidateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom complet
        Text(
          candidate.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Nationalité
        Text(
          candidate.nationality,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        // Description
        Text(
          candidate.fullDescription,
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildVotesBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            candidate.votesCount.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          Text(
            'vote${candidate.votesCount > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 10,
              color: AppConstants.primaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}