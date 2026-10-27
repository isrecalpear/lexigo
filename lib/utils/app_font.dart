/// Font choices available for the application UI.
///
/// Only the platform system font is bundled with the application. The optional
/// fonts are downloaded from their vendors' official websites at runtime and
/// cached in the application support directory, see [FontManager].
library;

/// User-selectable font for the application interface.
enum AppFont {
  /// The operating system's built-in UI font (default, nothing downloaded).
  system(
    storageId: 'system',
    familyName: null,
    officialPageUrl: null,
    downloadUrl: null,
    approximateSizeMb: null,
  ),

  /// Xiaomi MiSans, available from the official HyperOS font site.
  miSans(
    storageId: 'misans',
    familyName: 'MiSans',
    officialPageUrl: 'https://hyperos.mi.com/font/en/details/sc/',
    downloadUrl: 'https://hyperos.mi.com/font-download/MiSans.zip',
    approximateSizeMb: 218,
  ),

  /// Huawei HarmonyOS Sans, available from the official Huawei developer site.
  harmonyOS(
    storageId: 'harmonyos',
    familyName: 'HarmonyOS Sans',
    officialPageUrl:
        'https://developer.huawei.com/consumer/cn/design/resource-V1/',
    downloadUrl:
        'https://developer.huawei.com/images/download/general/HarmonyOS-Sans.zip',
    approximateSizeMb: 52,
  );

  const AppFont({
    required this.storageId,
    required this.familyName,
    required this.officialPageUrl,
    required this.downloadUrl,
    required this.approximateSizeMb,
  });

  /// Stable identifier used in `settings.yaml` and as the cache directory name.
  final String storageId;

  /// Font family registered with Flutter's font engine.
  ///
  /// `null` for [AppFont.system], which means "inherit the platform font".
  final String? familyName;

  /// Official page that documents and distributes the font.
  final String? officialPageUrl;

  /// Direct link to the official font archive.
  final String? downloadUrl;

  /// Rough size of the official archive in megabytes, used by the download
  /// confirmation dialog. `null` for [AppFont.system].
  final int? approximateSizeMb;

  /// Whether this option maps to the platform's own font.
  bool get isSystem => this == AppFont.system;

  /// Resolves a persisted [storageId] back to an [AppFont].
  ///
  /// Unknown or missing values fall back to [AppFont.system] so settings written
  /// by older versions keep working.
  static AppFont fromStorageId(String? raw) {
    for (final AppFont font in AppFont.values) {
      if (font.storageId == raw) {
        return font;
      }
    }
    return AppFont.system;
  }
}
