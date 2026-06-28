// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface.dart';

// ignore_for_file: type=lint
class $WordTableTable extends WordTable
    with TableInfo<$WordTableTable, WordTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalWordMeta = const VerificationMeta(
    'originalWord',
  );
  @override
  late final GeneratedColumn<String> originalWord = GeneratedColumn<String>(
    'original_word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalTranslationMeta =
      const VerificationMeta('originalTranslation');
  @override
  late final GeneratedColumn<String> originalTranslation =
      GeneratedColumn<String>(
        'original_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _exampleSentenceMeta = const VerificationMeta(
    'exampleSentence',
  );
  @override
  late final GeneratedColumn<String> exampleSentence = GeneratedColumn<String>(
    'example_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleTranslationMeta =
      const VerificationMeta('exampleTranslation');
  @override
  late final GeneratedColumn<String> exampleTranslation =
      GeneratedColumn<String>(
        'example_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => "DefaultUnit",
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => "DefaultBook",
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardStateMeta = const VerificationMeta(
    'cardState',
  );
  @override
  late final GeneratedColumn<int> cardState = GeneratedColumn<int>(
    'card_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardStepMeta = const VerificationMeta(
    'cardStep',
  );
  @override
  late final GeneratedColumn<int> cardStep = GeneratedColumn<int>(
    'card_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardStabilityMeta = const VerificationMeta(
    'cardStability',
  );
  @override
  late final GeneratedColumn<double> cardStability = GeneratedColumn<double>(
    'card_stability',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardDifficultyMeta = const VerificationMeta(
    'cardDifficulty',
  );
  @override
  late final GeneratedColumn<double> cardDifficulty = GeneratedColumn<double>(
    'card_difficulty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardDueTimeMeta = const VerificationMeta(
    'cardDueTime',
  );
  @override
  late final GeneratedColumn<DateTime> cardDueTime = GeneratedColumn<DateTime>(
    'card_due_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardLastReviewTimeMeta =
      const VerificationMeta('cardLastReviewTime');
  @override
  late final GeneratedColumn<DateTime> cardLastReviewTime =
      GeneratedColumn<DateTime>(
        'card_last_review_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtTimeMeta = const VerificationMeta(
    'createdAtTime',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtTime =
      GeneratedColumn<DateTime>(
        'created_at_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtTimeMeta = const VerificationMeta(
    'updatedAtTime',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtTime =
      GeneratedColumn<DateTime>(
        'updated_at_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    languageCode,
    originalWord,
    originalTranslation,
    exampleSentence,
    exampleTranslation,
    unitId,
    bookId,
    cardId,
    cardState,
    cardStep,
    cardStability,
    cardDifficulty,
    cardDueTime,
    cardLastReviewTime,
    createdAtTime,
    updatedAtTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('original_word')) {
      context.handle(
        _originalWordMeta,
        originalWord.isAcceptableOrUnknown(
          data['original_word']!,
          _originalWordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalWordMeta);
    }
    if (data.containsKey('original_translation')) {
      context.handle(
        _originalTranslationMeta,
        originalTranslation.isAcceptableOrUnknown(
          data['original_translation']!,
          _originalTranslationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTranslationMeta);
    }
    if (data.containsKey('example_sentence')) {
      context.handle(
        _exampleSentenceMeta,
        exampleSentence.isAcceptableOrUnknown(
          data['example_sentence']!,
          _exampleSentenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exampleSentenceMeta);
    }
    if (data.containsKey('example_translation')) {
      context.handle(
        _exampleTranslationMeta,
        exampleTranslation.isAcceptableOrUnknown(
          data['example_translation']!,
          _exampleTranslationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exampleTranslationMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('card_state')) {
      context.handle(
        _cardStateMeta,
        cardState.isAcceptableOrUnknown(data['card_state']!, _cardStateMeta),
      );
    } else if (isInserting) {
      context.missing(_cardStateMeta);
    }
    if (data.containsKey('card_step')) {
      context.handle(
        _cardStepMeta,
        cardStep.isAcceptableOrUnknown(data['card_step']!, _cardStepMeta),
      );
    } else if (isInserting) {
      context.missing(_cardStepMeta);
    }
    if (data.containsKey('card_stability')) {
      context.handle(
        _cardStabilityMeta,
        cardStability.isAcceptableOrUnknown(
          data['card_stability']!,
          _cardStabilityMeta,
        ),
      );
    }
    if (data.containsKey('card_difficulty')) {
      context.handle(
        _cardDifficultyMeta,
        cardDifficulty.isAcceptableOrUnknown(
          data['card_difficulty']!,
          _cardDifficultyMeta,
        ),
      );
    }
    if (data.containsKey('card_due_time')) {
      context.handle(
        _cardDueTimeMeta,
        cardDueTime.isAcceptableOrUnknown(
          data['card_due_time']!,
          _cardDueTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardDueTimeMeta);
    }
    if (data.containsKey('card_last_review_time')) {
      context.handle(
        _cardLastReviewTimeMeta,
        cardLastReviewTime.isAcceptableOrUnknown(
          data['card_last_review_time']!,
          _cardLastReviewTimeMeta,
        ),
      );
    }
    if (data.containsKey('created_at_time')) {
      context.handle(
        _createdAtTimeMeta,
        createdAtTime.isAcceptableOrUnknown(
          data['created_at_time']!,
          _createdAtTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtTimeMeta);
    }
    if (data.containsKey('updated_at_time')) {
      context.handle(
        _updatedAtTimeMeta,
        updatedAtTime.isAcceptableOrUnknown(
          data['updated_at_time']!,
          _updatedAtTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {originalWord, unitId, bookId, cardId},
  ];
  @override
  WordTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      originalWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_word'],
      )!,
      originalTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_translation'],
      )!,
      exampleSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_sentence'],
      )!,
      exampleTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_translation'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      cardState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_state'],
      )!,
      cardStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_step'],
      )!,
      cardStability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}card_stability'],
      ),
      cardDifficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}card_difficulty'],
      ),
      cardDueTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}card_due_time'],
      )!,
      cardLastReviewTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}card_last_review_time'],
      ),
      createdAtTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_time'],
      )!,
      updatedAtTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_time'],
      )!,
    );
  }

  @override
  $WordTableTable createAlias(String alias) {
    return $WordTableTable(attachedDatabase, alias);
  }
}

