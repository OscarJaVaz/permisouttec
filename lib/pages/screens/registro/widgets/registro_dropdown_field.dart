import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';

class RegistroDropdownField extends StatelessWidget {
  const RegistroDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
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
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: LoginColors.outline),
          style: GoogleFonts.inter(fontSize: 16, color: LoginColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: LoginColors.outline.withValues(alpha: 0.7),
            ),
            prefixIcon: const Icon(Icons.badge_outlined, color: LoginColors.outline, size: 22),
            filled: true,
            fillColor: LoginColors.paperWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              borderSide: const BorderSide(color: LoginColors.deepEmerald, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
