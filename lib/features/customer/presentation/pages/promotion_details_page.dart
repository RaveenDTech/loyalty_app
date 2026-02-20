import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

/// Data for a single promotion shown on the details page.
class PromotionDetailsData {
  const PromotionDetailsData({
    required this.id,
    required this.title,
    required this.imageAssetPath,
    required this.discountCredit,
    required this.discountDebit,
    required this.validFrom,
    required this.validTo,
    required this.conditions,
    required this.shopUrl,
    this.partnerName,
  });

  final String id;
  final String title;
  final String imageAssetPath;
  final String discountCredit;
  final String discountDebit;
  final String validFrom;
  final String validTo;
  final String conditions;
  final String shopUrl;
  final String? partnerName;
}

/// Promotion details page shown when user taps a promotion notification.
class PromotionDetailsPage extends StatelessWidget {
  const PromotionDetailsPage({
    super.key,
    required this.promotionId,
  });

  final String promotionId;

  static final Map<String, PromotionDetailsData> _promotions = {
    'shoe_offer': PromotionDetailsData(
      id: 'shoe_offer',
      title: 'Latest shoe offer with 25% discount',
      imageAssetPath: 'assets/Fab-Feb-Web.jpg-f08b2856-44b4-43ae-8844-5dcfc95fce39.png',
      discountCredit: '25% OFF for Credit Cards',
      discountDebit: '15% OFF for Debit Cards',
      validFrom: '20 February 2026',
      validTo: '23 February 2026',
      conditions: 'Valid only for online purchases',
      shopUrl: 'https://www.dsifootcandy.lk',
      partnerName: 'SampathCards',
    ),
  };

  static PromotionDetailsData? getPromotion(String id) => _promotions[id];

  @override
  Widget build(BuildContext context) {
    final promotion = PromotionDetailsPage.getPromotion(promotionId);
    if (promotion == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Promotion',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Promotion not found',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Promotion',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Promotion image: fixed aspect ratio, rounded corners, shadow
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.72,
                              child: Image.asset(
                                promotion.imageAssetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
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
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (promotion.partnerName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              promotion.partnerName!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          promotion.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _DetailRow(
                          icon: Icons.discount_rounded,
                          label: 'Credit Cards',
                          value: promotion.discountCredit,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.credit_card_rounded,
                          label: 'Debit Cards',
                          value: promotion.discountDebit,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AppTheme.borderColor,
                        ),
                        const SizedBox(height: 20),
                        _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Valid from',
                          value: promotion.validFrom,
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.event_rounded,
                          label: 'Valid to',
                          value: promotion.validTo,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AppTheme.borderColor,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                promotion.conditions,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openUrl(promotion.shopUrl),
                  icon: const Icon(Icons.shopping_cart_rounded, size: 20),
                  label: const Text('Buy online from www.dsifootcandy.lk'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.textPrimary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: effectiveColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
