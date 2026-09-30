import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Строка ввода «название — число — единица». Пустое поле означает
/// «такого угодья/продукции нет», а не ошибку.
class LabeledNumberField extends StatefulWidget {
  const LabeledNumberField({
    super.key,
    required this.label,
    required this.unit,
    required this.initialValue,
    required this.onChanged,
    this.warning,
  });

  final String label;
  final String unit;
  final double? initialValue;
  final ValueChanged<double?> onChanged;

  /// Текст предупреждения о неправдоподобном значении — поле
  /// подсвечивается, но ввод не блокируется.
  final String? warning;

  @override
  State<LabeledNumberField> createState() => _LabeledNumberFieldState();
}

class _LabeledNumberFieldState extends State<LabeledNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue == null ? '' : _format(widget.initialValue!),
    );
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  static String _format(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toString();

  @override
  Widget build(BuildContext context) {
    final hasWarning = widget.warning != null;
    final borderColor = hasWarning
        ? AppColors.accent
        : _focused
            ? AppColors.heading
            : AppColors.divider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: _focused || hasWarning ? 2 : 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              SizedBox(
                width: 96,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '—',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                  onChanged: (raw) {
                    final normalized = raw.replaceAll(',', '.');
                    widget.onChanged(double.tryParse(normalized));
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  widget.unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (hasWarning)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Text(
              widget.warning!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.accent,
                    height: 1.4,
                  ),
            ),
          ),
      ],
    );
  }
}
