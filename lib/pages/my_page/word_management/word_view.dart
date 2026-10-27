/// Page for viewing and managing existing words in a language.
///
/// Displays words in a list with buttons to add, edit, or delete words.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/manager.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/records/records_format.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/settings.dart';

/// Word list viewer and manager.
class WordViewPage extends StatefulWidget {
  const WordViewPage({super.key});

  @override
  State<WordViewPage> createState() => _WordViewPageState();
}

class _WordViewPageState extends State<WordViewPage> {
  LanguageCode _languageCode = SettingsStore.instance.settings.learningLanguage;
  bool _isLoading = false;
  List<Word> _words = [];
  final _wordManager = WordManager();

  @override
  void initState() {
    super.initState();
    AppLogger.info('Entering word view page');
    _loadWords();
  }

  @override
  void dispose() {
    AppLogger.info('Leaving word view page');
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final words = await _wordManager.getWords(_languageCode);

      if (!mounted) return;
      setState(() {
        _words = words;
      });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load word list',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loadFailed('$e'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddPage() async {
    await Navigator.push(
      context,
      AppRoutes.wordAdd(languageCode: _languageCode),
    );
    if (mounted) {
      await _loadWords();
    }
  }

  Future<void> _editWord(Word word) async {
    final updated = await Navigator.push<Word>(
      context,
      AppRoutes.wordEdit(word: word, card: word.card),
    );

    if (updated != null) {
      await _loadWords();
    }
  }

  Future<void> _deleteWord(Word word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final ColorScheme colors = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 28,
            color: colors.error,
          ),
          title: Text(context.l10n.deleteWordTitle),
          content: Text(context.l10n.deleteWordConfirm(word.originalWord)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _wordManager.deleteWordsByCardId([word.card.cardId]);
      AppLogger.info('Deleted word successfully: ${word.originalWord}');
      await _loadWords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleteSuccess)),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete word',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.deleteFailed('$e')),
          ),
        );
      }
    }
  }

  String _familiarityLabel(fsrs.Card card, BuildContext context) {
    switch (card.state) {
      case fsrs.State.learning:
        return AppLocalizations.of(context)!.familiarityLearning;
      case fsrs.State.relearning:
        return AppLocalizations.of(context)!.familiarityRelearning;
      case fsrs.State.review:
        return AppLocalizations.of(context)!.familiarityReview;
    }
  }

  /// Language filter shown above the list.
  Widget _buildLanguageFilter(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: <Widget>[
          AppIconBadge(icon: Icons.translate_rounded, size: 40, iconSize: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final LanguageCode code in LanguageCode.values)
                  ChoiceChip(
                    label: Text(_languageName(context, code)),
                    selected: _languageCode == code,
                    onSelected: _isLoading
                        ? null
                        : (bool selected) {
                            if (!selected) return;
                            setState(() {
                              _languageCode = code;
                            });
                            _loadWords();
                          },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds one word row.
  Widget _buildWordRow(BuildContext context, Word word) {
    final String familiarity = _familiarityLabel(word.card, context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AppSurface(
      onTap: () {
        AppLogger.debug('View word: ${word.originalWord}');
      },
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xxs,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  word.originalWord,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  word.originalTranslation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppPill(
            label: familiarity,
            color: stateOnColor(colors, word.card.state),
            backgroundColor: stateContainerColor(colors, word.card.state),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editWord(word);
                  break;
                case 'delete':
                  _deleteWord(word);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(AppLocalizations.of(context)!.edit),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: colors.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(AppLocalizations.of(context)!.delete),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Scrollable empty state, kept inside a list so pull-to-refresh still works.
  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppInsets.page,
      children: <Widget>[
        AppEmptyState(
          icon: Icons.list_alt_rounded,
          title: AppLocalizations.of(context)!.wordViewEmpty,
          message: context.l10n.wordListEmptyHint,
          action: FilledButton.tonal(
            onPressed: _openAddPage,
            child: Text(AppLocalizations.of(context)!.addWordTitle),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wordViewTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: context.l10n.addWordTitle,
            onPressed: _openAddPage,
          ),
        ],
      ),
      body: SafeArea(
        child: AppContent(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: _buildLanguageFilter(context),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadWords,
                  child: _isLoading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const <Widget>[
                            SizedBox(height: 200, child: AppLoading()),
                          ],
                        )
                      : _words.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xxl,
                          ),
                          itemCount: _words.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.xs),
                          itemBuilder: (context, index) =>
                              _buildWordRow(context, _words[index]),
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

/// Localized display name of [code].
String _languageName(BuildContext context, LanguageCode code) {
  return switch (code) {
    LanguageCode.ko => context.l10n.languageKoreanName,
    LanguageCode.ru => context.l10n.languageRussianName,
    LanguageCode.en => context.l10n.languageEnglishName,
  };
}
