import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/qr_generator.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/toast.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _flashEnabled = false;
  bool _hasPermission = false;
  bool _isCameraInitializing = true;
  bool _cameraError = false;
  String? _cameraErrorMessage;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;
  DateTime? _lastErrorTime;
  String? _lastScannedQrData;
  DateTime? _lastValidScanTime;
  String? _lastValidQrData;
  static const Duration _errorCooldown = Duration(seconds: 3);
  static const Duration _scanInterval = Duration(seconds: 3);
  static const int _maxRetryAttempts = 3;
  int _retryAttempts = 0;

  MobileScannerController get controller {
    _controller ??= MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.qrCode],
    );
    return _controller!;
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground - restart camera
        if (_hasPermission && !_isCameraInitializing) {
          _restartCamera();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App went to background - stop camera to free resources
        _stopCamera();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isCameraInitializing = true;
      _cameraError = false;
      _cameraErrorMessage = null;
      _retryAttempts = 0;
    });

    try {
      // Dispose existing controller if any
      if (_controller != null) {
        try {
          await _controller!.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
        _controller = null;
      }

      // Request permission first
      await _requestCameraPermission();

      if (_hasPermission && mounted) {
        // Wait a bit before initializing controller
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Ensure controller is created
        if (_controller == null) {
          _controller = MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
            facing: CameraFacing.back,
            formats: [BarcodeFormat.qrCode],
          );
        }
        
        // Start camera with retry logic
        await _startCameraWithRetry();
      } else {
        if (mounted) {
          setState(() {
            _isCameraInitializing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = true;
          _cameraErrorMessage = 'Failed to initialize camera: ${e.toString()}';
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _startCameraWithRetry() async {
    if (_controller == null) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        formats: [BarcodeFormat.qrCode],
      );
    }

    for (int attempt = 0; attempt < _maxRetryAttempts; attempt++) {
      try {
        if (!mounted) return;

        setState(() {
          _retryAttempts = attempt + 1;
        });

        // Wait a bit before starting (gives controller time to initialize)
        await Future.delayed(Duration(milliseconds: 300 + (attempt * 200)));

        // Try to start the camera
        await _controller!.start();
        
        // Verify camera is actually running
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          setState(() {
            _isCameraInitializing = false;
            _cameraError = false;
            _cameraErrorMessage = null;
            _retryAttempts = 0;
          });
        }
        return; // Success
      } catch (e) {
        debugPrint('Camera start attempt ${attempt + 1} failed: $e');
        
        if (attempt < _maxRetryAttempts - 1) {
          // Wait before retry with exponential backoff
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          
          // Try recreating controller on retry
          try {
            await _controller?.dispose();
          } catch (_) {}
          
          _controller = MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
            facing: CameraFacing.back,
            formats: [BarcodeFormat.qrCode],
          );
        } else {
          // All retries failed
          if (mounted) {
            setState(() {
              _cameraError = true;
              _cameraErrorMessage = 'Camera failed to start. Please try again.';
              _isCameraInitializing = false;
            });
          }
        }
      }
    }
  }

  Future<void> _restartCamera() async {
    if (!_hasPermission) return;
    
    setState(() {
      _isCameraInitializing = true;
      _cameraError = false;
      _retryAttempts = 0;
    });

    try {
      await _stopCamera();
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Recreate controller
      if (_controller != null) {
        try {
          await _controller!.dispose();
        } catch (e) {
          debugPrint('Error disposing on restart: $e');
        }
        _controller = null;
      }
      
      await _startCameraWithRetry();
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = true;
          _cameraErrorMessage = 'Failed to restart camera: ${e.toString()}';
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _stopCamera() async {
    try {
      if (_controller != null) {
        try {
          await _controller!.stop();
        } catch (e) {
          debugPrint('Error stopping camera: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in _stopCamera: $e');
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      // Check current status first
      final currentStatus = await Permission.camera.status;
      
      if (currentStatus.isGranted) {
        if (mounted) {
          setState(() {
            _hasPermission = true;
          });
        }
        return;
      }

      // Request permission
      final status = await Permission.camera.request();
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
        });
        
        if (status.isPermanentlyDenied) {
          // Show dialog to open settings
          _showPermissionDialog();
        } else if (status.isDenied) {
          // Show error message
          setState(() {
            _cameraError = true;
            _cameraErrorMessage = 'Camera permission is required to scan QR codes';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _cameraError = true;
          _cameraErrorMessage = 'Error requesting camera permission: ${e.toString()}';
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Camera Permission Required',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Camera permission is required to scan QR codes. Please enable it in app settings.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Open Settings',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    try {
      await _controller!.toggleTorch();
      setState(() {
        _flashEnabled = !_flashEnabled;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  /// Haptic feedback for successful QR scan
  Future<void> _hapticSuccess() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  /// Haptic feedback for failed QR scan
  Future<void> _hapticFailure() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.heavyImpact();
  }

  Future<void> _handleQRCode(String qrData) async {
    // Check if this is the same QR code that was recently scanned (valid or invalid)
    final now = DateTime.now();
    
    // Check for invalid QR code cooldown
    if (_lastScannedQrData == qrData && _lastErrorTime != null) {
      final timeSinceLastError = now.difference(_lastErrorTime!);
      if (timeSinceLastError < _errorCooldown) {
        // Still in error cooldown period, ignore this scan
        _isProcessing = false;
        return;
      }
    }
    
    // Check for valid QR code scan interval
    if (_lastValidQrData == qrData && _lastValidScanTime != null) {
      final timeSinceLastScan = now.difference(_lastValidScanTime!);
      if (timeSinceLastScan < _scanInterval) {
        // Still within scan interval, ignore this scan
        _isProcessing = false;
        return;
      }
    }

    bool hapticTriggered = false;
    try {
      // Parse QR code data using utility
      final parsedData = QRGenerator.parseQRData(qrData);
      if (parsedData == null) {
        // Check cooldown for invalid QR codes
        if (_lastErrorTime != null && _lastScannedQrData == qrData) {
          final timeSinceLastError = now.difference(_lastErrorTime!);
          if (timeSinceLastError < _errorCooldown) {
            // Still in cooldown, don't show error again
            _isProcessing = false;
            return;
          }
        }

        // Invalid format - trigger failure haptic
        await _hapticFailure();
        hapticTriggered = true;
        _lastErrorTime = now;
        _lastScannedQrData = qrData;
        throw Exception('Invalid QR code format');
      }

      // Valid QR code - reset error tracking
      _lastErrorTime = null;
      _lastScannedQrData = null;

      // Track valid QR scan for interval checking
      _lastValidScanTime = now;
      _lastValidQrData = qrData;

      // Valid QR code detected - trigger success haptic
      await _hapticSuccess();
      hapticTriggered = true;

      final supplierId = parsedData['supplierId']!;
      final supplierName = parsedData['supplierName']!;

      // Show modern confirmation dialog
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Confirm Discount Request',
        message: 'Send discount request to $supplierName?',
        icon: Icons.qr_code_2,
        iconColor: AppTheme.primaryColor,
        confirmText: 'Send Request',
        confirmColor: AppTheme.primaryColor,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
        barrierDismissible: false,
      );

      if (confirmed == true && mounted) {
        final loyaltyProvider =
            Provider.of<LoyaltyProvider>(context, listen: false);
        final notificationProvider =
            Provider.of<NotificationProvider>(context, listen: false);

        final success = await loyaltyProvider.sendDiscountRequest(
          supplierId,
          supplierName,
        );

        if (success && mounted) {
          // Show success notification
          await notificationProvider.showLocalNotification(
            title: 'Request Sent',
            body: 'Discount request sent to $supplierName',
          );

          // Additional success haptic for request sent
          await _hapticSuccess();

          if (mounted) {
            Toast.success(context, 'Request sent to $supplierName');
            Navigator.pop(context);
          }
        } else if (mounted) {
          // Request failed - trigger failure haptic
          await _hapticFailure();
          Toast.error(context, 'Failed to send request. Please try again.');
        }
      }
    } catch (e) {
      // Error occurred - trigger failure haptic (if not already triggered)
      if (!hapticTriggered) {
        await _hapticFailure();
        _lastErrorTime = DateTime.now();
        _lastScannedQrData = qrData;
      }
      
      if (mounted) {
        Toast.error(context, 'Error: ${e.toString()}');
      }
    } finally {
      _isProcessing = false;
    }
  }


  @override
  void dispose() {
    if (!kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
      _animationController.dispose();
      _stopCamera();
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'QR code scanning is available in the DSI Loyalty mobile app. '
              'Please use the app on your phone to scan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final scanArea = (size.width < 400 || size.height < 400) ? 250.0 : 300.0;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flashEnabled ? Icons.flash_on : Icons.flash_off,
              color: _flashEnabled ? AppTheme.primaryColor : Colors.white70,
            ),
            onPressed: _toggleFlash,
            tooltip: _flashEnabled ? 'Turn off flash' : 'Turn on flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          if (_hasPermission && !_cameraError && !_isCameraInitializing)
            Stack(
              children: [
                // Camera fills entire screen
                if (_controller != null)
                  Positioned.fill(
                    child: MobileScanner(
                      controller: _controller!,
                      onDetect: (capture) {
                        if (!_isProcessing && mounted) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty) {
                            final barcode = barcodes.first;
                            if (barcode.rawValue != null) {
                              _isProcessing = true;
                              _handleQRCode(barcode.rawValue!);
                            }
                          }
                        }
                      },
                    ),
                  ),
                // Overlay with scan area - non-interactive
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ScannerOverlayPainter(
                        scanArea: scanArea,
                        animation: _scanLineAnimation,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (_isCameraInitializing)
            // Camera Loading State
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Initializing Camera...',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (_retryAttempts > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Retrying... (${_retryAttempts}/$_maxRetryAttempts)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else if (_cameraError)
            // Camera Error State
            Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 80,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Camera Error',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_cameraErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _cameraErrorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _initializeCamera,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Permission Denied State
            Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 80,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Camera Permission Required',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Please grant camera permission to scan QR codes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          await _requestCameraPermission();
                          if (_hasPermission) {
                            await _startCameraWithRetry();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Grant Permission',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Instructions Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Instructions — glassmorphism
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1.2,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.surfaceColor.withOpacity(0.0),
                                  AppTheme.surfaceColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner,
                                    size: 26,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Position QR code within the frame',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'The scanner will automatically detect the code',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Scanner Overlay with Animated Scan Line
class ScannerOverlayPainter extends CustomPainter {
  final double scanArea;
  final Animation<double> animation;

  ScannerOverlayPainter({
    required this.scanArea,
    required this.animation,
  }) : super(repaint: animation);

  static const double _cornerRadius = 35.0;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final halfScanArea = scanArea / 2;

    // Rounded rectangle for the scan area (hole in the overlay)
    final scanRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: scanArea,
        height: scanArea,
      ),
      const Radius.circular(_cornerRadius),
    );

    // Draw dark overlay with rounded rectangular cutout
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final fullScreenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(scanRect);
    final overlayPath = Path.combine(PathOperation.difference, fullScreenPath, holePath);
    canvas.drawPath(overlayPath, overlayPaint);

    // Calculate scan line position
    final topY = centerY - halfScanArea;
    final bottomY = centerY + halfScanArea;
    final scanLineY = topY + (bottomY - topY) * animation.value;

    // Draw gradient scan line (clipped to rounded rect for visual consistency)
    canvas.save();
    canvas.clipRRect(scanRect);
    final scanLineRect = Rect.fromLTWH(
      centerX - halfScanArea,
      scanLineY - 1,
      scanArea,
      2,
    );
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        AppTheme.primaryColor.withOpacity(0.8),
        Colors.transparent,
      ],
    );
    final gradientPaint = Paint()
      ..shader = gradient.createShader(scanLineRect)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - halfScanArea, scanLineY),
      Offset(centerX + halfScanArea, scanLineY),
      gradientPaint,
    );
    canvas.restore();

    // Draw blue border only at the four rounded corners (arcs)
    final borderPaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tl = scanRect.tlRadius;
    final tr = scanRect.trRadius;
    final br = scanRect.brRadius;
    final bl = scanRect.blRadius;

    canvas.drawArc(
      Rect.fromLTWH(scanRect.left, scanRect.top, tl.x * 2, tl.y * 2),
      math.pi,
      math.pi / 2,
      false,
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanRect.right - tr.x * 2, scanRect.top, tr.x * 2, tr.y * 2),
      math.pi * 1.5,
      math.pi / 2,
      false,
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanRect.right - br.x * 2, scanRect.bottom - br.y * 2, br.x * 2, br.y * 2),
      0,
      math.pi / 2,
      false,
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanRect.left, scanRect.bottom - bl.y * 2, bl.x * 2, bl.y * 2),
      math.pi / 2,
      math.pi / 2,
      false,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanArea != scanArea ||
        oldDelegate.animation != animation;
  }
}
