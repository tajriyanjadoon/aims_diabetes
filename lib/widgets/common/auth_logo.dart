import 'package:flutter/material.dart';

import 'brand_header.dart';

/// Backward-compatible alias that delegates to [BrandHeader].
///
/// New screens should use [BrandHeader] directly.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  static double heightFor(Size screen) => BrandHeader.iconSizeFor(screen);

  @override
  Widget build(BuildContext context) => const BrandHeader();
}
