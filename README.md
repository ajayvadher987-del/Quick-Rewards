# Quick Rewards — Flutter + Firebase

## Abhi tak kya bana hai (Step 1)
- Flutter project structure, theme, bottom navigation (5 tabs)
- **Home screen** — poori tarah Firestore se connected (live coins, progress bars)
- Auth screen (Google Sign-In)
- Backend: `claimDailyLogin`, `submitCaptcha`, `submitMathQuiz`, `claimVideoWatch`, `spinWheel` Cloud Functions — sab secure (server-side validation)
- Firestore security rules — app se coins directly edit nahi ho sakte
- Earn / Invite / Wallet / Profile abhi placeholder hain ("coming soon") — agle steps me banega

## Zaroori: Maine ye code yahan RUN nahi kiya hai
Main jis environment me kaam kar raha hoon usme Flutter SDK ya Firebase CLI nahi hai, aur internet bhi nahi hai `pub get` chalane ke liye. Ye sab code **professional, production-pattern code hai** — lekin isse aapke apne computer par chalake test karna hoga. Neeche poore steps hain.

## Step-by-step setup

### 1. Flutter install karo
https://docs.flutter.dev/get-started/install se apne OS ke liye install karo, phir:
```
flutter doctor
```
sab green tick aane tak issues fix karo.

### 2. Project open karo
Is poore `quickrewards/` folder ko VS Code ya Android Studio me kholo, phir:
```
flutter pub get
```

### 3. Firebase project banao
1. https://console.firebase.google.com par jaake naya project banao ("Quick Rewards").
2. Usme **Authentication → Google Sign-In** enable karo.
3. **Firestore Database** banao (production mode).

### 4. FlutterFire CLI se app connect karo
```
dart pub global activate flutterfire_cli
flutterfire configure
```
Ye command `lib/firebase_options.dart` ko real keys ke saath replace kar dega (abhi usme placeholder "REPLACE_ME" hai).

### 5. Backend (Cloud Functions) deploy karo
```
cd backend
firebase init functions   # existing functions folder select karo, overwrite mat karna
cd functions
npm install
firebase deploy --only functions
```

### 6. Firestore rules deploy karo
```
cd backend
firebase deploy --only firestore:rules
```

### 7. App chalao
```
flutter run
```

## Important architecture note
Coins **kabhi bhi** Flutter app se directly Firestore me nahi likhe jaate — sirf Cloud Functions likhte hain (`backend/functions/index.js`). `firestore.rules` isi cheez ko enforce karta hai (`allow write: if false` on `users/{uid}`). Agar kabhi koi naya "earn coins" feature jodo, to hamesha isi pattern follow karo:
1. Flutter app ek Cloud Function ko call karta hai ("main captcha solve kiya")
2. Cloud Function server par validate karta hai (limit check, answer check)
3. Sirf tabhi Firestore me coins update hote hain

Isse koi bhi app ko modify/hack karke coins nahi bada sakta.

## Agle steps (jab bologe)
- Earn screen (Daily Spin, Scratch Card, Offers, Surveys, Missions, Social tasks)
- Wallet screen (UPI/Google Play redemption — jaisa UI mockup me tha)
- Invite screen (referral code + link + sharing)
- Profile screen
- CAPTCHA / Math Quiz / Video ke actual interactive screens
- Payment gateway integration (Razorpay/Cashfree) for real UPI payouts
- 
