# Métricas oficiais (mvvm-v1 x clean-v1)

Ferramentas: Flutter 3.47.8, Dart 3.13.7, lakos 2.0.7, dart_code_linter 4.4.4.

## 1. Por camada

| Versão | Camada | Arq. | SLOC | Classes | Abstr. | Funções | CC soma | CC méd. | CC med. | CC máx. | CC>10 | Anin. máx. | Anin. méd. | WMC méd. | WMC med. | WMC máx. | Mét./classe méd. | Mét./classe med. | Mét./classe máx. | Parâm. méd. | Parâm. máx. | Ca méd. | Ca med. | Ca máx. | Ce méd. | Ce med. | Ce máx. | I méd. | I med. | I máx. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mvvm-v1 | models | 10 | 270 | 8 | 0 | 29 | 61,00 | 2,10 | 1,00 | 10,00 | 0 | 1,00 | 0,45 | 7,50 | 7,00 | 16,00 | 3,50 | 3,00 | 6,00 | 0,07 | 1,00 | 5,60 | 4,50 | 15 | 0,50 | 0,00 | 4 | 0,04 | 0,00 | 0,21 |
| mvvm-v1 | montagem | 3 | 233 | 2 | 0 | 7 | 11,00 | 1,57 | 1,00 | 4,00 | 0 | 2,00 | 0,71 | 2,00 | 2,00 | 2,00 | 2,00 | 2,00 | 2,00 | 0,67 | 2,00 | 0,67 | 1,00 | 1 | 11,67 | 7,00 | 25 | 0,90 | 0,96 | 1,00 |
| mvvm-v1 | services | 6 | 483 | 10 | 0 | 46 | 107,00 | 2,33 | 2,00 | 19,00 | 2 | 5,00 | 1,20 | 10,70 | 6,00 | 26,00 | 4,60 | 3,00 | 13,00 | 0,89 | 3,00 | 7,67 | 7,00 | 15 | 2,17 | 2,00 | 4 | 0,25 | 0,23 | 0,50 |
| mvvm-v1 | ui | 43 | 4002 | 77 | 0 | 189 | 379,00 | 2,01 | 1,00 | 9,00 | 0 | 3,00 | 0,66 | 4,66 | 3,00 | 52,00 | 2,34 | 2,00 | 17,00 | 0,90 | 5,00 | 3,23 | 1,00 | 33 | 3,86 | 2,00 | 14 | 0,51 | 0,50 | 0,93 |
| mvvm-v1 | viewmodels | 12 | 988 | 10 | 0 | 83 | 215,00 | 2,59 | 2,00 | 14,00 | 2 | 4,00 | 1,18 | 20,80 | 18,50 | 45,00 | 7,90 | 7,50 | 13,00 | 0,86 | 8,00 | 2,67 | 2,00 | 6 | 4,67 | 4,50 | 11 | 0,58 | 0,67 | 0,85 |
| mvvm-v1 | TOTAL | 74 | 5976 | 107 | 0 | 354 | 773,00 | 2,18 | 1,00 | 19,00 | 4 | 5,00 | 0,83 | 6,90 | 4,00 | 52,00 | 3,15 | 2,00 | 17,00 | 0,84 | 8,00 | 3,72 | 2,00 | 33 | 3,72 | 2,00 | 25 | 0,46 | 0,50 | 1,00 |
| mvvm-v1 | TOTAL_SEM_UI | 31 | 1974 | 30 | 0 | 165 | 394,00 | 2,39 | 1,00 | 19,00 | 4 | 5,00 | 1,04 | 12,63 | 10,00 | 45,00 | 5,23 | 4,50 | 13,00 | 0,77 | 8,00 | 4,39 | 3,00 | 15 | 3,52 | 2,00 | 25 | 0,38 | 0,33 | 1,00 |
| clean-v1 | data | 17 | 449 | 17 | 5 | 81 | 124,00 | 1,53 | 1,00 | 8,00 | 0 | 3,00 | 0,58 | 7,29 | 7,00 | 18,00 | 4,76 | 4,00 | 11,00 | 1,07 | 3,00 | 1,53 | 1,00 | 3 | 2,12 | 1,00 | 7 | 0,45 | 0,50 | 0,88 |
| clean-v1 | domain | 45 | 847 | 44 | 5 | 123 | 211,00 | 1,72 | 1,00 | 9,00 | 0 | 3,00 | 0,46 | 4,61 | 3,00 | 27,00 | 2,68 | 2,00 | 9,00 | 1,18 | 8,00 | 5,02 | 2,00 | 26 | 1,98 | 2,00 | 9 | 0,35 | 0,33 | 0,82 |
| clean-v1 | infra | 5 | 437 | 5 | 0 | 42 | 97,00 | 2,31 | 2,00 | 18,00 | 1 | 5,00 | 1,26 | 19,40 | 19,00 | 31,00 | 8,40 | 9,00 | 16,00 | 1,03 | 3,00 | 1,00 | 1,00 | 1 | 2,00 | 2,00 | 2 | 0,67 | 0,67 | 0,67 |
| clean-v1 | montagem | 3 | 320 | 2 | 0 | 7 | 11,00 | 1,57 | 1,00 | 4,00 | 0 | 2,00 | 0,71 | 2,00 | 2,00 | 2,00 | 2,00 | 2,00 | 2,00 | 0,67 | 2,00 | 0,67 | 1,00 | 1 | 23,33 | 19,00 | 48 | 0,91 | 0,98 | 1,00 |
| clean-v1 | presentation | 10 | 785 | 10 | 0 | 75 | 135,00 | 1,80 | 1,00 | 5,00 | 0 | 3,00 | 0,91 | 13,50 | 12,00 | 31,00 | 7,50 | 8,00 | 12,00 | 0,72 | 8,00 | 2,80 | 2,00 | 6 | 5,40 | 5,50 | 10 | 0,65 | 0,69 | 0,78 |
| clean-v1 | ui | 43 | 4003 | 77 | 0 | 189 | 379,00 | 2,01 | 1,00 | 9,00 | 0 | 3,00 | 0,66 | 4,66 | 3,00 | 52,00 | 2,34 | 2,00 | 17,00 | 0,90 | 5,00 | 3,23 | 1,00 | 33 | 3,88 | 2,00 | 14 | 0,51 | 0,50 | 0,93 |
| clean-v1 | TOTAL | 123 | 6841 | 155 | 10 | 517 | 957,00 | 1,85 | 1,00 | 18,00 | 1 | 5,00 | 0,68 | 5,95 | 4,00 | 52,00 | 3,23 | 2,00 | 17,00 | 0,97 | 8,00 | 3,46 | 2,00 | 33 | 3,46 | 2,00 | 48 | 0,47 | 0,50 | 1,00 |
| clean-v1 | TOTAL_SEM_UI | 80 | 2838 | 78 | 10 | 328 | 578,00 | 1,76 | 1,00 | 18,00 | 1 | 5,00 | 0,70 | 7,22 | 6,00 | 31,00 | 4,10 | 3,00 | 16,00 | 1,00 | 8,00 | 3,59 | 2,00 | 26 | 3,24 | 2,00 | 48 | 0,45 | 0,50 | 1,00 |

