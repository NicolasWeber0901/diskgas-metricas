import 'dart:convert';
import 'dart:io';

String base = '';

Map<String, dynamic> lerJson(String caminho) =>
    jsonDecode(File(caminho).readAsStringSync()) as Map<String, dynamic>;

double media(List<num> v) =>
    v.isEmpty ? 0 : v.fold<num>(0, (a, b) => a + b) / v.length;

double mediana(List<num> v) {
  if (v.isEmpty) return 0;
  final o = [...v]..sort();
  final m = o.length ~/ 2;
  return o.length.isOdd ? o[m].toDouble() : (o[m - 1] + o[m]) / 2;
}

num maximo(List<num> v) => v.isEmpty ? 0 : v.reduce((a, b) => a > b ? a : b);

String numero(num v) => v is int ? '$v' : v.toStringAsFixed(2);

String campo(Object? v) {
  final t = v is num ? numero(v) : '${v ?? ''}';
  return t.contains(RegExp(r'[,"\n]')) ? '"${t.replaceAll('"', '""')}"' : t;
}

void gravar(String nome, List<String> cab, List<List<Object?>> linhas) {
  final saida = StringBuffer('${cab.join(',')}\n');
  for (final l in linhas) {
    saida.writeln(l.map(campo).join(','));
  }
  File('$base/resultados/tabelas/$nome.csv').writeAsStringSync(saida.toString());
}

