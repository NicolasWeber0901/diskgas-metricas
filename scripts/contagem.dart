import 'dart:convert';
import 'dart:io';

class Fonte {
  final String original;
  late final List<int> _a = original.codeUnits.toList();
  late final List<int> _b = original.codeUnits.toList();
  late final String semComentarios;
  late final String semStrings;

  Fonte(this.original) {
    _codigo(0, false);
    semComentarios = String.fromCharCodes(_a);
    semStrings = String.fromCharCodes(_b);
  }

  int get _n => original.length;

  void _apagar(List<int> lista, int de, int ate) {
    for (var i = de; i < ate && i < _n; i++) {
      if (lista[i] != 10 && lista[i] != 13) lista[i] = 32;
    }
  }

  bool _em(int i, String texto) => original.startsWith(texto, i);

  int _codigo(int inicio, bool ateFechar) {
    var i = inicio;
    var nivel = 0;
    while (i < _n) {
      if (_em(i, '//')) {
        var j = i;
        while (j < _n && original[j] != '\n') {
          j++;
        }
        _apagar(_a, i, j);
        _apagar(_b, i, j);
        i = j;
        continue;
      }
      if (_em(i, '/*')) {
        var j = i + 2;
        var profundidade = 1;
        while (j < _n && profundidade > 0) {
          if (_em(j, '/*')) {
            profundidade++;
            j += 2;
          } else if (_em(j, '*/')) {
            profundidade--;
            j += 2;
          } else {
            j++;
          }
        }
        _apagar(_a, i, j);
        _apagar(_b, i, j);
        i = j;
        continue;
      }
      final c = original[i];
      final cru =
          c == 'r' &&
          i + 1 < _n &&
          (original[i + 1] == "'" || original[i + 1] == '"') &&
          (i == 0 || !RegExp(r'\w').hasMatch(original[i - 1]));
      if (c == "'" || c == '"' || cru) {
        final fim = _string(i);
        _apagar(_b, i, fim);
        i = fim;
        continue;
      }
      if (c == '{') nivel++;
      if (c == '}') {
        if (ateFechar && nivel == 0) return i + 1;
        nivel--;
      }
      i++;
    }
    return _n;
  }

  int _string(int inicio) {
    var i = inicio;
    final cru = original[i] == 'r';
    if (cru) i++;
    final q = original[i];
    final tripla = _em(i, q * 3);
    final fecha = tripla ? q * 3 : q;
    i += fecha.length;
    while (i < _n) {
      if (!cru && original[i] == r'\') {
        i += 2;
        continue;
      }
      if (!cru && _em(i, r'${')) {
        i = _codigo(i + 2, true);
        continue;
      }
      if (_em(i, fecha)) return i + fecha.length;
      i++;
    }
    return _n;
  }
}

int fechamento(String texto, int abre) {
  final a = texto[abre];
  final f = a == '(' ? ')' : (a == '{' ? '}' : ']');
  var nivel = 0;
  for (var i = abre; i < texto.length; i++) {
    if (texto[i] == a) nivel++;
    if (texto[i] == f) {
      nivel--;
      if (nivel == 0) return i;
    }
  }
  return texto.length - 1;
}

int linhaDe(String texto, int posicao) =>
    '\n'.allMatches(texto.substring(0, posicao)).length;

int contar(String texto, String padrao) =>
    RegExp(padrao, multiLine: true).allMatches(texto).length;

