// data/models/candidate.dart
import 'package:equatable/equatable.dart';
import 'package:votyfy/core/constants/app_constants.dart';

class Candidate extends Equatable {
  final int id;
  final String lastName;
  final String firstName;
  final String nationality;
  final String fullDescription;
  final String profilePhoto;
  final int votesCount;
  final int concourId;

  const Candidate({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.nationality,
    required this.fullDescription,
    required this.profilePhoto,
    required this.votesCount,
    required this.concourId,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] as int,
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
      nationality: json['nationality'] as String,
      fullDescription: json['full_description'] as String,
      profilePhoto: json['profile_photo'] as String,
      votesCount: json['votes_count'] as int? ?? 0,
      concourId: json['concour_id'] as int,
    );
  }

  String get fullName => '$firstName $lastName';
  
  String get fullProfilePhotoUrl {
    if (profilePhoto.startsWith('http')) return profilePhoto;
    return '${AppConstants.baseUrl.replaceFirst('/api', '')}$profilePhoto';
  }

  @override
  List<Object?> get props => [
        id,
        lastName,
        firstName,
        nationality,
        fullDescription,
        profilePhoto,
        votesCount,
        concourId,
      ];
}