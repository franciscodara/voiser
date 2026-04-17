import 'package:flutter/material.dart';
import 'package:finwise/features/expenses/domain/entities/category.dart';

/// Categorias e subcategorias pré-definidas para o MVP.
/// Na V1, o usuário poderá criar categorias customizadas.
class DefaultCategories {
  DefaultCategories._();

  static const List<Category> all = [
    Category(
      id: 'income_salary',
      name: 'Receita',
      icon: Icons.payments_rounded,
      color: Color(0xFF10B981), // Verde Esmeralda
      subcategories: ['Salário', 'Freelance', 'Rendimento', 'Bônus', 'Venda', 'Outros'],
    ),
    Category(
      id: 'supermarket',
      name: 'Supermercado',
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF3B82F6), // Azul
      subcategories: ['Alimentos', 'Bebidas', 'Limpeza', 'Higiene', 'Açougue', 'Outros'],
    ),
    Category(
      id: 'fuel',
      name: 'Combustível',
      icon: Icons.local_gas_station_rounded,
      color: Color(0xFFF97316), // Laranja
      subcategories: ['Gasolina', 'Álcool', 'Diesel', 'Gás de cozinha'],
    ),
    Category(
      id: 'food',
      name: 'Alimentação',
      icon: Icons.restaurant_rounded,
      color: Color(0xFF22C55E), // Verde
      subcategories: ['Almoço', 'Jantar', 'Café da manhã', 'Delivery', 'Lanche'],
    ),
    Category(
      id: 'bar',
      name: 'Bar / Lazer',
      icon: Icons.local_bar_rounded,
      color: Color(0xFFA855F7), // Roxo
      subcategories: ['Bar', 'Balada', 'Cinema', 'Show', 'Outros'],
    ),
    Category(
      id: 'bills',
      name: 'Contas',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF64748B), // Cinza
      subcategories: ['Luz', 'Água', 'Internet', 'Telefone', 'Aluguel', 'Condomínio'],
    ),
    Category(
      id: 'health',
      name: 'Saúde',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEF4444), // Vermelho
      subcategories: ['Farmácia', 'Consulta', 'Exame', 'Academia', 'Outros'],
    ),
    Category(
      id: 'transport',
      name: 'Transporte',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF06B6D4), // Ciano
      subcategories: ['Uber/99', 'Ônibus', 'Metrô', 'Manutenção', 'Estacionamento'],
    ),
    Category(
      id: 'education',
      name: 'Educação',
      icon: Icons.school_rounded,
      color: Color(0xFFF59E0B), // Âmbar
      subcategories: ['Mensalidade', 'Curso', 'Livros', 'Material', 'Outros'],
    ),
    Category(
      id: 'other',
      name: 'Outros',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF94A3B8), // Cinza claro
      subcategories: ['Presente', 'Doação', 'Pet', 'Roupa', 'Eletrônico', 'Outros'],
    ),
  ];

  static Category? findById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static Category? findByName(String name) {
    final normalizedName = _normalizeText(name);

    try {
      return all.firstWhere((category) => _normalizeText(category.name) == normalizedName);
    } catch (_) {
      return null;
    }
  }

  static String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}

