import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    @Default([]) List<String> subcategories,
  }) = _Category;
}
