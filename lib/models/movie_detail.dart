import 'package:equatable/equatable.dart';

import 'cast_member.dart';

class MovieDetail extends Equatable {
  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.runtime,
    required this.voteAverage,
    required this.genres,
    required this.director,
    required this.cast,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;
  final int? runtime;
  final double voteAverage;
  final List<String> genres;
  final String? director;
  final List<CastMember> cast;

  MovieDetail copyWith({List<CastMember>? cast, String? director}) {
    return MovieDetail(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      runtime: runtime,
      voteAverage: voteAverage,
      genres: genres,
      director: director ?? this.director,
      cast: cast ?? this.cast,
    );
  }

  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;

  String? get backdropUrl =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w780$backdropPath' : null;

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        releaseDate,
        runtime,
        voteAverage,
        genres,
        director,
        cast,
      ];

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] != null && (json['release_date'] as String).isNotEmpty
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      runtime: json['runtime'] as int?,
      voteAverage: (json['vote_average'] is int)
          ? (json['vote_average'] as int).toDouble()
          : (json['vote_average'] ?? 0).toDouble(),
      genres: (json['genres'] as List<dynamic>? ?? <dynamic>[])
          .map((genre) => (genre['name'] ?? '') as String)
          .where((name) => name.isNotEmpty)
          .toList(),
      director: null,
      cast: const [],
    );
  }
}