## 2. Matriz de imports entre camadas

| Versão | Origem | Destino | Imports |
|---|---|---|---|
| mvvm-v1 | montagem | services | 10 |
| mvvm-v1 | montagem | viewmodels | 12 |
| mvvm-v1 | montagem | montagem | 2 |
| mvvm-v1 | montagem | ui | 11 |
| mvvm-v1 | models | models | 5 |
| mvvm-v1 | services | models | 8 |
| mvvm-v1 | services | services | 5 |
| mvvm-v1 | viewmodels | models | 21 |
| mvvm-v1 | viewmodels | services | 31 |
| mvvm-v1 | viewmodels | viewmodels | 4 |
| mvvm-v1 | ui | models | 22 |
| mvvm-v1 | ui | viewmodels | 16 |
| mvvm-v1 | ui | ui | 128 |
| clean-v1 | data | domain | 20 |
| clean-v1 | data | data | 16 |
| clean-v1 | domain | domain | 89 |
| clean-v1 | infra | data | 5 |
| clean-v1 | infra | domain | 5 |
| clean-v1 | montagem | data | 5 |
| clean-v1 | montagem | domain | 35 |
| clean-v1 | montagem | infra | 5 |
| clean-v1 | montagem | presentation | 12 |
| clean-v1 | montagem | montagem | 2 |
| clean-v1 | montagem | ui | 11 |
| clean-v1 | presentation | domain | 54 |
| clean-v1 | ui | domain | 23 |
| clean-v1 | ui | presentation | 16 |
| clean-v1 | ui | ui | 128 |

