import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a `users/{uid}` Firestore document. Every field here is
/// written ONLY by Cloud Functions (see backend/functions/index.js) —
/// the Flutter app only ever reads this, never writes coins directly.
/// That's what stops someone from editing coins by hacking the app.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final int coins;
  final int todayEarned;
  final int dailyGoal;
  final int loginStreakDay; // 1..7
  final DateTime? lastLoginClaim;
  final int captchaToday;
  final int mathToday;
  final int videoToday;
  final int spinToday;
  final int scratchCards;
  final String referralCode;
  final bool referralApplied;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.coins,
    required this.todayEarned,
    required this.dailyGoal,
    required this.loginStreakDay,
    required this.lastLoginClaim,
    required this.captchaToday,
    required this.mathToday,
    required this.videoToday,
    required this.spinToday,
    required this.scratchCards,
    required this.referralCode,
    required this.referralApplied,
  });

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final ts = d['lastLoginClaim'] as Timestamp?;
    return UserModel(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      coins: d['coins'] ?? 0,
      todayEarned: d['todayEarned'] ?? 0,
      dailyGoal: d['dailyGoal'] ?? 300,
      loginStreakDay: d['loginStreakDay'] ?? 1,
      lastLoginClaim: ts?.toDate(),
      captchaToday: d['captchaToday'] ?? 0,
      mathToday: d['mathToday'] ?? 0,
      videoToday: d['videoToday'] ?? 0,
      spinToday: d['spinToday'] ?? 0,
      scratchCards: d['scratchCards'] ?? 0,
      referralCode: d['referralCode'] ?? '',
      referralApplied: d['referralApplied'] ?? false,
    );
  }

  /// Used only while the very first Firestore snapshot is loading.
  factory UserModel.empty() => const UserModel(
        uid: '',
        name: '',
        email: '',
        coins: 0,
        todayEarned: 0,
        dailyGoal: 300,
        loginStreakDay: 1,
        lastLoginClaim: null,
        captchaToday: 0,
        mathToday: 0,
        videoToday: 0,
        spinToday: 0,
        scratchCards: 0,
        referralCode: '',
        referralApplied: false,
      );

  bool get hasClaimedLoginToday {
    if (lastLoginClaim == null) return false;
    final now = DateTime.now();
    return lastLoginClaim!.year == now.year &&
        lastLoginClaim!.month == now.month &&
        lastLoginClaim!.day == now.day;
  }
}
