import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../theme/app_theme.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/main_shell.dart';

/// Shows the sign-in screen until the user is authenticated, then
/// hands off to [OnboardingGate] (which shows the 3-slide intro once,
/// then [MainShell] from then on). Cloud Functions require a
/// signed-in user, so nothing coin-related works before this.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) return const OnboardingGate();
        return const _SignInScreen();
      },
    );
  }
}

class _SignInScreen extends StatefulWidget {
  const _SignInScreen();
  @override
  State<_SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<_SignInScreen> {
  bool _busy = false;
  bool _showEmailForm = false;
  bool _isRegister = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      // On first sign-in, ensureUserDoc (called right after) creates
      // the users/{uid} Firestore doc with starting coins = 0.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign-in failed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInGoogle() => _run(() async {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // user cancelled
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      });

  Future<void> _signInGuest() => _run(() => FirebaseAuth.instance.signInAnonymously());

  Future<void> _submitEmailForm() => _run(() async {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        if (email.isEmpty || password.length < 6) {
          throw FirebaseAuthException(code: 'invalid', message: 'Enter a valid email and a 6+ character password.');
        }
        if (_isRegister) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        } else {
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        }
      });

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: AppColors.goldGradient),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 20),
                const Text('Quick Rewards', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                  'Earn coins every day and redeem them for real rewards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),

                if (_showEmailForm) ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password (6+ characters)',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submitEmailForm,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.violet2),
                      child: Text(_busy ? '...' : (_isRegister ? 'Create account' : 'Log in')),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister ? 'Already have an account? Log in' : "New here? Create an account",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showEmailForm = false),
                    child: const Text('← Other sign-in options', style: TextStyle(color: Colors.white70)),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _signInGoogle,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.violet2),
                      icon: _busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.login),
                      label: Text(_busy ? 'Signing in…' : 'Continue with Google'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => setState(() => _showEmailForm = true),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Continue with Email'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _busy ? null : _signInGuest,
                      icon: const Icon(Icons.person_outline, color: Colors.white70),
                      label: const Text('Continue as Guest', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
