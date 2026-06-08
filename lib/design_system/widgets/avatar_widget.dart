import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/domain/avatar/avatar_config.dart';
import '../tokens/app_colors.dart';

/// Renders a player avatar from [AvatarConfig] using the DiceBear adventurer
/// API. Fetches a deterministic SVG over the network; shows a circular
/// placeholder while loading. Works at any [size] (list thumbnails → profile
/// hero). DiceBear radius=50 delivers a pre-clipped circular SVG.
class AvatarWidget extends StatelessWidget {
  final AvatarConfig config;
  final double size;

  const AvatarWidget({
    super.key,
    required this.config,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      config.svgUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholderBuilder: (_) => _AvatarPlaceholder(size: size),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final double size;
  const _AvatarPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.outline,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.55,
        color: AppColors.textSecondary,
      ),
    );
  }
}
