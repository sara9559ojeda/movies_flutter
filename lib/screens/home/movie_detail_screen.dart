import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/movie.dart';
import '../../models/movie_detail.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/cast_avatar.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieInfoCard extends StatelessWidget {
  const _MovieInfoCard({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    final year = detail.releaseDate != null
        ? DateFormat('y').format(detail.releaseDate!)
        : 'N/A';
    final type = detail.genres.isNotEmpty ? detail.genres.first : 'N/A';
    final runtime = _formatRuntime(detail.runtime);
    final director = detail.director ?? 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7C7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Color(0xFFFF9F1C)),
                    const SizedBox(width: 6),
                    Text(
                      detail.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5C558),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'IMDb',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(child: _InfoTile(label: 'Year', value: year)),
                const SizedBox(width: 12),
                Expanded(child: _InfoTile(label: 'Type', value: type)),
                const SizedBox(width: 12),
                Expanded(child: _InfoTile(label: 'Hour', value: runtime)),
                const SizedBox(width: 12),
                Expanded(child: _InfoTile(label: 'Director', value: director)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

String _formatRuntime(int? minutes) {
  if (minutes == null || minutes <= 0) return 'N/A';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) {
    return '$minutes min';
  }
  if (mins == 0) {
    return '${hours}h';
  }
  return '${hours}h ${mins}m';
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  MovieDetail? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final detail =
        await context.read<MovieNotifier>().loadMovieDetail(widget.movie.id);
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final posterUrl = detail?.backdropUrl ?? widget.movie.backdropUrl;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (posterUrl != null)
                    CachedNetworkImage(
                      imageUrl: posterUrl,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: Colors.black26),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(widget.movie.title),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : detail == null
                      ? const Text('No encontramos informacion de esta pelicula.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Transform.translate(
                              offset: const Offset(0, -80),
                              child: _MovieInfoCard(detail: detail),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Plot Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              detail.overview.isNotEmpty
                                  ? detail.overview
                                  : 'Sinopsis proximamente.',
                              style: const TextStyle(
                                height: 1.5,
                                color: AppColors.lightText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: detail.genres
                                  .map((genre) => Chip(label: Text(genre)))
                                  .toList(),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Cast',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: detail.cast.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final cast = detail.cast[index];
                                  return CastAvatar(cast: cast);
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
