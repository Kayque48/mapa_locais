import '../models/local.dart';

/// Pesquisa e filtros aplicados em memória (seção 16 do tutorial).
/// O Firestore fornece os documentos e o Flutter filtra a lista.
List<Local> filtrarLocais(
  List<Local> locais,
  String texto,
  String cidade,
  String categoria,
) {
  return locais.where((local) {
    final correspondeCidade =
        cidade == 'Todas' || local.cidade == cidade;

    final correspondeCategoria =
        categoria == 'Todos' ||
        local.categoria == categoria;

    final termo = texto.toLowerCase();

    final correspondeTexto =
        local.nome.toLowerCase().contains(termo) ||
        local.categoria.toLowerCase().contains(termo);

    return correspondeCidade &&
        correspondeCategoria &&
        correspondeTexto;
  }).toList();
}

/// Filtro de favoritos (seção 20: "os favoritos podem ser exibidos como um
/// filtro dentro da tela de resultados").
List<Local> filtrarFavoritos(List<Local> locais, bool apenasFavoritos) {
  if (!apenasFavoritos) return locais;
  return locais.where((local) => local.favorito).toList();
}
