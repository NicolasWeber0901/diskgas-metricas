# Conferência manual (clean-v1)

Medição oficial da tag clean-v1 (8cb5af7), feita em 10/11/2026 no mesmo dia e com as mesmas ferramentas da mvvm-v1.

## Função: `ValidarQuantidade.executar`

Arquivo: `lib/domain/casos_de_uso/validar_quantidade.dart`.

Complexidade ciclomática contada à mão: 1 (base) + 1 (`if` do estoque) + 1
(operador `?:` da mensagem) = **3**.
Valor do dart_code_linter: **3**. Confere.

Aninhamento: só o bloco da função = **1**. O `if` termina em `return` na mesma
linha, sem abrir bloco. Valor do dart_code_linter: **1**. Confere.

## Função: `RecusarPedido.validar`

Arquivo: `lib/domain/casos_de_uso/recusar_pedido.dart`.

Complexidade: 1 + 1 (primeiro `if`) + 1 (`||`) + 1 (segundo `if`) = **4**.
Aninhamento: bloco da função (1) + bloco do primeiro `if` (2) = **2**.
Valores do dart_code_linter: 4 e 2. Confere.

## Arquivo: `lib/domain/entidades/endereco.dart`

Importado por (busca nos fontes): `domain/entidades/cliente.dart`,
`domain/entidades/pedido.dart`, `domain/casos_de_uso/buscar_endereco_do_cliente.dart`,
`domain/casos_de_uso/cadastrar_cliente.dart`, `data/modelos/endereco_modelo.dart`,
`presentation/cadastro_viewmodel.dart`, `presentation/carrinho_viewmodel.dart` e
`ui/cadastro_view.dart`. Ca = **8**.

Não importa nenhum arquivo do projeto. Ce = **0**, instabilidade = **0**.

Valores do lakos: inDegree 8, outDegree 0, instabilidade 0,0. Confere.
