import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../services/movie_service.dart';

class MovieNotifier extends ChangeNotifier {
  MovieNotifier() : _service = MovieService();

  final MovieService _service;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Movie> _nowPlaying = [];
  List<Movie> get nowPlaying => _nowPlaying;

  List<Movie> _topRated = [];
  List<Movie> get topRated => _topRated;

  List<Movie> _trending = [];
  List<Movie> get trending => _trending;

  final Map<int, MovieDetail> _detailCache = {};

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      final nowPlayingFuture = _service.fetchNowPlaying();
      final topRatedFuture = _service.fetchTopRated();
      final trendingFuture = _service.fetchTrending();

      final nowPlaying = await nowPlayingFuture;
      final topRated = await topRatedFuture;
      final trending = await trendingFuture;

      _nowPlaying = nowPlaying;
      _topRated = topRated;
      _trending = trending;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'No pudimos cargar las peliculas.';
    } finally {
      _setLoading(false);
    }
  }

  Future<MovieDetail?> loadMovieDetail(int id) async {
    if (_detailCache.containsKey(id)) {
      return _detailCache[id];
    }
    try {
      final detail = await _service.fetchMovieDetail(id);
      _detailCache[id] = detail;
      notifyListeners();
      return detail;
    } catch (_) {
      _errorMessage = 'No pudimos cargar el detalle de la pelicula.';
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