## 3. Pacotes externos por camada

| Versão | Camada | Pacote | Imports |
|---|---|---|---|
| mvvm-v1 | montagem | cloud_firestore | 1 |
| mvvm-v1 | montagem | firebase_auth | 1 |
| mvvm-v1 | montagem | firebase_core | 1 |
| mvvm-v1 | montagem | flutter:material | 2 |
| mvvm-v1 | montagem | google_sign_in | 1 |
| mvvm-v1 | montagem | http | 1 |
| mvvm-v1 | montagem | provider | 3 |
| mvvm-v1 | montagem | flutter_localizations | 1 |
| mvvm-v1 | montagem | go_router | 2 |
| mvvm-v1 | models | cloud_firestore | 1 |
| mvvm-v1 | services | cloud_firestore | 4 |
| mvvm-v1 | services | firebase_auth | 1 |
| mvvm-v1 | services | google_sign_in | 1 |
| mvvm-v1 | services | dart:async | 1 |
| mvvm-v1 | services | dart:convert | 1 |
| mvvm-v1 | services | dart:io | 1 |
| mvvm-v1 | services | http | 1 |
| mvvm-v1 | viewmodels | dart:async | 8 |
| mvvm-v1 | viewmodels | flutter:foundation | 10 |
| mvvm-v1 | ui | flutter:material | 41 |
| mvvm-v1 | ui | go_router | 8 |
| mvvm-v1 | ui | provider | 13 |
| mvvm-v1 | ui | flutter:services | 6 |
| mvvm-v1 | ui | dart:async | 1 |
| mvvm-v1 | ui | dart:math | 1 |
| mvvm-v1 | ui | flutter:foundation | 1 |
| mvvm-v1 | ui | flutter:gestures | 1 |
| mvvm-v1 | ui | google_maps_flutter | 1 |
| clean-v1 | infra | cloud_firestore | 4 |
| clean-v1 | infra | firebase_auth | 1 |
| clean-v1 | infra | google_sign_in | 1 |
| clean-v1 | infra | dart:async | 1 |
| clean-v1 | infra | dart:convert | 1 |
| clean-v1 | infra | dart:io | 1 |
| clean-v1 | infra | http | 1 |
| clean-v1 | montagem | cloud_firestore | 1 |
| clean-v1 | montagem | firebase_auth | 1 |
| clean-v1 | montagem | firebase_core | 1 |
| clean-v1 | montagem | flutter:material | 2 |
| clean-v1 | montagem | google_sign_in | 1 |
| clean-v1 | montagem | http | 1 |
| clean-v1 | montagem | provider | 3 |
| clean-v1 | montagem | flutter_localizations | 1 |
| clean-v1 | montagem | go_router | 2 |
| clean-v1 | presentation | dart:async | 8 |
| clean-v1 | presentation | flutter:foundation | 10 |
| clean-v1 | ui | flutter:material | 41 |
| clean-v1 | ui | go_router | 8 |
| clean-v1 | ui | provider | 13 |
| clean-v1 | ui | flutter:services | 6 |
| clean-v1 | ui | dart:async | 1 |
| clean-v1 | ui | dart:math | 1 |
| clean-v1 | ui | flutter:foundation | 1 |
| clean-v1 | ui | flutter:gestures | 1 |
| clean-v1 | ui | google_maps_flutter | 1 |

## 4. Cobertura de linhas por camada

