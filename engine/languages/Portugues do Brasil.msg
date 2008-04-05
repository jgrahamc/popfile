# Copyright (c) 2001-2006 John Graham-Cumming
# Translated by Adriano Rafael Gomes <adrianorg@users.sourceforge.net>
# Updated by Fernando de Alcantara Correia <facorreia@users.sourceforge.net> to v0.19.1
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

# Identify the language and character set used for the interface
LanguageCode                            br
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          br

# This is where to find the FAQ on the Wiki
FAQLink                                 faq

# Common words that are used on their own all over the interface
Account                                 Conta POP3
Apply                                   Aplicar
ApplyChanges                            Aplicar Alterações
On                                      Ligado
Off                                     Desligado
TurnOn                                  Ligar
TurnOff                                 Desligar
Add                                     Adicionar
Remove                                  Remover
Previous                                Anterior
Next                                    Próximo
From                                    De
Subject                                 Assunto
Cc                                      Cc
Classification                          Balde
Reclassify                              Reclassificar
Probability                             Probabilidade
Scores                                  Pontos
QuickMagnets                            Ímãs Rápidos
Undo                                    Desfazer
Close                                   Fechar
Find                                    Procurar
Filter                                  Filtrar
Yes                                     Sim
No                                      Não
ChangeToYes                             Trocar para Sim
ChangeToNo                              Trocar para Não
Bucket                                  Balde
Magnet                                  Ímã
Delete                                  Excluir
Create                                  Criar
To                                      Para
Total                                   Total
Rename                                  Renomear
Frequency                               Freqüência
Probability                             Probabilidade
Score                                   Pontuação
Lookup                                  Procurar
Word                                    Palavra
Count                                   Quantidade
Update                                  Alterar
Refresh                                 Atualizar
FAQ                                     FAQ
ID                                      ID
Date                                    Data
Arrived                                 Chegada
Size                                    Tamanho
Up                                      Cima
Down                                    Baixo
Go                                      Ir
Edit                                    Editar
Logout                                  Logout

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       .
Locale_Decimal                         ,

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %R | %D %R

# The header and footer that appear on every UI page
Header_Title                            Centro de Controle do POPFile
Header_Shutdown                         Desligar o POPFile
Header_History                          Histórico
Header_Buckets                          Baldes
Header_Configuration                    Configuração
Header_Advanced                         Avançado
Header_Security                         Segurança
Header_Administration                   Administração
Header_Magnets                          Ímãs
Header_Users                            Usuários

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Manual
Footer_Forums                           Forums
Footer_FeedMe                           Contribua
Footer_RequestFeature                   Pedir uma Característica
Footer_MailingList                      Lista de Email
Footer_Wiki                             Documentação

