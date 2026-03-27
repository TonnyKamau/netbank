import 'package:flutter/material.dart';

import '../../core/models/universal_folder_models.dart';
import '../../core/services/platform_account_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

class ConnectCloudScreen extends StatefulWidget {
  const ConnectCloudScreen({super.key, this.onBack, this.onConnect});

  final VoidCallback? onBack;
  final ValueChanged<String>? onConnect;

  @override
  State<ConnectCloudScreen> createState() => _ConnectCloudScreenState();
}

class _ConnectCloudScreenState extends State<ConnectCloudScreen> {
  final _account = PlatformAccountService.instance;
  late Future<List<CloudProviderInfo>> _providersFuture;
  String? _message;

  @override
  void initState() {
    super.initState();
    _providersFuture = _account.fetchCloudProviders();
  }

  Future<void> _connect(CloudProviderInfo provider) async {
    try {
      await _account.connectCloud(
        provider: provider.code,
        accountLabel: provider.name,
        syncMode: provider.syncModes.contains('auto') ? 'auto' : 'manual',
      );
      if (!mounted) return;
      setState(() => _message = '${provider.name} connected.');
      widget.onConnect?.call(provider.name);
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Connect Cloud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
      ),
      body: FutureBuilder<List<CloudProviderInfo>>(
        future: _providersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load cloud providers.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final providers = snapshot.data ?? const [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.primary.withValues(alpha: 0.02)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.cloud_sync, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cloud Integration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text('Providers and connections are now loaded from the backend platform API.', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Choose a Service', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                const SizedBox(height: 12),
                ...providers.map((provider) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CloudServiceCard(provider: provider, isDark: isDark, onConnect: _connect),
                )),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: _message!.contains('connected') ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CloudServiceCard extends StatelessWidget {
  const _CloudServiceCard({required this.provider, required this.isDark, required this.onConnect});

  final CloudProviderInfo provider;
  final bool isDark;
  final ValueChanged<CloudProviderInfo> onConnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.cloud_outlined, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                Text('${provider.authType} • ${provider.syncModes.join(", ")}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onConnect(provider),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(84, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}

class CloudSyncSettingsScreen extends StatefulWidget {
  const CloudSyncSettingsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<CloudSyncSettingsScreen> createState() => _CloudSyncSettingsScreenState();
}

class _CloudSyncSettingsScreenState extends State<CloudSyncSettingsScreen> {
  final _account = PlatformAccountService.instance;
  CloudSyncSettingsModel? _settings;
  List<CloudConnectionInfo> _connections = const [];
  String? _message;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _account.fetchCloudSettings();
      final connections = await _account.fetchCloudConnections();
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _connections = connections;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = error.toString();
      });
    }
  }

  Future<void> _save(CloudSyncSettingsModel settings) async {
    setState(() => _loading = true);
    try {
      final updated = await _account.updateCloudSettings(settings);
      if (!mounted) return;
      setState(() {
        _settings = updated;
        _loading = false;
        _message = 'Cloud sync settings saved.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading && _settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cloud Sync Settings'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack ?? () => Navigator.maybePop(context)),
        ),
        body: Center(child: Text(_message ?? 'Could not load settings.')),
      );
    }

    final settings = _settings!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Cloud Sync Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack ?? () => Navigator.maybePop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_connections.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: _connections.map((connection) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_done, color: AppColors.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${connection.accountLabel} • ${connection.status}',
                            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 20),
            _SwitchTile(
              title: 'Auto Sync',
              subtitle: 'Sync files automatically',
              value: settings.autoSync,
              onChanged: (value) => _save(CloudSyncSettingsModel(
                autoSync: value,
                wifiOnly: settings.wifiOnly,
                compressBeforeSync: settings.compressBeforeSync,
                syncPhotos: settings.syncPhotos,
                syncDocs: settings.syncDocs,
                syncVideos: settings.syncVideos,
              )),
              isDark: isDark,
            ),
            _SwitchTile(
              title: 'Wi-Fi Only',
              subtitle: 'Only sync on Wi-Fi networks',
              value: settings.wifiOnly,
              onChanged: (value) => _save(CloudSyncSettingsModel(
                autoSync: settings.autoSync,
                wifiOnly: value,
                compressBeforeSync: settings.compressBeforeSync,
                syncPhotos: settings.syncPhotos,
                syncDocs: settings.syncDocs,
                syncVideos: settings.syncVideos,
              )),
              isDark: isDark,
            ),
            _SwitchTile(
              title: 'Compress Before Sync',
              subtitle: 'Reduce file size before uploading',
              value: settings.compressBeforeSync,
              onChanged: (value) => _save(CloudSyncSettingsModel(
                autoSync: settings.autoSync,
                wifiOnly: settings.wifiOnly,
                compressBeforeSync: value,
                syncPhotos: settings.syncPhotos,
                syncDocs: settings.syncDocs,
                syncVideos: settings.syncVideos,
              )),
              isDark: isDark,
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: _message!.contains('saved') ? AppColors.success : AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.title, required this.value, required this.onChanged, required this.isDark, this.subtitle});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class CloudConnectionErrorScreen extends StatelessWidget {
  const CloudConnectionErrorScreen({super.key, this.onRetry, this.onBack});

  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack ?? () => Navigator.maybePop(context))),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Center(
              child: Container(
                width: context.s(100),
                height: context.s(100),
                decoration: const BoxDecoration(color: AppColors.errorLight, shape: BoxShape.circle),
                child: const Icon(Icons.cloud_off, color: AppColors.error, size: 52),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Connection Failed', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('The cloud provider could not be connected right now.', textAlign: TextAlign.center),
            const Spacer(),
            PrimaryButton(label: 'Try Again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class CloudConnectionSuccessScreen extends StatelessWidget {
  const CloudConnectionSuccessScreen({super.key, this.serviceName = 'Google Drive', this.onDone});

  final String serviceName;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: context.s(100),
                  height: context.s(100),
                  decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                  child: const Icon(Icons.cloud_done, color: AppColors.success, size: 52),
                ),
              ),
              const SizedBox(height: 24),
              Text('Connected!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('$serviceName has been connected through the platform backend.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.6)),
              const Spacer(),
              PrimaryButton(label: 'Get Started', onPressed: onDone),
            ],
          ),
        ),
      ),
    );
  }
}