| Versão | Camada | Cobertas | Linhas | % |
|---|---|---|---|---|
| mvvm-v1 | models | 11 | 117 | 9,40 |
| mvvm-v1 | montagem | 1 | 104 | 0,96 |
| mvvm-v1 | services | 4 | 246 | 1,63 |
| mvvm-v1 | ui | 19 | 1536 | 1,24 |
| mvvm-v1 | viewmodels | 305 | 521 | 58,54 |
| mvvm-v1 | TOTAL | 340 | 2524 | 13,47 |
| mvvm-v1 | TOTAL_SEM_UI | 321 | 988 | 32,49 |
| clean-v1 | data | 0 | 219 | 0,00 |
| clean-v1 | domain | 164 | 281 | 58,36 |
| clean-v1 | infra | 0 | 210 | 0,00 |
| clean-v1 | montagem | 1 | 138 | 0,72 |
| clean-v1 | presentation | 51 | 373 | 13,67 |
| clean-v1 | ui | 19 | 1536 | 1,24 |
| clean-v1 | TOTAL | 235 | 2757 | 8,52 |
| clean-v1 | TOTAL_SEM_UI | 216 | 1221 | 17,69 |

## 5. Testes por arquivo

| Versão | Arquivo | Cenários | SLOC corpo | SLOC preparação | Dublês | when corpo | when preparação | verify | verifyNever |
|---|---|---|---|---|---|---|---|---|---|
| mvvm-v1 | viewmodels/cadastro_viewmodel_test.dart | 2 | 17 | 30 | 3 (MockAuthService MockClienteService FakeCliente) | 3 | 1 | 1 | 2 |
| mvvm-v1 | viewmodels/carrinho_viewmodel_test.dart | 5 | 50 | 53 | 5 (MockAuthService MockClienteService MockProdutoService MockPedidoService FakePedido) | 2 | 5 | 1 | 2 |
| mvvm-v1 | viewmodels/detalhe_pedido_viewmodel_test.dart | 10 | 48 | 84 | 4 (MockPedidoService MockRotaService MockProdutoService FakePedido) | 3 | 7 | 6 | 5 |
| mvvm-v1 | viewmodels/login_viewmodel_test.dart | 2 | 16 | 7 | 1 (MockAuthService) | 2 | 0 | 0 | 0 |
| mvvm-v1 | viewmodels/pedidos_viewmodel_test.dart | 2 | 11 | 67 | 2 (MockPedidoService MockProdutoService) | 0 | 2 | 0 | 0 |
| mvvm-v1 | viewmodels/perfil_cliente_viewmodel_test.dart | 1 | 37 | 32 | 2 (MockClienteService MockPedidoService) | 2 | 0 | 0 | 0 |
| clean-v1 | domain/casos_de_uso/aceitar_pedido_test.dart | 1 | 13 | 33 | 1 (MockPedidoRepositorio) | 0 | 0 | 0 | 1 |
| clean-v1 | domain/casos_de_uso/ampliar_tempo_test.dart | 2 | 13 | 40 | 1 (MockPedidoRepositorio) | 0 | 1 | 1 | 1 |
| clean-v1 | domain/casos_de_uso/cadastrar_cliente_test.dart | 2 | 23 | 31 | 3 (MockAutenticacaoRepositorio MockClienteRepositorio FakeCliente) | 3 | 0 | 1 | 2 |
| clean-v1 | domain/casos_de_uso/calcular_rota_do_pedido_test.dart | 2 | 7 | 47 | 2 (MockRotaRepositorio MockPedidoRepositorio) | 0 | 2 | 2 | 1 |
| clean-v1 | domain/casos_de_uso/enviar_pedido_test.dart | 3 | 39 | 48 | 5 (MockAutenticacaoRepositorio MockClienteRepositorio MockProdutoRepositorio MockPedidoRepositorio FakePedido) | 2 | 4 | 1 | 2 |
| clean-v1 | domain/casos_de_uso/filtrar_pedidos_test.dart | 2 | 16 | 50 | 0 () | 0 | 0 | 0 | 0 |
| clean-v1 | domain/casos_de_uso/finalizar_entrega_test.dart | 2 | 20 | 47 | 3 (MockPedidoRepositorio MockProdutoRepositorio FakePedido) | 2 | 1 | 1 | 1 |
| clean-v1 | domain/casos_de_uso/recusar_pedido_test.dart | 2 | 20 | 40 | 1 (MockPedidoRepositorio) | 0 | 1 | 1 | 1 |
| clean-v1 | domain/casos_de_uso/resumir_pedidos_do_cliente_test.dart | 1 | 15 | 30 | 0 () | 0 | 0 | 0 | 0 |
| clean-v1 | domain/casos_de_uso/validar_quantidade_test.dart | 2 | 2 | 7 | 0 () | 0 | 0 | 0 | 0 |
| clean-v1 | presentation/detalhe_pedido_viewmodel_test.dart | 1 | 26 | 36 | 7 (MockObservarPedido MockCalcularRotaDoPedido MockAceitarPedido MockAmpliarTempo MockRecusarPedido MockFinalizarEntrega FakePedido) | 5 | 0 | 1 | 0 |
| clean-v1 | presentation/login_viewmodel_test.dart | 2 | 16 | 8 | 2 (MockEntrarComEmail MockEntrarComGoogle) | 2 | 0 | 0 | 0 |
| mvvm-v1 | TOTAL (6 arquivos) | 22 | 179 | 273 | 17 | 12 | 15 | 8 | 9 |
| clean-v1 | TOTAL (12 arquivos) | 22 | 210 | 417 | 25 | 14 | 9 | 8 | 9 |

