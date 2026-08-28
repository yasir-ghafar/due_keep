import 'package:flutter/material.dart';

import '../../core/constants/brand.dart';
import '../../core/extensions/build_context_x.dart';
import '../../core/notifications/notification_permission.dart';
import '../../core/theme/ledger_motion.dart';
import '../../data/datasources/onboarding_store.dart';

class OnboardingSlide {
  const OnboardingSlide({required this.headline, required this.body});

  final String headline;
  final String body;
}

/// Three screens: problem, method, privacy. Last screen asks for alerts.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.store,
    required this.onFinished,
    this.permission = const NotificationPermission(),
  });

  static const slides = [
    OnboardingSlide(
      headline: 'Renewals hide until they cost you.',
      body:
          'Streaming, insurance, the laptop warranty. They sit in different inboxes until the charge or the expiry.',
    ),
    OnboardingSlide(
      headline: 'Add once. See what’s next. Get reminded in time.',
      body:
          'A timeline of what is due, soonest first. A reminder before money leaves or coverage ends.',
    ),
    OnboardingSlide(
      headline: 'Stays on this phone. No bank login.',
      body:
          'A private vault. You type it in — or scan a bill. Nothing leaves the device in v1.',
    ),
  ];

  final OnboardingStore store;
  final VoidCallback onFinished;
  final NotificationPermission permission;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;
  bool _busy = false;

  bool get _isLast => _index == OnboardingPage.slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    await _controller.animateToPage(
      index,
      duration: LedgerMotion.duration,
      curve: LedgerMotion.curve,
    );
  }

  Future<void> _continue() async {
    if (_isLast) return;
    await _goTo(_index + 1);
  }

  Future<void> _finish({required bool requestAlerts}) async {
    if (_busy) return;
    setState(() => _busy = true);
    if (requestAlerts) {
      await widget.permission.request();
    }
    await widget.store.markComplete();
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Brand.name.toUpperCase(),
                style: texts.labelSmall?.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.68,
                  fontWeight: FontWeight.w600,
                  color: ledger.pine,
                  height: 1.2,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: OnboardingPage.slides.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) {
                    final slide = OnboardingPage.slides[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.headline,
                            style: texts.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.96,
                              height: 1.15,
                              color: ledger.ink,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            slide.body,
                            style: texts.bodySmall?.copyWith(
                              fontSize: 13,
                              height: 1.45,
                              color: ledger.mute,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _PageDots(
                count: OnboardingPage.slides.length,
                index: _index,
              ),
              const SizedBox(height: 16),
              if (_isLast) ...[
                _PrimaryButton(
                  label: 'Allow notifications',
                  onPressed: _busy ? null : () => _finish(requestAlerts: true),
                ),
                _GhostButton(
                  label: 'Not now',
                  onPressed: _busy ? null : () => _finish(requestAlerts: false),
                ),
              ] else
                _PrimaryButton(
                  label: 'Continue',
                  onPressed: _busy ? null : _continue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          AnimatedContainer(
            duration: LedgerMotion.duration,
            curve: LedgerMotion.curve,
            width: i == index ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index ? ledger.pine : ledger.line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.16,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: ledger.mute,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
