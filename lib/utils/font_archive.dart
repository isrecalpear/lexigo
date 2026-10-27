/// Pure-Dart helpers for selecting and extracting fonts from vendor archives.
///
/// This file intentionally has no Flutter dependency so the extraction rules can
/// be exercised with plain `dart run` scripts (and unit tests) without a Flutter
/// engine. [FontManager] uses it before registering the files with [FontLoader].
library;

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:archive/archive_io.dart';

/// A font file extracted from a vendor archive.
class ExtractedFont {
  const ExtractedFont({required this.weight, required this.file});

  /// CSS/Flutter font weight represented by this file.
  final int weight;

  /// Extracted file inside the target directory.
  final File file;
}

/// Result of a successful [FontArchiveExtractor.extract] call.
class FontArchiveResult {
  const FontArchiveResult(this.fonts);

  /// Extracted files, sorted by weight.
  final List<ExtractedFont> fonts;
}

/// A font entry chosen from the archive, before it is written to disk.
class _SelectedFont {
  const _SelectedFont({
    required this.entry,
    required this.weight,
    required this.fileName,
  });

  final ArchiveFile entry;
  final int weight;
  final String fileName;
}

/// Selects the required weights from a vendor font archive and writes them to
/// [targetDirectory].
///
/// The official MiSans and HarmonyOS Sans archives contain many variants
/// (OTF, TTF, variable fonts, italics, Traditional Chinese, Arabic, ...). Only
/// the Simplified Chinese (or default) set for the weights used by Material's
/// text theme is kept.
abstract final class FontArchiveExtractor {
  /// Fonts smaller than this are icon helpers or macOS resource forks.
  static const int minimumFontFileSize = 100 * 1024;

  /// Weight keywords matched against lower-case font file names.
  static const List<(List<String>, int)> _weightMatchers =
      <(List<String>, int)>[
        (['regular', 'normal', 'book'], 400),
        (['medium'], 500),
        (['semibold', 'demibold'], 600),
        (['bold'], 700),
      ];

  /// Locale/variant tokens that should not be installed on a Chinese UI.
  static const List<String> _excludedTokens = <String>[
    'lao',
    'arabic',
    'devanagari',
    'gujarati',
    'gurmukhi',
    'khmer',
    'l3',
    'latin',
    'myanmar',
    'tc',
    'thai',
    'tibetan',
    'japanese',
    'korean',
  ];

  /// Decodes [archiveFile] and extracts the wanted font files.
  ///
  /// Returns an empty result when the archive contains no matching fonts; the
  /// caller should treat that as an invalid font package.
  static Future<FontArchiveResult> extract(
    File archiveFile,
    Directory targetDirectory, {
    Set<int> wantedWeights = const <int>{400, 500, 600, 700},
  }) async {
    final Archive archive = ZipDecoder().decodeStream(
      InputFileStream(archiveFile.path),
    );
    try {
      final List<_SelectedFont> selected = _selectFonts(
        archive.files,
        wantedWeights,
      );

      final List<ExtractedFont> extracted = <ExtractedFont>[];
      for (final _SelectedFont font in selected) {
        final File target = File('${targetDirectory.path}/${font.fileName}');
        final OutputFileStream output = OutputFileStream(target.path);
        try {
          font.entry.writeContent(output);
        } finally {
          output.closeSync();
        }
        if (await target.length() > 0) {
          extracted.add(ExtractedFont(weight: font.weight, file: target));
        }
      }

      extracted.sort(
        (ExtractedFont a, ExtractedFont b) => a.weight.compareTo(b.weight),
      );
      return FontArchiveResult(extracted);
    } finally {
      archive.clearSync();
    }
  }

