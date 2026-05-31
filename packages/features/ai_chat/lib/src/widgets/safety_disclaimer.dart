import 'package:flutter/material.dart';
import 'package:fnx_core_tokens/fnx_core_tokens.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

/// Matches investment-themed wording in either Russian or English.
///
/// Per PRD F-07, whenever the AI mentions investing/stocks we must surface a
/// reminder that it is not a licensed financial advisor.
final RegExp kInvestmentMentionPattern = RegExp(
  r'инвест|акци|invest|stock',
  caseSensitive: false,
);

/// Returns whether [text] mentions investing/stocks and therefore needs the
/// [SafetyDisclaimer].
bool mentionsInvestment(String text) =>
    kInvestmentMentionPattern.hasMatch(text);

/// Small inline notice reminding the user the AI is not a financial advisor.
class SafetyDisclaimer extends StatelessWidget {
  /// Default constructor.
  const SafetyDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    return Container(
      key: const Key('ai_chat_safety_disclaimer'),
      margin: const EdgeInsets.only(top: FnxSpacing.x2),
      padding: const EdgeInsets.all(FnxSpacing.x3),
      decoration: BoxDecoration(
        color: colors.warningSubtle,
        borderRadius: BorderRadius.circular(FnxTokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 18, color: colors.warning),
          const SizedBox(width: FnxSpacing.x2),
          Expanded(
            child: Text(
              'Это не индивидуальная инвестиционная рекомендация. '
              'FinNex предоставляет информацию для справки, а не услуги '
              'финансового советника.',
              style: typo.caption.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
