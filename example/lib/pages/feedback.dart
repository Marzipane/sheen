import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../demo.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _done = 0;

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Feedback',
    children: [
      const Demo(
        title: 'Progress',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheenProgressBar(value: .62, semanticLabel: 'Uploading'),
            SizedBox(height: 14),
            SheenProgressBar(semanticLabel: 'Loading'),
            SizedBox(height: 14),
            Gap(
              children: [
                SheenProgressRing(value: .3),
                SheenProgressRing(value: .75, size: 40, stroke: 4),
                SheenProgressRing(),
                SheenSpinner(color: SheenColors.defaultLightAccent),
                SheenProgressCapsule(label: 'Checking live prices'),
              ],
            ),
          ],
        ),
      ),
      const Demo(
        title: 'Loading placeholders',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheenSkeleton(height: 120, radius: 20),
            SizedBox(height: 10),
            SheenSkeleton(width: 180, height: 16),
            SizedBox(height: 8),
            SheenSkeleton(width: 120, height: 14),
          ],
        ),
      ),
      Demo(
        title: 'Banners and notices',
        child: Column(
          children: [
            SheenActionBanner(
              icon: SheenIcons.refresh,
              tone: SheenTone.warning,
              title: 'Prices changed',
              message: '3 stays are now cheaper.',
              actionLabel: 'Show',
              onAction: () {},
            ),
            const SizedBox(height: 10),
            const SheenStatusNotice(message: 'Payments are temporarily unavailable.'),
          ],
        ),
      ),
      const Demo(
        title: 'Status pills and countdown',
        child: Gap(
          children: [
            SheenStatusPill(label: 'Confirmed', tone: SheenTone.success, icon: SheenIcons.check),
            SheenStatusPill(label: 'Pending', tone: SheenTone.warning),
            SheenStatusPill(label: 'Cancelled', tone: SheenTone.danger),
            SheenCountdownPill(remaining: Duration(minutes: 12, seconds: 48), semanticLabel: 'Held for'),
            SheenCountdownPill(remaining: Duration(minutes: 1, seconds: 45), semanticLabel: 'Held for'),
          ],
        ),
      ),
      Demo(
        title: 'Badges',
        child: Gap(
          spacing: 18,
          children: [
            SheenBadge(
              count: 3,
              child: SheenIconButton(icon: SheenIcons.bell, semanticLabel: 'Notifications', onTap: () {}),
            ),
            SheenBadge(
              count: 120,
              child: SheenIconButton(icon: SheenIcons.chat, semanticLabel: 'Messages', onTap: () {}),
            ),
            SheenBadge.dot(
              child: SheenIconButton(icon: SheenIcons.mail, semanticLabel: 'Mail', onTap: () {}),
            ),
          ],
        ),
      ),
      const Demo(
        title: 'Empty state',
        child: SheenEmptyState(
          icon: SheenIcons.search,
          title: 'No results',
          message: 'Try fewer filters or another date.',
        ),
      ),
      Demo(
        title: 'Success',
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Center(
                child: SheenSuccessCheck(key: ValueKey(_done), semanticLabel: 'Done'),
              ),
            ),
            SheenTextLink(label: 'Play again', onPressed: () => setState(() => _done++)),
          ],
        ),
      ),
    ],
  );
}
