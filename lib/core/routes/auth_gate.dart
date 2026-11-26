import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../screens/authentication/login_screen.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/brand_header.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/status_pill.dart';

/// Root authentication gate for AIMS-Diabetes.
///
/// Reacts to changes in [AuthProvider]:
/// - Shows a branded loading screen while session initialization runs.
/// - Routes to [LoginScreen] if the user is unauthenticated.
/// - Routes to [AuthenticatedPlaceholderScreen] when authenticated.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = context.appColors;

    // ── 1. Checking Session State ───────────────────────────────────────────
    if (auth.isCheckingSession) {
      return Scaffold(
        backgroundColor: colors.bgApp,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandHeader(),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.bgPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── 2. Unauthenticated State ────────────────────────────────────────────
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // ── 3. Authenticated State ──────────────────────────────────────────────
    return const AuthenticatedPlaceholderScreen();
  }
}

/// Temporary placeholder for the authenticated main application shell.
///
/// Provides a visible confirmation of successful login and a logout action
/// that returns the user to [LoginScreen] via [AuthGate].
/// Will be replaced by the 5-tab MainShell and Home dashboard in subsequent steps.
class AuthenticatedPlaceholderScreen extends StatelessWidget {
  const AuthenticatedPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = context.appColors;
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: colors.bgApp,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo.symbol(size: 28),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'AIMSD',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('auth_placeholder_logout_icon'),
            icon: Icon(Icons.logout, color: colors.textSecondary),
            tooltip: 'Log Out',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(
                  variant: AppLogoVariant.symbolOnly,
                  height: 64,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Welcome, ${user?.name ?? "User"}!',
                  style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyDefault.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                const StatusPill(
                  label: 'Session Active (Mock Mode)',
                  type: StatusPillType.success,
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.borderDefault),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Authenticated App Shell Placeholder',
                        style: AppTextStyles.titleCard.copyWith(color: colors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'The 5-tab dashboard, glucose tracking, meal logging, and AIMSD AI modules will be introduced in subsequent steps.',
                        style: AppTextStyles.captionDefault.copyWith(color: colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  key: const Key('auth_placeholder_logout_button'),
                  text: 'Log Out',
                  isLoading: auth.isLoading,
                  onPressed: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
