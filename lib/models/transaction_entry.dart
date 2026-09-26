import 'package:cloud_firestore/cloud_firestore.dart';

/// One row from users/{uid}/transactions — written only by Cloud
/// Functions (see backend/functions/index.js logTransaction()).
class TransactionEntry {
  final String title;
  final int amount; // positive = earned, negative = spent
  final String icon;
  final DateTime? createdAt;

  const TransactionEntry({required this.title, required this.amount, required this.icon, required this.createdAt});

  factory TransactionEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final ts = d['createdAt'] as Timestamp?;
    return TransactionEntry(
      title: d['title'] ?? '',
      amount: d['amount'] ?? 0,
      icon: d['icon'] ?? 'coin',
      createdAt: ts?.toDate(),
    );
  }
}

/// One row from the top-level `redemptions` collection — a Wallet
/// payout request and its current status.
class RedemptionEntry {
  final String method; // 'googlePlay' | 'upi'
  final int coinsSpent;
  final int inr;
  final String status; // 'pending' | 'paid' | 'rejected'
  final DateTime? createdAt;

  const RedemptionEntry({
    required this.method,
    required this.coinsSpent,
    required this.inr,
    required this.status,
    required this.createdAt,
  });

  factory RedemptionEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final ts = d['createdAt'] as Timestamp?;
    return RedemptionEntry(
      method: d['method'] ?? 'upi',
      coinsSpent: d['coinsSpent'] ?? 0,
      inr: d['inr'] ?? 0,
      status: d['status'] ?? 'pending',
      createdAt: ts?.toDate(),
    );
  }
}
