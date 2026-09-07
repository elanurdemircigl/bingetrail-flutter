import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class NetworkPoster extends StatelessWidget {
  const NetworkPoster({
    required this.imageUrl,
    super.key,
    this.fit = BoxFit.cover,
    this.iconSize = 38,
  });

  final String? imageUrl;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null) {
      return _Placeholder(iconSize: iconSize);
    }

    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => _Placeholder(iconSize: iconSize),
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return const ColoredBox(
          color: AppTheme.surface,
          child: Center(
            child: SizedBox.square(
              dimension: 26,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.surface,
      child: Center(
        child: Icon(
          Icons.local_movies_outlined,
          color: AppTheme.mutedText,
          size: iconSize,
        ),
      ),
    );
  }
}