Configuration_Error1                    O caracter separador deve ser um único caracter
Configuration_Error2                    O porta da interface de usuário deve ser um número entre 1 e 65535
Configuration_Error3                    A porta de escuta POP3 deve ser um número entre 1 e 65535
Configuration_Error4                    O tamanho da página deve ser um número entre 1 e 1000
Configuration_Error5                    O número de dias no histórico deve ser um número entre 1 e 366
Configuration_Error6                    O tempo limite TCP deve ser um número entre 10 e 300
Configuration_Error7                    A porta de escuta XML-RPC deve ser um número entre 1 e 65535
Configuration_Error8                    A porta do proxy SOCKS V deve ser um número entre 1 e 65535
Configuration_POP3Port                  Porta de escuta POP3
Configuration_POP3Update                A porta POP3 foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_XMLRPCUpdate              A porta XML-RPC foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_XMLRPCPort                Porta de escuta XML-RPC
Configuration_SMTPPort                  Porta de escuta SMTP
Configuration_SMTPUpdate                A porta SMTP foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_NNTPPort                  Porta de escuta NNTP
Configuration_NNTPUpdate                A porta NNTP foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_POPFork                   Permitir conexões POP3 concorrentes
Configuration_SMTPFork                  Permitir conexões SMTP concorrentes
Configuration_NNTPFork                  Permitir conexões NNTP concorrentes
Configuration_POP3Separator             Caracter de separação POP3 servidor:porta:usuário
Configuration_NNTPSeparator             Caracter de separação NNTP servidor:porta:usuário
Configuration_POP3SepUpdate             Separador POP3 alterado para %s
Configuration_NNTPSepUpdate             Separador NNTP alterado para %s
Configuration_UI                        Porta da interface web de usuário
Configuration_UIUpdate                  Alterada a porta da interface web de usuário para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_History                   Mensagens por página
Configuration_HistoryUpdate             Alterado o número de mensagens por página para %s
Configuration_Days                      Dias para manter no histórico
Configuration_DaysUpdate                Alterado o número de dias para manter no histórico para %s
Configuration_UserInterface             Interface de Usuário
Configuration_Skins                     Skins
Configuration_SkinsChoose               Skin
Configuration_Language                  Linguagem
Configuration_LanguageChoose            Linguagem
Configuration_ListenPorts               Opções de Módulo
Configuration_HistoryView               Exibir Histórico
Configuration_TCPTimeout                Tempo Limite de Conexão
Configuration_TCPTimeoutSecs            Tempo limite de conexão em segundos
Configuration_TCPTimeoutUpdate          Alterado o tempo limite de conexão para %s
Configuration_ClassificationInsertion   Inserção de Texto na Mensagem
Configuration_SubjectLine               Modificação de<br>linha de assunto
Configuration_XTCInsertion              Cabeçalho<br>X-Text-Classification
Configuration_XPLInsertion              Cabeçalho<br>X-POPFile-Link
Configuration_Logging                   Logging
Configuration_None                      Nada
Configuration_ToScreen                  Na Tela (console)
Configuration_ToFile                    Em Arquivo
Configuration_ToScreenFile              Na Tela e em Arquivo
Configuration_LoggerOutput              Saída do Logger
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins
Configuration_CurrentLogFile            &lt;Exibir arquivo de log atual&gt;
Configuration_SOCKSServer               Endereço do proxy SOCKS V
Configuration_SOCKSPort                 Porta do proxy SOCKS V
Configuration_SOCKSPortUpdate           Alterada a porta do proxy SOCKS V para %s
Configuration_SOCKSServerUpdate         Alterado o endereço do proxy SOCKS V para %s
Configuration_Fields                    Adicionar colunas do histórico
Configuration_ChangePassword            Alterar Senha
Configuration_OldPassword               Atual
Configuration_NewPassword               Nova
Configuration_ConfirmPassword           Confirmar Nova
Configuration_Password_Mismatch         A nova senha deve igual nos campos Nova e Confirmar Nova
Configuration_Password_Bad              A senha atual informada está incorreta
Configuration_Password_Fail             Falha ao alterar a senha
Configuration_Set_Password              A senha foi alterada

Advanced_Error1                         '%s' já está na lista de Palavras Ignoradas
Advanced_Error2                         Palavras ignoradas podem somente conter caracteres alfanuméricos, ., _, -, ou @
Advanced_Error3                         '%s' adicionado na lista de Palavras Ignoradas
Advanced_Error4                         '%s' não está na lista de Palavras Ignoradas
Advanced_Error5                         '%s' removido da lista de Palavras Ignoradas
Advanced_StopWords                      Palavras Ignoradas
Advanced_Message1                       O POPFile ignora as seguintes palavras freqüentemente usadas:
Advanced_AddWord                        Adicionar palavra
Advanced_RemoveWord                     Remover palavra
Advanced_AllParameters                  Parâmetros Globais do POPFile
Advanced_Parameter                      Parâmetro
Advanced_Value                          Valor
Advanced_Warning                        Esta é a lista completa dos parâmetros do POPFile.  Somente para usuários avançados: você pode alterar qualquer um e clicar em Alterar; não há verificação de validade.  Ítens em negrito estão diferentes da configuração padrão. Veja <a href="http://getpopfile.org/docs/OptionReference">OptionReference</a> para mais informação sobre as opções.
Advanced_ConfigFile                     Arquivo de configuração:

