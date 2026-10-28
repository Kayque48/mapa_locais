import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/locais_exemplo.dart';
import '../models/local.dart';

/// Responsável por conversar com o Cloud Firestore.
/// Assim nenhuma tela executa comandos de banco diretamente.
class LocalService {
  final CollectionReference locais =
      FirebaseFirestore.instance.collection('locais');

  /// READ — escuta a coleção em tempo real (snapshots).
  Stream<List<Local>> listarLocais() {
    return locais.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Local.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  /// READ — escuta um único documento (usado na tela de detalhes para
  /// refletir na hora a troca de favorito ou uma edição).
  /// Emite `null` se o documento for excluído.
  Stream<Local?> observarLocal(String id) {
    return locais.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Local.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  /// CREATE — o ID do documento é gerado automaticamente pelo Firestore.
  Future<void> adicionar(Local local) async {
    await locais.add(local.toMap());
  }

  /// UPDATE — o documento é identificado pelo ID guardado no Model.
  Future<void> atualizar(Local local) async {
    await locais.doc(local.id).update(local.toMap());
  }

  /// DELETE
  Future<void> excluir(String id) async {
    await locais.doc(id).delete();
  }

  /// UPDATE parcial — altera somente o campo favorito.
  Future<void> alterarFavorito(
    String id,
    bool favorito,
  ) async {
    await locais.doc(id).update({
      'favorito': favorito,
    });
  }

  /// Cadastra de uma vez os locais de exemplo (lib/data/locais_exemplo.dart).
  /// Usa um WriteBatch: ou grava todos, ou nenhum.
  /// Retorna a quantidade de documentos criados.
  Future<int> cadastrarLocaisExemplo() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final local in locaisExemplo) {
      batch.set(locais.doc(), local.toMap());
    }
    await batch.commit();
    return locaisExemplo.length;
  }
}
