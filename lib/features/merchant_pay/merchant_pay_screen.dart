import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Merchant payment is the same universal route picker — typing a 5–6
/// digit code detects MoMo Pay automatically.
class MerchantPayScreen extends StatelessWidget {
  const MerchantPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushReplacement('/send');
    });
    return const Scaffold(body: SizedBox.shrink());
  }
}