Users_Create                            Criar Novo Usuário
Users_Remove                            Remover Usuário Existente
Users_Edit                              Editar Configurações do Usuário
Users_CopyFrom                          Copiando configurações do usuário
Users_RemoveUser                        Remover usuário
Users_CreateUser                        Criar usuário com nome
Users_EditUser                          Editar usuário
Users_Parameters                        Parâmetros
Users_Created                           Criado usuário '%s' (senha inicial '%s')
Users_Not_Created                       Falha ao criar usuário '%s'
Users_Created_And_Cloned                Criado usuário '%s' como um clone de '%s' (senha inicial '%s')
Users_Not_Created_Exists                Usuário '%s' não criado: já existente
Users_Created_Not_Cloned                Criado usuário '%s' mas clonagem de '%s' falhou (senha inicial '%s')
Users_Removed                           Removido usuário '%s'
Users_Removed_Failed                    Falha ao remover usuário '%s'
Users_Removed_Failed_Admin              Falha ao remover usuário '%s': desabilite direitos de administrador primeiro
Users_SingleUserMode                    Modo mono usuário (POPFile Clássico)
Users_Accounts                          Contas POP3 Associadas
Users_AddAccount                        Adicionar conta POP3 (computador:usuário)
Users_Bad_Account                       O nome da nova conta deve estar na forma computador:usuário
Users_Duplicate_Account                 Falha ao adicionar a conta porque ela já está associada a outro usuário
Users_Failed_Account                    Falha ao adicionar a conta


History_Filter                          &nbsp;(apenas mostrando o balde <font color="%s">%s</font>)
History_FilterBy                        Filtrar Por
History_Search                          &nbsp;(procurado por remetente/assunto %s)
History_Title                           Mensagens Recentes
History_Jump                            Ir para a página
History_ShowAll                         Exibir Tudo
History_ShouldBe                        Deveria ser
History_NoFrom                          sem linha de
History_NoSubject                       sem linha de assunto
History_ClassifyAs                      Classificar como
History_MagnetUsed                      Ímã usado
History_MagnetBecause                   <b>Ímã Utilizado</b><p>Classificado para <font color="%s">%s</font> por causa do ímã %s </p>
History_ChangedTo                       Alterado para <font color="%s">%s</font>
History_Already                         Reclassificado como <font color="%s">%s</font>
History_RemoveAll                       Remover Tudo
History_RemovePage                      Remover a Página
History_RemoveChecked                   Remover Marcados
History_SearchMessage                   Procurar Remetente/Assunto
History_NoMessages                      Nenhuma mensagem
History_ShowMagnet                      magnetizado
History_Negate_Search                   Inverter procura/filtro
History_Magnet                          &nbsp;(mostrando apenas mensagens classificadas por ímã)
History_NoMagnet                        &nbsp;(mostrando apenas mensagens não classificadas por ímã)
History_ResetSearch                     Limpar
History_ChangedClass                    Deveria classificar agora como
History_Purge                           Expirar Agora
History_Increase                        Incrementar
History_Decrease                        Decrementar
History_Column_Characters               Largura da coluna de histórico
History_Automatic                       Automático
History_Reclassified                    Reclassificado
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB
History_Click_To_Sort                   Clique para ordenar por esta coluna

Password_Title                          Login
Password_Password                       Senha
Password_Username                       Nome do usuário
Password_Go                             Login
Password_Error1                         Senha ou nome de usuário incorretos

