import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';

/// Legend / filter pill (Approved, Pending, Rejected ...). API unchanged.
/// Also used by the Capex screens, so they pick up the new look too.
class TitleWidget extends StatefulWidget {
  String selectedTitle = "";
  final String title;
  final Color color;
  final VoidCallback? onTap;

  TitleWidget({
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  _TitleWidgetState createState() => _TitleWidgetState();
}

class _TitleWidgetState extends State<TitleWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.title,
              style: TextStyle(
                color: widget.color == Colors.orange
                    ? const Color(0xFFB45309)
                    : widget.color,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
