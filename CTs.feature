      # language: pt
      @VZS-142
      Funcionalidade: Cupom de desconto e frete grátis
      Como cliente da Verzel Store
      Quero aplicar um cupom de desconto e ganhar frete grátis em compras maiores
      Para pagar menos nas minhas compras

      # Premissas (confirmar na documentação / ambiente):
      # - Cupom válido principal: BEMVINDO10 (10% sobre o subtotal dos produtos)
      # - EXPIRADO10 representa um cupom existente porém fora da validade
      # - OUTROCUPOM representa um segundo cupom válido (usado para testar CA05)
      # - Regra de arredondamento: half-up (0,005 sobe para 0,01)
      # - Total = subtotal - desconto + frete

      Contexto:
      Dado que sou um cliente acessando a Verzel Store
      E que o carrinho está vazio

      # ---------------------------------------------------------------- CA01
      @CA01 @smoke @automatizar
      Cenário: Aplicar o cupom BEMVINDO10 em compra abaixo de R$ 200,00
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ 10,00
      E o frete deve ser de R$ 19,90
      E o total deve ser de R$ 109,90

      @CA01
      Cenário: Aplicar o cupom BEMVINDO10 em compra acima de R$ 200,00
      Dado que o carrinho possui produtos com subtotal de R$ 250,00
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ 25,00
      E o frete deve ser grátis
      E o total deve ser de R$ 225,00

      @CA01
      Cenário: O desconto incide apenas sobre o subtotal dos produtos
      Dado que o carrinho possui 2 produtos diferentes com subtotal de R$ 150,00
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ 15,00

      # ---------------------------------------------------------------- CA02
      @CA02 @automatizar
      Esquema do Cenário: Código do cupom não diferencia maiúsculas de minúsculas
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom "<codigo_digitado>"
      Então o cupom deve ser aceito
      E o desconto exibido deve ser de R$ 10,00

      Exemplos:
      | codigo_digitado |
      | BEMVINDO10      |
      | bemvindo10      |
      | BemVindo10      |
      | bEmViNdO10      |

      @CA02
      Esquema do Cenário: Espaços no início e no fim do código são ignorados
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom "<codigo_digitado>"
      Então o cupom deve ser aceito
      E o desconto exibido deve ser de R$ 10,00

      Exemplos:
      | codigo_digitado    |
      | " BEMVINDO10"      |
      | "BEMVINDO10 "      |
      | "   BEMVINDO10   " |
      | "  bemvindo10  "   |

      @CA02 @exploratorio
      Cenário: Espaços no meio do código não devem ser ignorados
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom "BEM VINDO10"
      Então devo ver a mensagem "Cupom inválido."
      E nenhum desconto deve ser aplicado

      # ---------------------------------------------------------------- CA03
      @CA03 @automatizar
      Cenário: Cupom inexistente exibe mensagem de erro e não aplica desconto
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom "CUPOMFALSO"
      Então devo ver a mensagem "Cupom inválido."
      E nenhum desconto deve ser aplicado
      E o total deve ser de R$ 119,90

      @CA03 @exploratorio
      Esquema do Cenário: Entradas inválidas ou atípicas no campo de cupom
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom "<entrada>"
      Então nenhum desconto deve ser aplicado
      E o total deve permanecer R$ 119,90

      Exemplos:
      | entrada                   |
      |                           |
      | "   "                     |
      | BEMVINDO100               |
      | BEMVINDO                  |
      | <script>alert(1)</script> |
      | ' OR '1'='1               |

      @CA03
      Cenário: Cupom inválido não substitui um cupom válido já aplicado
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      E que o cupom "BEMVINDO10" está aplicado
      Quando eu tento aplicar o cupom "CUPOMFALSO"
      Então devo ver a mensagem "Cupom inválido."
      E o cupom "BEMVINDO10" deve continuar aplicado
      E o desconto exibido deve continuar sendo R$ 10,00

      # ---------------------------------------------------------------- CA04
      @CA04 @automatizar
      Cenário: Cupom expirado exibe mensagem de erro e não aplica desconto
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom expirado "EXPIRADO10"
      Então devo ver a mensagem "Cupom expirado."
      E nenhum desconto deve ser aplicado
      E o total deve ser de R$ 119,90

      @CA04 @exploratorio
      Cenário: Cupom expirado não substitui um cupom válido já aplicado
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      E que o cupom "BEMVINDO10" está aplicado
      Quando eu tento aplicar o cupom expirado "EXPIRADO10"
      Então devo ver a mensagem "Cupom expirado."
      E o cupom "BEMVINDO10" deve continuar aplicado

      @CA04 @exploratorio
      Cenário: Validade do cupom no limite (último dia e dia seguinte)
      Dado que existe um cupom cuja validade termina em uma data D
      Quando eu aplico o cupom na data D
      Então o cupom deve ser aceito
      Quando eu aplico o cupom na data D + 1 dia
      Então devo ver a mensagem "Cupom expirado."

      # ---------------------------------------------------------------- CA05
      @CA05 @automatizar
      Cenário: Não é possível aplicar um segundo cupom com outro já aplicado
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      E que o cupom "BEMVINDO10" está aplicado
      Quando eu tento aplicar o cupom "OUTROCUPOM"
      Então o segundo cupom não deve ser aplicado
      E apenas o cupom "BEMVINDO10" deve constar no carrinho
      E o desconto não deve ser acumulado

      @CA05
      Cenário: Trocar de cupom removendo o atual e aplicando outro
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      E que o cupom "BEMVINDO10" está aplicado
      Quando eu removo o cupom atual
      Então nenhum desconto deve ser exibido
      E o total deve ser de R$ 119,90
      Quando eu aplico o cupom "OUTROCUPOM"
      Então apenas o cupom "OUTROCUPOM" deve constar no carrinho

      @CA05
      Cenário: Reaplicar o mesmo cupom não duplica o desconto
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      E que o cupom "BEMVINDO10" está aplicado
      Quando eu aplico novamente o cupom "BEMVINDO10"
      Então o desconto exibido deve continuar sendo R$ 10,00

      @CA05 @exploratorio
      Cenário: Remover o cupom recalcula o total e o frete
      Dado que o carrinho possui produtos com subtotal de R$ 210,00
      E que o cupom "BEMVINDO10" está aplicado
      Quando eu removo o cupom atual
      Então nenhum desconto deve ser exibido
      E o frete deve ser grátis
      E o total deve ser de R$ 210,00

      # ---------------------------------------------------------------- CA06
      @CA06 @automatizar
      Esquema do Cenário: Frete grátis para subtotal a partir de R$ 200,00 (valores-limite)
      Dado que o carrinho possui produtos com subtotal de R$ <subtotal>
      Quando eu visualizo o resumo do carrinho
      Então o frete deve ser <frete>

      Exemplos:
      | subtotal | frete    |
      | 199,99   | R$ 19,90 |
      | 200,00   | grátis   |
      | 200,01   | grátis   |
      | 500,00   | grátis   |

      # ---------------------------------------------------------------- CA07
      @CA07 @automatizar
      Cenário: Frete fixo e valor restante para frete grátis abaixo de R$ 200,00
      Dado que o carrinho possui produtos com subtotal de R$ 150,00
      Quando eu visualizo o resumo do carrinho
      Então o frete deve ser de R$ 19,90
      E o carrinho deve informar que faltam R$ 50,00 para o frete grátis

      @CA07
      Esquema do Cenário: Valor restante para o frete grátis é calculado corretamente
      Dado que o carrinho possui produtos com subtotal de R$ <subtotal>
      Quando eu visualizo o resumo do carrinho
      Então o frete deve ser de R$ 19,90
      E o carrinho deve informar que faltam R$ <faltante> para o frete grátis

      Exemplos:
      | subtotal | faltante |
      | 0,01     | 199,99   |
      | 100,00   | 100,00   |
      | 199,99   | 0,01     |

      @CA07
      Cenário: A mensagem de valor restante não é exibida quando o frete é grátis
      Dado que o carrinho possui produtos com subtotal de R$ 200,00
      Quando eu visualizo o resumo do carrinho
      Então o frete deve ser grátis
      E o carrinho não deve exibir mensagem de valor faltante para frete grátis

      @CA07 @exploratorio
      Cenário: Mensagem de valor restante é atualizada ao alterar a quantidade
      Dado que o carrinho possui 1 unidade de um produto de R$ 150,00
      Quando eu aumento a quantidade para 2 unidades
      Então o subtotal deve ser de R$ 300,00
      E o frete deve ser grátis
      E a mensagem de valor faltante deve desaparecer

      # ---------------------------------------------------------------- CA08
      @CA08 @automatizar
      Cenário: Frete grátis considera o subtotal antes do desconto do cupom
      Dado que o carrinho possui produtos com subtotal de R$ 205,00
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ 20,50
      E o frete deve ser grátis
      E o total deve ser de R$ 184,50

      @CA08
      Cenário: Subtotal exatamente R$ 200,00 com cupom mantém o frete grátis
      Dado que o carrinho possui produtos com subtotal de R$ 200,00
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ 20,00
      E o frete deve ser grátis
      E o total deve ser de R$ 180,00

      @CA08
      Cenário: Subtotal abaixo de R$ 200,00 com cupom não ganha frete grátis
      Dado que o carrinho possui produtos com subtotal de R$ 199,99
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ 20,00
      E o frete deve ser de R$ 19,90
      E o total deve ser de R$ 199,89

      # ---------------------------------------------------------------- CA09
      @CA09 @automatizar
      Cenário: O desconto do cupom não incide sobre o frete
      Dado que o carrinho possui produtos com subtotal de R$ 100,00
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ 10,00
      E o frete deve continuar sendo R$ 19,90
      E o total deve ser de R$ 109,90

      # ---------------------------------------------------------------- CA10
      @CA10 @automatizar
      Cenário: Adicionar 5 unidades do mesmo produto pela interface
      Dado que estou na página de um produto
      Quando eu adiciono 5 unidades ao carrinho
      Então o carrinho deve conter 5 unidades do produto

      @CA10 @automatizar
      Cenário: Bloquear a 6ª unidade do mesmo produto pela interface
      Dado que o carrinho possui 5 unidades de um produto
      Quando eu tento adicionar mais 1 unidade do mesmo produto
      Então devo ver uma mensagem informando o limite de 5 unidades por produto
      E o carrinho deve continuar com 5 unidades do produto

      @CA10
      Cenário: Bloquear alteração de quantidade acima de 5 no carrinho
      Dado que o carrinho possui 1 unidade de um produto
      Quando eu altero a quantidade para 6 no carrinho
      Então devo ver uma mensagem informando o limite de 5 unidades por produto
      E a quantidade do produto deve permanecer válida (máximo de 5)

      @CA10
      Cenário: O limite é por produto e não por pedido
      Dado que o carrinho possui 5 unidades do produto "A"
      Quando eu adiciono 5 unidades do produto "B"
      Então o carrinho deve conter 5 unidades do produto "A"
      E o carrinho deve conter 5 unidades do produto "B"

      @CA10 @api @automatizar
      Esquema do Cenário: Limite de unidades por produto validado na API
      Quando eu envio uma requisição à API para adicionar <quantidade> unidades de um produto ao pedido
      Então a API deve responder com <resultado>

      Exemplos:
      | quantidade | resultado                                     |
      | 1          | sucesso                                       |
      | 5          | sucesso                                       |
      | 6          | erro de validação (4xx) e item não adicionado |
      | 100        | erro de validação (4xx) e item não adicionado |

      @CA10 @api
      Cenário: API bloqueia acúmulo acima de 5 unidades em chamadas sucessivas
      Dado que já adicionei 3 unidades de um produto ao pedido pela API
      Quando eu envio outra requisição para adicionar 3 unidades do mesmo produto
      Então a API deve responder com erro de validação (4xx)
      E o pedido deve continuar com 3 unidades do produto

      @CA10 @api @exploratorio
      Esquema do Cenário: API rejeita quantidades inválidas
      Quando eu envio uma requisição à API para adicionar <quantidade> unidades de um produto ao pedido
      Então a API deve responder com erro de validação (4xx)

      Exemplos:
      | quantidade |
      | 0          |
      | -1         |
      | 1.5        |
      | "abc"      |

      # ---------------------------------------------------------------- CA11
      @CA11 @automatizar
      Esquema do Cenário: Valores monetários arredondados para 2 casas decimais
      Dado que o carrinho possui produtos com subtotal de R$ <subtotal>
      Quando eu aplico o cupom "BEMVINDO10"
      Então o desconto exibido deve ser de R$ <desconto>
      E o total deve ser de R$ <total>

      Exemplos:
      | subtotal | desconto | total  | observação                          |
      | 33,33    | 3,33     | 49,90  | 3,333 arredonda para 3,33           |
      | 19,99    | 2,00     | 37,89  | 1,999 arredonda para 2,00           |
      | 10,05    | 1,01     | 28,94  | 1,005 arredonda (half-up) para 1,01 |
      | 99,99    | 10,00    | 109,89 | 9,999 arredonda para 10,00          |

@CA11
Cenário: Subtotal com múltiplas unidades mantém 2 casas decimais
Dado que o carrinho possui 3 unidades de um produto de R$ 33,33
Quando eu visualizo o resumo do carrinho
Então o subtotal deve ser de R$ 99,99
E todos os valores exibidos devem ter exatamente 2 casas decimais

@CA11 @api
Cenário: A API retorna valores arredondados para 2 casas decimais
Dado que o pedido possui produtos com subtotal de R$ 33,33
Quando eu aplico o cupom "BEMVINDO10" via API
Então os campos de desconto, frete e total devem ter no máximo 2 casas decimais
E o desconto retornado deve ser 3.33
