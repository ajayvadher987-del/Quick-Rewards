import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import 'account_history_screen.dart';
import 'my_rewards_screen.dart';
import 'static_page_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = UserRepository();

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (ok == true) await _repo.signOut();
    // AuthGate's authStateChanges() stream picks this up automatically
    // and swaps back to the sign-in screen — no manual navigation needed.
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'Your coins and rewards will be removed permanently. This cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final result = await _repo.deleteAccount();
    if (!mounted) return;
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    }
    // On success, Firebase Auth signs the user out server-side too;
    // AuthGate swaps to the sign-in screen automatically.
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: null,
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.line)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.transparent),
                    ),
                  ),
                  const Expanded(
                    child: Text('Account', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [AppColors.gold1, AppColors.violet3]),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.violet2,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name.isEmpty ? 'Player' : user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    Text(user.email, style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFF8DE9B)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
                            child: const Icon(Icons.bolt, color: Colors.white, size: 12),
                          ),
                          const SizedBox(width: 7),
                          Text('${user.coins} coins', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Menu([
                _MenuItem(Icons.receipt_long_rounded, 'Account History', () => _push(const AccountHistoryScreen())),
                _MenuItem(Icons.emoji_events_rounded, 'My Rewards', () => _push(const MyRewardsScreen())),
              ]),
              const SizedBox(height: 16),
              _Menu([
                _MenuItem(Icons.translate_rounded, 'Change language', () => _push(const StaticPageScreen(
                      title: 'Change language',
                      body: 'English, हिन्दी, ગુજરાતી — language switching UI goes here once you add localization (flutter_localizations).',
                    ))),
                _MenuItem(Icons.lock_outline_rounded, 'Terms & Conditions', () => _push(const StaticPageScreen(
                      title: 'Terms & Conditions',
                      body: 'Your Terms & Conditions text goes here.',
                    ))),
                _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () => _push(const StaticPageScreen(
                      title: 'Privacy Policy',
                      body: 'Your Privacy Policy text goes here.',
                    ))),
                _MenuItem(Icons.help_outline_rounded, 'Help & FAQ', () => _push(const StaticPageScreen(
                      title: 'Help & FAQ',
                      body: 'Q: How do I earn coins?\nA: Complete tasks on Home and Earn.\n\nQ: How do I withdraw?\nA: Open Wallet, pick a method, choose an amount.',
                    ))),
              ]),
              const SizedBox(height: 16),
              _Menu([
                _MenuItem(Icons.delete_outline_rounded, 'Delete Account', _confirmDelete, danger: true),
                _MenuItem(Icons.logout_rounded, 'Logout', _confirmLogout, danger: true),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  _MenuItem(this.icon, this.label, this.onTap, {this.danger = false});
}

class _Menu extends StatelessWidget {
  const _Menu(this.items);
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: item.danger ? const Color(0xFFFFE9EA) : const Color(0xFFF1ECFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: item.danger ? const Color(0xFFD1323A) : AppColors.violet2),
                ),
                title: Text(
                  item.label,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: item.danger ? const Color(0xFFD1323A) : AppColors.ink),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFA5A2BB)),
              ),
              if (i != items.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}