Security_Error1                         A porta deve ser um número entre 1 e 65535
Security_Stealth                        Modo Stealth/Operação Servidor
Security_NoStealthMode                  Não (Modo Stealth)
Security_StealthMode                    (Modo Stealth)
Security_ExplainStats                   (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: bc (o número total de baldes que você tem), mc (o número total de mensagens que o POPFile classificou) e ec (o número total de erros de classificação).  Isto fica guardado em um arquivo e eu vou usar para publicar algumas estatísticas sobre como as pessoas usam o POPFile e o quão bem ele funciona.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as estatístcas e os endereços IP de cada um.)
Security_ExplainUpdate                  (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: ma (o número maior da versão do seu POPFile), mi (o número menor da versão do seu POPFile) e bn (o número do build da sua versão do POPFile). O POPFile recebe uma resposta na forma de um gráfico que aparece no topo da página se uma nova versão estiver disponível.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as verificações de versão e os endereços IP de cada um.)
Security_PasswordTitle                  Senha da Interface de Usuário
Security_Password                       Senha
Security_PasswordUpdate                 Alterada a senha
Security_AUTHTitle                      Servidores Remotos
Security_SecureServer                   Servidor POP3 remoto (SPA/AUTH ou proxy transparente)
Security_SecureServerUpdate             Alterado o servidor POP3 remoto para %s
Security_SecurePort                     Porta POP3 remota (SPA/AUTH ou proxy transparente)
Security_SecurePortUpdate               Alterada a porta do servidor POP3 remoto para %s
Security_SMTPServer                     Servidor da cadeia SMTP
Security_SMTPServerUpdate               Alterado o servidor da cadeia SMTP para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SMTPPort                       Porta da cadeia SMTP
Security_SMTPPortUpdate                 Alterada a porta da cadeia SMTP para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_POP3                           Aceitar conexões POP3 de máquinas remotas (requer reiniciar o POPFile)
Security_SMTP                           Aceitar conexões SMTP de máquinas remotas (requer reiniciar o POPFile)
Security_NNTP                           Aceitar conexões NNTP de máquinas remotas (requer reiniciar o POPFile)
Security_UI                             Aceitar conexões HTTP (Interface de Usuário) de máquinas remotas (requer reiniciar o POPFile)
Security_XMLRPC                         Aceitar conexões XML-RPC de máquinas remotas (requer reiniciar o POPFile)
Security_UpdateTitle                    Verificação Automática de Atualização
Security_Update                         Verificar diariamente atualizações para o POPFile
Security_StatsTitle                     Reportar Estatísticas
Security_Stats                          Enviar estatísticas diariamente

Magnet_Error1                           Ímã '%s' já existe no balde '%s'
Magnet_Error2                           O novo ímã '%s' conflita com o ímã '%s' no balde '%s' e pode causar resultados ambíguos.  O novo ímã não foi adicionado.
Magnet_Error3                           Criar novo ímã '%s' no balde '%s'
Magnet_CurrentMagnets                   Ímãs Atuais
Magnet_Message1                         Os seguintes ímãs fazem as mensagens serem sempre classificadas no balde especificado.
Magnet_CreateNew                        Criar Novo Ímã
Magnet_Explanation                      <b>Estes tipos de ímã estão disponíveis:</b> <ul><li><b>Endereço ou nome do remetente:</b> Por exemplo: fulano@empresa.com para pegar um endereço específico, <br />empresa.com para pegar todo mundo que envia de empresa.com, <br />Fulano de Tal para pegar uma pessoa específica, Fulano para pegar todos os Fulanos.</li><li><b>Endereço ou nome de destinatário/cópia:</b> Como um ímã de remetente mas para o endereço Para:/Cc: de uma mensagem.</li> <li><b>Palavras no assunto:</b> Por exemplo: olá para pegar todas as mensagens com olá no assunto.</li></ul>
Magnet_MagnetType                       Tipo do ímã
Magnet_Value                            Valores
Magnet_Always                           Sempre vai para o balde
Magnet_Jump                             Ir para a página de ímãs
Magnet_Note                             Ímãs devem ser pouco usados, uma vez que eles desviam do processo de aprendizado do POPFile.  Usar ímãs faz o POPFile levar mais tempo para atingir alta precisão.<br /><br />Leia mais sobre ímãs no <a href="http://getpopfile.org/docs/Glossary:AMagnet">Projeto de Documentação do POPFile</a>.

