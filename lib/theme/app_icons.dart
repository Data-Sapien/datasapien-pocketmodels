import 'package:flutter/widgets.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

/// Centralized app icon mapping backed by SF Symbols.
class AppIcons {
  AppIcons._();

  static const IconData sparkles = SFIcons.sf_sparkles;
  static const IconData checkmark = SFIcons.sf_checkmark;
  static const IconData xmark = SFIcons.sf_xmark;
  static const IconData search = SFIcons.sf_magnifyingglass;
  static const IconData trash = SFIcons.sf_trash;
  static const IconData chevronRight = SFIcons.sf_chevron_right;
  static const IconData arrowLeft = SFIcons.sf_arrow_left;
  static const IconData arrowDownCircle = SFIcons.sf_arrow_down_circle;
  static const IconData checkmarkCircleFill = SFIcons.sf_checkmark_circle_fill;
  static const IconData xmarkCircleFill = SFIcons.sf_xmark_circle_fill;
  static const IconData plusCircleFill = SFIcons.sf_plus_circle_fill;
  static const IconData brainHeadProfile = SFIcons.sf_brain_head_profile;
  // iOS uses `cube.box.fill`; closest available glyph in flutter_sficon 1.3.0.
  static const IconData cubeBoxFill = SFIcons.sf_shippingbox_fill;
  static const IconData cubeFill = cubeBoxFill;
  static const IconData lockFill = SFIcons.sf_lock_fill;
  static const IconData checkmarkSealFill = SFIcons.sf_checkmark_seal_fill;
  static const IconData exclamationmarkTriangleFill =
      SFIcons.sf_exclamationmark_triangle_fill;
  static const IconData heartFill = SFIcons.sf_heart_fill;
  static const IconData documentOnDocument = SFIcons.sf_document_on_document;
  static const IconData zipperPage = SFIcons.sf_zipper_page;
  static const IconData arrowDownDocumentFill = SFIcons.sf_arrow_down_document_fill;
}
