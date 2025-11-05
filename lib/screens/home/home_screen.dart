import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/movie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<DateTime> _days;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _days = List<DateTime>.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day + index),
    );
  }

  Future<void> _refreshMovies(BuildContext context) async {
    await context.read<MovieNotifier>().loadInitialData();
  }

  void _openMovieDetail(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthNotifier>();

    return Scaffold(
      body: SafeArea(
        child: Consumer<MovieNotifier>(
          builder: (context, movies, _) {
            final padding = MediaQuery.of(context).size.width > 420 ? 48.0 : 24.0;
            return RefreshIndicator(
              onRefresh: () => _refreshMovies(context),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Top Movies',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Cerrar sesion',
                        onPressed: auth.status == AuthStatus.authenticated
                            ? () => auth.signOut()
                            : null,
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final date = _days[index];
                        final isSelected = index == _selectedDayIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 66,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('E', 'es')
                                        .format(date)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date.day.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Estrenos',
                    action: 'Ver todo',
                    onActionTap: () {},
                  ),
                  SizedBox(
                    height: 320,
                    child: movies.isLoading && movies.nowPlaying.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: movies.nowPlaying.length,
                            itemBuilder: (context, index) {
                              final movie = movies.nowPlaying[index];
                              return MovieCard(
                                movie: movie,
                                onTap: () => _openMovieDetail(context, movie),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Trailers',
                    action: 'Popular',
                    onActionTap: () {},
                  ),
                  SizedBox(
                    height: 240,
                    child: movies.trending.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: movies.trending.length,
                            itemBuilder: (context, index) {
                              final movie = movies.trending[index];
                              return MovieCard(
                                movie: movie,
                                large: false,
                                onTap: () => _openMovieDetail(context, movie),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Mejor valoradas',
                    action: 'Ranking',
                    onActionTap: () {},
                  ),
                  ...movies.topRated.take(5).map(
                        (movie) => _TopRatedTile(
                          movie: movie,
                          onTap: () => _openMovieDetail(context, movie),
                        ),
                      ),
                  if (movies.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      movies.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onActionTap,
  });

  final String title;
  final String action;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          TextButton(
            onPressed: onActionTap,
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

class _TopRatedTile extends StatelessWidget {
  const _TopRatedTile({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius / 2),
        child: AspectRatio(
          aspectRatio: AppSizes.posterAspectRatio,
          child: movie.posterUrl != null
              ? CachedNetworkImage(
                  imageUrl: movie.posterUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.black12),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image_outlined),
                )
              : Container(color: Colors.black12),
        ),
      ),
      title: Text(
        movie.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      subtitle: Text(
        movie.releaseDate != null
            ? DateFormat('y', 'es').format(movie.releaseDate!)
            : 'Sin fecha',
        style: const TextStyle(color: AppColors.lightText),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, size: 18, color: Colors.amber),
          Text(movie.voteAverage.toStringAsFixed(1)),
        ],
      ),
      onTap: onTap,
    );
  }
}
