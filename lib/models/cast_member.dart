import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      character: (json['character'] ?? '') as String,
      profilePath: json['profile_path'] as String?,
    );
  }

  String? get avatarUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w185$profilePath' : null;

  @override
  List<Object?> get props => [id, name, character, profilePath];
}
