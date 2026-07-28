import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class CustomOverlayLoader {
  /// Show loader
  static void show(BuildContext context) {
    try {
      if (Overlay.maybeOf(context) != null) {
        Loader.show(
          context,
          isSafeAreaOverlay: false,
          isBottomBarOverlay: false,
          overlayFromBottom: 0,
          overlayColor: Colors.black26,
          progressIndicator: const CircularProgressIndicator(
            backgroundColor: Colors.red,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          themeData: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
          ),
        );
      }
    } catch (e) {
      debugPrint("CustomOverlayLoader error: $e");
    }
  }

  /// Hide loader
  static void hide() {
    try {
      Loader.hide();
    } catch (_) {}
  }
}
