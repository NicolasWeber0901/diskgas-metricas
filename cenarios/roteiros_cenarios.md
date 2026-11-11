# Roteiros dos cenários de mudança (09/11/2026)

Valem igual para o MVVM e para a Clean. Cada cenário é feito numa cópia exportada da tag, fora dos repositórios, sem commit. A diferença entre a cópia e a tag fica guardada como patch em metricas\cenarios\.

Para cada cenário e versão:
- Base: metricas\fontes\<tag>\, intocada. Cópia: metricas\cenarios\<versao>-c1\ ou <versao>-c2\.
- Só vale quando o flutter analyze não acusa nada e todos os testes passam.
- Medida: git diff --no-index --numstat entre a base e a cópia, separando lib/, test/ e o resto (pubspec, regras). Arquivos criados, alterados e apagados, por camada; linhas acrescentadas e removidas; testes alterados e novos.
- Nada é publicado no Firebase e nenhuma tag é criada.

## C1. Trocar o provedor de rotas
Objetivo: medir o quanto a troca de um serviço externo se espalha pelo código.
1. Ao abrir um pedido Aguardando sem distância, o app consulta o novo provedor e grava no pedido a distância, o tempo e a rota, nos mesmos campos de hoje.
2. Endereço em coordenadas pelo Nominatim: https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&countrycodes=br&q=<endereço>, com o endereço em texto e ", SC, Brasil" no fim, como hoje. Origem: o endereço do depósito. Destino: o do cliente. O cabeçalho User-Agent identifica o app (por exemplo, DiskGasTCC/1.0), sem e-mail, e há no máximo uma consulta por segundo.
3. Rota pelo OSRM: https://router.project-osrm.org/route/v1/driving/<lon_origem>,<lat_origem>;<lon_destino>,<lat_destino>?overview=full&geometries=polyline. Distância em routes[0].distance (metros), tempo em routes[0].duration (segundos) e rota em routes[0].geometry, no mesmo formato de polyline do Google (precisão 5).
4. Endereço não encontrado, code diferente de Ok, lista de rotas vazia, erro HTTP ou mais de 10 s de espera viram a mesma falha de rota de hoje, com o mesmo aviso.
5. A chave do Google deixa de ser usada para a rota e continua sendo usada pelo mapa.
6. Nenhuma tela muda e nenhum pacote novo entra (o http já está no projeto).
Testes: os três de RF16 continuam com os mesmos nomes. Se algum precisar mudar, a mudança é contada. Nenhum teste novo.
Conferência manual: calcular a rota do depósito até um endereço de Nova Esperança e conferir que a distância fica na mesma ordem da Routes API (cerca de 5 km).

## C2. Situação nova "Saiu para entrega"
Objetivo: medir uma mudança de regra que atravessa as camadas.
1. Nova situação "Saiu para entrega", entre Aceito e Entregue, gravada no Firestore do mesmo jeito que as outras.
2. No detalhe de um pedido Aceito, o administrador tem o botão "Saiu para entrega", que muda a situação e registra a data e a hora no histórico do pedido.
3. A entrega só pode ser finalizada em pedidos que saíram para entrega. Num pedido Aceito, o botão de finalizar não aparece, e uma chamada direta é bloqueada com a mensagem "Marque a saída para entrega antes de finalizar."
4. Ampliar o tempo (RN06) vale para pedidos Aceitos e para os que saíram para entrega. Recusar continua só para Aguardando.
5. O cliente vê a nova etapa na linha do tempo do acompanhamento, entre Aceito e Entregue.
6. O selo de situação ganha cor, ícone e texto próprios, no mesmo padrão dos outros. O filtro de situação (US17) ganha a opção nova. Na lista do administrador, esses pedidos ficam logo depois dos Aceitos.
7. O resumo do perfil (US16) não muda: continua somando só os entregues.
8. Se as firestore.rules precisarem aceitar a situação nova, a mudança entra no patch e é contada à parte, mas não é publicada.
Testes:
- Os dois testes da RN04 passam a partir de pedidos que saíram para entrega, com os mesmos nomes.
- Um teste novo, igual nas duas versões, no grupo "Saída para entrega": "pedido aceito só pode ser finalizado depois de marcar a saída" (finalizar num Aceito é bloqueado com a mensagem do item 3; depois de marcar a saída, a finalização passa).

## Decisões tomadas no MVVM (09/11), para a Clean seguir igual

### C1
- O endereço de origem passa a ser "Dona Emma, SC, Brasil".
- O limite de uma consulta por segundo fica dentro do próprio serviço de rotas, com intervalo de 1,1 s entre as consultas ao Nominatim.
- O serviço de rotas não recebe mais a chave do Google, e o README não muda.
- O Nominatim não encontra os endereços completos cadastrados nem o endereço do depósito, somente a localidade (por exemplo, "Nova Esperança, Dona Emma"). Esses casos caem na mesma falha de rota de hoje.

### C2
1. A situação é gravada no Firestore como saiuParaEntrega, e a data da saída fica no novo campo dataSaida.
2. Ao finalizar um pedido Aceito, a mensagem é "Marque a saída para entrega antes de finalizar."; em qualquer outra situação que não seja Saiu para entrega, é "Somente pedidos que saíram podem ser finalizados."
3. A transação de finalizar a entrega passa a exigir a situação saiuParaEntrega. A mensagem "Somente pedidos aceitos podem ter o tempo ampliado." não muda.
4. O histórico mostra a etapa "Saiu para entrega" somente quando existe dataSaida.
5. O tempo estimado continua aparecendo depois da saída.
6. O erro do botão de saída aparece com MensagemErro no detalhe do pedido Aceito.
7. A tela de detalhe extrai _avisoTempo e _botaoAmpliar para não repetir código.

As firestore.rules não precisaram mudar.
