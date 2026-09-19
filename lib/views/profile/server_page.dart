import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../shared/components/confirm_dialog.dart';
import '../../shared/models/wiwit_api/instance/instance_response.dart';
import '../../shared/models/wiwit_api/problem_details.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/chopper_provider.dart';
import '../../shared/providers/server_url_provider.dart';
import 'components/settings_section_card.dart';
import 'components/settings_section_label.dart';
import 'components/settings_tile.dart';

/// The states the instance description can be in.
enum _InstanceStatus { loading, ready, error }

class ServerPage extends ConsumerStatefulWidget {
  const ServerPage({super.key});

  @override
  ConsumerState<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends ConsumerState<ServerPage> {
  static const _shortShaLength = 7;

  _InstanceStatus _status = .loading;
  InstanceResponse? _instance;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInstance();
  }

  Future<({InstanceResponse? data, String? error})> _fetchInstance() async {
    try {
      final instance = await ref.read(instanceServiceProvider).getInstance();

      return (data: instance, error: null);
    } on ProblemDetails catch (error) {
      return (data: null, error: error.detail);
    } catch (error) {
      return (data: null, error: '$error');
    }
  }

  Future<void> _loadInstance() async {
    setState(() {
      _status = _InstanceStatus.loading;
      _errorMessage = null;
    });

    final result = await _fetchInstance();

    if (!mounted) return;

    setState(() {
      if (result.data == null) {
        _status = _InstanceStatus.error;
        _errorMessage = result.error;
        return;
      }

      _instance = result.data;
      _status = _InstanceStatus.ready;
    });
  }

  Future<void> _copy({required String value, required String label}) async {
    await Clipboard.setData(ClipboardData(text: value));

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label copied')));
  }

  Future<void> _changeServer() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Change server?',
      message:
          'This signs you out and takes you back to the server setup screen.',
      confirmLabel: 'Change server',
      action: () async {
        await ref.read(authTokenProvider.notifier).clear();
        await ref.read(serverUrlProvider.notifier).clear();
      },
    );

    if (!confirmed || !mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildIdentityCard(String serverUrl) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.dns_rounded,
                size: 22,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _instance?.instanceName ?? 'Server',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    serverUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionSection(Version version) {
    final colorScheme = Theme.of(context).colorScheme;

    final release = version.display ?? version.releaseTag;
    final commitSha = version.commitSha;
    final shortSha = commitSha.substring(0, _shortShaLength);

    final rows = <Widget>[
      if (release != null) _DetailRow(label: 'Release', value: release),
      if (version.refName != null)
        _DetailRow(label: 'Ref', value: version.refName!),
      _DetailRow(
        label: 'Commit',
        value: shortSha,
        onCopy: () => _copy(value: commitSha, label: 'Commit'),
      ),
      _DetailRow(
        label: 'Repository',
        value: version.repositoryUrl,
        onCopy: () => _copy(value: version.repositoryUrl, label: 'Repository'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionLabel('Version'),
        const Gap(8),
        SettingsSectionCard(
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: 18,
                    endIndent: 18,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                rows[index],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _errorMessage ?? 'Could not reach the server.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loadInstance,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_status) {
      _InstanceStatus.loading => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      _InstanceStatus.error => _buildErrorCard(),
      _InstanceStatus.ready => _buildVersionSection(_instance!.version),
    };
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = ref.watch(serverUrlProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const Gap(4),
                  Text(
                    'Server',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIdentityCard(serverUrl ?? 'Loading…'),
                    const Gap(24),
                    _buildBody(),
                    const Gap(12),
                    SettingsSectionCard(
                      child: SettingsTile(
                        icon: Icons.swap_horiz_rounded,
                        title: 'Change server',
                        isDestructive: true,
                        isCompact: true,
                        onTap: _changeServer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.onCopy});

  final String label;
  final String value;

  final Future<void> Function()? onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final valueStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w400,
    );

    return InkWell(
      onTap: onCopy,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: valueStyle,
              ),
            ),
            if (onCopy != null) ...[
              const Gap(12),
              Icon(
                Icons.copy_rounded,
                size: 17,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
