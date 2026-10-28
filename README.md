# Mapa de Locais — Flutter + Cloud Firestore

Avaliação Formativa SENAI — Desenvolvimento de Aplicação Mobile com Flutter.
Aplicação de localização com 3 telas (Mapa, Resultados e Detalhes) e CRUD na coleção `locais` do Cloud Firestore.

> O passo a passo completo (Firebase, FlutterFire, regras, testes e problemas comuns)
> está no arquivo **Guia_Passo_a_Passo_Firebase.docx**, na pasta acima desta.

## Comandos rápidos (PowerShell, dentro desta pasta)

```powershell
flutter create . --platforms=android,web   # gera android/ e web/ sem sobrescrever o código
flutter pub get
firebase login
dart pub global activate flutterfire_cli
flutterfire configure                      # escolha o projeto mapa-locais-flutter + android
flutter test                               # testes automatizados
flutter run
```

## Estrutura

```
lib/
├── main.dart                 # inicializa o Firebase e abre a MapaScreen
├── firebase_options.dart     # PROVISÓRIO — gerado pelo "flutterfire configure"
├── models/local.dart         # Model Local (fromMap / toMap / copyWith)
├── services/local_service.dart  # CRUD no Firestore (add, snapshots, update, delete)
├── screens/
│   ├── mapa_screen.dart      # Tela 1 — mapa, cidade, pesquisa, marcadores
│   ├── resultados_screen.dart# Tela 2 — lista, filtros, cadastrar/editar/excluir
│   └── detalhes_screen.dart  # Tela 3 — detalhes, favorito, ver no mapa
├── widgets/
│   ├── local_card.dart       # item da lista
│   ├── local_form.dart       # formulário (Bottom Sheet) de cadastro/edição
│   ├── mapa_ilustrado.dart   # representação do mapa (CustomPainter)
│   ├── barra_navegacao.dart  # Mapa | Favoritos | Perfil
│   ├── seletor_cidade.dart   # Bottom Sheet de cidades
│   ├── imagem_local.dart     # placeholder de imagem do wireframe
│   └── perfil_sheet.dart     # aba Perfil + carregar locais de exemplo
├── dialogs/confirm_delete.dart  # confirmação antes de excluir
├── utils/                    # constantes, filtros, formatadores, mensagens, navegação
└── data/locais_exemplo.dart  # 17 locais de exemplo (SP, Campinas, Jundiaí)
firestore.rules               # regras de segurança para publicar no console
```
