import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Represents why a scan did not produce text.
enum DocumentScannerError {
  permissionDenied,
  unsupported,
  failed,
}

class DocumentScannerException implements Exception {
  DocumentScannerException(this.reason, [this.detail]);
  final DocumentScannerError reason;
  final Object? detail;

  @override
  String toString() =>
      'DocumentScannerException($reason${detail == null ? '' : ': $detail'})';
}

/// Wraps `cunning_document_scanner` (VNDocumentCameraViewController on iOS,
/// MLKit Document Scanner on Android) + `google_mlkit_text_recognition` OCR.
///
/// Mirrors iOS `MainChatViewController.didSelectScanText` flow:
/// open scanner → OCR each page → concatenate → return trimmed text.
class DocumentScannerService {
  DocumentScannerService._();

  /// Only Android + iOS support a native document scanner UI.
  static bool get isSupported => Platform.isIOS || Platform.isAndroid;

  /// Opens the native document scanner and runs OCR on the captured pages.
  ///
  /// Returns the extracted text, or `null` when the user cancels.
  /// Throws [DocumentScannerException] on permission denial / platform errors.
  static Future<String?> scanAndRecognize() async {
    if (!isSupported) {
      throw DocumentScannerException(DocumentScannerError.unsupported);
    }

    List<String>? picturePaths;
    try {
      picturePaths = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: false,
      );
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('permission')) {
        throw DocumentScannerException(
          DocumentScannerError.permissionDenied,
          e,
        );
      }
      throw DocumentScannerException(DocumentScannerError.failed, e);
    }

    if (picturePaths == null || picturePaths.isEmpty) {
      return null;
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final buffer = StringBuffer();
    try {
      for (final path in picturePaths) {
        final input = InputImage.fromFilePath(path);
        final result = await recognizer.processImage(input);
        final pageText = result.text.trim();
        if (pageText.isNotEmpty) {
          buffer.write(pageText);
          buffer.write('\n\n');
        }
      }
    } catch (e) {
      throw DocumentScannerException(DocumentScannerError.failed, e);
    } finally {
      await recognizer.close();
    }

    final combined = buffer.toString().trim();
    return combined.isEmpty ? null : combined;
  }
}
