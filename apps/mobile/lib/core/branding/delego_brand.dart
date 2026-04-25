import 'package:flutter/material.dart';

/// User-facing product name (launcher, MaterialApp, headers).
const String kAppDisplayName = 'Delego';

/// Bundled mark used for login header and marketing surfaces.
const String kDelegoIconAsset = 'assets/branding/app_icon.png';

/// Rounded square logo (matches generated launcher art).
class DelegoLogoBadge extends StatelessWidget {
  const DelegoLogoBadge({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(size * 0.27);
    return ClipRRect(
      borderRadius: r,
      child: Image.asset(
        kDelegoIconAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
