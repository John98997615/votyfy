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

  String get fullImageUrl {
    if (image == null) return '';
    if (image!.startsWith('http')) return image!;
    return '${AppConstants.baseUrl.replaceFirst('/api', '')}$image';
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
}