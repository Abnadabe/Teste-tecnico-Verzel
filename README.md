# Teste Técnico Verzel

Este repositório reúne a solução do teste técnico da Verzel Store, incluindo cenários em Gherkin, casos de teste manuais, automação com Playwright e relatório de bugs encontrados.

> História de negócio: como cliente da Verzel Store, quero aplicar um cupom de desconto e ganhar frete grátis em compras maiores para pagar menos nas minhas compras.

## Visão geral

A proposta do projeto foi validar os requisitos de cupom de desconto e regra de frete grátis, cobrindo:

- comportamento esperado em cenários funcionais e de limite;
- casos de erro e regras de validação;
- automação de testes críticos;
- registro de defeitos identificados com evidências.

## Estrutura do projeto

| Entrega | Arquivo | Descrição |
|---|---|---|
| Cenários em Gherkin | [CTs.feature](CTs.feature) | Definição dos cenários de teste em linguagem natural, com tags por critério de aceite. |
| Casos de teste manuais | [casos_de_teste_manuais.xlsx](casos_de_teste_manuais.xlsx) | Casos executáveis com passos, resultados esperados, status e evidências. |
| Automação Playwright | [tests/automação-verzel.spec.ts](tests/automação-verzel.spec.ts) | Testes automatizados dos principais fluxos de risco. |
| Configuração do Playwright | [playwright.config.ts](playwright.config.ts) | Configuração da suíte e do ambiente de execução. |
| Relatório de bugs | [BUGs Encontrados.md](BUGs%20Encontrados.md) | Documentação dos defeitos identificados, com descrição e evidências. |

## Critérios de aceite cobertos

| Código | Requisito |
|---|---|
| CA01 | O cupom BEMVINDO10 aplica 10% de desconto sobre o subtotal dos produtos. |
| CA02 | O código do cupom não diferencia maiúsculas e minúsculas, e ignora espaços no início e no fim. |
| CA03 | Cupom inexistente exibe a mensagem “Cupom inválido.” e não aplica desconto. |
| CA04 | Cupom fora da validade exibe a mensagem “Cupom expirado.” e não aplica desconto. |
| CA05 | Só pode existir um cupom ativo por vez; a troca deve ocorrer por remoção e re-aplicação. |
| CA06 | Frete grátis quando o subtotal atinge R$ 200,00 ou mais. |
| CA07 | Abaixo de R$ 200,00, o frete fixo é R$ 19,90 e o carrinho informa quanto falta para o frete grátis. |
| CA08 | A regra de frete grátis considera o subtotal antes do desconto do cupom. |
| CA09 | O desconto do cupom não incide sobre o frete. |
| CA10 | O limite é de 5 unidades por produto por pedido. |
| CA11 | Todos os valores devem ser arredondados para 2 casas decimais. |

## Entregáveis

### 1) Cenários Gherkin

No arquivo [CTs.feature](CTs.feature), os comportamentos foram modelados em português com tags por critério de aceite, incluindo:

- fluxo principal da regra de cupom e frete grátis;
- casos de limite e borda;
- cenários de erro e validação;
- cenários exploratórios para comportamentos não totalmente especificados;
- marcação para automação e para revisão manual.

### 2) Casos de teste manuais

A planilha [casos_de_teste_manuais.xlsx](casos_de_teste_manuais.xlsx) contém casos executáveis, com:

- passos de execução;
- resultado esperado;
- resultado obtido;
- status;
- identificação do defeito e evidência.

### 3) Automação com Playwright

A suíte automatizada está em [tests/automação-verzel.spec.ts](tests/automação-verzel.spec.ts). Ela cobre os fluxos de maior risco e foi estruturada com 3 testes principais:

| Teste | Critério | Validação |
|---|---|---|
| @CA01 | CA01 | Cupom BEMVINDO10 aplica 10% de desconto em subtotal de R$ 100,00. |
| @CA03 | CA03 | Cupom inexistente retorna mensagem de erro e não aplica desconto. |
| @CA10 | CA10 | Permite 5 unidades do mesmo produto e bloqueia a 6ª. |

Os demais critérios são contemplados pelos cenários Gherkin e pelos casos manuais.

## Como executar a automação

Pré-requisitos:

- Node.js 18 ou superior
- npm

Passos:

```bash
npm install
npx playwright install chromium
npx playwright test
npx playwright test --grep "@CA01"
npx playwright show-report
```

Observações:

- a base URL da aplicação está configurada em [playwright.config.ts](playwright.config.ts);
- os testes geram evidência visual e capturam trace em falhas;
- o relatório HTML pode ser aberto com o comando acima;
- como a suíte foi escrita sem acesso direto ao ambiente real em tempo de execução, pode haver necessidade de ajuste nos seletores do carrinho, caso a interface da loja tenha pequenas variações.

## Bugs identificados

O relatório de defeitos foi documentado em [BUGs Encontrados.md](BUGs%20Encontrados.md). Os principais itens registrados incluem:

- VZ-001: frete não fica grátis ao atingir o valor mínimo com desconto aplicado;
- VZ-002: cobrança indevida mesmo com subtotal elegível para frete grátis;
- VZ-003: carrinho exibe frete incorreto ao atingir o valor mínimo;
- VZ-004: falha no frete grátis ao aplicar o cupom BEMVINDO10.

## Premissas e limitações

- A automação considera seletores baseados no HTML da vitrine e do carrinho, e a navegação até o carrinho foi implementada como função específica para o ambiente;
- A regra de frete grátis foi tratada com base em subtotal antes do desconto do cupom;
- Alguns cenários de validade de cupom e troca de cupom dependem de dados específicos do ambiente e foram priorizados nos testes manuais e em Gherkin;
- Os resultados das mensagens específicas de limite de quantidade e do valor restante para frete grátis devem ser observados e registrados conforme a interface exibida.

## Conclusão

O projeto entrega uma visão completa do comportamento esperado da Verzel Store em relação a cupons e frete grátis, combinando testes de especificação, validação manual e automação de regressão para os casos de maior risco.

