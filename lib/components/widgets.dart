import 'package:flutter/material.dart';

const double _buttonHeight = 48;
const double _buttonRadius = 6;

/// Full width filled button.
class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.title,
    this.bgColor,
    this.isEnable = true,
    this.onTap,
  });

  final String title;
  final Color? bgColor;
  final bool isEnable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = bgColor ?? Theme.of(context).colorScheme.primary;
    return FilledButton(
      onPressed: isEnable ? onTap : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(_buttonHeight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius)),
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.3),
        disabledForegroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: Text(title),
    );
  }
}

/// Full width button with a light background, used for secondary actions.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.title,
    this.bgColor,
    this.titleColor,
    this.onTap,
  });

  final String title;
  final Color? bgColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Theme.of(context).colorScheme.primary;
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(_buttonHeight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius)),
        backgroundColor: bgColor ?? themeColor.withValues(alpha: 0.1),
        foregroundColor: titleColor ?? themeColor,
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: Text(title),
    );
  }
}

/// Dialog showing a long text with a single action button.
/// The dialog stays open after the action, close it with the close icon or by tapping outside.
class ScrollableTextDialog extends StatelessWidget {
  const ScrollableTextDialog({
    super.key,
    required this.title,
    required this.contentText,
    required this.submitText,
    this.submitBgColor,
    this.onSubmitClick,
  });

  final String title;
  final String contentText;
  final String submitText;
  final Color? submitBgColor;
  final VoidCallback? onSubmitClick;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4),
                child: SingleChildScrollView(
                  child: SelectableText(
                    contentText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: MainButton(
                title: submitText,
                bgColor: submitBgColor,
                onTap: onSubmitClick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show a short message in the center of the screen.
void showCenterToast({
  required String text,
  required BuildContext context,
  Duration duration = const Duration(seconds: 2),
}) {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final OverlayEntry entry = OverlayEntry(
    builder: (context) => Center(
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Material(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(duration, () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}
