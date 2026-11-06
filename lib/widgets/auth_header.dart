// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';

// =============================================================================
// REUSABLE UI: AUTH HEADER & BRANDING
// =============================================================================
// Header visual untuk halaman Login & Register yang menampilkan branding
// Course Explorer serta lencana identitas mahasiswa.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Brand Logo Icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.auto_stories_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // App Name
        const Text(
          'Course Explorer v2',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle / Tagline
        Text(
          'Platform Pembelajaran & Manajemen Kursus Terintegrasi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 14),

        // Student Info Badge (Worksheet 9 Praktik 1)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: Color(0xFF1D4ED8),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Praktik 1 — Worksheet 9',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Nama: Gede Supadma',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'NIM: 2415051014',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Form Title
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Form Subtitle
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
