# diskgas-metricas

Material da medição do Trabalho de Conclusão de Curso "Avaliação comparativa entre MVVM e Clean Architecture em Flutter" (Engenharia de Software, UDESC/CEAVI), de Nicolas Weber, 2026.

Aqui estão os scripts usados na coleta, as saídas brutas das ferramentas, as tabelas consolidadas e os patches dos cenários de mudança. O código dos aplicativos fica nos repositórios `diskgas-mvvm` e `diskgas-clean`.

## Versões medidas

| Versão | Repositório | Tag | Commit |
|---|---|---|---|
| MVVM v1 | diskgas-mvvm | `mvvm-v1` | `5a920d9` |
| MVVM v2 | diskgas-mvvm | `mvvm-v2` | `9a8f637` |
| Clean v1 | diskgas-clean | `clean-v1` | `8cb5af7` |
| Clean v2 | diskgas-clean | `clean-v2` | `db11a74` |

A v1 é a medição principal. A v2 é complementar: foi medida passando o hash do commit no lugar da tag (`-Tag 9a8f637` e `-Tag db11a74`), e as pastas foram depois movidas para `resultados/v2/`. Por isso o campo `commit` do `versoes.txt` da v2 ficou vazio (o hash está no campo `tag`).

## Ferramentas e versões

- Flutter 3.47.8 e Dart 3.13.7
- lakos 2.0.7: grafo de dependências entre arquivos, linhas de código (SLOC), Ca, Ce e instabilidade
- dart_code_linter 4.4.4: complexidade ciclomática, aninhamento, número de parâmetros e número de métodos por classe
- `flutter test --coverage`: cobertura de linhas (lcov)
- Git 2.34.0 (exportação das tags e diferenças dos cenários)
- Windows PowerShell 5.1 (`medir.ps1`)
- Python 3.14.0 (`diff_cenario.py`)

As versões do Flutter, do Dart e dos pacotes usados em cada medição ficaram registradas em `resultados/<versão>/versoes.txt`.

## Scripts (`scripts/`)

- `medir.ps1`: mede uma tag. Ele faz, nesta ordem:
  1. exporta a tag com `git archive` para `fontes/<tag>`, fora do repositório;
  2. roda `flutter pub get` e `flutter analyze`, e interrompe a medição se o analyze acusar algum problema;
  3. roda o lakos (`-f json -m --node-metrics`) e o dart_code_linter (`metrics analyze lib --reporter=json`);
  4. cria, só na cópia exportada, um teste auxiliar que importa todos os arquivos de `lib/`, para que a cobertura considere todos os arquivos, inclusive os que nenhum teste importa;
  5. roda `flutter test --coverage`, guarda o `lcov.info` e apaga o teste auxiliar;
  6. roda `flutter test` três vezes, medindo o tempo de cada execução com `Measure-Command`;
  7. roda o `contagem.dart` e grava as versões das ferramentas.

  Tudo vai para `resultados/<tag>/`. O script não formata nem altera o código medido; o repositório original não é tocado.
- `contagem.dart`: lê os fontes da cópia e conta, por arquivo, classes, classes abstratas, enums, mixins e extensões. Também monta a matriz de importações entre camadas, os pacotes externos usados por camada e os arquivos que têm comentários de regra (`// RNxx:`). Nos testes, conta as linhas do corpo de cada teste, as linhas de preparação do arquivo, os dublês (classes `Mock` e `Fake`) e as chamadas `when`, `verify` e `verifyNever`. Uso: `dart contagem.dart <copia> <camadas.json> <saida.json>`.
- `consolidar.dart`: junta `contagem.json`, `lakos.json`, `dcl.json`, `lcov.info` e `tempos_testes.txt` das tags informadas e gera os CSVs de `resultados/tabelas/`. Calcula por camada o SLOC (do lakos), a complexidade ciclomática, o WMC (soma da complexidade dos métodos de cada classe), Ca, Ce, instabilidade e a cobertura. Também gera os totais com e sem a camada de interface (`TOTAL` e `TOTAL_SEM_UI`). Uso: `dart consolidar.dart <tag> <tag>`.
- `verificar_camadas.dart`: confere a regra de dependência da versão Clean. Ele aponta importações proibidas entre camadas, pacotes externos fora da camada permitida e arquivos fora das camadas. Usa o mapa `camadas_clean.json` e se aplica só à versão Clean. Saída 0 quando não há violações e 1 quando há. Uso: `dart verificar_camadas.dart <repositorio>`.
- `diff_cenario.py`: compara a cópia de um cenário com a base usando `git diff --no-index --numstat --ignore-space-at-eol -M`. Grava o `.patch` e o `.numstat.txt` e mostra o resumo por camada (`lib/`, `test/` e demais arquivos). Uso: `python diff_cenario.py <base> <copia> <camadas.json> <saida>`.
- `camadas_mvvm.json` e `camadas_clean.json`: mapa de pasta para camada de cada versão.

