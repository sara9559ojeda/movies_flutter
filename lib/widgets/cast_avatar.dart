import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/cast_member.dart';

class CastAvatar extends StatelessWidget {
  const CastAvatar({super.key, required this.cast});

  final CastMember cast;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = cast.avatarUrl;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.black12,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person_outline),
                  )
                : const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Column(
            children: [
              Text(
                cast.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                cast.character,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
