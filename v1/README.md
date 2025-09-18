# Win11 Ultimate Gaming Tweak Script

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Um script PowerShell agressivo para otimizar o Windows 11, focado em obter a máxima performance, reduzir a latência do sistema e remover componentes desnecessários.

## Sobre o Projeto

Este script foi criado para gamers e power users que desejam extrair o máximo de desempenho de suas máquinas. Ele automatiza dezenas de otimizações que normalmente exigiriam horas de configuração manual. A filosofia é simples: desativar ou remover tudo que não contribui diretamente para a performance, resultando em um sistema mais limpo, rápido e responsivo.

---

## ⚠️ AVISO IMPORTANTE

Este é um script de nível **AVANÇADO**. Ele realiza alterações profundas no sistema operacional.

- **USE POR SUA CONTA E RISCO.** Eu não me responsabilizo por qualquer problema que possa ocorrer.
- **CRIE UM BACKUP:** O script cria um Ponto de Restauração do Sistema no início, que é sua principal rede de segurança. Tenha certeza de que ele foi criado com sucesso.
- **NÃO É PARA TODOS:** Se você usa intensivamente o ecossistema da Microsoft (OneDrive, Office Hub, etc.) ou depende de funcionalidades específicas que o script remove, este script não é para você.

---

## O que este script faz?

- ✅ **Cria um Ponto de Restauração:** Sua segurança em primeiro lugar.
- ✅ **Remove Bloatware:** Desinstala dezenas de aplicativos pré-instalados (Candy Crush, Your Phone, etc.), mas **mantém a Xbox Game Bar** por sua utilidade em jogos.
- ✅ **Remove o OneDrive:** Desinstala completamente o OneDrive.
- ✅ **Desativa Telemetria e Coleta de Dados:** Impede que o Windows envie dados de uso para a Microsoft.
- ✅ **Desativa Serviços Pesados:** Para serviços desnecessários como SysMain (Superfetch), Fax, entre outros.
- ✅ **Desativa Tarefas Agendadas:** Impede a execução de tarefas de manutenção e telemetria em segundo plano.
- ✅ **Ativa o Plano de Energia de Desempenho Máximo:** Garante que seu processador esteja sempre pronto para a ação.
- ✅ **Aplica Otimizações de Rede e de Registro:** Reduz a latência de menus, acelera o desligamento e melhora a privacidade.

---

## Como Usar

1.  **Download:** Clique no botão verde "Code" no topo desta página e depois em **"Download ZIP"**. Extraia o arquivo `Optimize-Win11.ps1` para uma pasta de fácil acesso (ex: `C:\Temp`).

2.  **Abra o PowerShell como Administrador:**
    - Clique no Menu Iniciar.
    - Digite "PowerShell".
    - Clique com o botão direito em "Windows PowerShell" e selecione **"Executar como administrador"**.

3.  **Permita a Execução do Script:** Por padrão, o PowerShell bloqueia a execução de scripts. Execute o seguinte comando para permitir a execução apenas nesta sessão:
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    ```

4.  **Navegue até a Pasta e Execute:** Use o comando `cd` para navegar até a pasta onde você salvou o script e depois execute-o. Por exemplo:
    ```powershell
    cd C:\Temp
    .\Optimize-Win11.ps1
    ```

5.  **Reinicie o Computador:** Após a conclusão do script, reinicie o seu PC para que todas as alterações tenham efeito.

---

## Otimizações Manuais Essenciais (Pós-Script)

Para o ganho final de performance, algumas otimizações de alto impacto precisam ser feitas manualmente por segurança.

### 1. Desativar VBS (Segurança Baseada em Virtualização)
Esta é a otimização **mais importante** para jogos no Windows 11, podendo aumentar significativamente seus FPS mínimos.

-   **Verifique se está ativo:** Abra o menu Iniciar, digite `msinfo32` e pressione Enter. Procure pela linha **"Segurança baseada em virtualização"**. Se estiver "Em execução", desative-o seguindo os passos abaixo.
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

-   À comunidade de power users do Windows.
-   Aos criadores de scripts de otimização que pavimentaram o caminho.