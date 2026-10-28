import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/mensagens.dart';
import '../utils/navegacao.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/mapa_ilustrado.dart';
import '../widgets/perfil_sheet.dart';
import '../widgets/seletor_cidade.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

/// TELA 1 — Mapa principal.
/// Exibe o mapa com a localização do usuário e os pontos de interesse da
/// cidade selecionada. No topo há o seletor de cidade e o campo de pesquisa.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LocalService service = LocalService();
  final TextEditingController pesquisaController = TextEditingController();
  final TransformationController _zoomController = TransformationController();

  late final Stream<List<Local>> _streamLocais;

  String cidadeSelecionada = cidades.first;
  String? _idSelecionado;
  EstiloMapa _estilo = EstiloMapa.padrao;

  /// Posições dos marcadores no desenho do mapa (frações da largura/altura).
  static const List<Offset> _posicoes = [
    Offset(0.18, 0.17),
    Offset(0.74, 0.14),
    Offset(0.22, 0.42),
    Offset(0.80, 0.40),
    Offset(0.16, 0.60),
    Offset(0.66, 0.60),
    Offset(0.42, 0.78),
    Offset(0.86, 0.76),
    Offset(0.48, 0.24),
    Offset(0.30, 0.90),
    Offset(0.70, 0.90),
    Offset(0.58, 0.40),
  ];

  @override
  void initState() {
    super.initState();
    _streamLocais = service.listarLocais();
    localParaMostrarNoMapa.addListener(_mostrarLocalVindoDosDetalhes);
  }

  @override
  void dispose() {
    localParaMostrarNoMapa.removeListener(_mostrarLocalVindoDosDetalhes);
    pesquisaController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  /// "Ver no mapa" (Tela 3) -> seleciona a cidade e destaca o marcador.
  void _mostrarLocalVindoDosDetalhes() {
    final local = localParaMostrarNoMapa.value;
    if (local == null) return;
    setState(() {
      if (cidades.contains(local.cidade)) cidadeSelecionada = local.cidade;
      _idSelecionado = local.id;
      _zoomController.value = Matrix4.identity();
    });
    localParaMostrarNoMapa.value = null;
  }

  Future<void> _escolherCidade() async {
    final cidade = await selecionarCidade(
      context,
      cidadeAtual: cidadeSelecionada,
    );
    if (cidade != null) {
      setState(() {
        cidadeSelecionada = cidade;
        _idSelecionado = null;
      });
    }
  }

  /// Navega para a Tela 2 levando a cidade e o texto pesquisado (seção 21).
  void _abrirResultados() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadosScreen(
          cidade: cidadeSelecionada,
          pesquisa: pesquisaController.text,
        ),
      ),
    );
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

  void _onBarraNavegacao(int indice) {
    switch (indice) {
      case abaMapa:
        break; // já está no mapa
      case abaFavoritos:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ResultadosScreen(
              cidade: 'Todas',
              pesquisa: '',
              apenasFavoritos: true,
            ),
          ),
        );
        break;
      case abaPerfil:
        mostrarPerfil(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _cabecalho(context),
            Expanded(
              child: StreamBuilder<List<Local>>(
                stream: _streamLocais,
                builder: (context, snapshot) {
                  final todos = snapshot.data ?? [];
                  final locaisDaCidade = todos
                      .where((l) => l.cidade == cidadeSelecionada)
                      .toList()
                    ..sort((a, b) => a.nome.compareTo(b.nome));

                  return Stack(
                    children: [
                      Positioned.fill(child: _mapa(locaisDaCidade)),
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 72,
                        child: _statusConexao(snapshot, locaisDaCidade),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 24,
                        child: Column(
                          children: [
                            _botaoRedondo(
                              icone: Icons.my_location,
                              dica: 'Minha localização',
                              onPressed: () {
                                _zoomController.value = Matrix4.identity();
                                mostrarInfo(
                                  context,
                                  'Mapa centralizado na sua localização.',
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _botaoRedondo(
                              icone: Icons.layers_outlined,
                              dica: 'Camadas do mapa',
                              onPressed: () => setState(() {
                                _estilo = _estilo == EstiloMapa.padrao
                                    ? EstiloMapa.satelite
                                    : EstiloMapa.padrao;
                              }),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 24,
                        child: FilledButton.icon(
                          onPressed: _abrirResultados,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                          icon: const Icon(Icons.list_alt),
                          label: Text(
                            'Ver resultados (${locaisDaCidade.length})',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BarraNavegacao(
        indiceAtual: abaMapa,
        onSelecionar: _onBarraNavegacao,
      ),
    );
  }

  /// Cidade selecionada + campo de pesquisa (topo do wireframe).
  Widget _cabecalho(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _escolherCidade,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 28),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cidade selecionada',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            cidadeSelecionada,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pesquisaController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _abrirResultados(),
            decoration: InputDecoration(
              hintText: 'Buscar locais, endereços ou categorias...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Pesquisar',
                icon: const Icon(Icons.arrow_forward),
                onPressed: _abrirResultados,
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
        ],
      ),
    );
  }

  /// Mapa com zoom/arraste, posição do usuário e marcadores.
  Widget _mapa(List<Local> locais) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final altura = constraints.maxHeight;

        return InteractiveViewer(
          transformationController: _zoomController,
          minScale: 1,
          maxScale: 3,
          child: SizedBox(
            width: largura,
            height: altura,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: MapaIlustrado(estilo: _estilo)),
                // Localização atual do usuário (ponto azul).
                Positioned(
                  left: largura * 0.5 - 28,
                  top: altura * 0.48 - 28,
                  child: const _PontoUsuario(),
                ),
                for (var i = 0; i < locais.length; i++)
                  _marcador(locais[i], _posicao(i, locais[i]), largura, altura),
              ],
            ),
          ),
        );
      },
    );
  }

  Offset _posicao(int indice, Local local) {
    if (indice < _posicoes.length) return _posicoes[indice];
    // Mais locais do que posições fixas: posição calculada a partir do ID.
    var hash = 0;
    for (final c in local.id.codeUnits) {
      hash = (hash * 31 + c) & 0x7fffffff;
    }
    return Offset(0.1 + (hash % 80) / 100, 0.1 + ((hash ~/ 80) % 80) / 100);
  }

  Widget _marcador(Local local, Offset posicao, double largura, double altura) {
    final selecionado = local.id == _idSelecionado;
    const tamanho = 40.0;
    // Perto da borda direita o balão com o nome aparece à esquerda do pino.
    final balaoAEsquerda = posicao.dx > 0.6;

    final pino = GestureDetector(
      onTap: () {
        if (selecionado) {
          _abrirDetalhes(local);
        } else {
          setState(() => _idSelecionado = local.id);
        }
      },
      child: Icon(
        Icons.location_on,
        size: tamanho,
        color: selecionado
            ? Theme.of(context).colorScheme.primary
            : const Color(0xFF3C3F44),
        shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
      ),
    );

    final balao = GestureDetector(
      onTap: () => _abrirDetalhes(local),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(blurRadius: 6, color: Colors.black26),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              local.nome,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16),
          ],
        ),
      ),
    );

    return Positioned(
      left: balaoAEsquerda ? null : posicao.dx * largura - tamanho / 2,
      right: balaoAEsquerda
          ? largura - (posicao.dx * largura + tamanho / 2)
          : null,
      top: posicao.dy * altura - tamanho,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balaoAEsquerda
            ? [if (selecionado) balao, pino]
            : [pino, if (selecionado) balao],
      ),
    );
  }

  /// Mostra carregando / erro / vazio sobre o mapa.
  Widget _statusConexao(
    AsyncSnapshot<List<Local>> snapshot,
    List<Local> locaisDaCidade,
  ) {
    String? texto;
    IconData icone = Icons.info_outline;
    Color cor = Colors.white;

    if (snapshot.connectionState == ConnectionState.waiting) {
      texto = 'Carregando locais do Firestore...';
      icone = Icons.cloud_download_outlined;
    } else if (snapshot.hasError) {
      texto = 'Erro ao carregar os locais.';
      icone = Icons.error_outline;
      cor = Colors.red.shade50;
    } else if (locaisDaCidade.isEmpty) {
      texto = 'Nenhum local em $cidadeSelecionada. '
          'Cadastre em "Ver resultados" ou carregue exemplos no Perfil.';
    }

    if (texto == null) return const SizedBox.shrink();

    return Material(
      color: cor,
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icone, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(texto, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoRedondo({
    required IconData icone,
    required String dica,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        tooltip: dica,
        icon: Icon(icone),
        onPressed: onPressed,
      ),
    );
  }
}

/// Ponto azul com halo (posição do usuário).
class _PontoUsuario extends StatelessWidget {
  const _PontoUsuario();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.18),
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ),
    );
  }
}
