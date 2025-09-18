# Win11 Ultimate Gaming Tweak Suite v2.1

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Uma suíte de otimização interativa em PowerShell para o Windows 11, focada em obter a máxima performance, reduzir a latência do sistema e dar ao usuário controle total sobre as modificações.

## Sobre o Projeto

Este projeto nasceu da necessidade de gamers e power users que desejam extrair o máximo de desempenho de suas máquinas. Ele automatiza dezenas de otimizações que normalmente exigiriam horas de configuração manual.

Na **versão 2.1**, o script evoluiu de uma ferramenta de execução única para uma **suíte interativa completa**. A filosofia continua simples: desativar ou remover tudo que não contribui diretamente para a performance. A diferença é que agora **você está no controle**, decidindo exatamente o que será alterado, com mais segurança e transparência.

---

## ⚠️ AVISO IMPORTANTE

Este é um script de nível **AVANÇADO**. Ele realiza alterações profundas no sistema operacional.

- **USE POR SUA CONTA E RISCO.** Não nos responsabilizamos por qualquer problema que possa ocorrer.
- **PRINCIPAL REDE DE SEGURANÇA:** O script cria um **Ponto de Restauração do Sistema** no início. Tenha certeza de que ele foi criado com sucesso antes de prosseguir.
- **SAÍDA RÁPIDA:** A versão 2.1 inclui um **gerador de script de reversão** para a maioria das configurações, oferecendo uma segunda camada de segurança.
- **NÃO É PARA TODOS:** Se você usa intensivamente o ecossistema da Microsoft (OneDrive, Office Hub, etc.) ou depende de funcionalidades específicas que o script remove, use as opções do menu para aplicar apenas os tweaks que desejar.

---

## O que esta suíte faz?

Através de um menu interativo, você pode escolher aplicar o pacote completo ou apenas as otimizações que desejar:

- ✅ **Cria um Ponto de Restauração:** Sua segurança em primeiro lugar.
- ✅ **Menu Interativo:** Você no controle! Escolha o que quer otimizar.
- ✅ **Gera Script de Reversão:** Permite reverter a maioria das configurações de forma rápida.
- ✅ **Cria Log de Atividades:** Salva um registro de tudo que foi feito em um arquivo de texto.
- ✅ **Remove Bloatware:** Desinstala dezenas de apps pré-instalados, mas **mantém a Xbox Game Bar**.
- ✅ **Remove o OneDrive:** Opção de desinstalar completamente o OneDrive (pede sua confirmação).
- ✅ **Desativa Telemetria:** Impede que o Windows envie dados de uso para a Microsoft.
- ✅ **Desativa Serviços Pesados:** Para serviços desnecessários como SysMain (Superfetch), Fax, etc.
- ✅ **Desativa Tarefas Agendadas:** Impede a execução de tarefas de telemetria em segundo plano.
- ✅ **Ativa o Plano de Energia de Desempenho Máximo:** Garante que seu hardware entregue 100%.
- ✅ **Aplica Otimizações de Rede e de Registro:** Reduz a latência, acelera o desligamento e melhora a privacidade.

---

## Como Usar

1.  **Download:** Baixe o arquivo `Optimize-Win11.ps1` para uma pasta de fácil acesso (ex: `C:\Temp`).

2.  **Abra o PowerShell como Administrador:**
    -   Clique no Menu Iniciar.
    -   Digite "PowerShell".
    -   Clique com o botão direito em "Windows PowerShell" e selecione **"Executar como administrador"**.

3.  **Permita a Execução do Script:** Por padrão, o PowerShell bloqueia scripts. Execute o seguinte comando para permitir a execução apenas nesta sessão:
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    ```

4.  **Navegue até a Pasta e Execute:** Use o comando `cd` para ir até a pasta onde você salvou o script e depois execute-o. Por exemplo:
    ```powershell
    cd C:\Temp
    .\Optimize-Win11.ps1
    ```

5.  **Siga o Menu:** O script irá apresentar um menu de opções. Leia cada uma e digite o número correspondente à otimização que deseja aplicar. Para as ações mais críticas, o script pedirá uma confirmação adicional `[s/N]`.

6.  **Reinicie o Computador:** Após a conclusão, reinicie o seu PC para que todas as alterações tenham efeito.

---

## Otimizações Manuais Essenciais (Pós-Script)

Para o ganho final de performance, algumas otimizações de alto impacto precisam ser feitas manualmente por segurança.

### 1. Desativar VBS (Segurança Baseada em Virtualização)
Esta é a otimização **mais importante** para jogos no Windows 11, podendo aumentar significativamente seus FPS mínimos.

-   **Verifique se está ativo:** Abra o menu Iniciar, digite `msinfo32` e pressione Enter. Procure pela linha **"Segurança baseada em virtualização"**. Se estiver "Em execução", desative-o.
-   **Como desativar:**
    1.  Vá em `Configurações > Privacidade e segurança > Segurança do Windows`.
    2.  Clique em **"Segurança do dispositivo"** e depois em **"Detalhes de isolamento de núcleo"**.
    3.  Desative a **"Integridade da memória"**.
    4.  Reinicie o PC.

### 2. Desativar a Indexação de Pesquisa no SSD
Reduz o uso de disco em segundo plano.

1.  Abra o "Explorador de Arquivos".
2.  Clique com o botão direito no seu disco de jogos/sistema (ex: `C:`), e vá em **"Propriedades"**.
3.  Na aba "Geral", desmarque a caixa **"Permitir que os arquivos nesta unidade tenham o conteúdo indexado..."**.
4.  Clique em "Aplicar", escolha aplicar a todas as subpastas e arquivos, e confirme.

---

## Licença

Este projeto está sob a licença MIT.

## Agradecimentos
- À comunidade de power users do Windows.
- Aos criadores de scripts de otimização que pavimentaram o caminho.