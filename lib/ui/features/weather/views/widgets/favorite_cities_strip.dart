import 'package:flutter/material.dart';

import 'package:responsi_flutter/domain/models/location_item.dart';
import 'package:responsi_flutter/ui/core/widgets/liquid_glass_card.dart';
import 'package:responsi_flutter/ui/core/widgets/press_scale.dart';

/// Translucent Liquid Glass strip of saved favorite cities for quick switching.
class FavoriteCitiesStrip extends StatelessWidget {
  const FavoriteCitiesStrip({
    super.key,
    required this.favorites,
    required this.selectedLocation,
    required this.onSelectCity,
    required this.onOpenSearch,
  });

  final List<LocationItem> favorites;
  final LocationItem? selectedLocation;
  final ValueChanged<LocationItem> onSelectCity;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return PressScale(
        onTap: onOpenSearch,
        borderRadius: BorderRadius.circular(18),
        child: LiquidGlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.bookmark_add_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Belum ada kota favorit. Tekan Simpan atau cari kota lain.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = favorites[index];
          final isSelected = selectedLocation?.uniqueKey == city.uniqueKey;
          return PressScale(
            onTap: () => onSelectCity(city),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.32)
                    : Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(isSelected ? 0.65 : 0.24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: isSelected
                        ? const Color(0xFFFDE047)
                        : Colors.white.withOpacity(0.85),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    city.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