class WordTableData extends DataClass implements Insertable<WordTableData> {
  final int id;
  final String languageCode;
  final String originalWord;
  final String originalTranslation;
  final String exampleSentence;
  final String exampleTranslation;
  final String unitId;
  final String bookId;
  final int cardId;
  final int cardState;
  final int cardStep;
  final double? cardStability;
  final double? cardDifficulty;
  final DateTime cardDueTime;
  final DateTime? cardLastReviewTime;
  final DateTime createdAtTime;
  final DateTime updatedAtTime;
  const WordTableData({
    required this.id,
    required this.languageCode,
    required this.originalWord,
    required this.originalTranslation,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.unitId,
    required this.bookId,
    required this.cardId,
    required this.cardState,
    required this.cardStep,
    this.cardStability,
    this.cardDifficulty,
    required this.cardDueTime,
    this.cardLastReviewTime,
    required this.createdAtTime,
    required this.updatedAtTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['language_code'] = Variable<String>(languageCode);
    map['original_word'] = Variable<String>(originalWord);
    map['original_translation'] = Variable<String>(originalTranslation);
    map['example_sentence'] = Variable<String>(exampleSentence);
    map['example_translation'] = Variable<String>(exampleTranslation);
    map['unit_id'] = Variable<String>(unitId);
    map['book_id'] = Variable<String>(bookId);
    map['card_id'] = Variable<int>(cardId);
    map['card_state'] = Variable<int>(cardState);
    map['card_step'] = Variable<int>(cardStep);
    if (!nullToAbsent || cardStability != null) {
      map['card_stability'] = Variable<double>(cardStability);
    }
    if (!nullToAbsent || cardDifficulty != null) {
      map['card_difficulty'] = Variable<double>(cardDifficulty);
    }
    map['card_due_time'] = Variable<DateTime>(cardDueTime);
    if (!nullToAbsent || cardLastReviewTime != null) {
      map['card_last_review_time'] = Variable<DateTime>(cardLastReviewTime);
    }
    map['created_at_time'] = Variable<DateTime>(createdAtTime);
    map['updated_at_time'] = Variable<DateTime>(updatedAtTime);
    return map;
  }

  WordTableCompanion toCompanion(bool nullToAbsent) {
    return WordTableCompanion(
      id: Value(id),
      languageCode: Value(languageCode),
      originalWord: Value(originalWord),
      originalTranslation: Value(originalTranslation),
      exampleSentence: Value(exampleSentence),
      exampleTranslation: Value(exampleTranslation),
      unitId: Value(unitId),
      bookId: Value(bookId),
      cardId: Value(cardId),
      cardState: Value(cardState),
      cardStep: Value(cardStep),
      cardStability: cardStability == null && nullToAbsent
          ? const Value.absent()
          : Value(cardStability),
      cardDifficulty: cardDifficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(cardDifficulty),
      cardDueTime: Value(cardDueTime),
      cardLastReviewTime: cardLastReviewTime == null && nullToAbsent
          ? const Value.absent()
          : Value(cardLastReviewTime),
      createdAtTime: Value(createdAtTime),
      updatedAtTime: Value(updatedAtTime),
    );
  }

  factory WordTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordTableData(
      id: serializer.fromJson<int>(json['id']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      originalWord: serializer.fromJson<String>(json['originalWord']),
      originalTranslation: serializer.fromJson<String>(
        json['originalTranslation'],
      ),
      exampleSentence: serializer.fromJson<String>(json['exampleSentence']),
      exampleTranslation: serializer.fromJson<String>(
        json['exampleTranslation'],
      ),
      unitId: serializer.fromJson<String>(json['unitId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      cardId: serializer.fromJson<int>(json['cardId']),
      cardState: serializer.fromJson<int>(json['cardState']),
      cardStep: serializer.fromJson<int>(json['cardStep']),
      cardStability: serializer.fromJson<double?>(json['cardStability']),
      cardDifficulty: serializer.fromJson<double?>(json['cardDifficulty']),
      cardDueTime: serializer.fromJson<DateTime>(json['cardDueTime']),
      cardLastReviewTime: serializer.fromJson<DateTime?>(
        json['cardLastReviewTime'],
      ),
      createdAtTime: serializer.fromJson<DateTime>(json['createdAtTime']),
      updatedAtTime: serializer.fromJson<DateTime>(json['updatedAtTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'languageCode': serializer.toJson<String>(languageCode),
      'originalWord': serializer.toJson<String>(originalWord),
      'originalTranslation': serializer.toJson<String>(originalTranslation),
      'exampleSentence': serializer.toJson<String>(exampleSentence),
      'exampleTranslation': serializer.toJson<String>(exampleTranslation),
      'unitId': serializer.toJson<String>(unitId),
      'bookId': serializer.toJson<String>(bookId),
      'cardId': serializer.toJson<int>(cardId),
      'cardState': serializer.toJson<int>(cardState),
      'cardStep': serializer.toJson<int>(cardStep),
      'cardStability': serializer.toJson<double?>(cardStability),
      'cardDifficulty': serializer.toJson<double?>(cardDifficulty),
      'cardDueTime': serializer.toJson<DateTime>(cardDueTime),
      'cardLastReviewTime': serializer.toJson<DateTime?>(cardLastReviewTime),
      'createdAtTime': serializer.toJson<DateTime>(createdAtTime),
      'updatedAtTime': serializer.toJson<DateTime>(updatedAtTime),
    };
  }

  WordTableData copyWith({
    int? id,
    String? languageCode,
    String? originalWord,
    String? originalTranslation,
    String? exampleSentence,
    String? exampleTranslation,
    String? unitId,
    String? bookId,
    int? cardId,
    int? cardState,
    int? cardStep,
    Value<double?> cardStability = const Value.absent(),
    Value<double?> cardDifficulty = const Value.absent(),
    DateTime? cardDueTime,
    Value<DateTime?> cardLastReviewTime = const Value.absent(),
    DateTime? createdAtTime,
    DateTime? updatedAtTime,
  }) => WordTableData(
    id: id ?? this.id,
    languageCode: languageCode ?? this.languageCode,
    originalWord: originalWord ?? this.originalWord,
    originalTranslation: originalTranslation ?? this.originalTranslation,
    exampleSentence: exampleSentence ?? this.exampleSentence,
    exampleTranslation: exampleTranslation ?? this.exampleTranslation,
    unitId: unitId ?? this.unitId,
    bookId: bookId ?? this.bookId,
    cardId: cardId ?? this.cardId,
    cardState: cardState ?? this.cardState,
    cardStep: cardStep ?? this.cardStep,
    cardStability: cardStability.present
        ? cardStability.value
        : this.cardStability,
    cardDifficulty: cardDifficulty.present
        ? cardDifficulty.value
        : this.cardDifficulty,
    cardDueTime: cardDueTime ?? this.cardDueTime,
    cardLastReviewTime: cardLastReviewTime.present
        ? cardLastReviewTime.value
        : this.cardLastReviewTime,
    createdAtTime: createdAtTime ?? this.createdAtTime,
    updatedAtTime: updatedAtTime ?? this.updatedAtTime,
  );
  WordTableData copyWithCompanion(WordTableCompanion data) {
    return WordTableData(
      id: data.id.present ? data.id.value : this.id,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      originalWord: data.originalWord.present
          ? data.originalWord.value
          : this.originalWord,
      originalTranslation: data.originalTranslation.present
          ? data.originalTranslation.value
          : this.originalTranslation,
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
      exampleTranslation: data.exampleTranslation.present
          ? data.exampleTranslation.value
          : this.exampleTranslation,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      cardState: data.cardState.present ? data.cardState.value : this.cardState,
      cardStep: data.cardStep.present ? data.cardStep.value : this.cardStep,
      cardStability: data.cardStability.present
          ? data.cardStability.value
          : this.cardStability,
      cardDifficulty: data.cardDifficulty.present
          ? data.cardDifficulty.value
          : this.cardDifficulty,
      cardDueTime: data.cardDueTime.present
          ? data.cardDueTime.value
          : this.cardDueTime,
      cardLastReviewTime: data.cardLastReviewTime.present
          ? data.cardLastReviewTime.value
          : this.cardLastReviewTime,
      createdAtTime: data.createdAtTime.present
          ? data.createdAtTime.value
          : this.createdAtTime,
      updatedAtTime: data.updatedAtTime.present
          ? data.updatedAtTime.value
          : this.updatedAtTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordTableData(')
          ..write('id: $id, ')
          ..write('languageCode: $languageCode, ')
          ..write('originalWord: $originalWord, ')
          ..write('originalTranslation: $originalTranslation, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('unitId: $unitId, ')
          ..write('bookId: $bookId, ')
          ..write('cardId: $cardId, ')
          ..write('cardState: $cardState, ')
          ..write('cardStep: $cardStep, ')
          ..write('cardStability: $cardStability, ')
          ..write('cardDifficulty: $cardDifficulty, ')
          ..write('cardDueTime: $cardDueTime, ')
          ..write('cardLastReviewTime: $cardLastReviewTime, ')
          ..write('createdAtTime: $createdAtTime, ')
          ..write('updatedAtTime: $updatedAtTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    languageCode,
    originalWord,
    originalTranslation,
    exampleSentence,
    exampleTranslation,
    unitId,
    bookId,
    cardId,
    cardState,
    cardStep,
    cardStability,
    cardDifficulty,
    cardDueTime,
    cardLastReviewTime,
    createdAtTime,
    updatedAtTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordTableData &&
          other.id == this.id &&
          other.languageCode == this.languageCode &&
          other.originalWord == this.originalWord &&
          other.originalTranslation == this.originalTranslation &&
          other.exampleSentence == this.exampleSentence &&
          other.exampleTranslation == this.exampleTranslation &&
          other.unitId == this.unitId &&
          other.bookId == this.bookId &&
          other.cardId == this.cardId &&
          other.cardState == this.cardState &&
          other.cardStep == this.cardStep &&
          other.cardStability == this.cardStability &&
          other.cardDifficulty == this.cardDifficulty &&
          other.cardDueTime == this.cardDueTime &&
          other.cardLastReviewTime == this.cardLastReviewTime &&
          other.createdAtTime == this.createdAtTime &&
          other.updatedAtTime == this.updatedAtTime);
}

class WordTableCompanion extends UpdateCompanion<WordTableData> {
  final Value<int> id;
  final Value<String> languageCode;
  final Value<String> originalWord;
  final Value<String> originalTranslation;
  final Value<String> exampleSentence;
  final Value<String> exampleTranslation;
  final Value<String> unitId;
  final Value<String> bookId;
  final Value<int> cardId;
  final Value<int> cardState;
  final Value<int> cardStep;
  final Value<double?> cardStability;
  final Value<double?> cardDifficulty;
  final Value<DateTime> cardDueTime;
  final Value<DateTime?> cardLastReviewTime;
  final Value<DateTime> createdAtTime;
  final Value<DateTime> updatedAtTime;
  const WordTableCompanion({
    this.id = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.originalWord = const Value.absent(),
    this.originalTranslation = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.unitId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.cardState = const Value.absent(),
    this.cardStep = const Value.absent(),
    this.cardStability = const Value.absent(),
    this.cardDifficulty = const Value.absent(),
    this.cardDueTime = const Value.absent(),
    this.cardLastReviewTime = const Value.absent(),
    this.createdAtTime = const Value.absent(),
    this.updatedAtTime = const Value.absent(),
  });
  WordTableCompanion.insert({
    this.id = const Value.absent(),
    required String languageCode,
    required String originalWord,
    required String originalTranslation,
    required String exampleSentence,
    required String exampleTranslation,
    this.unitId = const Value.absent(),
    this.bookId = const Value.absent(),
    required int cardId,
    required int cardState,
    required int cardStep,
    this.cardStability = const Value.absent(),
    this.cardDifficulty = const Value.absent(),
    required DateTime cardDueTime,
    this.cardLastReviewTime = const Value.absent(),
    required DateTime createdAtTime,
    required DateTime updatedAtTime,
  }) : languageCode = Value(languageCode),
       originalWord = Value(originalWord),
       originalTranslation = Value(originalTranslation),
       exampleSentence = Value(exampleSentence),
       exampleTranslation = Value(exampleTranslation),
       cardId = Value(cardId),
       cardState = Value(cardState),
       cardStep = Value(cardStep),
       cardDueTime = Value(cardDueTime),
       createdAtTime = Value(createdAtTime),
       updatedAtTime = Value(updatedAtTime);
  static Insertable<WordTableData> custom({
    Expression<int>? id,
    Expression<String>? languageCode,
    Expression<String>? originalWord,
    Expression<String>? originalTranslation,
    Expression<String>? exampleSentence,
    Expression<String>? exampleTranslation,
    Expression<String>? unitId,
    Expression<String>? bookId,
    Expression<int>? cardId,
    Expression<int>? cardState,
    Expression<int>? cardStep,
    Expression<double>? cardStability,
    Expression<double>? cardDifficulty,
    Expression<DateTime>? cardDueTime,
    Expression<DateTime>? cardLastReviewTime,
    Expression<DateTime>? createdAtTime,
    Expression<DateTime>? updatedAtTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (languageCode != null) 'language_code': languageCode,
      if (originalWord != null) 'original_word': originalWord,
      if (originalTranslation != null)
        'original_translation': originalTranslation,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (exampleTranslation != null) 'example_translation': exampleTranslation,
      if (unitId != null) 'unit_id': unitId,
      if (bookId != null) 'book_id': bookId,
      if (cardId != null) 'card_id': cardId,
      if (cardState != null) 'card_state': cardState,
      if (cardStep != null) 'card_step': cardStep,
      if (cardStability != null) 'card_stability': cardStability,
      if (cardDifficulty != null) 'card_difficulty': cardDifficulty,
      if (cardDueTime != null) 'card_due_time': cardDueTime,
      if (cardLastReviewTime != null)
        'card_last_review_time': cardLastReviewTime,
      if (createdAtTime != null) 'created_at_time': createdAtTime,
      if (updatedAtTime != null) 'updated_at_time': updatedAtTime,
    });
  }

  WordTableCompanion copyWith({
    Value<int>? id,
    Value<String>? languageCode,
    Value<String>? originalWord,
    Value<String>? originalTranslation,
    Value<String>? exampleSentence,
    Value<String>? exampleTranslation,
    Value<String>? unitId,
    Value<String>? bookId,
    Value<int>? cardId,
    Value<int>? cardState,
    Value<int>? cardStep,
    Value<double?>? cardStability,
    Value<double?>? cardDifficulty,
    Value<DateTime>? cardDueTime,
    Value<DateTime?>? cardLastReviewTime,
    Value<DateTime>? createdAtTime,
    Value<DateTime>? updatedAtTime,
  }) {
    return WordTableCompanion(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      originalWord: originalWord ?? this.originalWord,
      originalTranslation: originalTranslation ?? this.originalTranslation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      unitId: unitId ?? this.unitId,
      bookId: bookId ?? this.bookId,
      cardId: cardId ?? this.cardId,
      cardState: cardState ?? this.cardState,
      cardStep: cardStep ?? this.cardStep,
      cardStability: cardStability ?? this.cardStability,
      cardDifficulty: cardDifficulty ?? this.cardDifficulty,
      cardDueTime: cardDueTime ?? this.cardDueTime,
      cardLastReviewTime: cardLastReviewTime ?? this.cardLastReviewTime,
      createdAtTime: createdAtTime ?? this.createdAtTime,
      updatedAtTime: updatedAtTime ?? this.updatedAtTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (originalWord.present) {
      map['original_word'] = Variable<String>(originalWord.value);
    }
    if (originalTranslation.present) {
      map['original_translation'] = Variable<String>(originalTranslation.value);
    }
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (exampleTranslation.present) {
      map['example_translation'] = Variable<String>(exampleTranslation.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (cardState.present) {
      map['card_state'] = Variable<int>(cardState.value);
    }
    if (cardStep.present) {
      map['card_step'] = Variable<int>(cardStep.value);
    }
    if (cardStability.present) {
      map['card_stability'] = Variable<double>(cardStability.value);
    }
    if (cardDifficulty.present) {
      map['card_difficulty'] = Variable<double>(cardDifficulty.value);
    }
    if (cardDueTime.present) {
      map['card_due_time'] = Variable<DateTime>(cardDueTime.value);
    }
    if (cardLastReviewTime.present) {
      map['card_last_review_time'] = Variable<DateTime>(
        cardLastReviewTime.value,
      );
    }
    if (createdAtTime.present) {
      map['created_at_time'] = Variable<DateTime>(createdAtTime.value);
    }
    if (updatedAtTime.present) {
      map['updated_at_time'] = Variable<DateTime>(updatedAtTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordTableCompanion(')
          ..write('id: $id, ')
          ..write('languageCode: $languageCode, ')
          ..write('originalWord: $originalWord, ')
          ..write('originalTranslation: $originalTranslation, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('unitId: $unitId, ')
          ..write('bookId: $bookId, ')
          ..write('cardId: $cardId, ')
          ..write('cardState: $cardState, ')
          ..write('cardStep: $cardStep, ')
          ..write('cardStability: $cardStability, ')
          ..write('cardDifficulty: $cardDifficulty, ')
          ..write('cardDueTime: $cardDueTime, ')
          ..write('cardLastReviewTime: $cardLastReviewTime, ')
          ..write('createdAtTime: $createdAtTime, ')
          ..write('updatedAtTime: $updatedAtTime')
          ..write(')'))
        .toString();
  }
}

class $WordLearningHistoryTableTable extends WordLearningHistoryTable
    with
        TableInfo<
          $WordLearningHistoryTableTable,
          WordLearningHistoryTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordLearningHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Rating, int> rating =
      GeneratedColumn<int>(
        'rating',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Rating>($WordLearningHistoryTableTable.$converterrating);
  static const VerificationMeta _reviewDateTimeMeta = const VerificationMeta(
    'reviewDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> reviewDateTime =
      GeneratedColumn<DateTime>(
        'review_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _reviewDurationMeta = const VerificationMeta(
    'reviewDuration',
  );
  @override
  late final GeneratedColumn<int> reviewDuration = GeneratedColumn<int>(
    'review_duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    rating,
    reviewDateTime,
    reviewDuration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_learning_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordLearningHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('review_date_time')) {
      context.handle(
        _reviewDateTimeMeta,
        reviewDateTime.isAcceptableOrUnknown(
          data['review_date_time']!,
          _reviewDateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewDateTimeMeta);
    }
    if (data.containsKey('review_duration')) {
      context.handle(
        _reviewDurationMeta,
        reviewDuration.isAcceptableOrUnknown(
          data['review_duration']!,
          _reviewDurationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordLearningHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordLearningHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      rating: $WordLearningHistoryTableTable.$converterrating.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}rating'],
        )!,
      ),
      reviewDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_date_time'],
      )!,
      reviewDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_duration'],
      ),
    );
  }

  @override
  $WordLearningHistoryTableTable createAlias(String alias) {
    return $WordLearningHistoryTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Rating, int, int> $converterrating =
      const EnumIndexConverter<Rating>(Rating.values);
}

class WordLearningHistoryTableData extends DataClass
    implements Insertable<WordLearningHistoryTableData> {
  final int id;
  final int cardId;
  final Rating rating;
  final DateTime reviewDateTime;
  final int? reviewDuration;
  const WordLearningHistoryTableData({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewDateTime,
    this.reviewDuration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    {
      map['rating'] = Variable<int>(
        $WordLearningHistoryTableTable.$converterrating.toSql(rating),
      );
    }
    map['review_date_time'] = Variable<DateTime>(reviewDateTime);
    if (!nullToAbsent || reviewDuration != null) {
      map['review_duration'] = Variable<int>(reviewDuration);
    }
    return map;
  }

  WordLearningHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return WordLearningHistoryTableCompanion(
      id: Value(id),
      cardId: Value(cardId),
      rating: Value(rating),
      reviewDateTime: Value(reviewDateTime),
      reviewDuration: reviewDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewDuration),
    );
  }

  factory WordLearningHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordLearningHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      rating: $WordLearningHistoryTableTable.$converterrating.fromJson(
        serializer.fromJson<int>(json['rating']),
      ),
      reviewDateTime: serializer.fromJson<DateTime>(json['reviewDateTime']),
      reviewDuration: serializer.fromJson<int?>(json['reviewDuration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'rating': serializer.toJson<int>(
        $WordLearningHistoryTableTable.$converterrating.toJson(rating),
      ),
      'reviewDateTime': serializer.toJson<DateTime>(reviewDateTime),
      'reviewDuration': serializer.toJson<int?>(reviewDuration),
    };
  }

  WordLearningHistoryTableData copyWith({
    int? id,
    int? cardId,
    Rating? rating,
    DateTime? reviewDateTime,
    Value<int?> reviewDuration = const Value.absent(),
  }) => WordLearningHistoryTableData(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    rating: rating ?? this.rating,
    reviewDateTime: reviewDateTime ?? this.reviewDateTime,
    reviewDuration: reviewDuration.present
        ? reviewDuration.value
        : this.reviewDuration,
  );
  WordLearningHistoryTableData copyWithCompanion(
    WordLearningHistoryTableCompanion data,
  ) {
    return WordLearningHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewDateTime: data.reviewDateTime.present
          ? data.reviewDateTime.value
          : this.reviewDateTime,
      reviewDuration: data.reviewDuration.present
          ? data.reviewDuration.value
          : this.reviewDuration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordLearningHistoryTableData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewDateTime: $reviewDateTime, ')
          ..write('reviewDuration: $reviewDuration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, rating, reviewDateTime, reviewDuration);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordLearningHistoryTableData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.reviewDateTime == this.reviewDateTime &&
          other.reviewDuration == this.reviewDuration);
}

class WordLearningHistoryTableCompanion
    extends UpdateCompanion<WordLearningHistoryTableData> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<Rating> rating;
  final Value<DateTime> reviewDateTime;
  final Value<int?> reviewDuration;
  const WordLearningHistoryTableCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewDateTime = const Value.absent(),
    this.reviewDuration = const Value.absent(),
  });
  WordLearningHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required Rating rating,
    required DateTime reviewDateTime,
    this.reviewDuration = const Value.absent(),
  }) : cardId = Value(cardId),
       rating = Value(rating),
       reviewDateTime = Value(reviewDateTime);
  static Insertable<WordLearningHistoryTableData> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<int>? rating,
    Expression<DateTime>? reviewDateTime,
    Expression<int>? reviewDuration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (reviewDateTime != null) 'review_date_time': reviewDateTime,
      if (reviewDuration != null) 'review_duration': reviewDuration,
    });
  }

  WordLearningHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<Rating>? rating,
    Value<DateTime>? reviewDateTime,
    Value<int?>? reviewDuration,
  }) {
    return WordLearningHistoryTableCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      reviewDateTime: reviewDateTime ?? this.reviewDateTime,
      reviewDuration: reviewDuration ?? this.reviewDuration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(
        $WordLearningHistoryTableTable.$converterrating.toSql(rating.value),
      );
    }
    if (reviewDateTime.present) {
      map['review_date_time'] = Variable<DateTime>(reviewDateTime.value);
    }
    if (reviewDuration.present) {
      map['review_duration'] = Variable<int>(reviewDuration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordLearningHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewDateTime: $reviewDateTime, ')
          ..write('reviewDuration: $reviewDuration')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $WordTableTable wordTable = $WordTableTable(this);
  late final $WordLearningHistoryTableTable wordLearningHistoryTable =
      $WordLearningHistoryTableTable(this);
  late final Index idxWordDue = Index(
    'idx_word_due',
    'CREATE INDEX idx_word_due ON word_table (card_due_time)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wordTable,
    wordLearningHistoryTable,
    idxWordDue,
  ];
}

typedef $$WordTableTableCreateCompanionBuilder =
    WordTableCompanion Function({
      Value<int> id,
      required String languageCode,
      required String originalWord,
      required String originalTranslation,
      required String exampleSentence,
      required String exampleTranslation,
      Value<String> unitId,
      Value<String> bookId,
      required int cardId,
      required int cardState,
      required int cardStep,
      Value<double?> cardStability,
      Value<double?> cardDifficulty,
      required DateTime cardDueTime,
      Value<DateTime?> cardLastReviewTime,
      required DateTime createdAtTime,
      required DateTime updatedAtTime,
    });
typedef $$WordTableTableUpdateCompanionBuilder =
    WordTableCompanion Function({
      Value<int> id,
      Value<String> languageCode,
      Value<String> originalWord,
      Value<String> originalTranslation,
      Value<String> exampleSentence,
      Value<String> exampleTranslation,
      Value<String> unitId,
      Value<String> bookId,
      Value<int> cardId,
      Value<int> cardState,
      Value<int> cardStep,
      Value<double?> cardStability,
      Value<double?> cardDifficulty,
      Value<DateTime> cardDueTime,
      Value<DateTime?> cardLastReviewTime,
      Value<DateTime> createdAtTime,
      Value<DateTime> updatedAtTime,
    });

class $$WordTableTableFilterComposer
    extends Composer<_$Database, $WordTableTable> {
  $$WordTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalWord => $composableBuilder(
    column: $table.originalWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalTranslation => $composableBuilder(
    column: $table.originalTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardState => $composableBuilder(
    column: $table.cardState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardStep => $composableBuilder(
    column: $table.cardStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cardStability => $composableBuilder(
    column: $table.cardStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cardDifficulty => $composableBuilder(
    column: $table.cardDifficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cardDueTime => $composableBuilder(
    column: $table.cardDueTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cardLastReviewTime => $composableBuilder(
    column: $table.cardLastReviewTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtTime => $composableBuilder(
    column: $table.createdAtTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtTime => $composableBuilder(
    column: $table.updatedAtTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WordTableTableOrderingComposer
    extends Composer<_$Database, $WordTableTable> {
  $$WordTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalWord => $composableBuilder(
    column: $table.originalWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalTranslation => $composableBuilder(
    column: $table.originalTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardState => $composableBuilder(
    column: $table.cardState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardStep => $composableBuilder(
    column: $table.cardStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cardStability => $composableBuilder(
    column: $table.cardStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cardDifficulty => $composableBuilder(
    column: $table.cardDifficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cardDueTime => $composableBuilder(
    column: $table.cardDueTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cardLastReviewTime => $composableBuilder(
    column: $table.cardLastReviewTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtTime => $composableBuilder(
    column: $table.createdAtTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtTime => $composableBuilder(
    column: $table.updatedAtTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordTableTableAnnotationComposer
    extends Composer<_$Database, $WordTableTable> {
  $$WordTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalWord => $composableBuilder(
    column: $table.originalWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalTranslation => $composableBuilder(
    column: $table.originalTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get cardState =>
      $composableBuilder(column: $table.cardState, builder: (column) => column);

  GeneratedColumn<int> get cardStep =>
      $composableBuilder(column: $table.cardStep, builder: (column) => column);

  GeneratedColumn<double> get cardStability => $composableBuilder(
    column: $table.cardStability,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cardDifficulty => $composableBuilder(
    column: $table.cardDifficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cardDueTime => $composableBuilder(
    column: $table.cardDueTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cardLastReviewTime => $composableBuilder(
    column: $table.cardLastReviewTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtTime => $composableBuilder(
    column: $table.createdAtTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtTime => $composableBuilder(
    column: $table.updatedAtTime,
    builder: (column) => column,
  );
}

class $$WordTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $WordTableTable,
          WordTableData,
          $$WordTableTableFilterComposer,
          $$WordTableTableOrderingComposer,
          $$WordTableTableAnnotationComposer,
          $$WordTableTableCreateCompanionBuilder,
          $$WordTableTableUpdateCompanionBuilder,
          (
            WordTableData,
            BaseReferences<_$Database, $WordTableTable, WordTableData>,
          ),
          WordTableData,
          PrefetchHooks Function()
        > {
  $$WordTableTableTableManager(_$Database db, $WordTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> originalWord = const Value.absent(),
                Value<String> originalTranslation = const Value.absent(),
                Value<String> exampleSentence = const Value.absent(),
                Value<String> exampleTranslation = const Value.absent(),
                Value<String> unitId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<int> cardState = const Value.absent(),
                Value<int> cardStep = const Value.absent(),
                Value<double?> cardStability = const Value.absent(),
                Value<double?> cardDifficulty = const Value.absent(),
                Value<DateTime> cardDueTime = const Value.absent(),
                Value<DateTime?> cardLastReviewTime = const Value.absent(),
                Value<DateTime> createdAtTime = const Value.absent(),
                Value<DateTime> updatedAtTime = const Value.absent(),
              }) => WordTableCompanion(
                id: id,
                languageCode: languageCode,
                originalWord: originalWord,
                originalTranslation: originalTranslation,
                exampleSentence: exampleSentence,
                exampleTranslation: exampleTranslation,
                unitId: unitId,
                bookId: bookId,
                cardId: cardId,
                cardState: cardState,
                cardStep: cardStep,
                cardStability: cardStability,
                cardDifficulty: cardDifficulty,
                cardDueTime: cardDueTime,
                cardLastReviewTime: cardLastReviewTime,
                createdAtTime: createdAtTime,
                updatedAtTime: updatedAtTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String languageCode,
                required String originalWord,
                required String originalTranslation,
                required String exampleSentence,
                required String exampleTranslation,
                Value<String> unitId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                required int cardId,
                required int cardState,
                required int cardStep,
                Value<double?> cardStability = const Value.absent(),
                Value<double?> cardDifficulty = const Value.absent(),
                required DateTime cardDueTime,
                Value<DateTime?> cardLastReviewTime = const Value.absent(),
                required DateTime createdAtTime,
                required DateTime updatedAtTime,
              }) => WordTableCompanion.insert(
                id: id,
                languageCode: languageCode,
                originalWord: originalWord,
                originalTranslation: originalTranslation,
                exampleSentence: exampleSentence,
                exampleTranslation: exampleTranslation,
                unitId: unitId,
                bookId: bookId,
                cardId: cardId,
                cardState: cardState,
                cardStep: cardStep,
                cardStability: cardStability,
                cardDifficulty: cardDifficulty,
                cardDueTime: cardDueTime,
                cardLastReviewTime: cardLastReviewTime,
                createdAtTime: createdAtTime,
                updatedAtTime: updatedAtTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $WordTableTable,
      WordTableData,
      $$WordTableTableFilterComposer,
      $$WordTableTableOrderingComposer,
      $$WordTableTableAnnotationComposer,
      $$WordTableTableCreateCompanionBuilder,
      $$WordTableTableUpdateCompanionBuilder,
      (
        WordTableData,
        BaseReferences<_$Database, $WordTableTable, WordTableData>,
      ),
      WordTableData,
      PrefetchHooks Function()
    >;
typedef $$WordLearningHistoryTableTableCreateCompanionBuilder =
    WordLearningHistoryTableCompanion Function({
      Value<int> id,
      required int cardId,
      required Rating rating,
      required DateTime reviewDateTime,
      Value<int?> reviewDuration,
    });
typedef $$WordLearningHistoryTableTableUpdateCompanionBuilder =
    WordLearningHistoryTableCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<Rating> rating,
      Value<DateTime> reviewDateTime,
      Value<int?> reviewDuration,
    });

class $$WordLearningHistoryTableTableFilterComposer
    extends Composer<_$Database, $WordLearningHistoryTableTable> {
  $$WordLearningHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Rating, Rating, int> get rating =>
      $composableBuilder(
        column: $table.rating,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get reviewDateTime => $composableBuilder(
    column: $table.reviewDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewDuration => $composableBuilder(
    column: $table.reviewDuration,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WordLearningHistoryTableTableOrderingComposer
    extends Composer<_$Database, $WordLearningHistoryTableTable> {
  $$WordLearningHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewDateTime => $composableBuilder(
    column: $table.reviewDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewDuration => $composableBuilder(
    column: $table.reviewDuration,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordLearningHistoryTableTableAnnotationComposer
    extends Composer<_$Database, $WordLearningHistoryTableTable> {
  $$WordLearningHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Rating, int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewDateTime => $composableBuilder(
    column: $table.reviewDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewDuration => $composableBuilder(
    column: $table.reviewDuration,
    builder: (column) => column,
  );
}

class $$WordLearningHistoryTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $WordLearningHistoryTableTable,
          WordLearningHistoryTableData,
          $$WordLearningHistoryTableTableFilterComposer,
          $$WordLearningHistoryTableTableOrderingComposer,
          $$WordLearningHistoryTableTableAnnotationComposer,
          $$WordLearningHistoryTableTableCreateCompanionBuilder,
          $$WordLearningHistoryTableTableUpdateCompanionBuilder,
          (
            WordLearningHistoryTableData,
            BaseReferences<
              _$Database,
              $WordLearningHistoryTableTable,
              WordLearningHistoryTableData
            >,
          ),
          WordLearningHistoryTableData,
          PrefetchHooks Function()
        > {
  $$WordLearningHistoryTableTableTableManager(
    _$Database db,
    $WordLearningHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordLearningHistoryTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WordLearningHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WordLearningHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<Rating> rating = const Value.absent(),
                Value<DateTime> reviewDateTime = const Value.absent(),
                Value<int?> reviewDuration = const Value.absent(),
              }) => WordLearningHistoryTableCompanion(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewDateTime: reviewDateTime,
                reviewDuration: reviewDuration,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required Rating rating,
                required DateTime reviewDateTime,
                Value<int?> reviewDuration = const Value.absent(),
              }) => WordLearningHistoryTableCompanion.insert(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewDateTime: reviewDateTime,
                reviewDuration: reviewDuration,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordLearningHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $WordLearningHistoryTableTable,
      WordLearningHistoryTableData,
      $$WordLearningHistoryTableTableFilterComposer,
      $$WordLearningHistoryTableTableOrderingComposer,
      $$WordLearningHistoryTableTableAnnotationComposer,
      $$WordLearningHistoryTableTableCreateCompanionBuilder,
      $$WordLearningHistoryTableTableUpdateCompanionBuilder,
      (
        WordLearningHistoryTableData,
        BaseReferences<
          _$Database,
          $WordLearningHistoryTableTable,
          WordLearningHistoryTableData
        >,
      ),
      WordLearningHistoryTableData,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$WordTableTableTableManager get wordTable =>
      $$WordTableTableTableManager(_db, _db.wordTable);
  $$WordLearningHistoryTableTableTableManager get wordLearningHistoryTable =>
      $$WordLearningHistoryTableTableTableManager(
        _db,
        _db.wordLearningHistoryTable,
      );
}
