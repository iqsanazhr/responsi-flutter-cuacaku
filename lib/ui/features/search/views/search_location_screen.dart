import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:responsi_flutter/domain/models/location_item.dart';
import 'package:responsi_flutter/ui/core/widgets/liquid_glass_card.dart';
import 'package:responsi_flutter/ui/core/widgets/press_scale.dart';
import 'package:responsi_flutter/ui/core/widgets/state_feedback_view.dart';
import 'package:responsi_flutter/ui/features/search/view_models/search_view_model.dart';
import 'package:responsi_flutter/ui/features/search/views/widgets/location_tile.dart';
import 'package:responsi_flutter/ui/features/weather/view_models/weather_view_model.dart';

/// Adaptive Light/Dark iOS 27 Liquid Glass Location Search & Favorites Screen.
class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SearchViewModel>().loadSavedData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectLocation(LocationItem location) async {
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.recordSelection(location);
    if (!mounted) return;
    Navigator.of(context).pop();
    await weatherVm.selectLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disableAnim = MediaQuery.disableAnimationsOf(context);

    final primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF334155);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF050914) : const Color(0xFFD6E6FB),
      body: Stack(
        children: [
          // Atmospheric background canvas with soft ambient glow for Liquid Glass refraction
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF0B1833),
                          Color(0xFF070E1F),
                          Color(0xFF040710),
                        ]
                      : const [
                          Color(0xFFC4DDFB),
                          Color(0xFFDBEAFD),
                          Color(0xFFEAF2FE),
                        ],
                ),
              ),
              child: CustomPaint(
                painter: _SearchBackdropGlowPainter(isDark: isDark),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 16, 6),
                      child: Row(
                        children: [
                          PressScale(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(999),
                            child: LiquidGlassCard(
                              borderRadius: 999,
                              padding: const EdgeInsets.all(10),
                              tintOpacity: isDark ? 0.16 : 0.34,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: primaryText,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cari Lokasi',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                          PressScale(
                            onTap: weatherVm.toggleThemeMode,
                            borderRadius: BorderRadius.circular(999),
                            child: Tooltip(
                              message: isDark
                                  ? 'Beralih ke Mode Terang'
                                  : 'Beralih ke Mode Gelap',
                              child: LiquidGlassCard(
                                borderRadius: 999,
                                padding: const EdgeInsets.all(10),
                                tintOpacity: isDark ? 0.16 : 0.34,
                                child: Icon(
                                  isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: isDark
                                      ? const Color(0xFFFDE047)
                                      : const Color(0xFF1E3A8A),
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(color: primaryText, fontSize: 15),
                            textInputAction: TextInputAction.search,
                            onChanged: searchVm.onQueryChanged,
                            onSubmitted: searchVm.search,
                            decoration: InputDecoration(
                              hintText:
                                  'Cari nama kota (Purwokerto, Bandung, Tokyo)...',
                              hintStyle: TextStyle(
                                color: secondaryText,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.11)
                                  : Colors.white.withOpacity(0.55),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: secondaryText,
                              ),
                              suffixIcon: _controller.text.isNotEmpty ||
                                      searchVm.query.isNotEmpty
                                  ? IconButton(
                                      tooltip: 'Bersihkan pencarian',
                                      onPressed: () {
                                        _controller.clear();
                                        searchVm.onQueryChanged('');
                                      },
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: secondaryText,
                                      ),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(
                                    isDark ? 0.2 : 0.65,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(
                                    isDark ? 0.2 : 0.65,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF2563EB),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: disableAnim
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        child: _buildBody(context, searchVm, isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchViewModel searchVm,
    bool isDark,
  ) {
    switch (searchVm.status) {
      case SearchViewStatus.loading:
        return LoadingStateView(
          key: const ValueKey('search_loading'),
          message: 'Mencari kota di Open-Meteo Geocoding API...',
          useDarkInk: !isDark,
        );
      case SearchViewStatus.error:
        return ErrorStateView(
          key: const ValueKey('search_error'),
          message: searchVm.errorMessage ?? 'Gagal mencari lokasi.',
          onRetry: () => searchVm.search(_controller.text),
          useDarkInk: !isDark,
        );
      case SearchViewStatus.empty:
        return EmptyStateView(
          key: const ValueKey('search_empty'),
          icon: Icons.search_off_rounded,
          title: 'Lokasi Tidak Ditemukan',
          subtitle:
              'Tidak ada hasil untuk "${searchVm.query.trim()}". Coba gunakan nama kota yang lebih spesifik.',
          useDarkInk: !isDark,
        );
      case SearchViewStatus.loaded:
        return ListView.separated(
          key: const ValueKey('search_results'),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: searchVm.searchResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = searchVm.searchResults[index];
            return LocationTile(
              location: item,
              isFavorite: searchVm.isFavorite(item),
              onTap: () => _selectLocation(item),
              onToggleFavorite: () => searchVm.toggleFavorite(item),
            );
          },
        );
      case SearchViewStatus.idle:
        return _buildSavedCollections(context, searchVm, isDark);
    }
  }

  Widget _buildSavedCollections(
    BuildContext context,
    SearchViewModel searchVm,
    bool isDark,
  ) {
    final hasFavorites = searchVm.favorites.isNotEmpty;
    final hasHistory = searchVm.history.isNotEmpty;
    final sectionColor =
        isDark ? Colors.white.withOpacity(0.75) : const Color(0xFF334155);

    if (!hasFavorites && !hasHistory) {
      return EmptyStateView(
        key: const ValueKey('search_idle_empty'),
        icon: Icons.travel_explore_rounded,
        title: 'Mulai Pencarian Kota',
        subtitle:
            'Ketik nama kota di kolom pencarian di atas untuk melihat hasil dari Open-Meteo Geocoding API dan menyimpannya ke favorit.',
        useDarkInk: !isDark,
      );
    }

    return ListView(
      key: const ValueKey('search_saved_lists'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (hasFavorites) ...[
          Row(
            children: [
              Icon(
                Icons.bookmarks_rounded,
                size: 16,
                color: isDark
                    ? const Color(0xFFFDE047)
                    : const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              Text(
                'LOKASI FAVORIT (${searchVm.favorites.length})',
                style: TextStyle(
                  color: sectionColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...searchVm.favorites.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationTile(
                location: item,
                isFavorite: true,
                isHighlightCard: true,
                onTap: () => _selectLocation(item),
                onToggleFavorite: () => searchVm.toggleFavorite(item),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (hasHistory) ...[
          Row(
            children: [
              Icon(Icons.history_rounded, size: 16, color: sectionColor),
              const SizedBox(width: 8),
              Text(
                'RIWAYAT PENCARIAN',
                style: TextStyle(
                  color: sectionColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: searchVm.clearHistory,
                style: TextButton.styleFrom(
                  foregroundColor: isDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF1D4ED8),
                ),
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...searchVm.history.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationTile(
                location: item,
                isFavorite: searchVm.isFavorite(item),
                onTap: () => _selectLocation(item),
                onToggleFavorite: () => searchVm.toggleFavorite(item),
                trailingExtra: IconButton(
                  tooltip: 'Hapus dari riwayat',
                  onPressed: () => searchVm.removeHistoryItem(item),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: isDark
                        ? Colors.white.withOpacity(0.65)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchBackdropGlowPainter extends CustomPainter {
  const _SearchBackdropGlowPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final topOrb = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? const Color(0xFF2563EB) : const Color(0xFF38BDF8))
              .withOpacity(isDark ? 0.25 : 0.28),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.14),
          radius: size.width * 0.65,
        ),
      );
    canvas.drawRect(Offset.zero & size, topOrb);

    final bottomOrb = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? const Color(0xFF4F46E5) : const Color(0xFF60A5FA))
              .withOpacity(isDark ? 0.18 : 0.22),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.15, size.height * 0.78),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, bottomOrb);
  }

  @override
  bool shouldRepaint(covariant _SearchBackdropGlowPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