Bucket_Error1                           Nomes de balde somente podem conter as letras de a até z minúsculas, números de 0 a 9, mais - e _
Bucket_Error2                           O balde %s já existe
Bucket_Error3                           Criado o balde %s
Bucket_Error4                           Por favor digite uma palavra que não seja em branco
Bucket_Error5                           Renomeado o balde %s para %s
Bucket_Error6                           Excluído o balde %s
Bucket_Title                            Configuração do Balde
Bucket_BucketName                       Nome do<br>Balde
Bucket_WordCount                        Contagem de Palavras
Bucket_WordCounts                       Contagens de Palavras
Bucket_UniqueWords                      Palavras Distintas
Bucket_SubjectModification              Modificação do<br>Cabeçalho Assunto
Bucket_ChangeColor                      Cor do<br>Balde
Bucket_NotEnoughData                    Dados insuficientes
Bucket_ClassificationAccuracy           Precisão da Classificação
Bucket_EmailsClassified                 Mensagens classificadas
Bucket_EmailsClassifiedUpper            Mensagens Classificadas
Bucket_ClassificationErrors             Erros de classificação
Bucket_Accuracy                         Precisão
Bucket_ClassificationCount              Contagem da Classificação
Bucket_ClassificationFP                 Falsos Positivos
Bucket_ClassificationFN                 Falsos Negativos
Bucket_ResetStatistics                  Reiniciar Estatísticas
Bucket_LastReset                        Último Reinício
Bucket_MessagesPerDay                   Média De Mensagens Por Dia
Bucket_CurrentColor                     A cor atual de %s é %s
Bucket_SetColorTo                       Ajustar a cor de %s para %s
Bucket_Maintenance                      Manutenção
Bucket_CreateBucket                     Criar balde com o nome
Bucket_DeleteBucket                     Excluir o balde chamado
Bucket_RenameBucket                     Renomear o balde chamado
Bucket_Lookup                           Procurar
Bucket_LookupMessage                    Procurar por palavra nos baldes
Bucket_LookupMessage2                   Procurar no resultado por
Bucket_LookupMostLikely                 <b>%s</b> é mais provável de aparecer em <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> não aparece em nenhum dos baldes
Bucket_DisabledGlobally                 Desabilitado globalmente
Bucket_To                               para
Bucket_Quarantine                       Mensagem de<br>Quarentena

SingleBucket_Title                      Detalhes para %s
SingleBucket_WordCount                  Contagem de palavras do balde
SingleBucket_TotalWordCount             Contagem total de palavras
SingleBucket_Percentage                 Percentual do total
SingleBucket_WordTable                  Tabela de Palavras para %s
SingleBucket_Message1                   Clique em uma letra no índice para ver a lista de palavras que começam com tal letra.  Clique em qualquer palavra para procurar sua probabilidade para todos os baldes.
SingleBucket_Unique                     %s distinta
SingleBucket_ClearBucket                Remover Todas Palavras

Session_Title                           Sessão do POPFile Expirada
Session_Error                           A sua sessão do POPFile expirou.  Isto pode ter sido causado por iniciar e parar o POPFile mas deixando o navegador web aberto.  Por favor clique em um dos atalhos acima para continuar a usar o POPFile.

View_Title                              Visão de Única Mensagem
View_ShowFrequencies                    Exibir freqüência das palavras
View_ShowProbabilities                  Exibir probabilidade das palavras
View_ShowScores                         Exibir pontuação das palavras e gráfico de decisão
View_WordMatrix                         Matriz de palavras
View_WordProbabilities                  exibindo probabilidade das palavras
View_WordFrequencies                    exibindo freqüência das palavras
View_WordScores                         exibindo pontuação das palavras
View_Chart                              Gráfico de Decisão

Windows_TrayIcon                        Exibir o ícone do POPFile na bandeja do sistema?
Windows_Console                         Executar o POPFile em uma janela de console?
Windows_NextTime                        Esta alteração não terá efeito até que você reinicie o POPFile

