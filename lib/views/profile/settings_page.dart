import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/components/confirm_dialog.dart';
import '../../shared/components/profile_avatar_widget.dart';
import '../../shared/constants.dart';
import '../../shared/models/wiwit_api/profile/profile_response.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/server_url_provider.dart';
import '../../shared/providers/theme_mode_provider.dart';
import '../../shared/utils/theme_mode_utils.dart';
import '../categories/categories_page.dart';
import 'app_information_page.dart';
import 'components/settings_section_card.dart';
import 'components/settings_section_label.dart';
import 'components/settings_tile.dart';
import 'components/theme_mode_dialog.dart';
import 'server_page.dart';

/// Represents the settings page
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, required this.userProfile});

  final ProfileResponse userProfile;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Future<PackageInfo> futurePackageInfo;

  @override
  void initState() {
    super.initState();
    futurePackageInfo = PackageInfo.fromPlatform();
  }

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Log out?',
      message: "You'll need to sign in again to see your transactions.",
      confirmLabel: 'Log out',
      action: ref.read(authTokenProvider.notifier).clear,
    );

    if (!confirmed || !mounted) return;

    Navigator.of(context).pop();
  }

  void _showThemeModeDialog() {
    showDialog<void>(context: context, builder: (_) => const ThemeModeDialog());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final serverUrl = ref.watch(serverUrlProvider).value;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const Gap(4),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              SettingsSectionCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Hero(
                        tag: kProfilePictureHeroTag,
                        child: ProfileAvatarWidget(
                          profileDetail: widget.userProfile,
                        ),
                      ),
                      title: Text(
                        widget.userProfile.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          // color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                    ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ServerPage()),
                      ),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      title: Text(
                        'SERVER',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      subtitle: Text(
                        serverUrl ?? 'Loading...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),
              const SettingsSectionLabel('Data'),
              const Gap(8),
              SettingsSectionCard(
                child: SettingsTile(
                  icon: Icons.label_outline,
                  title: 'Categories',
                  subtitle: 'Manage categories',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoriesPage()),
                  ),
                ),
              ),
              const Gap(24),
              const SettingsSectionLabel('Appearance'),
              const Gap(8),
              SettingsSectionCard(
                child: SettingsTile(
                  icon: themeMode.icon,
                  title: 'Theme',
                  subtitle: themeMode.label,
                  onTap: _showThemeModeDialog,
                ),
              ),
              const Gap(24),
              const SettingsSectionLabel('Account'),
              const Gap(8),
              SettingsSectionCard(
                child: SettingsTile(
                  icon: Icons.logout,
                  title: 'Log out',
                  subtitle: 'Sign out of this device',
                  isDestructive: true,
                  onTap: _logout,
                ),
              ),
              const Gap(32),
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onLongPress: () {
                    // opens app info page
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AppInformationPage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: futurePackageInfo,
                      builder: (context, asyncSnapshot) {
                        var textStyle = Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            );
                        if (!asyncSnapshot.hasData) {
                          return Text('Wiwit', style: textStyle);
                        }
                        var appVersion = asyncSnapshot.data?.version;
                        var appName = asyncSnapshot.data?.appName;
                        return Text('$appName v$appVersion', style: textStyle);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
