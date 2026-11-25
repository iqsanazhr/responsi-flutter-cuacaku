import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:responsi_flutter/domain/models/location_item.dart';
import 'package:responsi_flutter/ui/core/widgets/press_scale.dart';

/// Adaptive Light/Dark iOS 27 Liquid Glass city card or search result row.
class LocationTile extends StatelessWidget {
  const LocationTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.isHighlightCard = false,
    this.trailingExtra,
  });

  final LocationItem location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isHighlightCard;
  final Widget? trailingExtra;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coords =
        '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}';

    final useWhiteText = isHighlightCard || isDark;
    final titleColor = useWhiteText ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = useWhiteText
        ? Colors.white.withOpacity(0.8)
        : const Color(0xFF334155);
    final captionColor = useWhiteText
        ? Colors.white.withOpacity(0.65)
        : const Color(0xFF475569);

    final BoxDecoration decoration;
    if (isHighlightCard) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1D4ED8).withOpacity(0.55),
                  const Color(0xFF0F2942).withOpacity(0.68),
                ]
              : [
                  const Color(0xFF2563EB).withOpacity(0.84),
                  const Color(0xFF0EA5E9).withOpacity(0.76),
                ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.28 : 0.55),
          width: 1.0,
        ),
      );
    } else if (isDark) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.14),
            Colors.white.withOpacity(0.06),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.68),
            Colors.white.withOpacity(0.45),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
      );
    }

    return PressScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: isHighlightCard ? 16 : 13,
            ),
            decoration: decoration,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: isHighlightCard ? 19 : 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        location.subtitle.isNotEmpty
                            ? location.subtitle
                            : 'Koordinat $coords',
                        style: TextStyle(color: subtitleColor, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Lat/Lon: $coords',
                        style: TextStyle(
                          color: captionColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingExtra != null) trailingExtra!,
                IconButton(
                  tooltip: isFavorite
                      ? 'Hapus dari favorit'
                      : 'Simpan ke favorit',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isFavorite
                        ? const Color(0xFFFDE047)
                        : subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
