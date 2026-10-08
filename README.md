# Teste-tecnico-Verzel

> **História:** Como cliente da Verzel Store, quero aplicar um cupom de desconto e ganhar frete grátis em compras maiores, para pagar menos nas minhas compras.

Este repositório reúne os entregáveis do teste técnico: cenários de teste (Gherkin), execução manual/exploratória, automação com Playwright, report de bugs e evidências.

## Onde está cada entrega

| Entrega | Onde | Status |
|---|---|---|
| Cenários de teste em Gherkin | (CTs.feature)
| Casos de teste manuais (testes-manuais/casos_de_teste_manuais.xlsx)
| Automação com Playwright | (automacão-verzel.spec.ts)
| Report de bugs | (BUGs Encontrados.md)|

## Critérios de aceite cobertos

| CA | Regra |
|---|---|
| CA01 | O cupom `BEMVINDO10` aplica 10% de desconto sobre o subtotal dos produtos |
| CA02 | O código do cupom não diferencia maiúsculas de minúsculas; espaços no início e no fim são ignorados |
| CA03 | Cupom inexistente exibe "Cupom inválido." e nenhum desconto é aplicado |
| CA04 | Cupom fora da validade exibe "Cupom expirado." e nenhum desconto é aplicado |
| CA05 | Apenas um cupom por vez; para trocar, remove-se o atual e aplica-se outro |
| CA06 | Frete grátis para subtotal a partir de R$ 200,00, inclusive |
| CA07 | Abaixo de R$ 200,00: frete fixo de R$ 19,90 e o carrinho informa quanto falta para o frete grátis |
| CA08 | A regra do frete grátis considera o subtotal antes do desconto do cupom |
| CA09 | O desconto do cupom não incide sobre o frete |
| CA10 | Máximo de 5 unidades por produto por pedido (interface e API) |
| CA11 | Todos os valores são arredondados para 2 casas decimais |

## Estratégia

1. **Gherkin** descreve o comportamento esperado a partir dos CAs: caminho feliz, valores-limite e cenários negativos. As tags `@CA01`…`@CA11` ligam cada cenário ao critério; `@automatizar` marca os candidatos à automação, `@exploratorio` os que dependem de comportamento não especificado e `@api` os de API.
2. **Testes manuais** transformam esses cenários em casos executáveis, com passos, resultado esperado e campos para resultado obtido, status, Bug ID e evidência.
3. **Automação** com 3 testes simples nos pontos de maior risco.

### Cenários Gherkin

- 35 cenários (8 deles esquemas com tabela de exemplos), escritos em português (`# language: pt`).
- Cobrem todos os CAs, incluindo: variações de maiúsculas e espaços, entradas atípicas no campo de cupom, cupom inválido/expirado com cupom válido já aplicado, troca de cupom, valores-limite do frete e limite de 5 unidades por produto na interface e na API.

### Casos de teste manuais

- 37 casos (`TM-001` a `TM-037`) na aba **Casos de Teste**, com tipo (funcional, negativo, limite, exploratório) e prioridade.
- Aba **Resumo**: contagem automática por status e por CA, e percentual executado.
- Aba **Legenda**: como preencher, exemplo e premissas.
- Preencha apenas as colunas amarelas (resultado obtido, status, Bug ID, evidência).

### Automação (Playwright + TypeScript)

Spec única, sem Page Objects: [`automacão-verzel.spec.ts`](automacão-verzel.spec.ts), com apenas 3 testes simples. A tag do CA vai no título de cada teste.

| Teste | CA | O que valida |
|---|---|---|
| `@CA01` | CA01 | `BEMVINDO10` aplica 10% em R$ 100,00: desconto R$ 10,00, frete R$ 19,90, total R$ 109,90 |
| `@CA03` | CA03 | Cupom inexistente exibe "Cupom inválido." e não aplica desconto 
| `@CA10` | CA10 | 5 unidades do mesmo produto são aceitas e a 6ª é bloqueada |

Os demais critérios (CA02, CA04, CA05, CA07, CA09, CA11) ficam cobertos pelos cenários Gherkin e pelos casos manuais.

## Como rodar a automação

Pré-requisitos: Node.js 18+.

```bash
cd automacao
npm install
npx playwright install chromium
npm test                 # todos os testes
npx playwright test --grep @CA06   # um critério específico
npm run report           # abre o relatório HTML
```

A configuração tira print de todos os testes (aprovados ou não), e guarda vídeo e trace apenas nas falhas. Os prints servem de base para o documento de evidências.

## Limitações e premissas

- **Seletores:** baseados no HTML da vitrine e do carrinho (`data-valor` no resumo, `output` de quantidade, `#campo-cupom`). A única suposição que resta é o link/botão do carrinho no cabeçalho, cujo HTML não foi fornecido (função `irParaCarrinho` da spec).
- **Subtotais:** todos os preços do catálogo (R$ 29,90 a R$ 229,90) são múltiplos de R$ 0,10. Por isso subtotais como R$ 199,99 e R$ 200,01, e o arredondamento no ponto médio (R$ 10,05 → R$ 1,01), não são alcançáveis pela interface. Na automação os testes usam R$ 100,00, R$ 200,00 e R$ 209,50. Esses casos ficam para a API ou para teste exploratório.
- **Cupons:** os códigos de cupom expirado e de um segundo cupom válido não constam nos critérios de aceite; por isso CA04 e CA05 ficam nos casos manuais.
- **API:** a automação não cobre a API. O limite de 5 unidades na API (CA10) está nos cenários Gherkin e nos casos manuais.
- **Cálculo:** assumido total = subtotal − desconto + frete, com arredondamento half-up (0,005 sobe para 0,01).
- **Mensagens:** só "Cupom inválido." e "Cupom expirado." têm texto definido. As mensagens de limite de 5 unidades e de valor faltante para o frete grátis não estão especificadas e devem ser registradas como exibidas.
- **Execução:** a automação foi escrita sem acesso ao ambiente e ainda não foi executada contra a loja. Rode uma vez e ajuste `irParaCarrinho` se necessário.