String relativoLib(String caminho) {
  final p = caminho.replaceAll(r'\', '/');
  final i = p.lastIndexOf('/lib/');
  if (i != -1) return p.substring(i + 5);
  return p.startsWith('lib/') ? p.substring(4) : p;
}

double? metrica(Map<String, dynamic> item, String id) {
  for (final m in (item['metrics'] as List? ?? const [])) {
    if (m['metricsId'] == id) return (m['value'] as num).toDouble();
  }
  return null;
}

class Grupo {
  final String nome;
  int arquivos = 0;
  int sloc = 0;
  int classes = 0;
  int abstratas = 0;
  final cc = <num>[];
  final aninhamento = <num>[];
  final wmc = <num>[];
  final metodos = <num>[];
  final parametros = <num>[];
  final ca = <num>[];
  final ce = <num>[];
  final instabilidade = <num>[];
  Grupo(this.nome);

  void somar(Grupo o) {
    arquivos += o.arquivos;
    sloc += o.sloc;
    classes += o.classes;
    abstratas += o.abstratas;
    cc.addAll(o.cc);
    aninhamento.addAll(o.aninhamento);
    wmc.addAll(o.wmc);
    metodos.addAll(o.metodos);
    parametros.addAll(o.parametros);
    ca.addAll(o.ca);
    ce.addAll(o.ce);
    instabilidade.addAll(o.instabilidade);
  }

  List<Object?> linha(String tag) => [
    tag,
    nome,
    arquivos,
    sloc,
    classes,
    abstratas,
    cc.length,
    cc.fold<num>(0, (a, b) => a + b),
    media(cc),
    mediana(cc),
    maximo(cc),
    cc.where((v) => v > 10).length,
    maximo(aninhamento),
    media(aninhamento),
    media(wmc),
    mediana(wmc),
    maximo(wmc),
    media(metodos),
    mediana(metodos),
    maximo(metodos),
    media(parametros),
    maximo(parametros),
    media(ca),
    mediana(ca),
    maximo(ca),
    media(ce),
    mediana(ce),
    maximo(ce),
    media(instabilidade),
    mediana(instabilidade),
    maximo(instabilidade),
  ];
}

const cabecalhoCamadas = [
  'tag',
  'camada',
  'arquivos',
  'sloc',
  'classes',
  'classes_abstratas',
  'funcoes',
  'cc_soma',
  'cc_media',
  'cc_mediana',
  'cc_max',
  'funcoes_cc_maior_10',
  'aninhamento_max',
  'aninhamento_medio',
  'wmc_media',
  'wmc_mediana',
  'wmc_max',
  'metodos_classe_media',
  'metodos_classe_mediana',
  'metodos_classe_max',
  'parametros_media',
  'parametros_max',
  'ca_media',
  'ca_mediana',
  'ca_max',
  'ce_media',
  'ce_mediana',
  'ce_max',
  'instabilidade_media',
  'instabilidade_mediana',
  'instabilidade_max',
];

void main(List<String> args) {
  base = File(Platform.script.toFilePath()).parent.parent.path.replaceAll(r'\', '/');
  Directory('$base/resultados/tabelas').createSync(recursive: true);

  final linhasCamadas = <List<Object?>>[];
  final linhasMatriz = <List<Object?>>[];
  final linhasExternos = <List<Object?>>[];
  final linhasRegras = <List<Object?>>[];
  final linhasTestes = <List<Object?>>[];
  final linhasCobertura = <List<Object?>>[];
  final linhasGlobais = <List<Object?>>[];
  final linhasTempos = <List<Object?>>[];

  for (final tag in args) {
    final pasta = '$base/resultados/$tag';
    final contagem = lerJson('$pasta/contagem.json');
    final lakos = lerJson('$pasta/lakos.json');
    final dcl = lerJson('$pasta/dcl.json');

    final camadaDe = <String, String>{};
    final grupos = <String, Grupo>{};
    Grupo grupo(String nome) => grupos.putIfAbsent(nome, () => Grupo(nome));

    for (final a in contagem['arquivos'] as List) {
      final camada = a['camada'] as String;
      camadaDe[a['caminho'] as String] = camada;
      final g = grupo(camada);
      g.arquivos++;
      g.classes += a['classes'] as int;
      g.abstratas += a['classes_abstratas'] as int;
    }

    final nos = lakos['nodes'] as Map<String, dynamic>;
    for (final entrada in nos.entries) {
      final relativo = entrada.key.replaceFirst('/', '');
      final camada = camadaDe[relativo];
      if (camada == null) {
        stderr.writeln('lakos sem camada: $relativo');
        continue;
      }
      final g = grupo(camada);
      final no = entrada.value as Map<String, dynamic>;
      g.sloc += no['sloc'] as int;
      g.ca.add(no['inDegree'] as num);
      g.ce.add(no['outDegree'] as num);
      final instabilidade = no['instability'] as num?;
      if (instabilidade != null) g.instabilidade.add(instabilidade);
    }

    for (final r in dcl['records'] as List) {
      final relativo = relativoLib(r['path'] as String);
      final camada = camadaDe[relativo];
      if (camada == null) {
        stderr.writeln('dcl sem camada: $relativo');
        continue;
      }
      final g = grupo(camada);
      final funcoes = (r['functions'] as Map).cast<String, dynamic>();
      final porClasse = <String, double>{};
      for (final f in funcoes.entries) {
        final valor = f.value as Map<String, dynamic>;
        final cc = metrica(valor, 'cyclomatic-complexity');
        if (cc != null) {
          g.cc.add(cc);
          if (f.key.contains('.')) {
            final classe = f.key.split('.').first;
            porClasse[classe] = (porClasse[classe] ?? 0) + cc;
          }
        }
        final n = metrica(valor, 'maximum-nesting-level');
        if (n != null) g.aninhamento.add(n);
        final p = metrica(valor, 'number-of-parameters');
        if (p != null) g.parametros.add(p);
      }
      final classes = (r['classes'] as Map).cast<String, dynamic>();
      for (final c in classes.entries) {
        g.wmc.add(porClasse[c.key] ?? 0);
        final m = metrica(c.value as Map<String, dynamic>, 'number-of-methods');
        if (m != null) g.metodos.add(m);
      }
    }

    final total = Grupo('TOTAL');
    final semUi = Grupo('TOTAL_SEM_UI');
    final nomes = grupos.keys.toList()..sort();
    for (final n in nomes) {
      linhasCamadas.add(grupos[n]!.linha(tag));
      total.somar(grupos[n]!);
      if (n != 'ui') semUi.somar(grupos[n]!);
    }
    linhasCamadas.add(total.linha(tag));
    linhasCamadas.add(semUi.linha(tag));

    final m = lakos['metrics'] as Map<String, dynamic>;
    linhasGlobais.add([
      tag,
      m['numNodes'],
      m['numEdges'],
      m['avgDegree'],
      m['isAcyclic'],
      m['ccd'],
      m['acd'],
      m['nccd'],
      m['totalSloc'],
      m['avgSloc'],
      (m['orphans'] as List).join(' '),
    ]);

    final matriz = contagem['matriz_imports'] as Map<String, dynamic>;
    matriz.forEach((origem, destinos) {
      (destinos as Map<String, dynamic>).forEach((destino, n) {
        linhasMatriz.add([tag, origem, destino, n]);
      });
    });

    final externos = contagem['externos_por_camada'] as Map<String, dynamic>;
    externos.forEach((camada, pacotes) {
      (pacotes as Map<String, dynamic>).forEach((pacote, n) {
        linhasExternos.add([tag, camada, pacote, n]);
      });
    });

    for (final r in contagem['localizacao_regras'] as List) {
      linhasRegras.add([
        tag,
        r['arquivo'],
        r['camada'],
        (r['marcas'] as List).join(' '),
        (r['externos'] as List).join(' '),
      ]);
    }

    for (final t in contagem['testes'] as List) {
      linhasTestes.add([
        tag,
        t['arquivo'],
        t['grupo'],
        t['nome'],
        t['sloc_corpo'],
        t['sloc_preparacao_arquivo'],
        (t['duplas_declaradas'] as List).join(' '),
        t['instancias_corpo'],
        t['instancias_setup'],
        t['when_corpo'],
        t['verify_corpo'],
        t['verifyNever_corpo'],
        t['when_setup'],
        t['verify_setup'],
        t['verifyNever_setup'],
      ]);
    }

    final cobertura = <String, List<int>>{};
    final arquivoLcov = File('$pasta/lcov.info');
    String? atual;
    for (final linha in arquivoLcov.readAsLinesSync()) {
      if (linha.startsWith('SF:')) {
        atual = camadaDe[relativoLib(linha.substring(3).trim())] ?? 'sem_camada';
        cobertura.putIfAbsent(atual, () => [0, 0]);
      } else if (linha.startsWith('LF:')) {
        cobertura[atual]![0] += int.parse(linha.substring(3));
      } else if (linha.startsWith('LH:')) {
        cobertura[atual]![1] += int.parse(linha.substring(3));
      }
    }
    var lf = 0;
    var lh = 0;
    var lfSemUi = 0;
    var lhSemUi = 0;
    final nomesCob = cobertura.keys.toList()..sort();
    for (final n in nomesCob) {
      final v = cobertura[n]!;
      linhasCobertura.add([tag, n, v[0], v[1], v[0] == 0 ? 0.0 : 100 * v[1] / v[0]]);
      lf += v[0];
      lh += v[1];
      if (n != 'ui') {
        lfSemUi += v[0];
        lhSemUi += v[1];
      }
    }
    linhasCobertura.add([tag, 'TOTAL', lf, lh, lf == 0 ? 0.0 : 100 * lh / lf]);
    linhasCobertura.add([
      tag,
      'TOTAL_SEM_UI',
      lfSemUi,
      lhSemUi,
      lfSemUi == 0 ? 0.0 : 100 * lhSemUi / lfSemUi,
    ]);

    final tempos = File('$pasta/tempos_testes.txt')
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty)
        .map((l) => double.parse(l.trim().replaceAll(',', '.')))
        .toList();
    linhasTempos.add([tag, ...tempos, media(tempos)]);
  }

  gravar('camadas', cabecalhoCamadas, linhasCamadas);
  gravar('lakos_global', const [
    'tag', 'arquivos', 'dependencias', 'grau_medio', 'aciclico', 'ccd', 'acd',
    'nccd', 'sloc_total', 'sloc_medio', 'orfaos',
  ], linhasGlobais);
  gravar('matriz_imports', const ['tag', 'origem', 'destino', 'imports'], linhasMatriz);
  gravar('externos_por_camada', const ['tag', 'camada', 'pacote', 'imports'], linhasExternos);
  gravar('localizacao_regras', const ['tag', 'arquivo', 'camada', 'marcas', 'externos'], linhasRegras);
  gravar('testes', const [
    'tag', 'arquivo', 'grupo', 'nome', 'sloc_corpo', 'sloc_preparacao_arquivo',
    'duplas_declaradas', 'instancias_corpo', 'instancias_setup', 'when_corpo',
    'verify_corpo', 'verifyNever_corpo', 'when_setup', 'verify_setup',
    'verifyNever_setup',
  ], linhasTestes);
  gravar('cobertura', const ['tag', 'camada', 'linhas', 'linhas_cobertas', 'percentual'], linhasCobertura);
  gravar('tempos_testes', const ['tag', 'execucao_1', 'execucao_2', 'execucao_3', 'media'], linhasTempos);
}
