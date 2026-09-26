/**
 * Quick Rewards — Cloud Functions
 * ---------------------------------------------------------------
 * Golden rule: the Flutter app NEVER writes `coins` directly to
 * Firestore. It only calls these functions, and these functions
 * decide whether the request is legitimate before writing anything.
 * That's what stops someone from editing coins by tampering with the
 * app or calling Firestore directly.
 *
 * Every function:
 *   1. Checks the caller is signed in (`context.auth`).
 *   2. Re-checks the daily limit / cooldown from the DATABASE, not
 *      from whatever the client claims.
 *   3. Writes the coin change inside a Firestore transaction so two
 *      rapid taps can't double-award coins (a race condition).
 */

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

const DAILY_LOGIN_COINS = [10, 20, 30, 40, 50, 60, 70]; // day 1..7
const CAPTCHA_COINS = 10;
const CAPTCHA_DAILY_LIMIT = 30;
const MATH_COINS = 10;
const MATH_DAILY_LIMIT = 30;
const VIDEO_COINS = 10;
const VIDEO_DAILY_LIMIT = 10;
const SPIN_VALUES = [5, 10, 15, 20, 25];
const SPIN_DAILY_LIMIT = 10;

/** Writes one row to users/{uid}/transactions — the source of truth
 * for the Account History screen. Called from inside the same
 * Firestore transaction as the coin change so history can never go
 * out of sync with the actual balance. `amount` is positive for
 * earning, negative for spending (redemptions). */
