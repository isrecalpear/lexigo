import 'package:flutter/material.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:lexigo/datas/orms/words.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/pages/word_management/word_add_page.dart';
import 'package:lexigo/pages/word_management/word_edit_page.dart';
import 'package:lexigo/utils/app_logger.dart';

class WordViewPage extends StatefulWidget {
	const WordViewPage({super.key});

	@override
	State<WordViewPage> createState() => _WordViewPageState();
}

class _WordViewPageState extends State<WordViewPage> {
	LanguageCode _languageCode = LanguageCode.ko;
	bool _isLoading = false;
	List<_WordWithCard> _words = [];

	@override
	void initState() {
		super.initState();
		AppLogger.info('进入单词查看页面');
		_loadWords();
	}

	@override
	void dispose() {
		AppLogger.info('离开单词查看页面');
		super.dispose();
	}

	Future<void> _loadWords() async {
		setState(() {
			_isLoading = true;
		});

		try {
			final dao = await WordDao.open();
			final words = await dao.getWords(
				_languageCode,
				orderBy: 'card_due ASC',
			);

			final result = <_WordWithCard>[];
			for (final word in words) {
				final card = await word.card;
				result.add(_WordWithCard(word, card));
			}

			if (!mounted) return;
			setState(() {
				_words = result;
			});
		} catch (e, stackTrace) {
			AppLogger.error('加载单词列表失败', error: e, stackTrace: stackTrace);
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('加载失败: $e')),
			);
		} finally {
			if (mounted) {
				setState(() {
					_isLoading = false;
				});
			}
		}
	}

	Future<void> _editWord(_WordWithCard item) async {
		final updated = await Navigator.push<bool>(
			context,
			MaterialPageRoute(
				builder: (context) => WordEditPage(
					word: item.word,
					card: item.card,
				),
			),
		);

		if (updated == true) {
			await _loadWords();
		}
	}

	Future<void> _deleteWord(_WordWithCard item) async {
		final confirm = await showDialog<bool>(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: const Text('删除单词'),
					content: Text('确定删除 ${item.word.originalWord} 吗？'),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context, false),
							child: const Text('取消'),
						),
						FilledButton(
							onPressed: () => Navigator.pop(context, true),
							child: const Text('删除'),
						),
					],
				);
			},
		);

		if (confirm != true) {
			return;
		}

		try {
			final dao = await WordDao.open();
			await dao.deleteWordsByCardIds(
				_languageCode,
				[item.card.cardId],
			);
			AppLogger.info('删除单词成功: ${item.word.originalWord}');
			if (!mounted) return;
			await _loadWords();
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('删除成功')),
			);
		} catch (e, stackTrace) {
			AppLogger.error('删除单词失败', error: e, stackTrace: stackTrace);
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('删除失败: $e')),
			);
		}
	}


	String _familiarityLabel(fsrs.Card card) {
		switch (card.state) {
			case fsrs.State.learning:
				return '生疏';
			case fsrs.State.relearning:
				return '不熟';
			case fsrs.State.review:
				return '熟悉';
		}
	}

	Color _familiarityColor(fsrs.Card card, BuildContext context) {
		switch (card.state) {
			case fsrs.State.learning:
				return Theme.of(context).colorScheme.error;
			case fsrs.State.relearning:
				return Theme.of(context).colorScheme.tertiary;
			case fsrs.State.review:
				return Theme.of(context).colorScheme.primary;
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('单词管理'),
				actions: [
					IconButton(
						icon: const Icon(Icons.add),
						onPressed: () {
							Navigator.push(
								context,
								MaterialPageRoute(
									builder: (context) => const WordAddPage(),
								),
							).then((_) => _loadWords());
						},
					),
				],
			),
			body: SafeArea(
				child: Column(
					children: [
						Padding(
							padding: const EdgeInsets.all(16),
							child: DropdownButtonFormField<LanguageCode>(
								initialValue: _languageCode,
								decoration: const InputDecoration(
									labelText: '语言',
									border: OutlineInputBorder(),
								),
								items: LanguageCode.values
										.map(
												(item) => DropdownMenuItem(
													value: item,
													child: Text(item.name),
												),
										)
										.toList(),
								onChanged: _isLoading
										? null
										: (value) {
											if (value == null) return;
											setState(() {
												_languageCode = value;
											});
											_loadWords();
										},
							),
						),
						Expanded(
							child: RefreshIndicator(
								onRefresh: _loadWords,
								child: _isLoading
										? const Center(child: CircularProgressIndicator())
										: _words.isEmpty
												? const Center(child: Text('暂无单词'))
												: ListView.separated(
													itemCount: _words.length,
													separatorBuilder: (_, _) => const Divider(height: 1),
													itemBuilder: (context, index) {
														final item = _words[index];
														final familiarity = _familiarityLabel(item.card);
														final color = _familiarityColor(item.card, context);

														return ListTile(
															title: Text(item.word.originalWord),
															subtitle: Text(item.word.translation),
															trailing: Row(
																mainAxisSize: MainAxisSize.min,
																children: [
																	Chip(
																		label: Text(familiarity),
																		backgroundColor: color.withValues(alpha: 0.15),
																		labelStyle: TextStyle(color: color),
																	),
																	const SizedBox(width: 8),
																	PopupMenuButton<String>(
																		onSelected: (value) {
																		switch (value) {
																			case 'edit':
																				_editWord(item);
																				break;
																			case 'delete':
																				_deleteWord(item);
																				break;
																		}
																	},
																	itemBuilder: (context) => const [
																		PopupMenuItem(
																			value: 'edit',
																			child: Text('编辑'),
																		),
																		PopupMenuItem(
																			value: 'delete',
																			child: Text('删除'),
																		),
																	],
																),
																],
															),
															isThreeLine: true,
															dense: false,
															onTap: () {
																AppLogger.debug(
																	'查看单词: ${item.word.originalWord}',
																);
															},
														);
													},
												),
							),
						),
					],
				),
			),
		);
	}
}

class _WordWithCard {
	_WordWithCard(this.word, this.card);

	final Word word;
	final fsrs.Card card;
}
