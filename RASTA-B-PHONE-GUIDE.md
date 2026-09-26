# Rasta B — Phone se hi asli app taiyar karna (koi computer nahi chahiye)

Ye guide maan ke chal rahi hai ki aapke paas sirf ek Android phone hai.
Har step browser (Chrome) se hoga. Koi bhi terminal/command line kahin
nahi chalani.

---

## Step 1 — GitHub par account aur repo banao
1. https://github.com par jaake free account banao (agar nahi hai).
2. "+" → "New repository" → naam do `quick-rewards` → Create.
3. Us repo ke andar "Add file" → "Upload files" dabao.
4. Is poore `quickrewards` folder ke andar ki saari files ek-ek karke
   (ya jitni ek saath select ho sakein) upload karo — folder structure
   (jaise `lib/screens/home/...`) waisa hi rakhna zaroori hai. Agar
   upload me dikkat aaye, GitHub ke "Add file → Create new file" se
   file ka poora path (e.g. `lib/screens/home/home_screen.dart`) naam
   me likh ke, is chat me maine jo content diya hai wo paste kar do.
5. "Commit changes" dabao.

## Step 2 — Firebase project banao
1. https://console.firebase.google.com par naya project banao:
   "Quick Rewards".
2. **Authentication** → Sign-in method → Google → Enable.
3. **Firestore Database** → Create database → Production mode.
4. Project Settings (⚙️ icon) → General tab → "Your apps" → Android
   icon se ek Android app add karo (package name: `com.example.quickrewards`
   — ya jo bhi aap rakhna chaho, bas yaad rakhna).
5. Wahi settings screen par jo config values dikhte hain (apiKey,
   appId, messagingSenderId, projectId, storageBucket), unhe copy kar
   lo — agle step me chahiye honge.

## Step 3 — firebase_options.dart me real values daalo
1. GitHub par apne repo me `lib/firebase_options.dart` file kholo,
   pencil (✏️) icon se edit karo.
2. Jahan `REPLACE_ME` likha hai, wahan Step 2 ke values paste karo
   (android wale block me — ios wala abhi chhod do).
3. "Commit changes".

## Step 4 — Service account key banao (backend deploy ke liye)
1. Firebase Console → Project Settings → "Service accounts" tab.
2. "Generate new private key" dabao — ek `.json` file download hogi.
3. Us file ko text editor se kholo (phone me koi bhi file/text viewer
   app), poora content copy karo.

## Step 5 — GitHub Secrets me daalo
1. Apne GitHub repo me: Settings → Secrets and variables → Actions →
   "New repository secret".
2. Naam: `FIREBASE_SERVICE_ACCOUNT`, Value: Step 4 wali poori JSON
   paste karo. Save.
3. Dubara "New repository secret": Naam `FIREBASE_PROJECT_ID`, Value
   me apna Firebase project ka ID (Project Settings me dikhta hai).

## Step 6 — Backend apne aap deploy hoga
Jaise hi aap `backend/` folder ke andar kisi file ko commit/upload
karoge, GitHub Actions (jo maine `.github/workflows/deploy-backend.yml`
me likh diya hai) khud-ba-khud Cloud Functions aur Firestore rules
deploy kar dega. Progress dekhne ke liye repo ke "Actions" tab me jao.

## Step 7 — APK apne aap banega
Isi tarah, `.github/workflows/build-apk.yml` har baar `main` branch
par commit hone par ek APK bana dega. Repo ke "Actions" tab → us build
ke andar "Artifacts" section se `quick-rewards-debug-apk` download
karke phone me install kar sakte ho.

---

## Agar kahin atak jao
Is chat me wapas aake batao kis step par kya error/screen dikh raha
hai — screenshot bhi bhej sakte ho, main aage ka rasta bataunga.