function logTransaction(tx, uid, { title, amount, icon }) {
  const ref = db.collection('users').doc(uid).collection('transactions').doc();
  tx.set(ref, {
    title,
    amount,
    icon,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in first.');
  }
  return request.auth.uid;
}

/** Returns true if `date` (a JS Date) falls on today, in UTC. Swap
 * this for the user's local timezone once you collect it at sign-up
 * — UTC is a safe, simple default to start with. */
function isToday(date) {
  if (!date) return false;
  const now = new Date();
  return (
    date.getUTCFullYear() === now.getUTCFullYear() &&
    date.getUTCMonth() === now.getUTCMonth() &&
    date.getUTCDate() === now.getUTCDate()
  );
}

/**
 * Called once right after a successful sign-in (wire this into
 * AuthGate). Creates the user's Firestore profile — starting balance
 * 0 and a unique referral code — the first time only.
 */
exports.ensureUserDoc = onCall(async (request) => {
  const uid = requireAuth(request);
  const ref = db.collection('users').doc(uid);
  const snap = await ref.get();
  if (!snap.exists) {
    const referralCode = uid.substring(0, 8).toUpperCase();
    await ref.set({
      name: request.auth.token.name || '',
      email: request.auth.token.email || '',
      coins: 0,
      todayEarned: 0,
      dailyGoal: 300,
      loginStreakDay: 0,
      lastLoginClaim: null,
      captchaToday: 0,
      mathToday: 0,
      videoToday: 0,
      spinToday: 0,
      scratchCards: 0,
      referralCode,
      referralApplied: false,
      referredBy: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  return { success: true };
});

exports.claimDailyLogin = onCall(async (request) => {
  const uid = requireAuth(request);
  const ref = db.collection('users').doc(uid);

  return db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    const data = doc.data() || {};
    const lastClaim = data.lastLoginClaim ? data.lastLoginClaim.toDate() : null;

    if (isToday(lastClaim)) {
      return { success: false, coinsAwarded: 0, message: 'Already claimed today — come back tomorrow.' };
    }

    // If they missed a day, the streak resets to day 1. If yesterday
    // was their last claim, move to the next day (capped at 7).
    const wasYesterday =
      lastClaim && (new Date() - lastClaim) / (1000 * 60 * 60 * 24) < 2;
    const nextDay = wasYesterday ? Math.min((data.loginStreakDay || 0) + 1, 7) : 1;
    const coins = DAILY_LOGIN_COINS[nextDay - 1];

    tx.update(ref, {
      coins: admin.firestore.FieldValue.increment(coins),
      todayEarned: admin.firestore.FieldValue.increment(coins),
      loginStreakDay: nextDay,
      lastLoginClaim: admin.firestore.FieldValue.serverTimestamp(),
    });
    logTransaction(tx, uid, { title: `Daily Login — Day ${nextDay}`, amount: coins, icon: 'calendar' });

    return { success: true, coinsAwarded: coins, message: `Day ${nextDay} claimed!` };
  });
});

/**
 * CAPTCHA/quiz challenges are generated and validated using this
 * pattern: a `challenges/{id}` doc is created server-side with the
 * correct answer, and the client only ever sees the *puzzle*, never
 * the answer. `submitCaptcha` checks the client's answer against that
 * stored value — never trust an "isCorrect" flag sent from the app.
 */
exports.submitCaptcha = onCall(async (request) => {
  const uid = requireAuth(request);
  const { answer, challengeId } = request.data;
  return awardIfCorrect({
    uid,
    answer,
    challengeId,
    counterField: 'captchaToday',
    dailyLimit: CAPTCHA_DAILY_LIMIT,
    coins: CAPTCHA_COINS,
  });
});

exports.submitMathQuiz = onCall(async (request) => {
  const uid = requireAuth(request);
  const { answer, challengeId } = request.data;
  return awardIfCorrect({
    uid,
    answer,
    challengeId,
    counterField: 'mathToday',
    dailyLimit: MATH_DAILY_LIMIT,
    coins: MATH_COINS,
  });
});

async function awardIfCorrect({ uid, answer, challengeId, counterField, dailyLimit, coins }) {
  const challengeRef = db.collection('challenges').doc(challengeId);
  const userRef = db.collection('users').doc(uid);
  const label = counterField === 'captchaToday' ? 'Solve CAPTCHA' : 'Math Quiz';
  const icon = counterField === 'captchaToday' ? 'shield' : 'calc';

  return db.runTransaction(async (tx) => {
    const [challengeDoc, userDoc] = await Promise.all([tx.get(challengeRef), tx.get(userRef)]);
    const challenge = challengeDoc.data();
    const user = userDoc.data() || {};

    if (!challenge || challenge.uid !== uid || challenge.used) {
      throw new HttpsError('failed-precondition', 'Challenge not found or already used.');
    }
    if ((user[counterField] || 0) >= dailyLimit) {
      return { success: false, coinsAwarded: 0, message: 'Daily limit reached — come back tomorrow.' };
    }
    if (String(answer).trim().toUpperCase() !== String(challenge.answer).trim().toUpperCase()) {
      tx.update(challengeRef, { used: true });
      return { success: false, coinsAwarded: 0, message: 'Incorrect — try a new one.' };
    }

    tx.update(challengeRef, { used: true });
    tx.update(userRef, {
      coins: admin.firestore.FieldValue.increment(coins),
      todayEarned: admin.firestore.FieldValue.increment(coins),
      [counterField]: admin.firestore.FieldValue.increment(1),
    });
    logTransaction(tx, uid, { title: label, amount: coins, icon });
    return { success: true, coinsAwarded: coins, message: 'Correct!' };
  });
}

exports.claimVideoWatch = onCall(async (request) => {
  const uid = requireAuth(request);
  const { sessionId } = request.data;
  const sessionRef = db.collection('videoSessions').doc(sessionId);
  const userRef = db.collection('users').doc(uid);

  return db.runTransaction(async (tx) => {
    const [sessionDoc, userDoc] = await Promise.all([tx.get(sessionRef), tx.get(userRef)]);
    const session = sessionDoc.data();
    const user = userDoc.data() || {};

    // The session doc should have been created server-side (or via an
    // ad SDK server-to-server callback) when the video actually
    // started, with a minimum watch duration — never trust the app
    // saying "video finished" on its own.
    if (!session || session.uid !== uid || session.claimed) {
      throw new HttpsError('failed-precondition', 'Invalid or already-claimed session.');
    }
    if ((user.videoToday || 0) >= VIDEO_DAILY_LIMIT) {
      return { success: false, coinsAwarded: 0, message: 'Daily video limit reached.' };
    }

    tx.update(sessionRef, { claimed: true });
    tx.update(userRef, {
      coins: admin.firestore.FieldValue.increment(VIDEO_COINS),
      todayEarned: admin.firestore.FieldValue.increment(VIDEO_COINS),
      videoToday: admin.firestore.FieldValue.increment(1),
    });
    logTransaction(tx, uid, { title: 'Watch Video', amount: VIDEO_COINS, icon: 'video' });
    return { success: true, coinsAwarded: VIDEO_COINS, message: 'Reward added!' };
  });
});

exports.spinWheel = onCall(async (request) => {
  const uid = requireAuth(request);
  const userRef = db.collection('users').doc(uid);

  return db.runTransaction(async (tx) => {
    const doc = await tx.get(userRef);
    const user = doc.data() || {};
    if ((user.spinToday || 0) >= SPIN_DAILY_LIMIT) {
      return { success: false, coinsAwarded: 0, message: 'No spins left today.' };
    }
    // The random outcome is decided HERE, server-side — never let the
    // client pick which wedge it landed on.
    const coins = SPIN_VALUES[Math.floor(Math.random() * SPIN_VALUES.length)];
    tx.update(userRef, {
      coins: admin.firestore.FieldValue.increment(coins),
      todayEarned: admin.firestore.FieldValue.increment(coins),
      spinToday: admin.firestore.FieldValue.increment(1),
    });
    logTransaction(tx, uid, { title: 'Daily Spin', amount: coins, icon: 'spin' });
    return { success: true, coinsAwarded: coins, message: `You won ${coins} coins!` };
  });
});

const REFERRAL_BONUS_REFERRER = 300;
const REFERRAL_BONUS_NEW_USER = 200;

/**
 * A new user enters a friend's referral code (once). Both sides get
 * coins, but only after several server-side checks — this is a
 * classic fraud target (people making fake accounts to refer
 * themselves), so every check here matters:
 *   1. Caller hasn't already applied a code before.
 *   2. The code actually belongs to someone.
 *   3. The code isn't the caller's own code (self-referral).
 */
exports.applyReferralCode = onCall(async (request) => {
  const uid = requireAuth(request);
  const code = String(request.data.code || '').trim().toUpperCase();
  if (!code) {
    throw new HttpsError('invalid-argument', 'Enter a referral code.');
  }

  const userRef = db.collection('users').doc(uid);
  const ownerQuery = await db.collection('users').where('referralCode', '==', code).limit(1).get();

  if (ownerQuery.empty) {
    return { success: false, coinsAwarded: 0, message: 'Invalid referral code.' };
  }
  const referrerDoc = ownerQuery.docs[0];
  if (referrerDoc.id === uid) {
    return { success: false, coinsAwarded: 0, message: "You can't use your own code." };
  }

  return db.runTransaction(async (tx) => {
    const userDoc = await tx.get(userRef);
    const user = userDoc.data() || {};
    if (user.referralApplied) {
      return { success: false, coinsAwarded: 0, message: 'You already used a referral code.' };
    }

    tx.update(userRef, {
      coins: admin.firestore.FieldValue.increment(REFERRAL_BONUS_NEW_USER),
      referralApplied: true,
      referredBy: referrerDoc.id,
    });
    tx.update(referrerDoc.ref, {
      coins: admin.firestore.FieldValue.increment(REFERRAL_BONUS_REFERRER),
    });
    logTransaction(tx, uid, { title: 'Referral bonus', amount: REFERRAL_BONUS_NEW_USER, icon: 'invite' });
    logTransaction(tx, referrerDoc.id, { title: 'Referral bonus', amount: REFERRAL_BONUS_REFERRER, icon: 'invite' });

    return {
      success: true,
      coinsAwarded: REFERRAL_BONUS_NEW_USER,
      message: `+${REFERRAL_BONUS_NEW_USER} coins added!`,
    };
  });
});
// Keep this in sync with lib/models/reward_tier.dart on the Flutter
// side. Duplicated on purpose: the server must NEVER trust a coins/inr
// pair sent by the client — it looks the pair up here and only
// accepts it if it matches exactly.
const REWARD_TIERS = {
  googlePlay: [
    { coins: 10500, inr: 100 },
    { coins: 21000, inr: 200 },
    { coins: 31500, inr: 300 },
    { coins: 42000, inr: 400 },
    { coins: 52500, inr: 500 },
  ],
  upi: [
    { coins: 12500, inr: 100 },
    { coins: 25000, inr: 200 },
    { coins: 36000, inr: 300 },
    { coins: 50000, inr: 400 },
    { coins: 60000, inr: 500 },
  ],
};

/**
 * Permanently deletes the user's data and sign-in account. Firestore
 * data is removed first, then the Auth account — irreversible once
 * done, so the Flutter side always shows a confirmation dialog first.
 */
exports.deleteAccount = onCall(async (request) => {
  const uid = requireAuth(request);
  // Delete Firestore data first, then the Auth account itself — once
  // the Auth account is gone the user can never sign back in to undo
  // this, so order matters (data cleanup should never be "half done").
  const transactionsSnap = await db.collection('users').doc(uid).collection('transactions').get();
  const batch = db.batch();
  transactionsSnap.docs.forEach((d) => batch.delete(d.ref));
  batch.delete(db.collection('users').doc(uid));
  await batch.commit();
  await admin.auth().deleteUser(uid);
  return { success: true, coinsAwarded: 0, message: 'Account deleted.' };
});

/**
 * Wallet redemption. The app sends which method/tier the user tapped,
 * but this function re-derives the truth from REWARD_TIERS above and
 * the user's real Firestore balance — the `coins`/`inr` the client
 * sent are only used to figure out *which* tier they mean, never
 * trusted as the actual amount to deduct.
 */
exports.redeemReward = onCall(async (request) => {
  const uid = requireAuth(request);
  const { method, coins, destination } = request.data;

  if (!REWARD_TIERS[method]) {
    throw new HttpsError('invalid-argument', 'Unknown payment method.');
  }
  const tier = REWARD_TIERS[method].find((t) => t.coins === coins);
  if (!tier) {
    throw new HttpsError('invalid-argument', 'Unknown reward tier.');
  }
  if (!destination || String(destination).trim().length < 3) {
    throw new HttpsError('invalid-argument', 'A valid UPI ID / email is required.');
  }

  const userRef = db.collection('users').doc(uid);
  const redemptionRef = db.collection('redemptions').doc();

  return db.runTransaction(async (tx) => {
    const userDoc = await tx.get(userRef);
    const user = userDoc.data() || {};

    if ((user.coins || 0) < tier.coins) {
      return { success: false, coinsAwarded: 0, message: 'Not enough coins for this reward.' };
    }

    tx.update(userRef, { coins: admin.firestore.FieldValue.increment(-tier.coins) });
    tx.set(redemptionRef, {
      uid,
      method,
      coinsSpent: tier.coins,
      inr: tier.inr,
      destination: String(destination).trim(),
      status: 'pending', // an admin/ops process picks this up and pays out
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    logTransaction(tx, uid, {
      title: `${method === 'googlePlay' ? 'Google Play' : 'UPI'} redemption`,
      amount: -tier.coins,
      icon: 'wallet',
    });

    return {
      success: true,
      coinsAwarded: 0,
      message: `Your ₹${tier.inr} ${method === 'googlePlay' ? 'Google Play' : 'UPI'} reward is being processed.`,
    };
  });
});
  
