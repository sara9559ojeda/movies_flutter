import 'package:dio/dio.dart';

import '../models/cast_member.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';

class MovieService {
  MovieService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.themoviedb.org/3',
            headers: const {
              'Content-Type': 'application/json;charset=utf-8',
              'Authorization':
                  'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhODViZDMwY2UxMTJkYWJhZTE3ZTZjNjYxYmVjMGM1NyIsIm5iZiI6MTc2MDQyMTE5MC4yMjgsInN1YiI6IjY4ZWRlNTQ2NGMzZjhjYTQxMWQ2OTRmMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.6CMr7aLLRJ7wUbLLzZ7Uqg7pV_dC-pdjR3vimzhgWCM',
            },
          ),
        );

  final Dio _dio;

  Future<List<Movie>> fetchNowPlaying() async {
    final response = await _dio.get('/movie/now_playing');
    final results = response.data['results'] as List<dynamic>? ?? <dynamic>[];
    return results.map((data) => Movie.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<List<Movie>> fetchTopRated() async {
    final response = await _dio.get('/movie/top_rated');
    final results = response.data['results'] as List<dynamic>? ?? <dynamic>[];
    return results.map((data) => Movie.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<List<Movie>> fetchTrending() async {
    final response = await _dio.get('/trending/movie/week');
    final results = response.data['results'] as List<dynamic>? ?? <dynamic>[];
    return results.map((data) => Movie.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<MovieDetail> fetchMovieDetail(int id) async {
    final response = await _dio.get(
      '/movie/$id',
      queryParameters: {'append_to_response': 'credits'},
    );
    final data = response.data as Map<String, dynamic>;
    var detail = MovieDetail.fromJson(data);

    final credits = data['credits'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final castList = credits['cast'] as List<dynamic>? ?? <dynamic>[];
    final crewList = credits['crew'] as List<dynamic>? ?? <dynamic>[];
    final cast = castList
        .take(10)
        .map((raw) => CastMember.fromJson(raw as Map<String, dynamic>))
        .toList();
    final director = crewList
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (member) => (member['job'] ?? '') == 'Director',
          orElse: () => <String, dynamic>{},
        )['name'] as String?;

    detail = detail.copyWith(cast: cast, director: director);
    return detail;
  }
}
