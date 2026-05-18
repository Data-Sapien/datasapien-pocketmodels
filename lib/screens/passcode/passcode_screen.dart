import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../services/passcode_service.dart';

/// Passcode entry mode: verify (unlock) or set (create then confirm).
enum PasscodeMode {
  verify,
  set,
}

/// Full passcode screen: 6-dot display and numeric keypad.
/// Supports verify (unlock) and set (create/confirm) modes.
class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({
    super.key,
    required this.mode,
    required this.onSuccess,
    this.onCancel,
    this.showCancelButton = false,
  });

  final PasscodeMode mode;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  String _entered = '';
  String? _firstPasscode;
  String? _errorMessage;
  bool _isVerifying = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static int get _length => PasscodeService.passcodeLength;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.mode == PasscodeMode.verify) return l10n.passcode_enter;
    if (_firstPasscode == null) return l10n.passcode_enter_new;
    return l10n.passcode_confirm_new;
  }

  void _onDigit(String digit) {
    if (_isVerifying || _entered.length >= _length) return;
    HapticFeedback.lightImpact();
    setState(() {
      _entered += digit;
      _errorMessage = null;
      if (_entered.length == _length) _handleComplete();
    });
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _handleComplete() async {
    if (widget.mode == PasscodeMode.verify) {
      await _handleVerify();
      return;
    }
    if (_firstPasscode == null) {
      setState(() {
        _firstPasscode = _entered;
        _entered = '';
        _errorMessage = null;
      });
      return;
    }
    if (_entered == _firstPasscode) {
      await PasscodeService.setPasscode(_entered);
      if (!mounted) return;
      widget.onSuccess();
    } else {
      _showError(AppLocalizations.of(context)!.passcode_mismatch);
    }
  }

  Future<void> _handleVerify() async {
    setState(() => _isVerifying = true);
    final ok = await PasscodeService.verifyPasscode(_entered);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (ok) {
      widget.onSuccess();
    } else {
      _showError(AppLocalizations.of(context)!.passcode_incorrect);
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _errorMessage = message;
      _entered = '';
    });
    _shakeDots();
  }

  void _shakeDots() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.primaryBackground(context),
        appBar: widget.showCancelButton
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close, color: AppColor.textPrimary(context)),
                  onPressed: widget.onCancel,
                ),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                _title(context),
                style: AppFont.h2.copyWith(color: AppColor.textPrimary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildDots(context),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _errorMessage!,
                    style: AppFont.body.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const Spacer(),
              _buildKeypad(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots(BuildContext context) {
    final dots = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_length, (i) {
        final filled = i < _entered.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? AppColor.primaryTint
                : AppColor.textSecondary(context).withValues(alpha: 0.3),
          ),
        );
      }),
    );
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: dots,
    );
  }

  Widget _buildKeypad(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'delete'],
    ];
    const spacing = 30.0;
    const btnSize = 75.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((item) {
                if (item.isEmpty) {
                  return const SizedBox(width: btnSize + spacing);
                }
                if (item == 'delete') {
                  return _keypadButton(
                    context: context,
                    size: btnSize,
                    spacing: spacing,
                    icon: Icons.backspace_outlined,
                    onTap: _onDelete,
                  );
                }
                return _keypadButton(
                  context: context,
                  size: btnSize,
                  spacing: spacing,
                  label: item,
                  onTap: () => _onDigit(item),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _keypadButton({
    required BuildContext context,
    required double size,
    required double spacing,
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
      child: Material(
        color: AppColor.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: label != null
                  ? Text(
                      label,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                        color: AppColor.textPrimary(context),
                      ),
                    )
                  : Icon(
                      icon,
                      size: 24,
                      color: AppColor.textSecondary(context).withValues(alpha: 0.8),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
