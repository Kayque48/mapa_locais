import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/formatadores.dart';
import '../utils/mensagens.dart';
import '../utils/navegacao.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/imagem_local.dart';

/// TELA 3 — Detalhes do local.
/// Recebe o local selecionado e exibe todas as informações cadastradas,
/// o botão de favorito (altera o Firestore) e o botão "Ver no mapa".
class DetalhesScreen extends StatefulWidget {
  final Local local;

  const DetalhesScreen({
    super.key,
    required this.local,
  });

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final LocalService service = LocalService();
  final PageController _paginaController = PageController();
  late final Stream<Local?> _streamLocal;

  static const int _totalFotos = 5;
  int _fotoAtual = 0;
  bool _salvandoFavorito = false;

  @override
  void initState() {
    super.initState();
    _streamLocal = service.observarLocal(widget.local.id);
  }

  @override
  void dispose() {
    _paginaController.dispose();
    super.dispose();
  }

  /// Favoritar (seção 20): inverte o campo favorito do documento.
  Future<void> _alternarFavorito(Local local) async {
    setState(() => _salvandoFavorito = true);
    try {
      await LocalService().alterarFavorito(
        local.id,
        !local.favorito,
      );
      if (!mounted) return;
      mostrarSucesso(
        context,
        local.favorito
            ? '"${local.nome}" removido dos favoritos.'
            : '"${local.nome}" adicionado aos favoritos!',
      );
    } catch (e) {
      if (!mounted) return;
      mostrarErro(context, 'Erro ao atualizar favorito: $e');
    } finally {
      if (mounted) setState(() => _salvandoFavorito = false);
    }
  }

  Future<void> _compartilhar(Local local) async {
    await Clipboard.setData(
      ClipboardData(
        text: '${local.nome} (${local.categoria}) - ${local.cidade}\n'
            'Avaliação: ${formatarAvaliacao(local.avaliacao)} · '
            'Horário: ${local.horario}',
      ),
    );
    if (!mounted) return;
    mostrarInfo(context, 'Informações do local copiadas para compartilhar.');
  }

  Future<void> _agendar(Local local) async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 60)),
      helpText: 'Agendar visita',
    );
    if (data == null || !mounted) return;
    mostrarSucesso(
      context,
      'Visita a ${local.nome} agendada para '
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Local?>(
      stream: _streamLocal,
      initialData: widget.local,
      builder: (context, snapshot) {
        final local = snapshot.data;

        if (snapshot.hasError) {
          return _telaMensagem('Erro ao carregar o local.');
        }
        if (local == null) {
          return _telaMensagem('Este local foi excluído.');
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              tooltip: 'Voltar',
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                tooltip: local.favorito
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                onPressed:
                    _salvandoFavorito ? null : () => _alternarFavorito(local),
                icon: Icon(
                  local.favorito ? Icons.favorite : Icons.favorite_border,
                  color: local.favorito ? Colors.red : null,
                ),
              ),
              IconButton(
                tooltip: 'Compartilhar',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _compartilhar(local),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              _carrossel(local),
              const SizedBox(height: 16),
              Text(
                local.nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                local.categoria,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              _linhaAvaliacao(local),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _info(Icons.location_on_outlined,
                      formatarDistancia(local.distancia)),
                  _info(Icons.access_time,
                      textoHorario(local.horario, DateTime.now())),
                  _info(Icons.location_city_outlined, local.cidade),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _acaoRapida(
                    Icons.call_outlined,
                    'Ligar',
                    () => mostrarInfo(
                      context,
                      'Telefone de ${local.nome} ainda não cadastrado.',
                    ),
                  ),
                  _acaoRapida(
                    Icons.near_me_outlined,
                    'Como chegar',
                    () => mostrarInfo(
                      context,
                      'Rota até ${local.nome}: '
                      '${formatarDistancia(local.distancia)} de você.',
                    ),
                  ),
                  _acaoRapida(
                    Icons.event_outlined,
                    'Agendar',
                    () => _agendar(local),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Sobre',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                local.descricao.isEmpty
                    ? 'Nenhuma descrição cadastrada.'
                    : local.descricao,
              ),
              const Divider(height: 32),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Fotos',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _verTodasFotos(local),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Ver todas'),
                        Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: ImagemLocal(
                        categoria: local.categoria,
                        altura: 80,
                        tamanhoIcone: 32,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: FilledButton.icon(
                  onPressed: () => verNoMapa(context, local),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black87,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Ver no mapa'),
                ),
              ),
              BarraNavegacao(
                indiceAtual: abaMapa,
                onSelecionar: (indice) => navegarPelaBarra(context, indice),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Carrossel de imagens com contador "1/5" e indicadores (wireframe).
  Widget _carrossel(Local local) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _paginaController,
                  itemCount: _totalFotos,
                  onPageChanged: (pagina) =>
                      setState(() => _fotoAtual = pagina),
                  itemBuilder: (context, index) => ImagemLocal(
                    categoria: local.categoria,
                    raio: 0,
                    tamanhoIcone: 80,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_fotoAtual + 1}/$_totalFotos',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _totalFotos; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _fotoAtual
                      ? Colors.black87
                      : Colors.grey.shade300,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _linhaAvaliacao(Local local) {
    final estrelasCheias = local.avaliacao.floor();
    final temMeia = local.avaliacao - estrelasCheias >= 0.5;
    return Row(
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < estrelasCheias
                ? Icons.star
                : (i == estrelasCheias && temMeia
                    ? Icons.star_half
                    : Icons.star_border),
            size: 18,
            color: Colors.amber.shade700,
          ),
        const SizedBox(width: 6),
        Text(
          formatarAvaliacao(local.avaliacao),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '  (avaliação média)',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _info(IconData icone, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 18, color: Colors.grey.shade800),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }

  Widget _acaoRapida(IconData icone, String rotulo, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Icon(icone, size: 22),
            ),
            const SizedBox(height: 6),
            Text(rotulo, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _verTodasFotos(Local local) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fotos de ${local.nome}'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (var i = 0; i < _totalFotos; i++)
                ImagemLocal(categoria: local.categoria),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _telaMensagem(String mensagem) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(mensagem),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
