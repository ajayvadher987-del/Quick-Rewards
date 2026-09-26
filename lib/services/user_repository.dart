import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/transaction_entry.dart';

/// All coin-earning logic goes through Cloud Functions ("callable
/// functions"), never through a direct Firestore write from the app.
/// The client just says *what* the user did (e.g. "claim daily login");
/// the server decides *whether* that's allowed and *how many* coins
/// that's worth. See backend/functions/index.js for the matching code.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore, FirebaseFunctions? functions, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  String? get uid => _auth.currentUser?.uid;

  /// Live stream of the signed-in user's document. The Home/Wallet/etc
  /// screens rebuild automatically whenever coins change.
  Stream<UserModel> watchUser() {
    final id = uid;
    if (id == null) return Stream.value(UserModel.empty());
    return _db.collection('users').doc(id).snapshots().map((doc) {
      if (!doc.exists) return UserModel.empty();
      return UserModel.fromDoc(doc);
    });
  }

  Future<CoinResult> claimDailyLogin() => _call('claimDailyLogin');
  Future<CoinResult> submitCaptcha(String answer, String challengeId) =>
      _call('submitCaptcha', {'answer': answer, 'challengeId': challengeId});
  Future<CoinResult> submitMathQuiz(int answer, String challengeId) =>
      _call('submitMathQuiz', {'answer': answer, 'challengeId': challengeId});
  Future<CoinResult> claimVideoWatch(String sessionId) =>
      _call('claimVideoWatch', {'sessionId': sessionId});
  Future<CoinResult> spinWheel() => _call('spinWheel');

  /// Requests a Wallet redemption. `method` is 'googlePlay' or 'upi',
  /// `destination` is the UPI ID or the email for the gift card code.
  /// The Cloud Function re-checks the coin balance and deducts coins —
  /// the app only ever *asks*, it never deducts anything itself.
  Future<CoinResult> redeemReward({
    required String method,
    required int coins,
    required int inr,
    required String destination,
  }) =>
      _call('redeemReward', {
        'method': method,
        'coins': coins,
        'inr': inr,
        'destination': destination,
      });

  Future<CoinResult> applyReferralCode(String code) => _call('applyReferralCode', {'code': code});

  /// Last 30 Account History rows, newest first.
  Stream<List<TransactionEntry>> watchTransactions() {
    final id = uid;
    if (id == null) return Stream.value(const []);
    return _db
        .collection('users')
        .doc(id)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionEntry.fromDoc).toList());
  }

  /// The user's past Wallet redemption requests, newest first.
  Stream<List<RedemptionEntry>> watchRedemptions() {
    final id = uid;
    if (id == null) return Stream.value(const []);
    return _db
        .collection('redemptions')
        .where('uid', isEqualTo: id)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs.map(RedemptionEntry.fromDoc).toList());
  }

  Future<void> signOut() => _auth.signOut();

  Future<CoinResult> deleteAccount() => _call('deleteAccount');

  Future<CoinResult> _call(String name, [Map<String, dynamic>? data]) async {
    try {
      final result = await _functions.httpsCallable(name).call(data);
      final map = Map<String, dynamic>.from(result.data as Map);
      return CoinResult(
        success: map['success'] ?? false,
        coinsAwarded: map['coinsAwarded'] ?? 0,
        message: map['message'] ?? '',
      );
    } on FirebaseFunctionsException catch (e) {
      return CoinResult(success: false, coinsAwarded: 0, message: e.message ?? 'Something went wrong');
    }
  }
}

class CoinResult {
  final bool success;
  final int coinsAwarded;
  final String message;
  const CoinResult({required this.success, required this.coinsAwarded, required this.message});
}
