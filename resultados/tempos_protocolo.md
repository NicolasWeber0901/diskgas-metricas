# Tempos dos testes (v1)

Comando: `flutter test --no-pub` dentro de `fontes/<tag>`, com o computador sem outros programas pesados abertos (emulador e OBS fechados).
Antes das três execuções que valem, a ferramenta do Flutter já tinha rodado os testes uma vez (a primeira execução depois de um tempo parado leva mais, 33,38 s na MVVM, por compilar e carregar a ferramenta).

| tag | execução 1 | execução 2 | execução 3 | média |
|---|---|---|---|---|
| mvvm-v1 | 7,44 | 7,37 | 7,50 | 7,44 |
| clean-v1 | 9,34 | 8,96 | 8,97 | 9,09 |

Rodada anterior com o computador parado (mesmo dia): MVVM 8,17 e 7,94; Clean 9,76, 9,32 e 8,78.
Os tempos da primeira medição, com o computador em uso, ficaram em `tempos_testes_pc_em_uso.txt` de cada tag e não entram na comparação.