Header_MenuSummary                      Esta tabela é o menu de navegação que possibilita acesso a cada uma das diferentes páginas do centro de controle.
History_MainTableSummary                Esta tabela mostra o remetente e o assunto das mensagens recebidas recentemente e permite que elas sejam revisadas e reclassificadas.  Clicar na linha de assunto vai mostrar o texto inteiro da mensagem, juntamente com informação sobre por que ela foi classificada como o foi.  A coluna 'Deveria ser' permite que você especifique a que balde a mensagem pertence, ou desfazer esta mudança.  A coluna 'Remover' permite que você exclua mensagens específicas do histórico se você não precisar mais delas.
History_OpenMessageSummary              Esta tabela contém o texto integral de uma mensagem, com as palavras que são usadas para classificação destacadas de acordo com o balde que foi mais relevante para elas.
Bucket_MainTableSummary                 Esta tabela fornece uma visão geral dos baldes de classificação.  Cada linha mostra o nome do balde, a contagem total de palavras para aquele balde, o número real de palavras individuais em cada balde, se o assunto da mensagem vai ser modificado quando ele for classificado para aquele balde, se as mensagens recebidas naquele balde devem ficar em quarentena, e uma tabela para escolher a cor usada para mostrar qualquer coisa relacionada àquele balde no centro de controle.
Bucket_StatisticsTableSummary           Esta tabela fornece três conjuntos de estatísticas sobre o desempenho geral do PopFile.  A primeira é a exatidão da classificação, a segunda é quantas mensagens foram classificadas, e para quais baldes, e a terceira é quantas palavras existem em cada balde, e as suas porcentagens relativas.
Bucket_MaintenanceTableSummary          Esta tabela contém formulários que permitem que você crie, exclua ou renomeie baldes, e para procurar uma palavra em todos os baldes e ver as suas probabilidades relativas.
Bucket_AccuracyChartSummary             Esta tabela representa graficamente a exatidão da classificação de mensagens.
Bucket_BarChartSummary                  Esta tabela representa graficamente a uma alocação porcentual para cada um dos diferentes baldes.  Ela é usada tanto para o número de mensagens classificadas como para o número total de palavras.
Bucket_LookupResultsSummary             Esta tabela mostra as probabilidades associadas com qualquer palavra específica do corpus.  Para cada balde, ela mostra a freqüência com que cada palavra ocorre, a probabilidade de que ela ocorra naquele balde, e o efeito geral na pontuação do balde se aquela palavra existir em uma mensagem.
Bucket_WordListTableSummary             Esta tabela fornece uma relação de todas as palavras para um balde específico, organizada pela primeira letra comum para cada linha.
Magnet_MainTableSummary                 Esta tabela mostra a lista de ímãs que são usados para classificar automaticamente mensagens de acordo com regras fixas.  Cada linha mostra como o ímã está definido, para qual balde ele foi concebido, e um botão para excluir aquele ímã.
Configuration_MainTableSummary          Esta tabela contém alguns formulários que permitem que você controle a configuração do PopFile.
Configuration_InsertionTableSummary     Esta tabela contém botões para determinar se certas modificações são feitas no cabeçalho ou no assunto da mensagem antes que ela seja encaminhada para o programa cliente de mensagens.
Security_MainTableSummary               Esta tabela fornece conjuntos de controles que afetam a segurança da configuração geral do PopFile, se ele deve procurar automaticamente por atualizações do programa, e se estatísticas sobre o desempenho do PopFile devem ser enviadas ao banco de dados central do autor do programa para informação geral.
Advanced_MainTableSummary               Esta tabela fornece uma lista de palavras que o PopFile ignora quando classifica mensagens por causa da sua freqüência relativa nas mensagens em geral.  Elas são organizadas por linha de acordo com a primeira letra das palavras.
Users_AccountTableSummary               Esta tabela fornece uma lista de contas POP3 que são associadas com o usuário sendo editado.

