import 'package:flutter/material.dart';

/// Cidades disponíveis (RF01 — no mínimo São Paulo, Campinas e Jundiaí).
const List<String> cidades = ['São Paulo', 'Campinas', 'Jundiaí'];

/// Valor usado nos filtros para "não filtrar por cidade".
const String todasCidades = 'Todas';

/// Valor usado nos filtros para "não filtrar por categoria".
const String todasCategorias = 'Todos';

/// Categorias aceitas no cadastro (valor gravado no Firestore).
const List<String> categorias = [
  'Academia',
  'Restaurante',
  'Hospital',
  'Farmácia',
  'Mercado',
];

/// Rótulo no plural exibido nos chips de filtro (igual ao wireframe).
const Map<String, String> categoriasPlural = {
  'Academia': 'Academias',
  'Restaurante': 'Restaurantes',
  'Hospital': 'Hospitais',
  'Farmácia': 'Farmácias',
  'Mercado': 'Mercados',
};

/// Ícone de cada categoria (usado nos placeholders de imagem).
IconData iconeCategoria(String categoria) {
  switch (categoria) {
    case 'Academia':
      return Icons.fitness_center;
    case 'Restaurante':
      return Icons.restaurant;
    case 'Hospital':
      return Icons.local_hospital;
    case 'Farmácia':
      return Icons.local_pharmacy;
    case 'Mercado':
      return Icons.shopping_cart;
    default:
      return Icons.place;
  }
}
