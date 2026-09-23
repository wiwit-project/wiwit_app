import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/settings_section_card.dart';
import 'components/settings_section_label.dart';
import 'components/settings_tile.dart';

/// The app information page
class AppInformationPage extends StatelessWidget {
  const AppInformationPage({super.key});

  Future<void> _openLink(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: .topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                      ),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          'App information',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: .w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(36),
                  Column(
                    children: [
                      Image.asset(
                        'assets/logos/icon-${theme.brightness.name}-84.png',
                        height: 64,
                        width: 64,
                        excludeFromSemantics: true,
                      ),
                      const Gap(12),
                      Text(
                        'Wiwit',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: .w800,
                        ),
                        textAlign: .center,
                      ),
                    ],
                  ),
                  const Gap(36),
                  const SettingsSectionLabel('App information'),
                  const Gap(8),
                  SettingsSectionCard(
                    child: Column(
                      children: [
                        FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            final versionText = snapshot.hasData
                                ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                                : 'Loading...';

                            return _BuildDetail(
                              label: 'Application version',
                              value: versionText,
                              onLongPress: snapshot.hasData
                                  ? () {
                                      Clipboard.setData(
                                        ClipboardData(text: versionText),
                                      );
                                    }
                                  : null,
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _BuildDetail(
                          label: 'Flutter version',
                          value:
                              '${FlutterVersion.version} (${FlutterVersion.channel} channel)',
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  const SettingsSectionLabel('Project information'),
                  const Gap(8),
                  SettingsSectionCard(
                    child: Column(
                      children: [
                        SettingsTile(
                          icon: Icons.language_rounded,
                          title: 'The wiwit project',
                          onTap: () => _openLink('https://wiwit.iqfareez.com'),
                        ),
                        const Divider(height: 1, indent: 72, endIndent: 16),
                        SettingsTile(
                          icon: Icons.code_rounded,
                          title: 'Open source licenses',
                          onTap: () => showLicensePage(
                            context: context,
                            applicationName: 'Wiwit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(32),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _openLink('https://iqfareez.com'),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Copyright 2026 Muhammad Fareez',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                          textAlign: .center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildDetail extends StatelessWidget {
  const _BuildDetail({
    required this.label,
    required this.value,
    this.onLongPress,
  });

  final String label;
  final String value;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onLongPress: onLongPress,
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: .w600,
          ),
        ),
      ),
    );
  }
}