Imap_Bucket2Folder                      Email para o balde '<b>%s</b>' vai para a pasta
Imap_MapError                           Você não pode mapear mais de um balde para uma única pasta!
Imap_MapUpdated                         Mapeado balde '%s' para pasta '%s'.
Imap_Server                             Nome do servidor IMAP:
Imap_ServerNameError                    Por favor informe o nome do servidor!
Imap_Port                               Porta do servidor IMAP:
Imap_PortError                          Por favor informe um número de porta válido!
Imap_Login                              Conta de login IMAP:
Imap_LoginError                         Por favor informe um nome de usuário/login!
Imap_Password                           Senha para a conta IMAP:
Imap_PasswordError                      Por favor informe uma senha para o servidor!
Imap_ConnectionDetailsUpdated           Os detalhes da conexão IMAP foram atualizados. Por favor atualize a lista de pastas em seguida.
Imap_Expunge                            Expurgar mensagens deletadas de pastas em observação.
Imap_Interval                           Intervalo de atualização em segundos:
Imap_IntervalError                      Por favor informe um intervalo entre 10 e 3600 segundos.
Imap_OptionsUpdated                     As opções IMAP foram atualizadas com sucesso.
Imap_RefreshFolders                     Atualizar a lista de pastas
Imap_Now                                agora!
Imap_UpdateError1                       Não é possível logar. Verifique seu nome de usuário e senha, por favor.
Imap_UpdateError2                       Falha na conexão ao servidor. Por favor verifique o nome e porta do servidor e certifique-se que você está online.
Imap_UpdateError3                       Por favor configure os detalhes da conexão primeiro.
Imap_UpdateOK                           Lida com sucesso a lista de caixas postais/pastas do servidor.
Imap_NoConnectionMessage                Por favor configure os detalhes da conexão primeiro. Depois disto, mais opções estarão disponíveis nesta página.
Imap_WatchMore                          uma pasta para lista de pastas em observação
Imap_WatchedFolderAdded                 Outra pasta foi adicionada à lista de pastas em observação. Por favor escolha a pasta desejada agora.
Imap_WatchedFolder                      Pasta em observação nº
Imap_WatchedFoldersUpdated              Atualizada a lista de pastas em observação
Imap_WatchedFolderRemoved               Removida a pasta '%s' da lista de pastas em observação

Shutdown_Message                        O POPFile foi desligado

Help_Training                           Quando você usa o POPFile pela primeira vez, ele ainda não sabe nada e precisa de treinamento. O POPFile requer treinamento nas mensagens para cada balde, e o treinamento acontece quando você reclassifica para o balde correto uma mensagem que o POPFile classificou incorretamente. Você deve também configurar seu cliente de email para filtrar mensagens baseado na classificação do POPFile. Informação para configurar os filtros no seu cliente de email pode ser encontrado no <a href="http://getpopfile.org/docs/faq/EmailSorting">Projeto de Documentação do POPFile</a>.
Help_Bucket_Setup                       O POPFile requer pelo menos dois baldes além do pseudo-balde "unclassified". O que torna o POPFile único é que ele pode classificar email, mais do que isso, você pode ter qualquer número de baldes. Uma configuração simples poderia ser um balde "spam", "pessoal", e um balde "trabalho".
Help_No_More                            Não mostre isto novamente

# Tooltips used in title attribute of parts of the UI
tip_Menu_History                        Exibir e reclassificar email que o POPFile processou
tip_Menu_Buckets                        Gerenciar baldes e navegar nas estatísticas de classificação
tip_Menu_Magnets                        Gerenciar filtros simples que desviam do sistema de filtragem Bayesiano
tip_Menu_Admin                          Opções de configuraçãoConfiguration options
tip_Menu_Users                          Gerenciamento de usuários
tip_Menu_Advanced                       Configuração avançada

tip_History_RecentNum                   Número de mensagens casando com Procura e Filtro atual
tip_History_Column                      Ordenar por esta coluna
tip_History_Reclassify                  Aplicar correções do balde
tip_History_Search                      Procurar ocorrências no endereço do Remetente ou Assunto
tip_History_Filter                      Limitar a exibição aos ítens do balde selecionado
tip_History_SearchNegate                Inverter ambos Procura e Filtro
tip_History_SearchSubmit                Submeter Procura e Filtro
tip_History_SearchReset                 Limpar Procura e Filtro
tip_History_RemoveAll                   Remover todas mensagens do histórico (casando com Procura e Filtro)
tip_History_RemoveChecked               Remover mensagens selecionados do histórico
tip_History_RemovePage                  Remover mensagens desta página do histórico
tip_History_RemoveColumn                Remover coluna
tip_History_MoveLeft                    Mover para esquerda
tip_History_MoveRight                   Mover para direita
tip_History_Sort                        Clique para ordenar por esta coluna

