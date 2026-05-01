import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/expense.dart';

part 'supabase_datasource.g.dart';

@Riverpod(keepAlive: true)
SupabaseDatasource supabaseDatasource(SupabaseDatasourceRef ref) {
  return SupabaseDatasource();
}

class SupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  /// Utiliza UPSERT para garantir idempotência. 
  /// Se o ID já existir, atualiza. Se não existir, insere.
  Future<void> upsertExpense(Expense expense) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado no Supabase. Abortando sync da despesa.');
    }

    debugPrint('🌐 [Supabase] Iniciando upsert para despesa: ${expense.id}');
    
    try {
      // Garantia Offline-First: O tempo DEVE vir do cliente, e nunca ser carimbado pelo processo de sync.
      // Em casos de dados legados do Hive (migração), o fallback seguro é a data da própria despesa.
      final createdAt = expense.createdAt ?? expense.date; 
      final updatedAt = expense.updatedAt ?? expense.date; 
      
      // O deletedAt exato do momento do soft-delete no app
      final deletedAt = expense.deletedAt?.toUtc().toIso8601String();

      final payload = {
        'id': expense.id,
        'user_id': user.id, // Vínculo com RLS
        'date': expense.date.toUtc().toIso8601String(), // UTC é crucial para Postgres TIMESTAMPTZ
        'category_id': expense.categoryId,
        'category_name': expense.categoryName,
        'subcategory': expense.subcategory,
        'description': expense.description,
        'amount': expense.amount,
        'type': expense.type.name,
        'origin': expense.origin.name,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt, // Envia o Tombstone em caso de deleção
      };

      await _client
          .from('expenses')
          .upsert(payload, onConflict: 'id'); // <--- A MÁGICA DA IDEMPOTÊNCIA

      debugPrint('🟢 [Supabase] Upsert concluído com sucesso: ${expense.id}');
    } on PostgrestException catch (e) {
      debugPrint('❌ [Supabase] Erro do Postgrest (${e.code}): ${e.message}');
      debugPrint('❌ Detalhes: ${e.details} | Hint: ${e.hint}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [Supabase] Erro inesperado no Upsert: $e');
      rethrow;
    }
  }

  Future<List<Expense>> fetchExpenses({DateTime? updatedAfter}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado no Supabase. Abortando fetch de despesas.');
    }

    try {
      var query = _client.from('expenses').select().eq('user_id', user.id);

      if (updatedAfter != null) {
        query = query.gt('updated_at', updatedAfter.toUtc().toIso8601String());
      }

      final response = await query;
      final List<Expense> expenses = [];

      for (var row in response) {
        // Conversão de snake_case (Supabase) para camelCase (App/Freezed)
        final map = {
          'id': row['id'],
          'userId': row['user_id'],
          'date': row['date'],
          'categoryId': row['category_id'],
          'categoryName': row['category_name'],
          'subcategory': row['subcategory'],
          'description': row['description'],
          'amount': (row['amount'] as num).toDouble(),
          'type': row['type'],
          'origin': row['origin'],
          'synced': true, // veio do servidor, logo está syncado
          'deleted': row['deleted_at'] != null,
          'createdAt': row['created_at'],
          'updatedAt': row['updated_at'],
          'deletedAt': row['deleted_at'],
        };
        
        expenses.add(Expense.fromJson(map));
      }

      return expenses;
    } catch (e) {
      debugPrint('❌ [Supabase] Erro inesperado no Fetch: $e');
      rethrow;
    }
  }
}
