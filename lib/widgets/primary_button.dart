// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';

// =============================================================================
// REUSABLE UI: PRIMARY ACTION BUTTON
// =============================================================================
// Tombol aksi utama dengan touch target optimal (50px), animasi loading terintegrasi,
// dan visual state (active, disabled, loading).
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 50.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? const Color(0xFF1E40AF); // Professional Navy Blue
    final effectiveTextColor = textColor ?? Colors.white;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBgColor.withValues(alpha: 0.6),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.8),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Memproses...',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: effectiveTextColor),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
