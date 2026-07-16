import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../send/send_flow_state.dart';

/// Pay a merchant = the send flow in MoMo Pay code mode
/// (*182*8*1*code#). One screen owns that logic; this route just
/// preselects it.
class MerchantPayScreen extends ConsumerWidget {
  const MerchantPayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendFlowProvider.notifier).setTarget(PayTarget.merchantCode);
      context.pushReplacement('/send');
    });
    return const Scaffold(body: SizedBox.shrink());
  }
}
