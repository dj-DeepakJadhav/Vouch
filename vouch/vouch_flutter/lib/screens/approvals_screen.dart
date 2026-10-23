import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';
import '../logic/approvals_controller.dart';
import '../logic/household_controller.dart';
import '../widgets/approval_card.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApprovalsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final household = context.watch<HouseholdController>().overview;
    final memberNames = {
      for (final m in household?.members ?? [])
        if (m.id != null) m.id!: m.displayName,
    };

    return Consumer<ApprovalsController>(
      builder: (context, controller, _) {
        final pending = controller.approvals
            .where((a) => a.status == ApprovalStatus.pending)
            .toList();
        final decided = controller.approvals
            .where((a) => a.status != ApprovalStatus.pending)
            .toList();

        Widget card(Approval a, int i) => FadeSlideIn(
          key: ValueKey('approval-${a.id}'),
          index: i,
          child: ApprovalCard(
            approval: a,
            memberName: a.memberId != null ? memberNames[a.memberId] : null,
            confidence: a.speakerConfidence,
            onApprove: () => decideAndReport(context, controller, a.id!, true),
            onDeny: () => decideAndReport(context, controller, a.id!, false),
          ),
        );

        return VPage(
          maxWidth: 720,
          onRefresh: controller.load,
          children: [
            const FadeSlideIn(
              child: VPageHeader(
                title: 'Approvals',
                subtitle:
                    'Requests that need the owner wait here until you decide. '
                    'Alexa holds the command, and nothing runs without you.',
              ),
            ),
            if (controller.loading)
              const VListSkeleton(rows: 2)
            else if (controller.approvals.isEmpty)
              const VSurface(
                child: VEmptyState(
                  icon: VIcons.inbox,
                  title: 'Nothing waiting for you',
                  body:
                      'When someone asks for something that needs your approval, '
                      "it shows up here with who said it and what they asked.",
                ),
              )
            else ...[
              VSectionHeader('Waiting', count: pending.length),
              if (pending.isEmpty)
                const VSurface(
                  key: Key('pending-empty'),
                  child: VEmptyState(
                    icon: VIcons.inbox,
                    title: 'Nothing waiting for you',
                    body: 'New requests that need your approval appear here.',
                  ),
                )
              else
                for (var i = 0; i < pending.length; i++) card(pending[i], i),
              if (decided.isNotEmpty) ...[
                const SizedBox(height: VSpace.s6),
                VSectionHeader('Decided', count: decided.length),
                for (var i = 0; i < decided.length; i++)
                  card(decided[i], pending.length + i),
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Shared by the Approvals tab and the Alexa tab's inline owner's-phone
/// card: decide through [ApprovalsController] and show any failure as a
/// short snackbar.
Future<void> decideAndReport(
  BuildContext context,
  ApprovalsController controller,
  int approvalId,
  bool approve,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final error = await controller.decide(approvalId, approve);
  if (error != null) {
    messenger?.showSnackBar(SnackBar(content: Text(error)));
  }
}
