// Testes automatizados da lógica do app (não precisam do Firebase).
// Execute com:  flutter test
//
// Os testes manuais T01–T11 da seção 26 estão no documento de entrega.

import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/utils/filtros.dart';
import 'package:mapa_locais/utils/formatadores.dart';

Local _local(String nome, String categoria, String cidade,
    {bool favorito = false}) {
  return Local(
    id: nome,
    nome: nome,
    categoria: categoria,
    cidade: cidade,
    avaliacao: 4.5,
    distancia: 1.0,
    horario: '06:00 - 22:00',
    descricao: '',
    favorito: favorito,
  );
}

void main() {
  final locais = [
    _local('Academia Fitness', 'Academia', 'São Paulo', favorito: true),
    _local('Smart Fit', 'Academia', 'São Paulo'),
    _local('Sabor Caipira', 'Restaurante', 'Campinas'),
    _local('Campinas Fit Club', 'Academia', 'Campinas', favorito: true),
    _local('Farmácia Saúde Já', 'Farmácia', 'Jundiaí'),
  ];

  group('Model Local', () {
    test('fromMap converte os tipos e aplica valores padrão', () {
      final local = Local.fromMap('abc', {
        'nome': 'Academia Fitness',
        'categoria': 'Academia',
        'cidade': 'São Paulo',
        'avaliacao': 5, // int no Firestore
        'distancia': 1.2,
      });

      expect(local.id, 'abc');
      expect(local.avaliacao, 5.0);
      expect(local.distancia, 1.2);
      expect(local.horario, '');
      expect(local.descricao, '');
      expect(local.favorito, false);
    });

    test('toMap gera os 8 campos da coleção locais (sem o id)', () {
      final mapa = locais.first.toMap();
      expect(mapa.keys, [
        'nome',
        'categoria',
        'cidade',
        'avaliacao',
        'distancia',
        'horario',
        'descricao',
        'favorito',
      ]);
      expect(mapa.containsKey('id'), false);
    });

    test('copyWith mantém o id e altera apenas o informado', () {
      final editado = locais.first.copyWith(nome: 'Novo nome');
      expect(editado.id, locais.first.id);
      expect(editado.nome, 'Novo nome');
      expect(editado.favorito, true);
    });
  });

  group('Pesquisa e filtros', () {
    test('T02 - pesquisar por "Academia" (nome ou categoria)', () {
      final r = filtrarLocais(locais, 'academia', 'Todas', 'Todos');
      expect(r.map((l) => l.nome), [
        'Academia Fitness',
        'Smart Fit',
        'Campinas Fit Club',
      ]);
    });

    test('T03 - selecionar Campinas', () {
      final r = filtrarLocais(locais, '', 'Campinas', 'Todos');
      expect(r.every((l) => l.cidade == 'Campinas'), true);
      expect(r.length, 2);
    });

    test('T04 - selecionar uma categoria', () {
      final r = filtrarLocais(locais, '', 'Todas', 'Restaurante');
      expect(r.single.nome, 'Sabor Caipira');
    });

    test('filtros combinados (cidade + categoria + texto)', () {
      final r = filtrarLocais(locais, 'club', 'Campinas', 'Academia');
      expect(r.single.nome, 'Campinas Fit Club');
    });

    test('T09 - filtro de favoritos', () {
      final r = filtrarFavoritos(locais, true);
      expect(r.length, 2);
      expect(filtrarFavoritos(locais, false).length, locais.length);
    });
  });

  group('Formatadores', () {
    test('distância e avaliação com vírgula', () {
      expect(formatarDistancia(1.2), '1,2 km');
      expect(formatarAvaliacao(4.8), '4,8');
    });

    test('aberto / fechado pelo horário', () {
      final dezHoras = DateTime(2026, 1, 1, 10);
      final meiaNoite = DateTime(2026, 1, 1, 23, 30);
      expect(estaAberto('06:00 - 22:00', dezHoras), true);
      expect(estaAberto('06:00 - 22:00', meiaNoite), false);
      expect(estaAberto('18:00 - 02:00', meiaNoite), true);
      expect(estaAberto('00:00 - 00:00', meiaNoite), true);
      expect(estaAberto('qualquer', dezHoras), null);
    });

    test('validação do horário e leitura de números', () {
      expect(horarioValido('06:00 - 22:00'), true);
      expect(horarioValido('25:00 - 22:00'), false);
      expect(horarioValido('6h às 22h'), false);
      expect(lerNumero('4,5'), 4.5);
      expect(lerNumero('abc'), null);
    });
  });
}
