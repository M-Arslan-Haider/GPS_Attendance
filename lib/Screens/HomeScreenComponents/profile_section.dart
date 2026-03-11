// import 'package:flutter/material.dart';
//
// import '../../Database/util.dart';
//
// /// Profile section widget.
// class ProfileSection extends StatefulWidget {
//   const ProfileSection({super.key});
//
//   @override
//   State<ProfileSection> createState() => _ProfileSectionState();
// }
//
// class _ProfileSectionState extends State<ProfileSection> {
//
//   // ── White & Blue Theme ─────────────────────────────────────────────────────
//   static const Color _accentBlue    = Color(0xFF1A5CFF);
//   static const Color _accentLight   = Color(0xFFE6EDFF);
//   static const Color _textPrimary   = Color(0xFF0A1931);
//   static const Color _textSecondary = Color(0xFF6B7FA8);
//   static const Color _border        = Color(0xFFD0DBEE);
//   // ──────────────────────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   Future<void> _load() async {
//     await loadEmployeeData();
//     if (mounted) setState(() {});
//   }
//
//   /// Returns up to 2 initials from the employee name
//   String _getInitials(String name) {
//     final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String name        = emp_name.isNotEmpty ? emp_name : 'Employee';
//     final String designation = emp_job.isNotEmpty ? emp_job : 'Staff';
//     final String id          = emp_id.isNotEmpty ? emp_id : '--';
//     final String initials    = _getInitials(name);
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: _border, width: 1.2),
//           boxShadow: [
//             BoxShadow(
//               color: _accentBlue.withOpacity(0.08),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // ── Left: text info ──────────────────────────────────────────
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // App name badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _accentLight,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: _accentBlue.withOpacity(0.25)),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 6,
//                           height: 6,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _accentBlue,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         const Text(
//                           'Attendance System',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: _accentBlue,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Employee name
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: _textPrimary,
//                       letterSpacing: -0.3,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 5),
//
//                   // ID row
//                   Row(
//                     children: [
//                       const Icon(Icons.badge_outlined, size: 13, color: _textSecondary),
//                       const SizedBox(width: 4),
//                       Text(
//                         'ID: $id',
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: _textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//
//                   // Designation row
//                   Row(
//                     children: [
//                       const Icon(Icons.work_outline_rounded, size: 13, color: _textSecondary),
//                       const SizedBox(width: 4),
//                       Flexible(
//                         child: Text(
//                           designation,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: _textSecondary,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(width: 12),
//
//             // ── Right: circular avatar with initials ─────────────────────
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: _accentBlue,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: _accentBlue.withOpacity(0.30),
//                     blurRadius: 14,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Text(
//                   initials,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../Database/util.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {

  static const Color _accentBlue    = Color(0xFF4354E8);
  static const Color _accentLight   = Color(0xFFEBEEFD);
  static const Color _textPrimary   = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await loadEmployeeData();
    if (mounted) setState(() {});
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              _accentBlue,
              const Color(0xFF6270F0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Decorative background circle ─────────────────────────────
            Positioned(
              top: -20,
              right: 80,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // ── Left: Info ────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'GPS Attendance System',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Name
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // ID row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ID: $id',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Designation row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.work_outline_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                designation,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.85),
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

                  const SizedBox(width: 16),

                  // ── Right: Avatar ─────────────────────────────────────
                  Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Online indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}