// v1.6 - widgets/receipt_capture_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/receipt_service.dart';

class ReceiptCaptureWidget extends StatefulWidget {
  final String? initialReceiptPath;
  final Function(String?) onReceiptChanged;

  const ReceiptCaptureWidget({
    super.key,
    this.initialReceiptPath,
    required this.onReceiptChanged,
  });

  @override
  State<ReceiptCaptureWidget> createState() => _ReceiptCaptureWidgetState();
}

class _ReceiptCaptureWidgetState extends State<ReceiptCaptureWidget> {
  String? _receiptPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _receiptPath = widget.initialReceiptPath;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Comprobante de Pago Nequi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_receiptPath != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '✓ Subido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            
            // Solo botones, sin mostrar imagen
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _takePhoto,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                  label: Text(_isLoading ? 'Capturando...' : 'Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_receiptPath != null)
                  IconButton(
                    onPressed: _isLoading ? null : _removeReceipt,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar comprobante',
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              '💡 Tip: Toma una foto clara del comprobante de transferencia Nequi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoading = true);
    
    try {
      final receiptPath = await ReceiptService.takePhoto();
      if (receiptPath != null) {
        setState(() => _receiptPath = receiptPath);
        widget.onReceiptChanged(receiptPath);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    
    try {
      final receiptPath = await ReceiptService.pickFromGallery();
      if (receiptPath != null) {
        setState(() => _receiptPath = receiptPath);
        widget.onReceiptChanged(receiptPath);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeReceipt() {
    setState(() => _receiptPath = null);
    widget.onReceiptChanged(null);
  }
}

