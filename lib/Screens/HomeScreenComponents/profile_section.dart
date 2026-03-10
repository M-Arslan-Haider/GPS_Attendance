import 'package:flutter/material.dart';

import '../../Database/util.dart';

/// Profile section widget.
class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {

  // ── White & Blue Theme ─────────────────────────────────────────────────────
  static const Color _accentBlue    = Color(0xFF1A5CFF);
  static const Color _accentLight   = Color(0xFFE6EDFF);
  static const Color _textPrimary   = Color(0xFF0A1931);
  static const Color _textSecondary = Color(0xFF6B7FA8);
  static const Color _border        = Color(0xFFD0DBEE);
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await loadEmployeeData();
    if (mounted) setState(() {});
  }

  /// Returns up to 2 initials from the employee name
  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String name        = emp_name.isNotEmpty ? emp_name : 'Employee';
    final String designation = emp_job.isNotEmpty ? emp_job : 'Staff';
    final String id          = emp_id.isNotEmpty ? emp_id : '--';
    final String initials    = _getInitials(name);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Left: text info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App name badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentBlue.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accentBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Attendance System',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _accentBlue,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Employee name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // ID row
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, size: 13, color: _textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'ID: $id',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Designation row
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, size: 13, color: _textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          designation,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Right: circular avatar with initials ─────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _accentBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accentBlue.withOpacity(0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}