## 6. Maiores complexidades fora da interface

### mvvm-v1

| Função | Arquivo | CC |
|---|---|---|
| RotaService.calcularDeslocamento | lib/services/rota_service.dart | 19 |
| CarrinhoViewModel.enviarPedido | lib/viewmodels/carrinho_viewmodel.dart | 14 |
| CadastroViewModel._validar | lib/viewmodels/cadastro_viewmodel.dart | 13 |
| PedidoService.finalizarEntrega | lib/services/pedido_service.dart | 11 |
| Pedido.fromMap | lib/models/pedido.dart | 10 |

| Classe | Arquivo | WMC |
|---|---|---|
| DetalhePedidoViewModel | lib/viewmodels/detalhe_pedido_viewmodel.dart | 45 |
| CadastroViewModel | lib/viewmodels/cadastro_viewmodel.dart | 32 |
| CarrinhoViewModel | lib/viewmodels/carrinho_viewmodel.dart | 30 |
| PedidoService | lib/services/pedido_service.dart | 26 |
| RotaService | lib/services/rota_service.dart | 26 |

### clean-v1

| Função | Arquivo | CC |
|---|---|---|
| RotaGoogle.calcular | lib/infra/rota_google.dart | 18 |
| PedidoFirestore.finalizarEntrega | lib/infra/pedido_firestore.dart | 10 |
| CadastrarCliente.validar | lib/domain/casos_de_uso/cadastrar_cliente.dart | 9 |
| EnviarPedido.executar | lib/domain/casos_de_uso/enviar_pedido.dart | 9 |
| ClienteModelo.fromMap | lib/data/modelos/cliente_modelo.dart | 8 |

| Classe | Arquivo | WMC |
|---|---|---|
| PedidoFirestore | lib/infra/pedido_firestore.dart | 31 |
| DetalhePedidoViewModel | lib/presentation/detalhe_pedido_viewmodel.dart | 31 |
| CadastrarCliente | lib/domain/casos_de_uso/cadastrar_cliente.dart | 27 |
| AutenticacaoFirebase | lib/infra/autenticacao_firebase.dart | 22 |
| RotaGoogle | lib/infra/rota_google.dart | 19 |


## Tempos dos testes (s, PC parado)

| tag | 1 | 2 | 3 | média |
|---|---|---|---|---|
| mvvm-v1 | 7,44 | 7,37 | 7,50 | 7,44 |
| clean-v1 | 9,34 | 8,96 | 8,97 | 9,09 |

Protocolo em `tempos_protocolo.md`.
