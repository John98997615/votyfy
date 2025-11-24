// data/models/concour.dart
import 'package:equatable/equatable.dart';
import 'package:votyfy/core/constants/app_constants.dart';

class Concour extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? startAt;
  final String? endAt;
  final double pricePerVote;
  final String status;
  final int? candidatesCount;
  final int? totalVotes;

  const Concour({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.startAt,
    this.endAt,
    required this.pricePerVote,
    required this.status,
    this.candidatesCount,
    this.totalVotes,
  });

  factory Concour.fromJson(Map<String, dynamic> json) {
    return Concour(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      pricePerVote: (json['price_per_vote'] as num?)?.toDouble() ?? 100.0,
      status: json['status'] as String? ?? 'EN_COURS',
      candidatesCount: json['candidates_count'] as int?,
      totalVotes: json['total_votes'] as int?,
    );
  }

  // data/models/concour.dart
  // ASSUREZ-VOUS que la méthode fullImageUrl est correcte :

  // data/models/concour.dart
  // CORRECTION de la méthode fullImageUrl :

  // data/models/concour.dart
  // CORRECTION de la méthode fullImageUrl :

  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';

    // Si l'image commence déjà par http (URL complète)
    if (image!.startsWith('http')) return image!;

    // Nettoyer le chemin pour éviter les doublons
    String cleanPath = image!.replaceAll(RegExp(r'^storage/|^storage/'), '');

    return 'http://127.0.0.1:8000/storage/$cleanPath';
  }

  bool get isActive => status == 'EN_COURS';

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    image,
    startAt,
    endAt,
    pricePerVote,
    status,
    candidatesCount,
    totalVotes,
  ];


  // data/models/concour.dart
// AJOUTEZ ces méthodes :

String get formattedStartDate {
  if (startAt == null || startAt!.isEmpty) return 'Non définie';
  return _formatDate(startAt!);
}

String get formattedEndDate {
  if (endAt == null || endAt!.isEmpty) return 'Non définie';
  return _formatDate(endAt!);
}

String _formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateString; // Retourner la chaîne originale en cas d'erreur
  }
}

// bool get isActive => status == 'EN_COURS'; // Garder cette version simple

// CORRECTION de la méthode pour vérifier si c'est actuellement en cours
bool get isCurrentlyActive {
  if (startAt == null || endAt == null) return status == 'EN_COURS';
  
  try {
    final now = DateTime.now();
    final start = DateTime.parse(startAt!);
    final end = DateTime.parse(endAt!);
    
    return now.isAfter(start) && now.isBefore(end);
  } catch (e) {
    return status == 'EN_COURS';
  }
}

// Méthode pour obtenir la durée restante
String get remainingTime {
  if (endAt == null || endAt!.isEmpty) return 'Durée non définie';
  
  try {
    final end = DateTime.parse(endAt!);
    final now = DateTime.now();
    final difference = end.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Termine bientôt';
    }
  } catch (e) {
    return 'Durée inconnue';
  }
}

}
