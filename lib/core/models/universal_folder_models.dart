class StoredFileItem {
  const StoredFileItem({
    required this.name,
    required this.size,
    required this.modifiedAt,
    this.path,
  });

  final String name;
  final int size;
  final DateTime modifiedAt;
  final String? path;

  bool get isFolderArchive => name.toLowerCase().endsWith('.ufd');
  bool get isCompressedAsset => name.toLowerCase().endsWith('.uf');
  bool get canBeDecompressed => isCompressedAsset || isFolderArchive;

  factory StoredFileItem.fromJson(Map<String, dynamic> json) {
    return StoredFileItem(
      name: json['name'] as String? ?? 'unknown',
      size: (json['size'] as num?)?.toInt() ?? 0,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['mtime'] as num?)?.toInt() ?? 0,
      ),
      path: json['path'] as String?,
    );
  }
}

class BackendStats {
  const BackendStats({
    required this.ratio,
    required this.heatReduction,
    required this.accessTimeMs,
    required this.systemStatus,
    required this.activeTips,
    required this.creases,
  });

  final String ratio;
  final String heatReduction;
  final String accessTimeMs;
  final String systemStatus;
  final int activeTips;
  final int creases;

  factory BackendStats.fromJson(Map<String, dynamic> json) {
    return BackendStats(
      ratio: json['ratio']?.toString() ?? '-',
      heatReduction: json['heat_reduction']?.toString() ?? '-',
      accessTimeMs: json['access_time_ms']?.toString() ?? '-',
      systemStatus: json['system_status']?.toString() ?? 'Unknown',
      activeTips: (json['active_tips'] as num?)?.toInt() ?? 0,
      creases: (json['creases'] as num?)?.toInt() ?? 0,
    );
  }
}

class CompressionResponse {
  const CompressionResponse({
    required this.filename,
    required this.size,
    required this.originalSize,
    required this.ratio,
    required this.type,
    this.localPath,
  });

  final String filename;
  final int size;
  final int originalSize;
  final double ratio;
  final String type;
  final String? localPath;

  double get savingsFraction {
    if (originalSize <= 0) return 0;
    return 1 - (size / originalSize);
  }

  factory CompressionResponse.fromJson(Map<String, dynamic> json) {
    return CompressionResponse(
      filename: json['filename'] as String? ?? 'compressed.uf',
      size: (json['size'] as num?)?.toInt() ?? 0,
      originalSize: (json['original_size'] as num?)?.toInt() ?? 0,
      ratio: (json['ratio'] as num?)?.toDouble() ?? 1.0,
      type: json['type'] as String? ?? 'uf',
      localPath: json['local_path'] as String?,
    );
  }

  CompressionResponse copyWith({String? localPath}) {
    return CompressionResponse(
      filename: filename,
      size: size,
      originalSize: originalSize,
      ratio: ratio,
      type: type,
      localPath: localPath ?? this.localPath,
    );
  }
}

class DecompressionResponse {
  const DecompressionResponse({
    required this.filename,
    required this.size,
    required this.type,
    this.localPath,
  });

  final String filename;
  final int size;
  final String type;
  final String? localPath;

  factory DecompressionResponse.fromJson(Map<String, dynamic> json) {
    return DecompressionResponse(
      filename: json['filename'] as String? ?? 'output',
      size: (json['size'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'file',
      localPath: json['local_path'] as String?,
    );
  }

  DecompressionResponse copyWith({String? localPath}) {
    return DecompressionResponse(
      filename: filename,
      size: size,
      type: type,
      localPath: localPath ?? this.localPath,
    );
  }
}

enum OperationKind { compression, decompression }

class PlatformUser {
  const PlatformUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.defaultPlanCode,
    required this.isAdmin,
  });

  final int id;
  final String fullName;
  final String email;
  final String defaultPlanCode;
  final bool isAdmin;

