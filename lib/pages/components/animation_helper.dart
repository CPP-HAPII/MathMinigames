import 'package:flutter/material.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({Key? key}) : super(key: key);

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  OverlayEntry? entry;

  void alt() {
    WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        alt();
      },
      child: const Text('Press Me'),
    );
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  void showOverlay() {
    entry = OverlayEntry(
      builder: (context) => OverlayBanner(
        onBannerDismissed: () {
          hideOverlay();
        },
      ),
    );

    final overlay = Overlay.of(context)!;
    overlay.insert(entry!);
  }
}

class OverlayBanner extends StatefulWidget {
  const OverlayBanner({super.key, this.onBannerDismissed});

  final VoidCallback? onBannerDismissed;

  @override
  State<OverlayBanner> createState() => _OverlayBannerState();
}

class _OverlayBannerState extends State<OverlayBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const Curve curve = Curves.easeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _playAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, child) {
        final double animationValue = curve.transform(_controller.value);
        return FractionalTranslation(
          translation: Offset(0, -(1 - animationValue)),
          child: child,
        );
      },
      animation: _controller,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("/images/confetti_loop.gif"),
              fit: BoxFit.fitHeight
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playAnimation() async {
    // fist will show banner with forward.
    await _controller.forward();
    // wait for 3 second and then play reverse animation to hide the banner
    // Duration can be passed as parameter, banner will wait this much and then will dismiss
    await Future<void>.delayed(const Duration(seconds: 1));
    await _controller.reverse(from: 1);
    // call onDismissedCallback so OverlayWidget can remove and clear the OverlayEntry.
    widget.onBannerDismissed?.call();
  }
}