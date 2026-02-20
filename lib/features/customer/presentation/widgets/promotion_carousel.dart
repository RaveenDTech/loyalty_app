import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Model for a single promotion slide (image + optional link).
class PromotionItem {
  const PromotionItem({
    required this.assetPath,
    this.link,
    this.semanticLabel,
  });

  final String assetPath;
  final String? link;
  final String? semanticLabel;
}

/// Carousel of promotion banners for the customer dashboard.
/// Shows images in a horizontal PageView with dot indicators and optional auto-play.
class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({
    super.key,
    required this.items,
    this.height,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.enableAutoPlay = true,
  });

  final List<PromotionItem> items;
  final double? height;
  final Duration autoPlayDuration;
  final bool enableAutoPlay;

  /// Default promotions using the provided dashboard assets.
  static List<PromotionItem> get defaultPromotions => const [
        PromotionItem(
          assetPath: 'assets/Enjoy-10-Discount-at-DSI-1890x1100-1-b6079141-9d55-4f78-a1a0-6fb8f727895b.png',
          semanticLabel: '10% discount at DSI with Genie Debit Mastercard',
        ),
        PromotionItem(
          assetPath: 'assets/Fab-Feb-Web.jpg-cd96e36b-e311-457c-a66c-765072873e5b.png',
          semanticLabel: 'SampathCards 25% off credit, 15% off debit at dsifootcandy.lk',
        ),
      ];

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.enableAutoPlay && widget.items.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(PromotionCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAutoPlay != oldWidget.enableAutoPlay ||
        widget.items.length != oldWidget.items.length) {
      _autoPlayTimer?.cancel();
      if (widget.enableAutoPlay && widget.items.length > 1) {
        _startAutoPlay();
      }
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  double get _carouselHeight => widget.height ?? 180.0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    if (widget.items.length == 1) {
      return _buildSingleItem(widget.items.first);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _carouselHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.items.length,
            itemBuilder: (context, index) => _buildSlide(widget.items[index]),
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildSingleItem(PromotionItem item) {
    return SizedBox(
      height: _carouselHeight,
      child: _buildSlideContent(item),
    );
  }

  Widget _buildSlide(PromotionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _buildSlideContent(item),
    );
  }

  Widget _buildSlideContent(PromotionItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.link != null && item.link!.isNotEmpty
              ? () {
                  // Could use url_launcher here if you add a callback
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              item.assetPath,
              fit: BoxFit.cover,
              semanticLabel: item.semanticLabel,
              errorBuilder: (_, __, ___) =>  Container(
                color: AppTheme.surfaceColor,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: AppTheme.textSecondary,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? AppTheme.primaryColor
                : AppTheme.textSecondary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