  factory PlatformUser.fromJson(Map<String, dynamic> json) {
    return PlatformUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      defaultPlanCode: json['default_plan_code'] as String? ?? 'starter',
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final PlatformUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String? ?? '',
      user: PlatformUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

class PricingPlan {
  const PricingPlan({
    required this.code,
    required this.name,
    required this.priceMonthlyCents,
    required this.storageQuotaGb,
    required this.maxFileSizeMb,
    required this.features,
    required this.active,
  });

  final String code;
  final String name;
  final int priceMonthlyCents;
  final int storageQuotaGb;
  final int maxFileSizeMb;
  final List<String> features;
  final bool active;

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priceMonthlyCents: (json['price_monthly_cents'] as num?)?.toInt() ?? 0,
      storageQuotaGb: (json['storage_quota_gb'] as num?)?.toInt() ?? 0,
      maxFileSizeMb: (json['max_file_size_mb'] as num?)?.toInt() ?? 0,
      features: (json['features'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
      active: json['active'] as bool? ?? true,
    );
  }
}

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.planCode,
    required this.status,
    required this.provider,
    this.externalReference,
    this.currentPeriodEnd,
  });

  final String planCode;
  final String status;
  final String provider;
  final String? externalReference;
  final String? currentPeriodEnd;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      planCode: json['plan_code'] as String? ?? 'starter',
      status: json['status'] as String? ?? 'inactive',
      provider: json['provider'] as String? ?? 'none',
      externalReference: json['external_reference'] as String?,
      currentPeriodEnd: json['current_period_end'] as String?,
    );
  }
}

class CheckoutSession {
  const CheckoutSession({
    required this.checkoutUrl,
    required this.provider,
    required this.reference,
    required this.requiresExternalCheckout,
  });

  final String checkoutUrl;
  final String provider;
  final String reference;
  final bool requiresExternalCheckout;

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      checkoutUrl: json['checkout_url'] as String? ?? '',
      provider: json['provider'] as String? ?? 'demo',
      reference: json['reference'] as String? ?? '',
      requiresExternalCheckout: json['requires_external_checkout'] as bool? ?? false,
    );
  }
}

class CloudProviderInfo {
  const CloudProviderInfo({
    required this.code,
    required this.name,
    required this.authType,
    required this.syncModes,
  });

  final String code;
  final String name;
  final String authType;
  final List<String> syncModes;

  factory CloudProviderInfo.fromJson(Map<String, dynamic> json) {
    return CloudProviderInfo(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      authType: json['auth_type'] as String? ?? '',
      syncModes: (json['sync_modes'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
    );
  }
}

class CloudConnectionInfo {
  const CloudConnectionInfo({
    required this.id,
    required this.provider,
    required this.accountLabel,
    required this.status,
    required this.syncEnabled,
    required this.syncMode,
    required this.compressBeforeSync,
  });

  final int id;
  final String provider;
  final String accountLabel;
  final String status;
  final bool syncEnabled;
  final String syncMode;
  final bool compressBeforeSync;

  factory CloudConnectionInfo.fromJson(Map<String, dynamic> json) {
    return CloudConnectionInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      provider: json['provider'] as String? ?? '',
      accountLabel: json['account_label'] as String? ?? '',
      status: json['status'] as String? ?? '',
      syncEnabled: json['sync_enabled'] as bool? ?? false,
      syncMode: json['sync_mode'] as String? ?? 'manual',
      compressBeforeSync: json['compress_before_sync'] as bool? ?? true,
    );
  }
}

class CloudSyncSettingsModel {
  const CloudSyncSettingsModel({
    required this.autoSync,
    required this.wifiOnly,
    required this.compressBeforeSync,
    required this.syncPhotos,
    required this.syncDocs,
    required this.syncVideos,
  });

  final bool autoSync;
  final bool wifiOnly;
  final bool compressBeforeSync;
  final bool syncPhotos;
  final bool syncDocs;
  final bool syncVideos;

  factory CloudSyncSettingsModel.fromJson(Map<String, dynamic> json) {
    return CloudSyncSettingsModel(
      autoSync: json['auto_sync'] as bool? ?? true,
      wifiOnly: json['wifi_only'] as bool? ?? true,
      compressBeforeSync: json['compress_before_sync'] as bool? ?? true,
      syncPhotos: json['sync_photos'] as bool? ?? true,
      syncDocs: json['sync_docs'] as bool? ?? true,
      syncVideos: json['sync_videos'] as bool? ?? false,
    );
  }
}

class PlatformApiKey {
  const PlatformApiKey({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.keyPreview,
    this.apiKey,
  });

  final int id;
  final String name;
  final String createdAt;
  final String keyPreview;
  final String? apiKey;

  factory PlatformApiKey.fromJson(Map<String, dynamic> json) {
    return PlatformApiKey(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      keyPreview: json['key_preview'] as String? ?? '',
      apiKey: json['api_key'] as String?,
    );
  }
}
