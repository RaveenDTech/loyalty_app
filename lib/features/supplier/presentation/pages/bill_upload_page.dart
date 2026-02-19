import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/dsi_loyalty_tier.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/toast.dart';

class BillUploadPage extends StatefulWidget {
  final String requestId;

  const BillUploadPage({super.key, required this.requestId});

  @override
  State<BillUploadPage> createState() => _BillUploadPageState();
}

class _BillUploadPageState extends State<BillUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _billAmountController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _billImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _billAmountController.dispose();
    _discountAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        setState(() {
          _billImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, 'Error accessing camera: $e');
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        setState(() {
          _billImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, 'Error accessing gallery: $e');
      }
    }
  }

  void _calculateFinalAmount() {
    final billAmount = double.tryParse(_billAmountController.text) ?? 0;
    final discountAmount = double.tryParse(_discountAmountController.text) ?? 0;
    final finalAmount = billAmount - discountAmount;

    if (finalAmount < 0) {
      Toast.error(context, 'Discount cannot exceed bill amount');
    }
  }

  void _applyDsiLoyaltySuggestion(LoyaltyProvider loyaltyProvider, String customerId) {
    final billAmount = double.tryParse(_billAmountController.text);
    if (billAmount == null || billAmount <= 0) return;
    final suggested = loyaltyProvider.getSuggestedDiscountForCustomer(customerId, billAmount);
    if (suggested > 0) {
      _discountAmountController.text = suggested.toStringAsFixed(2);
      setState(() {});
    }
  }

  Future<void> _completeTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_billImage == null) {
      Toast.error(context, 'Please upload a bill image');
      return;
    }

    final billAmount = double.parse(_billAmountController.text);
    final discountAmount = double.parse(_discountAmountController.text);

    if (discountAmount > billAmount) {
      Toast.error(context, 'Discount cannot exceed bill amount');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final loyaltyProvider =
          Provider.of<LoyaltyProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      // In production, upload image to server and get URL
      final imageUrl = _billImage!.path; // Replace with actual upload logic

      final success = await loyaltyProvider.completeTransaction(
        requestId: widget.requestId,
        billAmount: billAmount,
        discountAmount: discountAmount,
        billImagePath: imageUrl,
      );

      if (success && mounted) {
        // Send notification to customer
        await notificationProvider.showLocalNotification(
          title: 'Transaction Completed',
          body:
              'Your discount of ${CurrencyFormat.lkr(discountAmount)} has been applied',
        );

        // Send SMS notification (in production)
        // await notificationProvider.sendSMSNotification(
        //   customerPhoneNumber,
        //   'Your DSI Loyalty discount of LKR ${discountAmount.toStringAsFixed(2)} has been applied. Final amount: LKR ${(billAmount - discountAmount).toStringAsFixed(2)}',
        // );

        if (mounted) {
          Toast.success(context, 'Transaction completed successfully');
          Navigator.pop(context, true);
        }
      } else if (mounted) {
        Toast.error(context, 'Failed to complete transaction');
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceBottomSheet(
        onCameraTap: () {
          Navigator.pop(context);
          _pickImage();
        },
        onGalleryTap: () {
          Navigator.pop(context);
          _pickImageFromGallery();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color _bgTop = Color(0xFF080E27);

    return Scaffold(
      backgroundColor: _bgTop,
      extendBodyBehindAppBar: true ,
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upload Bill',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer2<LoyaltyProvider, AuthProvider>(
        builder: (context, loyaltyProvider, authProvider, _) {
          // Find the approved request
          final approvedRequest = loyaltyProvider.approvedRequests
              .firstWhere(
                (r) => r.id == widget.requestId,
                orElse: () => loyaltyProvider.pendingRequests
                    .firstWhere((r) => r.id == widget.requestId),
              );

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Customer Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.primaryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.borderColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.primaryColor.withOpacity(0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  approvedRequest.customerName
                                      .trim()
                                      .split(' ')
                                      .where((e) => e.isNotEmpty)
                                      .map((e) => e[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    approvedRequest.customerName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer ID: ${approvedRequest.customerId.substring(0, 10)}...',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Bill Image Upload Section
                      Text(
                        'Bill Image',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_billImage == null)
                        InkWell(
                          onTap: _showImageSourceDialog,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 240,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.borderColor,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 40,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Upload bill image',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to choose image source',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Stack(
                          children: [
                            Container(
                              height: 240,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _billImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Row(
                                children: [
                                  // Change Image Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: AppTheme.primaryColor,
                                      ),
                                      onPressed: _showImageSourceDialog,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Remove Image Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() => _billImage = null);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Bill Amount
                      Text(
                        'Bill Amount',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _billAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Enter bill amount',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.currency_rupee_rounded,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          fillColor: AppTheme.surfaceColor
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bill amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          setState(() {});
                          _calculateFinalAmount();
                          _applyDsiLoyaltySuggestion(loyaltyProvider, approvedRequest.customerId);
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // DSI Loyalty suggestion chip
                      Builder(
                        builder: (context) {
                          final customerId = approvedRequest.customerId;
                          final tier = loyaltyProvider.getTierForCustomer(customerId);
                          final discountPercent = tier.discountPercent;
                          final billAmount = double.tryParse(_billAmountController.text);
                          final suggested = billAmount != null && billAmount > 0
                              ? loyaltyProvider.getSuggestedDiscountForCustomer(customerId, billAmount)
                              : 0.0;
                          if (discountPercent == 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 20,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'DSI Loyalty: $discountPercent% tier · ${CurrencyFormat.lkr(suggested, decimalDigits: 0)} suggested',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Discount Amount
                      Text(
                        'Discount Amount',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _discountAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Enter discount amount',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.discount_rounded,
                              color: AppTheme.successColor,
                            ),
                          ),
                          fillColor: AppTheme.surfaceColor
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter discount amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          final billAmount =
                              double.tryParse(_billAmountController.text) ?? 0;
                          if (amount > billAmount) {
                            return 'Discount cannot exceed bill amount';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          setState(() {});
                          _calculateFinalAmount();
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Final Amount Display
                      if (_billAmountController.text.isNotEmpty &&
                          _discountAmountController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.successColor.withOpacity(0.15),
                                AppTheme.successColor.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.successColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.successColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Final Amount',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                CurrencyFormat.lkr(
                                  (double.tryParse(_billAmountController.text) ?? 0) -
                                      (double.tryParse(_discountAmountController.text) ?? 0),
                                  decimalDigits: 0,
                                ),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Complete Transaction Button
                      ElevatedButton(
                        onPressed: _isUploading ? null : _completeTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Complete Transaction',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const _ImageSourceBottomSheet({
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              'Select Image Source',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            
            // Camera Option
            InkWell(
              onTap: onCameraTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Camera',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Take a photo with camera',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Gallery Option
            InkWell(
              onTap: onGalleryTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: AppTheme.secondaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gallery',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose from photo library',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
