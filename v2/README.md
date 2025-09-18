# O que há de novo na v2.1? De Script para Suíte

A versão 2.1 não é apenas uma atualização, é uma reimaginação completa da ferramenta. A essência agressiva de otimização foi mantida, mas agora ela é entregue com **Controle, Segurança e Flexibilidade** como pilares centrais.

Veja o que mudou:

### De: Execução Única → Para: Menu Interativo
-   **Como era:** O script executava todas as otimizações de uma vez, sem pausas ou escolhas.
-   **Como é agora:** Você é recebido por um menu claro onde pode aplicar o pacote completo ou escolher otimizações específicas (apenas rede, apenas bloatware, etc.). **A decisão final é sua.**

### De: Risco Assumido → Para: Segurança Ativa
-   **Como era:** O usuário precisava saber como rodar como Admin e torcer para não remover algo que usava.
-   **Como é agora:** O script **exige privilégios de Administrador** para rodar e **pede sua confirmação** `[s/N]` antes de realizar ações drásticas, como remover o OneDrive ou desativar o SmartScreen. Chega de acidentes.

### De: Reversão Total → Para: Reversão Rápida e Cirúrgica
-   **Como era:** A única forma de reverter era usando o Ponto de Restauração do Sistema, um processo demorado que revertia tudo no computador.
-   **Como é agora:** Uma nova opção `[G]` no menu **gera um script de reversão** (`Reverter-Otimizacoes.ps1`) em sua área de trabalho. Ele desfaz a maioria das *configurações* do script (serviços, registro, energia) em segundos, sem tocar nos seus arquivos ou outros programas.

### De: Ações Ocultas → Para: Transparência Total
-   **Como era:** O script rodava e fechava, deixando o usuário sem um registro claro do que foi feito.
-   **Como é agora:** Um **arquivo de log** (`.txt`) é criado automaticamente em sua Área de Trabalho, registrando cada comando executado, cada mensagem e cada erro. Perfeito para diagnóstico e para saber exatamente o que aconteceu.

### Resumo
A essência de performance do **Script para aumentar a performace** continua intacta. A diferença é que agora ele trata o usuário como um piloto, não como um passageiro. Você tem o controle do volante, com mais medidores, airbags e um botão de ejeção.