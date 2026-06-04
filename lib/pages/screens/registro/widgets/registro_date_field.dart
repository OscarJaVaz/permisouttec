import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';

class RegistroDateField extends StatelessWidget {
  const RegistroDateField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? DateFormat.yMMMMd('es_MX').format(value!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: LoginColors.outline,
            ),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: LoginColors.outline.withValues(alpha: 0.7),
              ),
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: LoginColors.outline,
                size: 22,
              ),
              suffixIcon: const Icon(
                Icons.expand_more,
                color: LoginColors.outline,
              ),
              filled: true,
              fillColor: LoginColors.paperWhite,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: LoginColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: LoginColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: LoginColors.deepEmerald,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              display ?? hint,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: display != null
                    ? LoginColors.onSurface
                    : LoginColors.outline.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
