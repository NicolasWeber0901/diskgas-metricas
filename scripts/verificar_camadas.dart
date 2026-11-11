import 'dart:convert';
import 'dart:io';

// Confere a regra de dependência da versão Clean nos imports de lib/.
// Uso: dart verificar_camadas.dart <repositorio>
// Saída 0: nenhuma violação. Saída 1: há violações. Saída 2: uso incorreto.

const _camadasPermitidas = {
  'domain': {'domain'},
  'data': {'domain', 'data'},
  'infra': {'data', 'domain', 'infra'},
  'presentation': {'domain', 'presentation'},
  'ui': {'presentation', 'domain', 'ui'},
};

const _pacotesPermitidos = {
  'infra': {
    'cloud_firestore',
    'firebase_auth',
    'firebase_core',
    'google_sign_in',
    'http',
  },
  'ui': {
    'flutter',
    'flutter_localizations',
    'provider',
    'go_router',
    'google_maps_flutter',
  },
};

const _urisPermitidas = {
  'presentation': {'package:flutter/foundation.dart'},
};

final _ignorar = RegExp(
  r'''\s+|//[^\n]*|/\*[\s\S]*?\*/|@\w+(?:\.\w+)*(?:\([^)]*\))?''',
);
final _semUri = RegExp(r'''library\b[^;]*;|part\s+of\b[^;]*;''');
final _comUri = RegExp(r'''(?:import|export|part)\s*(?=['"])[^;]*;''');
final _texto = RegExp("'([^']*)'|\"([^\"]*)\"");

List<String> lerDiretivas(String fonte) {
  final uris = <String>[];
  var posicao = 0;
  while (posicao < fonte.length) {
    final ignorado = _ignorar.matchAsPrefix(fonte, posicao);
    if (ignorado != null) {
      posicao = ignorado.end;
      continue;
    }
    final semUri = _semUri.matchAsPrefix(fonte, posicao);
    if (semUri != null) {
      posicao = semUri.end;
      continue;
    }
    final comUri = _comUri.matchAsPrefix(fonte, posicao);
    if (comUri == null) break;
    for (final texto in _texto.allMatches(comUri[0]!)) {
      uris.add(texto[1] ?? texto[2]!);
    }
    posicao = comUri.end;
  }
  return uris;
}

String? camadaDe(String caminho, List<dynamic> regras) {
  for (final regra in regras) {
    final prefixo = regra['prefixo'] as String;
    final confere = prefixo.endsWith('/')
        ? caminho.startsWith(prefixo)
        : caminho == prefixo;
    if (confere) return regra['camada'] as String;
  }
  return null;
}

String? problema(
  String uri,
  String arquivo,
  String camada,
  String pacoteApp,
  List<dynamic> regras,
) {
  if (camada == 'montagem' || uri.startsWith('dart:')) return null;

  String caminho;
  final interno = 'package:$pacoteApp/';
  if (uri.startsWith(interno)) {
    caminho = uri.substring(interno.length);
  } else if (uri.startsWith('package:')) {
    if (_urisPermitidas[camada]?.contains(uri) ?? false) return null;
    final pacote = uri.substring('package:'.length).split('/').first;
    if (_pacotesPermitidos[camada]?.contains(pacote) ?? false) return null;
    return 'pacote externo nao permitido';
  } else {
    final base = Uri.parse('file:///$arquivo');
    caminho = base.resolve(uri).path.substring(1);
  }

  final alvo = camadaDe(caminho, regras);
  if (alvo == null) return 'alvo fora das camadas';
  if (_camadasPermitidas[camada]!.contains(alvo)) return null;
  return 'camada $camada nao pode depender de $alvo';
}

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stdout.writeln('uso: dart verificar_camadas.dart <repositorio>');
    exitCode = 2;
    return;
  }
  final repositorio = args[0].replaceAll('\\', '/').replaceAll(RegExp(r'/+$'), '');
  final lib = Directory('$repositorio/lib');
  final pubspec = File('$repositorio/pubspec.yaml');
  if (!lib.existsSync() || !pubspec.existsSync()) {
    stdout.writeln('ERRO: lib/ ou pubspec.yaml nao encontrados em $repositorio');
    exitCode = 2;
    return;
  }
  final nome = RegExp(
    r'^name:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync())?[1];
  if (nome == null) {
    stdout.writeln('ERRO: nome do pacote nao encontrado no pubspec.yaml');
    exitCode = 2;
    return;
  }
  final mapa = File.fromUri(Platform.script.resolve('camadas_clean.json'));
  final regras = jsonDecode(mapa.readAsStringSync())['regras'] as List<dynamic>;

  final arquivos =
      lib
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final raiz = lib.path.length + 1;
  final porCamada = <String, int>{};
  var violacoes = 0;
  void registrar(String arquivo, String camada, String detalhe) {
    stdout.writeln('lib/$arquivo [$camada]: $detalhe');
    porCamada[camada] = (porCamada[camada] ?? 0) + 1;
    violacoes++;
  }

  for (final arquivo in arquivos) {
    final relativo = arquivo.path.substring(raiz).replaceAll('\\', '/');
    final camada = camadaDe(relativo, regras);
    if (camada == null) {
      registrar(relativo, 'fora das camadas', 'arquivo fora das camadas');
      continue;
    }
    final fonte = arquivo.readAsStringSync().replaceFirst('﻿', '');
    for (final uri in lerDiretivas(fonte)) {
      final motivo = problema(uri, relativo, camada, nome, regras);
      if (motivo != null) registrar(relativo, camada, '$uri ($motivo)');
    }
  }

  stdout.writeln(
    'Resumo: ${arquivos.length} arquivos, $violacoes violacoes $porCamada',
  );
  await stdout.flush();
  exitCode = violacoes == 0 ? 0 : 1;
}
