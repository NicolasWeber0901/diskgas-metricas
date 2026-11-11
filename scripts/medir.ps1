param(
  [Parameter(Mandatory = $true)][string]$Tag,
  [Parameter(Mandatory = $true)][string]$Repo,
  [Parameter(Mandatory = $true)][string]$Versao
)

$ErrorActionPreference = 'Continue'
$Scripts = $PSScriptRoot
$Base = Split-Path $Scripts -Parent
$Fontes = Join-Path $Base 'fontes'
$Copia = Join-Path $Fontes $Tag
$Zip = Join-Path $Fontes "$Tag.zip"
$Saida = Join-Path (Join-Path $Base 'resultados') $Tag
$Camadas = Join-Path $Scripts "camadas_$Versao.json"

function Falhar([string]$Mensagem) {
  Write-Output "ERRO: $Mensagem"
  exit 1
}

if (-not (Test-Path $Camadas)) { Falhar "mapa de camadas nao encontrado: $Camadas" }

New-Item -ItemType Directory -Force $Fontes | Out-Null
if (Test-Path $Copia) { Remove-Item -Recurse -Force $Copia }
if (Test-Path $Zip) { Remove-Item -Force $Zip }
if (Test-Path $Saida) { Remove-Item -Recurse -Force $Saida }
New-Item -ItemType Directory -Force $Saida | Out-Null

git -C $Repo archive --format=zip -o $Zip $Tag
if ($LASTEXITCODE -ne 0) { Falhar 'git archive falhou' }
Expand-Archive -Path $Zip -DestinationPath $Copia
Set-Location $Copia

flutter pub get | Out-Null
if ($LASTEXITCODE -ne 0) { Falhar 'flutter pub get falhou' }

flutter analyze --no-pub | Out-File -Encoding utf8 (Join-Path $Saida 'analyze.txt')
if ($LASTEXITCODE -ne 0) { Falhar 'flutter analyze reportou problemas (ver analyze.txt)' }

dart pub global run lakos -f json -m --node-metrics -o (Join-Path $Saida 'lakos.json') lib
if (-not (Test-Path (Join-Path $Saida 'lakos.json'))) { Falhar 'lakos nao gerou saida' }

$Dcl = Join-Path $Saida 'dcl.json'
dart pub global run dart_code_linter:metrics analyze lib --reporter=json "--json-path=$Dcl" --no-congratulate `
  --cyclomatic-complexity=20 --halstead-volume=150 --lines-of-code=100 --maximum-nesting-level=5 `
  --number-of-methods=10 --number-of-parameters=4 --source-lines-of-code=50 --weight-of-class=0.33 `
  --maintainability-index=50 --technical-debt=0 2>$null | Out-Null
if (-not (Test-Path $Dcl)) { Falhar 'dart_code_linter nao gerou saida' }

# Somente na copia: importa todo o lib para a cobertura ter o mesmo denominador.
$Nome = (Select-String -Path 'pubspec.yaml' -Pattern '^name:\s*(\S+)').Matches[0].Groups[1].Value
$Raiz = (Resolve-Path 'lib').Path
$Linhas = New-Object System.Collections.Generic.List[string]
$Indice = 0
Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart' | Sort-Object FullName | ForEach-Object {
  $Rel = $_.FullName.Substring($Raiz.Length + 1).Replace('\', '/')
  $Linhas.Add("import 'package:$Nome/$Rel' as a$Indice;")
  $Indice++
}
$Linhas.Add("import 'package:flutter_test/flutter_test.dart';")
$Linhas.Add('')
$Linhas.Add("void main() => test('cobertura', () {});")
$Auxiliar = Join-Path $Copia 'test\cobertura_todos_test.dart'
[System.IO.File]::WriteAllLines($Auxiliar, $Linhas)

flutter test --no-pub --coverage | Out-File -Encoding utf8 (Join-Path $Saida 'teste_cobertura.txt')
if ($LASTEXITCODE -ne 0) { Falhar 'testes falharam na execucao com cobertura' }
Copy-Item 'coverage\lcov.info' (Join-Path $Saida 'lcov.info')
Remove-Item -Force $Auxiliar

$Tempos = @()
foreach ($N in 1..3) {
  $Duracao = Measure-Command { flutter test --no-pub | Out-Null; $script:Codigo = $LASTEXITCODE }
  if ($script:Codigo -ne 0) { Falhar "testes falharam na execucao $N" }
  $Tempos += [math]::Round($Duracao.TotalSeconds, 2)
}
($Tempos -join "`n") | Out-File -Encoding ascii (Join-Path $Saida 'tempos_testes.txt')

dart (Join-Path $Scripts 'contagem.dart') $Copia $Camadas (Join-Path $Saida 'contagem.json')
if ($LASTEXITCODE -ne 0) { Falhar 'contagem.dart falhou' }

$Hash = git -C $Repo rev-parse "$Tag^{commit}"
$Versoes = @()
$Versoes += "tag: $Tag"
$Versoes += "commit: $Hash"
$Versoes += "versao: $Versao"
$Versoes += "data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
$Versoes += (flutter --version --no-version-check | Out-String)
$Versoes += (dart --version | Out-String)
$Versoes += (dart pub global list | Out-String)
$Versoes | Out-File -Encoding utf8 (Join-Path $Saida 'versoes.txt')
$Versao | Out-File -Encoding ascii (Join-Path $Saida 'versao.txt')

Set-Location $Base
Write-Output "OK: resultados em $Saida"
