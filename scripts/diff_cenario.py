import json
import os
import shutil
import subprocess
import sys

base = sys.argv[1]
copia = sys.argv[2]
camadas = json.load(open(sys.argv[3], encoding='utf-8'))['regras']
saida = sys.argv[4]
temp = saida + '_tmp'
IGNORAR = shutil.ignore_patterns(
    '.dart_tool', 'build', 'coverage', '.flutter-plugins*', '.idea',
    'local.properties', 'dart_defines.json', 'google-services.json', 'GeneratedPluginRegistrant*',
    '.gradle', 'gradlew*', 'gradle-wrapper*',
)


def copiar(origem, nome):
    destino = os.path.join(temp, nome)
    shutil.copytree(origem, destino, ignore=IGNORAR)


if os.path.exists(temp):
    shutil.rmtree(temp)
os.makedirs(temp)
copiar(base, 'a')
copiar(copia, 'b')


def git(*args):
    return subprocess.run(['git', '-c', 'core.quotepath=false', '-c', 'core.autocrlf=false', 'diff', '--no-index', *args, 'a', 'b'], cwd=temp, capture_output=True).stdout


numstat = git('--numstat', '--ignore-space-at-eol', '-M').decode('utf-8')
patch = git('--ignore-space-at-eol', '-M')
open(saida + '.patch', 'wb').write(patch)
open(saida + '.numstat.txt', 'w', encoding='utf-8', newline='\n').write(numstat)
shutil.rmtree(temp)


def camada(caminho):
    for r in camadas:
        p = r['prefixo']
        if (caminho == p) if not p.endswith('/') else caminho.startswith(p):
            return r['camada']
    return 'sem_camada'


status = {}
total = {'lib': [0, 0, 0], 'test': [0, 0, 0], 'outros': [0, 0, 0]}
por = {}
linhas = []
atual_a = set()
for linha in numstat.splitlines():
    add, rem, nome = linha.split('\t')
    nome = nome.replace('{a => b}/', '')
    tipo = 'alterado'
    if nome.startswith('/dev/null => b/') or '/dev/null =>' in nome:
        tipo = 'criado'
        nome = nome.split('=> b/')[-1]
    elif nome.endswith('=> /dev/null'):
        tipo = 'apagado'
        nome = nome.split(' => ')[0][2:]
    elif nome.startswith('a/') and ' => ' in nome:
        nome = nome.split(' => ')[-1][2:]
    elif nome[:2] in ('a/', 'b/'):
        nome = nome[2:]
    grupo = 'lib' if nome.startswith('lib/') else ('test' if nome.startswith('test/') else 'outros')
    total[grupo][0] += int(add)
    total[grupo][1] += int(rem)
    total[grupo][2] += 1
    c = camada(nome[4:]) if grupo == 'lib' else grupo
    p = por.setdefault(c, {'criado': 0, 'alterado': 0, 'apagado': 0, 'add': 0, 'rem': 0})
    p[tipo] += 1
    p['add'] += int(add)
    p['rem'] += int(rem)
    linhas.append((tipo, nome, add, rem, c))

print('por grupo (+, -, arquivos):', total)
for c, v in sorted(por.items()):
    print(' ', c, v)
for l in linhas:
    print('   ', *l)