## Tempos dos testes

Os tempos usados no trabalho (média de 7,44 s na MVVM e 9,09 s na Clean, em `resultados/tempos_protocolo.md`) vêm de uma rodada separada, feita com o computador sem outros programas pesados abertos. Antes dela houve uma execução de aquecimento, que foi descartada. Esses valores estão em `tempos_testes.txt` de `mvvm-v1` e `clean-v1`. A rodada feita pelo `medir.ps1`, com o computador em uso, ficou em `tempos_testes_pc_em_uso.txt` e não entra na comparação. Os tempos dependem da máquina.

## Estrutura

```
scripts/              scripts da coleta e mapas de camadas
resultados/
  mvvm-v1/, clean-v1/ saídas brutas da medição v1 (lakos.json, dcl.json, lcov.info,
                      contagem.json, analyze.txt, teste_cobertura.txt, tempos, versões)
  tabelas/            CSVs consolidados da v1
  tabelas_v1.md       tabelas da v1 em texto
  tempos_protocolo.md protocolo e tempos dos testes
  v2/                 medição complementar (9a8f637 e db11a74) e suas tabelas
cenarios/             roteiros, patches e numstat dos cenários C1, C2 e C3 nas duas versões
testes_ferramentas/   projeto pequeno, com erros de propósito, usado para validar o verificar_camadas.dart
```

Os arquivos de saída guardam os caminhos absolutos da máquina onde a medição foi feita (por exemplo, `rootDir` do lakos e os nomes dos testes em `teste_cobertura.txt`). Eles foram mantidos como as ferramentas os geraram.

## Como reproduzir

É preciso ter o Flutter 3.47.8 e ativar o lakos e o dart_code_linter nas versões acima:

```
dart pub global activate lakos 2.0.7
dart pub global activate dart_code_linter 4.4.4
```

Clone os dois repositórios ao lado desta pasta. Depois, no PowerShell, dentro de `diskgas-metricas`, rode o `medir.ps1` para cada tag e o `consolidar.dart`. Passe o caminho completo do repositório em `-Repo`, porque o script muda de pasta durante a medição. `-Versao` (`mvvm` ou `clean`) escolhe o mapa de camadas.

```
git clone https://github.com/NicolasWeber0901/diskgas-mvvm.git
git clone https://github.com/NicolasWeber0901/diskgas-clean.git
cd diskgas-metricas
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\medir.ps1 -Tag mvvm-v1 -Repo (Resolve-Path ..\diskgas-mvvm).Path -Versao mvvm
.\scripts\medir.ps1 -Tag clean-v1 -Repo (Resolve-Path ..\diskgas-clean).Path -Versao clean
dart scripts\consolidar.dart mvvm-v1 clean-v1
```

Para conferir a regra de dependência da Clean: `dart scripts\verificar_camadas.dart ..\diskgas-clean`. No projeto de validação, `dart scripts\verificar_camadas.dart testes_ferramentas\sintetico_camadas` deve acusar 14 violações.

Atenção: o `medir.ps1` apaga e recria `fontes/<tag>` e `resultados/<tag>` antes de medir. Rodar de novo para `mvvm-v1` ou `clean-v1` substitui as saídas guardadas aqui, inclusive os tempos.
