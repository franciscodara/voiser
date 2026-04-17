class VoiceCommandResult {
  const VoiceCommandResult({
    this.type = 'expense',
    required this.amount,
    required this.category,
    this.subcategory,
    this.description,
    this.needsManualReview = false,
  });

  final String type;
  final double amount;
  final String category;
  final String? subcategory;
  final String? description;
  final bool needsManualReview;

  VoiceCommandResult copyWith({
    String? type,
    double? amount,
    String? category,
    Object? subcategory = _voiceCommandResultSentinel,
    Object? description = _voiceCommandResultSentinel,
    bool? needsManualReview,
  }) {
    return VoiceCommandResult(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subcategory: identical(subcategory, _voiceCommandResultSentinel)
          ? this.subcategory
          : subcategory as String?,
      description: identical(description, _voiceCommandResultSentinel)
          ? this.description
          : description as String?,
      needsManualReview: needsManualReview ?? this.needsManualReview,
    );
  }

  factory VoiceCommandResult.fromJson(Map<String, dynamic> json) {
    return VoiceCommandResult(
      type: (json['type'] as String?) ?? 'expense',
      amount: _asDouble(json['amount']),
      category: (json['category'] as String?) ?? '',
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String?,
      needsManualReview: (json['needsManualReview'] as bool?) ??
          (json['needs_manual_review'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'amount': amount,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'needsManualReview': needsManualReview,
    };
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final normalized = value.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0;
    }

    return 0;
  }
}

const _voiceCommandResultSentinel = Object();
