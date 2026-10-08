# **BUGs Encontrados**

---

# **VZ-001**

**Título do BUG**: Frete não fica grátis ao atingir o valor mínimo com desconto aplicado 

**Pré-Condição:**  
Carrinho com produtos somando subtotal de R\$ 100,00 e Cupom BEMVINDO10 já aplicado.

**Passo a Passo**:  
1\. Dobrar a quantidade dos produtos no carrinho (subtotal passa a R\$ 200,00).  
2\. Verificar o resumo.

**Resultado atual**:  
Desconto é atualizado para R\$ 20,00 mas o frete continua e o total dá R\$ 199,90

**Resultado esperado**:  
Desconto atualizado para R\$ 20,00; frete grátis; total R\$ 180,00.

**Evidência**: [https\://jam.dev/c/9354bca4-d8df-43cf-ac42-f70621e1972c](https://jam.dev/c/9354bca4-d8df-43cf-ac42-f70621e1972c)   
---

# **VZ-002**

**Título do BUG**: Valor cobrado indevidamente mesmo atingindo a regra de frete grátis 

**Pré-Condição:**  
Carrinho com produtos somando subtotal de R\$ 200,00.

**Passo a Passo**:  
1\. Abrir o carrinho.  
2\. Verificar frete.

**Resultado atual**:  
Frete R\$ 19,00 e Total R\$ 219,90.

**Resultado esperado**:  
Frete grátis; total R\$ 200,00.

**Evidência**: [https\://jam.dev/c/7bd44cb7-cdfe-432e-b7fd-08d7634250bb](https://jam.dev/c/7bd44cb7-cdfe-432e-b7fd-08d7634250bb)   
---

# **VZ-003**

**Título do BUG**: Carrinho com subtotal elegível exibe frete incorretamente 

**Pré-Condição:**  
Carrinho com produtos somando subtotal de R\$ 200,00.

**Passo a Passo**:  
1\. Abrir o carrinho.  
2\. Verificar frete.

**Resultado atual**:  
Frete R\$ 19,00; nenhuma mensagem de valor faltante.

**Resultado esperado**:  
Frete grátis; nenhuma mensagem de valor faltante.

**Evidência**: [https\://jam.dev/c/7287b9ec-8c05-47d0-af16-e31f8c6c3203](https://jam.dev/c/7287b9ec-8c05-47d0-af16-e31f8c6c3203)   
---

# **VZ-004**

**Título do BUG**: Falha no frete grátis ao aplicar o cupom BEMVINDO10 

**Pré-Condição:**  
Carrinho com produtos somando subtotal de R\$ 200,00.

**Passo a Passo**:  
1\. Aplicar BEMVINDO10.  
2\. Verificar o resumo.

**Resultado atual**:  
Desconto R\$ 20,00; Frete R\$ 19,90; total R\$ 199,90.

**Resultado esperado**:  
Desconto R\$ 20,00; frete grátis; total R\$ 180,00.

**Evidência**: [https\://jam.dev/c/c36866cb-9568-4878-8877-497ab492d635](https://jam.dev/c/c36866cb-9568-4878-8877-497ab492d635)  
---

