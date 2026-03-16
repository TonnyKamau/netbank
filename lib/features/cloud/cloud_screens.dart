import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

// ─────────────────────────────────────────
// Connect Cloud Service Screen
// ─────────────────────────────────────────
class ConnectCloudScreen extends StatelessWidget {
  const ConnectCloudScreen({super.key, this.onBack, this.onConnect});

  final VoidCallback? onBack;
  final ValueChanged<String>? onConnect;

  static const _services = [
    _CloudService(name: 'Google Drive', icon: Icons.drive_folder_upload, color: Color(0xFF4285F4), capacity: '15 GB free'),
    _CloudService(name: 'Dropbox', icon: Icons.cloud, color: Color(0xFF0061FF), capacity: '2 GB free'),
    _CloudService(name: 'OneDrive', icon: Icons.cloud_queue, color: Color(0xFF094AB2), capacity: '5 GB free'),
    _CloudService(name: 'iCloud', icon: Icons.cloud_circle, color: Color(0xFF5856D6), capacity: '5 GB free'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Connect Cloud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack ?? () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
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
                        Text('Connect your cloud storage to compress and sync files directly.', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Choose a Service', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            ..._services.map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CloudServiceCard(service: service, isDark: isDark, onConnect: onConnect),
            )),
            const SizedBox(height: 8),
            Text(
              'Your data is encrypted and never shared. You can disconnect at any time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloudService {
  const _CloudService({required this.name, required this.icon, required this.color, required this.capacity});
  final String name;
  final IconData icon;
  final Color color;
  final String capacity;
}

class _CloudServiceCard extends StatelessWidget {
  const _CloudServiceCard({required this.service, required this.isDark, this.onConnect});
  final _CloudService service;
  final bool isDark;
  final ValueChanged<String>? onConnect;

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
            decoration: BoxDecoration(color: service.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(service.icon, color: service.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                Text(service.capacity, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onConnect?.call(service.name),
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

// ─────────────────────────────────────────
// Cloud Sync Settings Screen
// ─────────────────────────────────────────
class CloudSyncSettingsScreen extends StatefulWidget {
  const CloudSyncSettingsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<CloudSyncSettingsScreen> createState() => _CloudSyncSettingsScreenState();
}

class _CloudSyncSettingsScreenState extends State<CloudSyncSettingsScreen> {
  bool _autoSync = true;
  bool _wifiOnly = true;
  bool _compressBeforeSync = false;
  bool _syncPhotos = true;
  bool _syncDocs = true;
  bool _syncVideos = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // Connected account
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: const Color(0xFF4285F4).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.drive_folder_upload, color: Color(0xFF4285F4), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Google Drive', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        Text('user@gmail.com • 8.2 GB used', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Connected', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              title: 'Sync Options',
              isDark: isDark,
              children: [
                _SwitchTile(title: 'Auto Sync', subtitle: 'Sync files automatically', value: _autoSync, onChanged: (v) => setState(() => _autoSync = v), isDark: isDark),
                _SwitchTile(title: 'Wi-Fi Only', subtitle: 'Only sync on Wi-Fi networks', value: _wifiOnly, onChanged: (v) => setState(() => _wifiOnly = v), isDark: isDark),
                _SwitchTile(title: 'Compress Before Sync', subtitle: 'Reduce file size before uploading', value: _compressBeforeSync, onChanged: (v) => setState(() => _compressBeforeSync = v), isDark: isDark),
              ],
            ),
            _SettingsGroup(
              title: 'File Types',
              isDark: isDark,
              children: [
                _SwitchTile(title: 'Photos', subtitle: 'Sync photo files', value: _syncPhotos, onChanged: (v) => setState(() => _syncPhotos = v), isDark: isDark),
                _SwitchTile(title: 'Documents', subtitle: 'Sync PDF, DOCX, etc.', value: _syncDocs, onChanged: (v) => setState(() => _syncDocs = v), isDark: isDark),
                _SwitchTile(title: 'Videos', subtitle: 'Sync video files', value: _syncVideos, onChanged: (v) => setState(() => _syncVideos = v), isDark: isDark),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildWithDividers(List<Widget> children, bool isDark) {
  final result = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    result.add(children[i]);
    if (i < children.length - 1) {
      result.add(Divider(height: 1, indent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight));
    }
  }
  return result;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.isDark, required this.children});
  final String title;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: _buildWithDividers(children, isDark),
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

// ─────────────────────────────────────────
// Cloud Connection Error Screen
// ─────────────────────────────────────────
class CloudConnectionErrorScreen extends StatelessWidget {
  const CloudConnectionErrorScreen({super.key, this.onRetry, this.onBack});

  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
            Text('Connection Failed', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text('Unable to connect to cloud storage. Please check your internet connection and try again.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.6)),
            const Spacer(),
            PrimaryButton(label: 'Try Again', onPressed: onRetry),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onBack ?? () => Navigator.maybePop(context), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)), child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Cloud Connection Success Screen
// ─────────────────────────────────────────
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
              Text('$serviceName has been successfully connected. You can now compress and sync files directly to your cloud storage.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.6)),
              const SizedBox(height: 32),
              // Features list
              ...[
                'Compress files directly to cloud',
                'Auto-sync compressed files',
                'Access files from any device',
              ].map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle), child: const Icon(Icons.check, color: AppColors.success, size: 16)),
                    const SizedBox(width: 12),
                    Text(f, style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  ],
                ),
              )),
              const Spacer(),
              PrimaryButton(label: 'Get Started', onPressed: onDone),
            ],
          ),
        ),
      ),
    );
  }
}
