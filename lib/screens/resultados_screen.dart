import 'package:flutter/material.dart';
import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/filtros.dart';
import '../utils/mensagens.dart';
import '../utils/navegacao.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import '../widgets/perfil_sheet.dart';
import '../widgets/seletor_cidade.dart';
import 'detalhes_screen.dart';

/// TELA 2 — Lista / resultados.
/// Lê os locais do Firestore e aplica pesquisa, filtro por cidade,
/// categoria e favoritos. Daqui é possível cadastrar, editar e excluir.
class ResultadosScreen extends StatefulWidget {
  final String cidade;
  final String pesquisa;
  final bool apenasFavoritos;

  const ResultadosScreen({
    super.key,
    required this.cidade,
    required this.pesquisa,
    this.apenasFavoritos = false,
  });

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final LocalService service = LocalService();
  late final TextEditingController pesquisaController;
  late final Stream<List<Local>> _streamLocais;

  late String cidadeSelecionada;
  String categoriaSelecionada = todasCategorias;
  late bool apenasFavoritos;

  @override
  void initState() {
    super.initState();
    pesquisaController = TextEditingController(text: widget.pesquisa);
    cidadeSelecionada = widget.cidade;
    apenasFavoritos = widget.apenasFavoritos;
    _streamLocais = service.listarLocais();
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _escolherCidade() async {
    final cidade = await selecionarCidade(
      context,
      cidadeAtual: cidadeSelecionada,
      incluirTodas: true,
    );
    if (cidade != null) setState(() => cidadeSelecionada = cidade);
  }

  void _abrirDetalhes(Local local) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesScreen(
          local: local,
        ),
      ),
    );
  }

  /// DELETE com confirmação (seção 19).
  Future<void> _excluir(Local local) async {
    final confirmou = await confirmarExclusao(context, local.nome);
    if (!confirmou) return;

    try {
      await LocalService().excluir(local.id);
      if (!mounted) return;
      mostrarSucesso(context, 'Local "${local.nome}" excluído.');
    } catch (e) {
      if (!mounted) return;
      mostrarErro(context, 'Erro ao excluir: $e');
    }
  }

  void _onBarraNavegacao(int indice) {
    switch (indice) {
      case abaMapa:
        voltarParaMapa(context);
        break;
      case abaFavoritos:
        setState(() => apenasFavoritos = !apenasFavoritos);
        break;
      case abaPerfil:
        mostrarPerfil(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        centerTitle: true,
        title: Text(
          apenasFavoritos ? 'Favoritos' : 'Resultados',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: apenasFavoritos
                ? 'Mostrar todos'
                : 'Mostrar somente favoritos',
            icon: Icon(
              apenasFavoritos ? Icons.favorite : Icons.favorite_border,
              color: apenasFavoritos ? Colors.red : null,
            ),
            onPressed: () =>
                setState(() => apenasFavoritos = !apenasFavoritos),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormularioLocal(
          context,
          cidadeInicial: cidadeSelecionada,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo local'),
      ),
      bottomNavigationBar: BarraNavegacao(
        indiceAtual: apenasFavoritos ? abaFavoritos : abaMapa,
        onSelecionar: _onBarraNavegacao,
      ),
      body: Column(
        children: [
          _campoPesquisa(),
          _linhaCidade(),
          _chipsCategoria(),
          Expanded(child: _lista()),
        ],
      ),
    );
  }

  Widget _campoPesquisa() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: pesquisaController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Pesquisar por nome ou categoria',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: pesquisaController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    pesquisaController.clear();
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _linhaCidade() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.location_on_outlined),
          title: Text(
            cidadeSelecionada == todasCidades
                ? 'Todas as cidades'
                : cidadeSelecionada,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _escolherCidade,
        ),
      ),
    );
  }

  Widget _chipsCategoria() {
    final opcoes = [todasCategorias, ...categorias];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: opcoes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final categoria = opcoes[index];
          final selecionada = categoria == categoriaSelecionada;
          return ChoiceChip(
            label: Text(categoriasPlural[categoria] ?? categoria),
            selected: selecionada,
            showCheckmark: false,
            selectedColor: Colors.black87,
            labelStyle: TextStyle(
              color: selecionada ? Colors.white : Colors.black87,
            ),
            shape: const StadiumBorder(),
            onSelected: (_) =>
                setState(() => categoriaSelecionada = categoria),
          );
        },
      ),
    );
  }

  /// Leitura do Firestore com StreamBuilder (seção 15).
  Widget _lista() {
    return StreamBuilder<List<Local>>(
      stream: _streamLocais,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _mensagemCentral(
            Icons.cloud_off,
            'Erro ao carregar os locais.',
            'Verifique a internet e as regras do Firestore.\n'
                '${snapshot.error}',
          );
        }

        final todos = snapshot.data ?? [];
        final filtrados = filtrarFavoritos(
          filtrarLocais(
            todos,
            pesquisaController.text,
            cidadeSelecionada,
            categoriaSelecionada,
          ),
          apenasFavoritos,
        )..sort((a, b) => a.distancia.compareTo(b.distancia));

        if (filtrados.isEmpty) {
          return _mensagemCentral(
            apenasFavoritos ? Icons.favorite_border : Icons.search_off,
            'Nenhum local encontrado.',
            todos.isEmpty
                ? 'A coleção "locais" está vazia. Toque em "Novo local" '
                    'ou carregue exemplos na aba Perfil.'
                : 'Tente mudar a pesquisa ou os filtros.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 96),
          itemCount: filtrados.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Text(
                  '${filtrados.length} '
                  '${filtrados.length == 1 ? 'resultado' : 'resultados'}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              );
            }
            final local = filtrados[index - 1];
            return LocalCard(
              local: local,
              onTap: () => _abrirDetalhes(local),
              onEditar: () => abrirFormularioLocal(context, local: local),
              onExcluir: () => _excluir(local),
            );
          },
        );
      },
    );
  }

  Widget _mensagemCentral(IconData icone, String titulo, String subtitulo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