tip_Bucket_BucketName                   Exibir detalhes do balde
tip_Bucket_Distinct                     Palavras únicas em cada balde
tip_Bucket_SubjectMod                   Inserir o nome do balde no início do assunto. Para clientes que não podem usar o cabeçalho X-Text-Classification
tip_Bucket_XTCHeader                    Inserir um cabeçalho "invisível" que a maioria dos clientes de e-mail podem usar para aplicar uma regra baseada na classificação do POPFile
tip_Bucket_XPLHeader                    Inserir um cabeçalho com um link para a mensagem para permitir a rápida reclassificação de uma mensagem
tip_Bucket_Quarantine                   Isolar e-mail potencialmente perigoso colocando-o em um anexo
tip_Bucket_Color                        Selecionar uma cor para cada balde
tip_Bucket_Lookup                       Procurar a probabilidade e freqüência de uma palavra em cada balde
tip_Bucket_WordCount                    Número e percentual total de palavras em cada balde
tip_Bucket_Create                       Criar um novo balde
tip_Bucket_Delete                       Remover um balde e seu treinamento
tip_Bucket_Rename                       Renomear um balde
tip_Bucket_FalsePos                     Mensagens que foram incorretamente colocadas neste balde
tip_Bucket_FalseNeg                     Mensagens que foram incorretamente NÃO colocadas neste balde

tip_Magnet_Type                         Cabeçalho da mensagem a casar
tip_Magnet_Value                        Texto ou endereço a casar
tip_Magnet_Bucket                       Balde para mandar os casados

tip_Config_Skin                         Alterar o visual do POPFile
tip_Config_Language                     Alterar a linguagem da interface
tip_Config_HistoryColumns               Adicionar colunas para exibir no histórico de mensagens
tip_Config_PageSize                     Número de mensagens para exibir por página
tip_Config_Days                         Número de dias para manter as mensagens no histórico
tip_Config_Purge                        Expurgar mensagens antigas agora
tip_Config_HistoryWidth                 Ajustar o tamanho das colunas do histórico
tip_Config_ColumnIncrease               Aumentar a largura das colunas
tip_Config_ColumnDecrease               Diminuir a largura das colunas
tip_Config_ColumnAuto                   Resetar a largura baseado nas colunas atuais
tip_Config_HideBar                      Esconder a barra de configuração
tip_Config_ShowBar                      Exibir a barra de configuração

tip_Admin_AcceptRemoteHTTP              Permitir o acesso à UI a partir de outra máquina
tip_Admin_AcceptRemotePOP3              Permitir download POP3 a partir de outra máquina
tip_Admin_Password                      Adicionar uma senha para limitar o acesso ao POPFile
tip_Admin_UpdateCheck                   texto 0.22 deveria ser colocado de volta
tip_Admin_ReportStats                   texto 0.22 deveria ser colocado de volta

tip_Users_Remove                        Deletar usuário do POPFile

tip_Footer_HomePage                     Visitar a página do POPFile na Internet
tip_Footer_Manual                       A documentação original do POPFile (levemente defasada)
tip_Footer_Wiki                         Documentação wiki do POPFile
tip_Footer_FAQ                          Perguntas Freqüentemente Feitas sobre o POPFile
tip_Footer_Version                      Número de versão do POPFile
tip_Footer_Login                        Última data e hora acessada por este usuário
tip_Footer_RFE                          Tem uma idéia para melhorar o POPFile? Deixe-nos saber.
tip_Footer_MailingList                  Quer saber sobre as modificações no POPFile? Assine.
tip_Footer_FeedMe                       Gostou do POPFile? Contribua para torná-lo um maior sucesso.

# Jim's Bucket Stats stuff
Words                                   Palavras
Percent                                 Percentual
Header_ConfigurationShort               Configurar
Footer_HomePage_short                   Página na Internet
Footer_QuickStart                       Início Rápido
Footer_WikiShort                        Documentos
Bucket_BreakEmailsClassifiedUpper       Mensagens<br>Classifiadas
Bucket_ClassificationErrorsUpper        Erros de Classificação
Bucket_BreakClassificationFP            Falsos<br>Positivos
Bucket_BreakClassificationFN            Falsos<br>Negativos
Bucket_HitRate                          Taxa<br>Hit
Bucket_StrikeRate                       Taxa<br>Strike
