
import 'package:flutter/material.dart';
import 'daily_counter.dart';

class TodayStatsCard extends StatelessWidget {
  final double horizontalPadding;

  const TodayStatsCard({
    Key? key,
    this.horizontalPadding = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // 🔹 Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: const Text(
                "Today's Stats",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 2),

            // 🔹 Stats Row - Now with 4 items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatCircle(
                  title: "Shop Visits",
                  futureType: StatType.visits,
                ),
                _StatCircle(
                  title: "Today's Orders",
                  futureType: StatType.orders,
                ),
                _StatCircle(
                  title: "Order Amount",
                  futureType: StatType.amount,
                ),
              ],
            ),
        //     SizedBox(height: 15),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: const [
        //     _StatCircle(
        //       title: "Recovery Amount",
        //       futureType: StatType.recoveryAmount,
        //     ),
        //   ],
        // ),
            SizedBox(height: 16,)
        ]
      ),
    )
    );
  }
}

enum StatType { visits, orders, amount, recoveryAmount }

class _StatCircle extends StatelessWidget {
  final String title;
  final StatType futureType;

  const _StatCircle({
    required this.title,
    required this.futureType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _getFuture(),
          builder: (context, snap) {
            String value = "0";

            if (snap.hasData) {
              if (futureType == StatType.amount || futureType == StatType.recoveryAmount) {
                value = (snap.data as double).toStringAsFixed(0);
              } else {
                value = snap.data.toString();
              }
            }

            return Container(
              width: 65, // Slightly smaller to fit 4 items
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blueGrey.withOpacity(0.46),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Slightly smaller font
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.w800,
            fontSize: 12, // Slightly smaller text
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future _getFuture() {
    switch (futureType) {
      case StatType.visits:
        return DailyCounter.getTodayShopVisits();
      case StatType.orders:
        return DailyCounter.getTodayOrderCount();
      case StatType.amount:
        return DailyCounter.getTodayOrderAmount();
      case StatType.recoveryAmount:
        return DailyCounter.getTodayRecoveryAmount();
    }
  }
}
