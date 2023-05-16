import 'package:develop_tool/components/theme_color.dart';
import 'package:flutter/material.dart';


enum ToastPosition {
  top,
  center,
  bottom
}

class MMToaster {

  static OverlayEntry? _entry;

  static void showToast(BuildContext context, String text, [Duration duration = const Duration(milliseconds: 2000), ToastPosition position = ToastPosition.bottom]) {
    // 先移除上次的
    dismissTip();
    // 创建 entry
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return MMToastView(text: text, position: position, duration: duration, context: context, dismiss: () {
        MMToaster.dismissTip();
      });
    });
    _entry = entry;

    Overlay.of(context)?.insert(entry);
  }

  static void dismissTip() {
      _entry?.remove();
      _entry = null;
  }
}

class MMToastView extends StatefulWidget {
  final String text;
  final ToastPosition position;
  final Duration duration;
  final VoidCallback dismiss;
  final BuildContext context;
  const MMToastView({Key? key, required this.text, required this.position,
    required this.duration, required this.context, required this.dismiss}) : super(key: key);

  @override
  State<MMToastView> createState() => _MMToastViewState();
}

class _MMToastViewState extends State<MMToastView> with SingleTickerProviderStateMixin {

  AnimationController? _animationController;

  late Animation<double> _alphaAnimation;

  MainAxisAlignment toastAlignment = MainAxisAlignment.center;
  double topOffset = 0;
  double bottomOffset = 0;

  @override
  void initState() {
    super.initState();
    //利用 Interval 的 begin 和 end 可以控制动画开始时机，就不用创建两个controller了。动画 reverse 的时候也方便。
    AnimationController animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _alphaAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.2, curve: Curves.easeInOut)));
    _animationController = animationController;
    _animationController?.forward(from: 0);
    Future.delayed(widget.duration, () {
        _dismiss();
    });
    if (widget.position == ToastPosition.top) {
      toastAlignment = MainAxisAlignment.start;
      topOffset = MediaQuery.of(widget.context).viewInsets.top + 50;
    } else if (widget.position == ToastPosition.center) {
      toastAlignment = MainAxisAlignment.center;
    } else {
      toastAlignment = MainAxisAlignment.end;
      bottomOffset = MediaQuery.of(widget.context).viewInsets.bottom + 50;
    }
  }

  void _dismiss() {
    _animationController?.reverse();
    widget.dismiss();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _animationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: toastAlignment,
        children: [
          FadeTransition(
            opacity: _alphaAnimation,
            child: Container(
              margin: EdgeInsets.only(top: topOffset, bottom: bottomOffset),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: MMThemeColors.shared.grey_color
              ),
              child: Text(widget.text, style: TextStyle(color: MMThemeColors.shared.white_text_color),),
            ),
          ),
        ],
      ),
    );
  }
}
