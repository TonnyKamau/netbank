import '../models/universal_folder_models.dart';
import 'platform_auth_service.dart';
import 'universal_folder_api.dart';

class PlatformAccountService {
  PlatformAccountService._();

  static final PlatformAccountService instance = PlatformAccountService._();

  String _token() {
    final token = PlatformAuthService.instance.token;
    if ((token ?? '').isEmpty) {
      throw UniversalFolderApiException('You need to log in first.');
    }
    return token!;
  }

  Future<List<PricingPlan>> fetchPlans() async {
    final data = await UniversalFolderApi.instance.getJsonList('/plans');
    return data.map(PricingPlan.fromJson).toList();
  }

  Future<SubscriptionInfo> fetchSubscription() async {
    final data = await UniversalFolderApi.instance.getJsonMap(
      '/subscriptions/me',
      bearerToken: _token(),
    );
    return SubscriptionInfo.fromJson(data);
  }

  Future<CheckoutSession> createCheckoutSession(String planCode) async {
    final data = await UniversalFolderApi.instance.postJson(
      '/subscriptions/checkout-session',
      {'plan_code': planCode},
      bearerToken: _token(),
    );
    return CheckoutSession.fromJson(data);
  }

  Future<SubscriptionInfo> activateDemoPlan(String planCode, {String? reference}) async {
    final data = await UniversalFolderApi.instance.postJson(
      '/subscriptions/activate-demo',
      {
        'plan_code': planCode,
        'reference': reference,
      }..removeWhere((key, value) => value == null),
      bearerToken: _token(),
    );
    return SubscriptionInfo.fromJson(data);
  }

  Future<List<CloudProviderInfo>> fetchCloudProviders() async {
    final data = await UniversalFolderApi.instance.getJsonList('/cloud/providers');
    return data.map(CloudProviderInfo.fromJson).toList();
  }

  Future<List<CloudConnectionInfo>> fetchCloudConnections() async {
    final data = await UniversalFolderApi.instance.getJsonList(
      '/cloud/connections',
      bearerToken: _token(),
    );
    return data.map(CloudConnectionInfo.fromJson).toList();
  }

  Future<CloudConnectionInfo> connectCloud({
    required String provider,
    required String accountLabel,
    String syncMode = 'manual',
    bool compressBeforeSync = true,
  }) async {
    final data = await UniversalFolderApi.instance.postJson(
      '/cloud/connections',
      {
        'provider': provider,
        'account_label': accountLabel,
        'sync_mode': syncMode,
        'compress_before_sync': compressBeforeSync,
      },
      bearerToken: _token(),
    );
    return CloudConnectionInfo.fromJson(data);
  }

  Future<void> disconnectCloud(int connectionId) async {
    await UniversalFolderApi.instance.delete(
      '/cloud/connections/$connectionId',
      bearerToken: _token(),
    );
  }

  Future<CloudSyncSettingsModel> fetchCloudSettings() async {
    final data = await UniversalFolderApi.instance.getJsonMap(
      '/cloud/settings',
      bearerToken: _token(),
    );
    return CloudSyncSettingsModel.fromJson(data);
  }

  Future<CloudSyncSettingsModel> updateCloudSettings(CloudSyncSettingsModel settings) async {
    final data = await UniversalFolderApi.instance.putJson(
      '/cloud/settings',
      {
        'auto_sync': settings.autoSync,
        'wifi_only': settings.wifiOnly,
        'compress_before_sync': settings.compressBeforeSync,
        'sync_photos': settings.syncPhotos,
        'sync_docs': settings.syncDocs,
        'sync_videos': settings.syncVideos,
      },
      bearerToken: _token(),
    );
    return CloudSyncSettingsModel.fromJson(data);
  }

  Future<List<PlatformApiKey>> fetchApiKeys() async {
    final data = await UniversalFolderApi.instance.getJsonList(
      '/keys',
      bearerToken: _token(),
    );
    return data.map(PlatformApiKey.fromJson).toList();
  }

  Future<PlatformApiKey> createApiKey(String name) async {
    final data = await UniversalFolderApi.instance.postJson(
      '/keys',
      {'name': name},
      bearerToken: _token(),
    );
    return PlatformApiKey.fromJson(data);
  }

  Future<void> revokeApiKey(int keyId) async {
    await UniversalFolderApi.instance.delete(
      '/keys/$keyId',
      bearerToken: _token(),
    );
  }
}
