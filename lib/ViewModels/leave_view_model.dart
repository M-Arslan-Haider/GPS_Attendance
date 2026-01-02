
// leave_view_model.dart (اپ ڈیٹ شدہ)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/leave_model.dart';
import '../Repositories/leave_repository.dart';


class LeaveViewModel extends GetxController {
  // Reactive variables
  var isLoading = false.obs;
  var myLeaves = <LeaveModel>[].obs;
  var pendingLeaves = <LeaveModel>[].obs;
  var allLeaves = <LeaveModel>[].obs;

  // Selected leave for viewing/editing
  var selectedLeave = LeaveModel(
    bookerId: '',
    bookerName: '',
    leaveType: '',
    startDate: '',
    endDate: '',
    totalDays: 0,
    isHalfDay: false,
    reason: '',
  ).obs;

  final repo = LeaveRepository();

  // ==================== CRUD Operations ====================

  // ✅ Submit new leave application
  Future<bool> submitLeave(LeaveModel model) async {
    try {
      isLoading.value = true;
      final result = await repo.submitLeave(model);

      if (result) {
        // Refresh leaves list
        await getMyLeaves(model.bookerId);

        Get.snackbar(
          "کامیابی",
          "چھٹی کی درخواست کامیابی سے جمع ہوگئی",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return true;
      } else {
        Get.snackbar(
          "غلطی",
          "چھٹی جمع کرانے میں ناکامی",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "غلطی",
        "چھٹی جمع کرانے میں خرابی: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Get leaves by booker ID
  Future<void> getMyLeaves(String bookerId) async {
    try {
      isLoading.value = true;
      final leaves = await repo.getMyLeaves(bookerId);

      // Convert Map to LeaveModel objects
      myLeaves.value = leaves.map((map) => LeaveModel.fromMap(map)).toList();

      // Sort by date (newest first)
      sortLeavesByDate();
    } catch (e) {
      Get.snackbar(
        "غلطی",
        "چھٹیوں کی فہرست لانے میں خرابی: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Sync pending leaves with server
  Future<void> syncPendingLeaves() async {
    try {
      isLoading.value = true;

      Get.snackbar(
        "سینک کرنا",
        "زیر التواء چھٹیوں کو سرور پر بھیجا جارہا ہے...",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      await repo.syncPendingLeaves();

      // Refresh leaves if we have any user selected
      if (myLeaves.isNotEmpty) {
        final bookerId = myLeaves.first.bookerId;
        await getMyLeaves(bookerId);
      }

      Get.snackbar(
        "کامیابی",
        "تمام چھٹیاں کامیابی سے سرور پر بھیج دی گئیں",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        "غلطی",
        "چھٹیاں سینک کرنے میں خرابی: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Filtering & Sorting ====================

  // ✅ Sort leaves by date (newest first)
  void sortLeavesByDate() {
    myLeaves.sort((a, b) {
      try {
        final dateA = DateTime.tryParse(a.startDate) ?? DateTime.now();
        final dateB = DateTime.tryParse(b.startDate) ?? DateTime.now();
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
  }

  // ✅ Sort leaves by status
  void sortLeavesByStatus() {
    myLeaves.sort((a, b) {
      final statusOrder = {'pending': 0, 'approved': 1, 'rejected': 2};
      final orderA = statusOrder[a.status?.toLowerCase() ?? 'pending'] ?? 3;
      final orderB = statusOrder[b.status?.toLowerCase() ?? 'pending'] ?? 3;
      return orderA.compareTo(orderB);
    });
  }

  // ✅ Filter leaves by status
  List<LeaveModel> filterLeavesByStatus(String status) {
    return myLeaves.where((leave) =>
    (leave.status ?? '').toLowerCase() == status.toLowerCase()).toList();
  }

  // ✅ Filter leaves by type
  List<LeaveModel> filterLeavesByType(String type) {
    return myLeaves.where((leave) => leave.leaveType == type).toList();
  }

  // ✅ Filter leaves by date range
  List<LeaveModel> filterLeavesByDateRange(DateTime startDate,
      DateTime endDate) {
    return myLeaves.where((leave) {
      try {
        final leaveStart = DateTime.tryParse(leave.startDate);
        final leaveEnd = DateTime.tryParse(leave.endDate);

        if (leaveStart == null || leaveEnd == null) return false;

        return (leaveStart.isAfter(startDate) ||
            leaveStart.isAtSameMomentAs(startDate)) &&
            (leaveEnd.isBefore(endDate) || leaveEnd.isAtSameMomentAs(endDate));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // ✅ Search leaves by reason
  List<LeaveModel> searchLeavesByReason(String query) {
    if (query.isEmpty) return myLeaves.toList();

    return myLeaves.where((leave) =>
    leave.reason.toLowerCase().contains(query.toLowerCase()) ||
        leave.leaveType.toLowerCase().contains(query.toLowerCase()) ||
        ((leave.bookerName ?? '').toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // ==================== Utility Functions ====================

  // ✅ Get leave statistics
  Map<String, int> getLeaveStatistics() {
    final total = myLeaves.length;
    final approved = myLeaves
        .where((leave) => (leave.status ?? '').toLowerCase() == 'approved')
        .length;
    final pending = myLeaves
        .where((leave) => (leave.status ?? '').toLowerCase() == 'pending')
        .length;
    final rejected = myLeaves
        .where((leave) => (leave.status ?? '').toLowerCase() == 'rejected')
        .length;

    final annual = myLeaves
        .where((leave) => leave.leaveType == 'Annual Leave')
        .length;
    final sick = myLeaves
        .where((leave) => leave.leaveType == 'Sick Leave')
        .length;
    final casual = myLeaves
        .where((leave) => leave.leaveType == 'Casual Leave')
        .length;
    final short = myLeaves
        .where((leave) => leave.leaveType == 'Short Leave')
        .length;

    return {
      'total': total,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'annual': annual,
      'sick': sick,
      'casual': casual,
      'short': short,
    };
  }

  // ✅ Get total leave days
  int getTotalLeaveDays() {
    return myLeaves.fold(0, (sum, leave) => sum + leave.totalDays);
  }

  // ✅ Get upcoming leaves (within next 7 days)
  List<LeaveModel> getUpcomingLeaves() {
    final now = DateTime.now();
    final nextWeek = now.add(Duration(days: 7));

    return myLeaves.where((leave) {
      try {
        final startDate = DateTime.tryParse(leave.startDate);
        if (startDate == null) return false;

        return startDate.isAfter(now) && startDate.isBefore(nextWeek);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // ✅ Check if user has overlapping leave
  bool hasOverlappingLeave(String bookerId, DateTime newStartDate,
      DateTime newEndDate, {String? excludeLeaveId}) {
    final userLeaves = myLeaves.where((leave) =>
    leave.bookerId == bookerId &&
        (excludeLeaveId == null || leave.id != excludeLeaveId)
    );

    for (final leave in userLeaves) {
      try {
        final existingStart = DateTime.tryParse(leave.startDate);
        final existingEnd = DateTime.tryParse(leave.endDate);

        if (existingStart == null || existingEnd == null) continue;

        // Check for overlap
        if ((newStartDate.isBefore(existingEnd) ||
            newStartDate.isAtSameMomentAs(existingEnd)) &&
            (newEndDate.isAfter(existingStart) ||
                newEndDate.isAtSameMomentAs(existingStart))) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }

    return false;
  }

  // ✅ Validate leave dates
  String? validateLeaveDates(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      return "اختتام کی تاریخ شروع کی تاریخ سے پہلے نہیں ہوسکتی";
    }

    if (endDate
        .difference(startDate)
        .inDays > 365) {
      return "چھٹی ایک سال سے زیادہ نہیں ہوسکتی";
    }

    if (startDate.isBefore(DateTime.now())) {
      return "ماضی میں چھٹی کی درخواست نہیں کی جاسکتی";
    }

    return null;
  }

  // ==================== Selection & State Management ====================

  // ✅ Select a leave for viewing/editing
  void selectLeave(LeaveModel leave) {
    selectedLeave.value = leave;
  }

  // ✅ Clear selected leave
  void clearSelectedLeave() {
    selectedLeave.value = LeaveModel(
      bookerId: '',
      bookerName: '',
      leaveType: '',
      startDate: '',
      endDate: '',
      totalDays: 0,
      isHalfDay: false,
      reason: '',
    );
  }

  // ✅ Update leave status (for admin)
  Future<bool> updateLeaveStatus(String leaveId, String newStatus) async {
    try {
      // Find the leave
      final index = myLeaves.indexWhere((leave) => leave.id == leaveId);

      if (index != -1) {
        // Update in local list
        myLeaves[index] = myLeaves[index].copyWith(status: newStatus);
        myLeaves.refresh(); // Notify listeners

        // Here you would typically update in database and sync with server
        Get.snackbar(
          "کامیابی",
          "چھٹی کی حیثیت کامیابی سے اپ ڈیٹ ہوگئی",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar(
        "غلطی",
        "چھٹی کی حیثیت اپ ڈیٹ کرنے میں خرابی: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    }
  }

  // ✅ Check if leave can be edited
  bool canEditLeave(LeaveModel leave) {
    if ((leave.status ?? '').toLowerCase() == 'approved') {
      return false;
    }

    try {
      final startDate = DateTime.tryParse(leave.startDate);
      if (startDate == null) return true;

      // Allow editing only if leave starts in more than 24 hours
      return startDate.isAfter(DateTime.now().add(Duration(days: 1)));
    } catch (e) {
      return true;
    }
  }

  // ==================== Initialization & Cleanup ====================

  // ✅ Initialize with user data
  Future<void> initialize(String bookerId) async {
    await getMyLeaves(bookerId);
  }

  // ✅ Clear all data
  void clearData() {
    myLeaves.clear();
    pendingLeaves.clear();
    allLeaves.clear();
    clearSelectedLeave();
  }

  // ==================== Helper Methods ====================

  // ✅ Format date for display
  String formatDate(String dateString) {
    try {
      final date = DateTime.tryParse(dateString);
      if (date == null) return dateString;

      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  // ✅ Get status color
  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ✅ Get status text in Urdu
  String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'منظور شدہ';
      case 'rejected':
        return 'مسترد شدہ';
      case 'pending':
        return 'زیر التواء';
      default:
        return 'نامعلوم';
    }
  }

  // ✅ Get leave type in Urdu
  String getLeaveTypeText(String type) {
    switch (type) {
      case 'Annual Leave':
        return 'سالانہ چھٹی';
      case 'Sick Leave':
        return 'بیماری کی چھٹی';
      case 'Casual Leave':
        return 'عارضی چھٹی';
      case 'Short Leave':
        return 'چھوٹی چھٹی';
      default:
        return type;
    }
  }

  void setAllLeaves(List<LeaveModel> leaves) {
    allLeaves.value = leaves;
    // Log the properties of each leave to check for nulls
    for (var leave in allLeaves) {
      debugPrint('--- Leave ID: ${leave.leaveId ?? 'NULL'} ---');
      debugPrint('Booker Name: ${leave.bookerName ?? 'NULL'}');
      // debugPrint('Attachment URL: ${leave.attachmentUrl ?? 'NULL'}');
      debugPrint('Application Date: ${leave.applicationDate ?? 'NULL'}');
      debugPrint('Status: ${leave.status ?? 'NULL'}');
    }
  }
}