  static List<_SelectedFont> _selectFonts(
    List<ArchiveFile> entries,
    Set<int> wantedWeights,
  ) {
    final List<ArchiveFile> fontFiles = entries.where((ArchiveFile entry) {
      if (!entry.isFile) {
        return false;
      }
      final String path = entry.name.toLowerCase();
      if (!path.endsWith('.ttf') && !path.endsWith('.otf')) {
        return false;
      }
      if (path.contains('__macosx') || path.contains('italic')) {
        return false;
      }
      if (entry.size < minimumFontFileSize) {
        return false;
      }
      return true;
    }).toList();

    if (fontFiles.isEmpty) {
      return <_SelectedFont>[];
    }

    List<ArchiveFile> pool = fontFiles
        .where(
          (ArchiveFile entry) => !_matchesAnyToken(entry.name, _excludedTokens),
        )
        .toList();
    if (pool.isEmpty) {
      pool = fontFiles;
    }

    // Prefer Simplified Chinese variants when the archive ships several locales.
    final List<ArchiveFile> simplified = pool
        .where((ArchiveFile entry) => _matchesAnyToken(entry.name, ['sc']))
        .toList();
    if (simplified.isNotEmpty) {
      pool = simplified;
    }

    final Map<int, _SelectedFont> byWeight = <int, _SelectedFont>{};
    for (final ArchiveFile entry in pool) {
      final int? weight = _weightOf(entry.name);
      if (weight == null || !wantedWeights.contains(weight)) {
        continue;
      }

      final _SelectedFont candidate = _SelectedFont(
        entry: entry,
        weight: weight,
        fileName: _fileNameFor(entry.name, weight),
      );
      final _SelectedFont? current = byWeight[weight];
      if (current == null || _preferEntry(candidate, current)) {
        byWeight[weight] = candidate;
      }
    }

    final List<_SelectedFont> result = byWeight.values.toList()
      ..sort(
        (_SelectedFont a, _SelectedFont b) => a.weight.compareTo(b.weight),
      );
    return result;
  }

  /// Picks the "best" file when one weight appears more than once.
  ///
  /// Regular is preferred over Normal/Book and SemiBold over DemiBold, since
  /// the former names are canonical. When two files carry the same name (MiSans
  /// ships both `.otf` and `.ttf`), the TrueType variant is preferred because it
  /// is the most portable format.
  static bool _preferEntry(_SelectedFont candidate, _SelectedFont current) {
    final int candidateScore = _nameScore(candidate.entry.name);
    final int currentScore = _nameScore(current.entry.name);
    if (candidateScore != currentScore) {
      return candidateScore > currentScore;
    }
    final bool candidateIsTtf = candidate.entry.name.toLowerCase().endsWith(
      '.ttf',
    );
    final bool currentIsTtf = current.entry.name.toLowerCase().endsWith('.ttf');
    return candidateIsTtf && !currentIsTtf;
  }

  static int _nameScore(String name) {
    final String lower = name.toLowerCase();
    if (lower.contains('regular')) {
      return 3;
    }
    if (lower.contains('semibold')) {
      return 3;
    }
    if (lower.contains('normal') || lower.contains('demibold')) {
      return 2;
    }
    if (lower.contains('book')) {
      return 1;
    }
    return 0;
  }

  static int? _weightOf(String name) {
    final String lower = name.toLowerCase();
    for (final (List<String> keywords, int weight) in _weightMatchers) {
      for (final String keyword in keywords) {
        if (lower.contains(keyword)) {
          return weight;
        }
      }
    }
    return null;
  }

  static bool _matchesAnyToken(String name, List<String> tokens) {
    final String lower = name.toLowerCase();
    for (final String token in tokens) {
      final bool matches = RegExp(
        '(^|[^a-z])${RegExp.escape(token)}([^a-z]|\$)',
      ).hasMatch(lower);
      if (matches) {
        return true;
      }
    }
    return false;
  }

  static String _fileNameFor(String entryName, int weight) {
    final String baseName = entryName.split(RegExp(r'[/\\]')).last;
    final String sanitized = baseName.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    return '$weight-$sanitized';
  }
}
