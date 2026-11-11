# Cenários de mudança na versão Clean

Base: tag clean-v1 (8cb5af7), cópia em `fontes/clean-v1`. Cada cenário foi feito numa cópia separada (`cenarios/clean-c1` e `cenarios/clean-c2`), sem commit. Os números saem de `git diff --no-index --numstat --ignore-space-at-eol -M` entre a base e a cópia (arquivos `.patch` e `.numstat.txt` ao lado).

Depois de cada cenário: `flutter analyze` sem avisos, `verificar_camadas.dart` com 0 violações e todos os testes passando.

## C1: trocar o serviço de rota (Google Routes para Nominatim + OSRM)

| Camada | Arquivos | Linhas |
|---|---|---|
| infra | 1 removido (`rota_google.dart`), 1 criado (`rota_osrm.dart`) | +102 / -80 |
| montagem (`main.dart`) | 1 alterado | +2 / -2 |
| data, domain, presentation, ui | nenhum | 0 |
| **Total lib** | **3** | **+104 / -82** |
| test | nenhum | 0 |

A classe nova `RotaOsrm` implementa a mesma interface `RotaFonte` da camada data, então nada acima da infra mudou. Testes: 22, todos passando, nenhum alterado ou criado (a rota não tinha teste de unidade nas duas versões).

Comparando só o conteúdo (rota_google contra rota_osrm, como se fosse o mesmo arquivo editado): +59 / -37. Na MVVM o mesmo cenário deu `rota_service.dart` +57 / -37 e `main.dart` +1 / -4.

## C2: novo estado "Saiu para entrega" entre Aceito e Entregue

| Camada | Arquivos | Linhas |
|---|---|---|
| domain | 1 criado (`casos_de_uso/marcar_saida.dart`, 24) e 6 alterados (`situacao_pedido`, `pedido`, `pedido_repositorio`, `ampliar_tempo`, `finalizar_entrega`, `observar_pedidos_recebidos`) | +41 / -6 |
| data | 3 alterados (`pedido_fonte`, `pedido_modelo`, `pedido_repositorio_dados`) | +7 / 0 |
| infra | 1 alterado (`pedido_firestore`) | +9 / -1 |
| presentation | 1 alterado (`detalhe_pedido_viewmodel`) | +10 / 0 |
| ui | 4 alterados (`acompanhamento_view`, `detalhe_pedido/historico_pedido`, `detalhe_pedido_view`, `widgets/selo_situacao`) | +62 / -24 |
| montagem (`main/app_router.dart`) | 1 alterado | +2 / 0 |
| **Total lib** | **17** | **+131 / -31** |
| test | 2 alterados | +43 / -4 |

A parte de ui é igual à da MVVM (mesmos trechos). A diferença está no resto: na Clean a regra nova virou um caso de uso próprio (`MarcarSaida`) e a operação passou pela interface do repositório, pela fonte, pelo repositório de dados e pela implementação Firestore.

Testes: 23 no total, todos passando.
- `domain/casos_de_uso/finalizar_entrega_test.dart` (alterado): os testes da RN04 passam a usar pedido em `saiuParaEntrega`; teste novo no grupo "Saída para entrega": "pedido aceito só pode ser finalizado depois de marcar a saída".
- `presentation/detalhe_pedido_viewmodel_test.dart` (alterado): só inclui o `MockMarcarSaida` no construtor do ViewModel.
