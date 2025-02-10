import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:image_picker/image_picker.dart';
import 'package:payment_app/screens/payment.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class PayTab extends StatefulWidget {
  const PayTab({super.key});

  @override
  State<PayTab> createState() => _PayTabState();
}

class _PayTabState extends State<PayTab> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isNavigating = false;

  /// Navigates to the PaymentScreen with the scanned QR data.
  void _navigateToPayment(String qrData) {
    setState(() {
      _isNavigating = true;
    });
    controller?.pauseCamera();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PaymentScreen(qrData: qrData),
      ),
    ).then((_) {
      setState(() {
        _isNavigating = false;
        controller?.resumeCamera();
      });
    });
  }

  /// Displays an error message using a SnackBar.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// Called when the QR view is created.
  void _onQrViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final String scannedText = scanData.code ?? 'Invalid QR Code';
      if (!_isNavigating && scannedText != 'Invalid QR Code') {
        _navigateToPayment(scannedText);
      }
    });
  }

  /// Picks an image from the gallery and scans it for a QR code using ML Kit.
  Future<void> _pickImageAndScanQr() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Create an InputImage for ML Kit from the picked image file.
      final mlkit.InputImage inputImage =
          mlkit.InputImage.fromFilePath(pickedFile.path);

      // Initialize the BarcodeScanner from ML Kit.
      final mlkit.BarcodeScanner barcodeScanner = mlkit.BarcodeScanner();

      try {
        final List<mlkit.Barcode> barcodes =
            await barcodeScanner.processImage(inputImage);
        if (barcodes.isNotEmpty) {
          // Retrieve the first found barcode's raw value.
          final String? qrCode = barcodes.first.rawValue;
          if (qrCode != null && qrCode.isNotEmpty) {
            _navigateToPayment(qrCode);
          } else {
            _showError('No QR code found in the image.');
          }
        } else {
          _showError('No QR code found in the image.');
        }
      } catch (e) {
        _showError('Error scanning image: $e');
      } finally {
        barcodeScanner.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera-based QR scanning view.
        Expanded(
          flex: 5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQrViewCreated,
          ),
        ),
        // Controls: Button to pick an image from the gallery.
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _pickImageAndScanQr,
                icon: const Icon(
                  Icons.image,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              const Text('Scan a QR code from image or camera'),
            ],
          ),
        ),
      ],
    );
  }
}