List<String> arquivosDart(Directory pasta) {
  if (!pasta.existsSync()) return [];
  final lista =
      pasta
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map((f) => f.path.replaceAll(r'\', '/'))
          .toList()
        ..sort();
  return lista;
}

String camadaDe(String relativo, List<dynamic> regras) {
  for (final regra in regras) {
    final prefixo = regra['prefixo'] as String;
    final exato = !prefixo.endsWith('/');
    if (exato ? relativo == prefixo : relativo.startsWith(prefixo)) {
      return regra['camada'] as String;
    }
  }
  return 'sem_camada';
}

String nomeExterno(String uri) {
  if (uri.startsWith('dart:')) return uri;
  final sem = uri.substring('package:'.length);
  final partes = sem.split('/');
  if (partes.first == 'flutter') {
    return 'flutter:${partes[1].replaceAll('.dart', '')}';
  }
  return partes.first;
}

final _reImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

Map<String, dynamic> medirArquivo(
  String caminho,
  String raizLib,
  String pacote,
  List<dynamic> regras,
) {
  final relativo = caminho.substring(raizLib.length + 1);
  final fonte = Fonte(File(caminho).readAsStringSync());
  final codigo = fonte.semStrings;
  final classes = RegExp(
    r'^\s*((?:abstract\s+|sealed\s+|base\s+|final\s+|interface\s+|mixin\s+)*)class\s+(\w+)',
    multiLine: true,
  ).allMatches(codigo).toList();
  final abstratas = classes.where((m) {
    final mod = m.group(1)!.trim().split(RegExp(r'\s+')).join(' ');
    return mod == 'abstract' || mod == 'abstract interface';
  }).length;
  final internos = <String>[];
  final externos = <String>[];
  for (final m in _reImport.allMatches(fonte.semComentarios)) {
    final uri = m.group(1)!;
    if (uri.startsWith('package:$pacote/')) {
      internos.add(uri.substring('package:$pacote/'.length));
    } else if (uri.startsWith('package:') || uri.startsWith('dart:')) {
      externos.add(nomeExterno(uri));
    } else {
      internos.add(Uri.parse(relativo).resolve(uri).path);
    }
  }
  final marcas = <String>{
    for (final m in RegExp(
      r'^\s*//\s*(R[NF]\d\d):',
      multiLine: true,
    ).allMatches(fonte.original))
      m.group(1)!,
    for (final linha in RegExp(
      r'^\s*///.*$',
      multiLine: true,
    ).allMatches(fonte.original))
      for (final c in RegExp(
        r'RF16|US08|US16|US17',
      ).allMatches(linha.group(0)!))
        c.group(0)!,
  };
  return {
    'caminho': relativo,
    'camada': camadaDe(relativo, regras),
    'classes': classes.length,
    'classes_abstratas': abstratas,
    'enums': contar(codigo, r'^\s*enum\s+\w+'),
    'mixins': contar(codigo, r'^\s*(?:base\s+)?mixin\s+(?!class\b)\w+'),
    'extensoes': contar(codigo, r'^\s*extension\s+(?:type\s+)?\w*'),
    'internos': internos,
    'externos': externos,
    'marcas': marcas.toList()..sort(),
  };
}

List<Map<String, dynamic>> medirTestes(String caminho, String relativo) {
  final fonte = Fonte(File(caminho).readAsStringSync());
  final b = fonte.semStrings;
  final a = fonte.semComentarios;
  final linhasA = a.split('\n');
  final chamadas = RegExp(
    r'\b(group|test|testWidgets|setUp|setUpAll|tearDown|tearDownAll)\s*\(',
  ).allMatches(b).toList();

  final duplas = [
    for (final m in RegExp(
      r'class\s+(\w+)\s+extends\s+(Mock|Fake)\b',
    ).allMatches(b))
      m.group(1)!,
  ];

  String nomeEm(int abre) {
    final nome = StringBuffer();
    var i = abre + 1;
    while (true) {
      while (i < a.length && RegExp(r'\s').hasMatch(a[i])) {
        i++;
      }
      if (i >= a.length || (a[i] != "'" && a[i] != '"')) break;
      final q = a[i];
      i++;
      while (i < a.length && a[i] != q) {
        if (a[i] == r'\') i++;
        nome.write(a[i]);
        i++;
      }
      i++;
    }
    return nome.toString();
  }

  final categorias = <int, String>{};
  void marcar(int de, int ate, String categoria) {
    for (var l = de; l <= ate; l++) {
      categorias[l] = categoria;
    }
  }

  final mainM = RegExp(r'\bvoid\s+main\s*\(').firstMatch(b);
  if (mainM != null) {
    final chave = b.indexOf('{', mainM.end);
    if (chave != -1) {
      marcar(linhaDe(b, mainM.start), linhaDe(b, mainM.start), 'estrutura');
      final fim = linhaDe(b, fechamento(b, chave));
      marcar(fim, fim, 'estrutura');
    }
  }

  final grupos = <(int, int, String)>[];
  final prepTextos = StringBuffer();
  final testes = <Map<String, dynamic>>[];

  for (final m in chamadas) {
    final tipo = m.group(1)!;
    final abre = m.end - 1;
    final fecha = fechamento(b, abre);
    if (tipo == 'group') {
      grupos.add((abre, fecha, nomeEm(abre)));
      final linha = linhaDe(b, m.start);
      marcar(linha, linha, 'estrutura');
      final linhaFim = linhaDe(b, fecha);
      marcar(linhaFim, linhaFim, 'estrutura');
    } else if (tipo.startsWith('setUp') || tipo.startsWith('tearDown')) {
      if (tipo.startsWith('setUp')) prepTextos.write(b.substring(abre, fecha));
    }
  }

  int slocEntre(int de, int ate) {
    var total = 0;
    for (var l = de; l <= ate && l < linhasA.length; l++) {
      if (linhasA[l].trim().isNotEmpty) total++;
    }
    return total;
  }

  final textoSetUp = prepTextos.toString();
  for (final m in chamadas) {
    final tipo = m.group(1)!;
    if (tipo != 'test' && tipo != 'testWidgets') continue;
    final abre = m.end - 1;
    final fecha = fechamento(b, abre);
    marcar(linhaDe(b, m.start), linhaDe(b, fecha), 'teste');
    final chave = b.indexOf('{', abre);
    final seta = b.indexOf('=>', abre);
    int sloc;
    String corpo;
    if (seta != -1 && seta < fecha && (chave == -1 || seta < chave)) {
      corpo = b.substring(seta, fecha);
      sloc = slocEntre(linhaDe(b, seta), linhaDe(b, fecha));
    } else {
      final fim = fechamento(b, chave);
      corpo = b.substring(chave, fim);
      final inicio = linhaDe(b, chave);
      final termino = linhaDe(b, fim);
      sloc = termino == inicio ? 1 : slocEntre(inicio + 1, termino - 1);
    }
    var grupo = '';
    for (final g in grupos) {
      if (g.$1 < abre && fecha < g.$2) grupo = g.$3;
    }
    int instancias(String texto) => [
      for (final d in duplas) contar(texto, '\\b$d\\('),
    ].fold(0, (x, y) => x + y);
    testes.add({
      'arquivo': relativo,
      'grupo': grupo,
      'nome': nomeEm(abre),
      'sloc_corpo': sloc,
      'instancias_corpo': instancias(corpo),
      'instancias_setup': instancias(textoSetUp),
      'when_corpo': contar(corpo, r'\bwhen\('),
      'verify_corpo': contar(corpo, r'\bverify\('),
      'verifyNever_corpo': contar(corpo, r'\bverifyNever\('),
      'when_setup': contar(textoSetUp, r'\bwhen\('),
      'verify_setup': contar(textoSetUp, r'\bverify\('),
      'verifyNever_setup': contar(textoSetUp, r'\bverifyNever\('),
    });
  }

  var preparacao = 0;
  for (var l = 0; l < linhasA.length; l++) {
    final texto = linhasA[l].trim();
    if (texto.isEmpty) continue;
    if (RegExp(r'^(import|export|library|part)\b').hasMatch(texto)) continue;
    if (categorias.containsKey(l)) continue;
    preparacao++;
  }
  for (final t in testes) {
    t['sloc_preparacao_arquivo'] = preparacao;
    t['duplas_declaradas'] = duplas;
  }
  return testes;
}

void main(List<String> args) {
  final copia = args[0].replaceAll(r'\', '/');
  final regras = (jsonDecode(File(args[1]).readAsStringSync()) as Map)['regras'] as List;
  final pubspec = File('$copia/pubspec.yaml').readAsStringSync();
  final pacote = RegExp(
    r'^name:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspec)!.group(1)!;
  final raiz = '$copia/lib';
  final arquivos = [
    for (final c in arquivosDart(Directory(raiz)))
      medirArquivo(c, raiz, pacote, regras),
  ];
  final porCaminho = {
    for (final a in arquivos) a['caminho'] as String: a['camada'] as String,
  };

  final matriz = <String, Map<String, int>>{};
  final externos = <String, Map<String, int>>{};
  final naoResolvidos = <String>[];
  final regrasLocal = <Map<String, dynamic>>[];
  for (final a in arquivos) {
    final origem = a['camada'] as String;
    for (final alvo in a['internos'] as List<String>) {
      final destino = porCaminho[alvo];
      if (destino == null) {
        naoResolvidos.add('${a['caminho']} -> $alvo');
        continue;
      }
      final linha = matriz.putIfAbsent(origem, () => {});
      linha[destino] = (linha[destino] ?? 0) + 1;
    }
    for (final pacoteExterno in a['externos'] as List<String>) {
      final linha = externos.putIfAbsent(origem, () => {});
      linha[pacoteExterno] = (linha[pacoteExterno] ?? 0) + 1;
    }
    if ((a['marcas'] as List).isNotEmpty) {
      regrasLocal.add({
        'arquivo': a['caminho'],
        'camada': origem,
        'marcas': a['marcas'],
        'externos': a['externos'],
      });
    }
  }

  final raizTeste = '$copia/test';
  final testes = <Map<String, dynamic>>[];
  for (final c in arquivosDart(Directory(raizTeste))) {
    if (c.endsWith('_test.dart')) {
      testes.addAll(medirTestes(c, c.substring(copia.length + 1)));
    }
  }

  File(args[2]).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'pacote': pacote,
      'arquivos': arquivos,
      'matriz_imports': matriz,
      'externos_por_camada': externos,
      'imports_nao_resolvidos': naoResolvidos,
      'localizacao_regras': regrasLocal,
      'testes': testes,
    }),
  );
}
