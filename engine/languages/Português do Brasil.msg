# Copyright (c) 2001-2003 John Graham-Cumming
# Translated by Adriano Rafael Gomes <adrianorg@users.sourceforge.net>
# Updated by Fernando de Alcantara Correia <facorreia@users.sourceforge.net> to v0.19.1
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
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

# Common words that are used on their own all over the interface
Apply                                   Aplicar
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
Classification                          Classificação
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

# The header and footer that appear on every UI page
Header_Title                            Centro de Controle do POPFile
Header_Shutdown                         Desligar o POPFile
Header_History                          Histórico
Header_Buckets                          Baldes
Header_Configuration                    Configuração
Header_Advanced                         Avançado
Header_Security                         Segurança
Header_Magnets                          Ímãs

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Manual
Footer_Forums                           Forums
Footer_FeedMe                           Contribua
Footer_RequestFeature                   Pedir uma Característica
Footer_MailingList                      Lista de Email

Configuration_Error1                    O caracter separador deve ser um único caracter
Configuration_Error2                    O porta da interface de usuário deve ser um número entre 1 e 65535
Configuration_Error3                    A porta de escuta POP3 deve ser um número entre 1 e 65535
Configuration_Error4                    O tamanho da página deve ser um número entre 1 e 1000
Configuration_Error5                    O número de dias no histórico deve ser um número entre 1 e 366
Configuration_Error6                    O tempo limite TCP deve ser um número entre 10 e 300
Configuration_Error7                    A porta de escuta XML-RPC deve ser um número entre 1 e 65535
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
Configuration_History                   Número de mensagens por página
Configuration_HistoryUpdate             Alterado o número de mensagens por página para %s
Configuration_Days                      Número de dias para manter no histórico
Configuration_DaysUpdate                Alterado o número de dias para manter no histórico para %s
Configuration_UserInterface             Interface de Usuário
Configuration_Skins                     Skins
Configuration_SkinsChoose               Escolha o skin
Configuration_Language                  Linguagem
Configuration_LanguageChoose            Escolha a linguagem
Configuration_ListenPorts               Opções de Módulo
Configuration_HistoryView               Exibir Histórico
Configuration_TCPTimeout                Tempo Limite de Conexão
Configuration_TCPTimeoutSecs            Tempo limite de conexão em segundos
Configuration_TCPTimeoutUpdate          Alterado o tempo limite de conexão para %s
Configuration_ClassificationInsertion   Inserção de Texto na Mensagem
Configuration_SubjectLine               Modificação de linha de assunto
Configuration_XTCInsertion              Cabeçalho X-Text-Classification
Configuration_XPLInsertion              Cabeçalho X-POPFile-Link
Configuration_Logging                   Logging
Configuration_None                      Nada
Configuration_ToScreen                  Na Tela
Configuration_ToFile                    Em Arquivo
Configuration_ToScreenFile              Na Tela e em Arquivo
Configuration_LoggerOutput              Saída do Logger
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins
Configuration_CurrentLogFile            &lt;arquivo de log atual&gt;

Advanced_Error1                         '%s' já está na lista de Palavras Ignoradas
Advanced_Error2                         Palavras ignoradas podem somente conter caracteres alfanuméricos, ., _, -, ou @
Advanced_Error3                         '%s' adicionado na lista de Palavras Ignoradas
Advanced_Error4                         '%s' não está na lista de Palavras Ignoradas
Advanced_Error5                         '%s' removido da lista de Palavras Ignoradas
Advanced_StopWords                      Palavras Ignoradas
Advanced_Message1                       O POPFile ignora as seguintes palavras freqüentemente usadas:
Advanced_AddWord                        Adicionar palavra
Advanced_RemoveWord                     Remover palavra
Advanced_AllParameters                  Todos os Parâmetros do POPFile
Advanced_Parameter                      Parâmetro
Advanced_Value                          Valor
Advanced_Warning                        Esta é a lista completa dos parâmetros do POPFile.  Somente para usuários avançados: você pode alterar qualquer um e clicar em Alterar; não há verificação de validade.

History_Filter                          &nbsp;(apenas mostrando o balde <font color="%s">%s</font>)
History_FilterBy                        Filtrar Por
History_Search                          &nbsp;(procurado por remetente/assunto %s)
History_Title                           Mensagens Recentes
History_Jump                            Ir para a mensagem
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
History_Remove                          Para remover entradas do histórico clique
History_SearchMessage                   Procurar Remetente/Assunto
History_NoMessages                      Nenhuma mensagem
History_ShowMagnet                      magnetizado
History_ShowNoMagnet                    desmagnetizado
History_Magnet                          &nbsp;(mostrando apenas mensagens classificadas por ímã)
History_NoMagnet                        &nbsp;(mostrando apenas mensagens não classificadas por ímã)
History_ResetSearch                     Limpar

Password_Title                          Senha
Password_Enter                          Digite a senha
Password_Go                             Ir!
Password_Error1                         Senha incorreta

Security_Error1                         A porta deve ser um número entre 1 e 65535
Security_Stealth                        Modo Stealth/Operação Servidor
Security_NoStealthMode                  Não (Modo Stealth)
Security_ExplainStats                   (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: bc (o número total de baldes que você tem), mc (o número total de mensagens que o POPFile classificou) e ec (o número total de erros de classificação).  Isto fica guardado em um arquivo e eu vou usar para publicar algumas estatísticas sobre como as pessoas usam o POPFile e o quão bem ele funciona.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as estatístcas e os endereços IP de cada um.)
Security_ExplainUpdate                  (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: ma (o número maior da versão do seu POPFile), mi (o número menor da versão do seu POPFile) e bn (o número do build da sua versão do POPFile). O POPFile recebe uma resposta na forma de um gráfico que aparece no topo da página se uma nova versão estiver disponível.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as verificações de versão e os endereços IP de cada um.)
Security_PasswordTitle                  Senha da Interface de Usuário
Security_Password                       Senha
Security_PasswordUpdate                 Alterada a senha para %s
Security_AUTHTitle                      Servidores Remotos
Security_SecureServer                   Servidor POP3 SPA/AUTH
Security_SecureServerUpdate             Alterado o servidor seguro POP3 SPA/AUTH para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SecurePort                     Porta POP3 SPA/AUTH
Security_SecurePortUpdate               Alterada a porta POP3 SPA/AUTH para %s; esta alteração não terá efeito até que você reinicie o POPFile
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
Magnet_Explanation                      Estes tipos de ímã estão disponíveis:</b> <ul><li><b>Endereço ou nome do remetente:</b> Por exemplo: fulano@empresa.com para pegar um endereço específico, <br />empresa.com para pegar todo mundo que envia de empresa.com, <br />Fulano de Tal para pegar uma pessoa específica, Fulano para pegar todos os Fulanos.</li><li><b>Endereço ou nome de destinatário/cópia:</b> Como um ímã de remetente mas para o endereço Para:/Cc: de uma mensagem.</li> <li><b>Palavras no assunto:</b> Por exemplo: olá para pegar todas as mensagens com olá no assunto.</li></ul>
Magnet_MagnetType                       Tipo do ímã
Magnet_Value                            Valor
Magnet_Always                           Sempre vai para o balde
Magnet_Jump                             Ir para a página de ímãs

Bucket_Error1                           Nomes de balde somente podem conter as letras de a até z minúsculas, números de 0 a 9, mais - e _
Bucket_Error2                           O balde %s já existe
Bucket_Error3                           Criado o balde %s
Bucket_Error4                           Por favor digite uma palavra que não seja em branco
Bucket_Error5                           Renomeado o balde %s para %s
Bucket_Error6                           Excluído o balde %s
Bucket_Title                            Sumário
Bucket_BucketName                       Nome do Balde
Bucket_WordCount                        Contagem de Palavras
Bucket_WordCounts                       Contagens de Palavras
Bucket_UniqueWords                      Palavras Únicas
Bucket_SubjectModification              Modificação do Assunto
Bucket_ChangeColor                      Trocar Cor
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
Bucket_Quarantine                       Quarentena

SingleBucket_Title                      Detalhes para %s
SingleBucket_WordCount                  Contagem de palavras do balde
SingleBucket_TotalWordCount             Contagem total de palavras
SingleBucket_Percentage                 Percentual do total
SingleBucket_WordTable                  Tabela de Palavras para %s
SingleBucket_Message1                   Clique em uma letra no índice para ver a lista de palavras que começam com tal letra.  Clique em qualquer palavra para procurar sua probabilidade para todos os baldes.
SingleBucket_Unique                     %s únicas
SingleBucket_ClearBucket                Remover Todas Palavras

Session_Title                           Sessão do POPFile Expirada
Session_Error                           A sua sessão do POPFile expirou.  Isto pode ter sido causado por iniciar e parar o POPFile mas deixando o navegador web aberto.  Por favor clique em um dos atalhos acima para continuar a usar o POPFile.

View_Title                              Visão de Única Mensagem
View_ShowFrequencies                    Exibir freqüência das palavras
View_ShowProbabilities                  Exibir probabilidade das palavras
View_ShowScores                         Exibir pontuação das palavras
View_WordMatrix                         Matriz de palavras

Windows_TrayIcon                        Exibir o ícone do POPFile na bandeja do sistema?
Windows_Console                         Enviar mensagens do POPFile para uma janela de console?
Windows_NextTime                        <p><font color="red">Esta alteração não terá efeito até que você reinicie o POPFile</font>

Header_MenuSummary                      Esta tabela é o menu de navegação que possibilita acesso a cada uma das diferentes páginas do centro de controle.
History_MainTableSummary                Esta tabela mostra o remetente e o assunto das mensagens recebidas recentemente e permite que elas sejam revisadas e reclassificadas.  Clicar na linha de assunto vai mostrar o texto inteiro da mensagem, juntamente com informação sobre por que ela foi classificada como o foi.  A coluna 'Deveria ser' permite que você especifique a que balde a mensagem pertence, ou desfazer esta mudança.  A coluna 'Remover' permite que você exclua mensagens específicas do histórico se você não precisar mais delas.
History_OpenMessageSummary              Esta tabela contém o texto integral de uma mensagem, com as palavras que são usadas para classificação destacadas de acordo com o balde que foi mais relevante para elas.
Bucket_MainTableSummary                 Esta tabela fornece uma visão geral dos baldes de classificação.  Cada linha mostra o nome do balde, a contagem total de palavras para aquele balde, o número real de palavras individuais em cada balde, se o assunto da mensagem vai ser modificado quando ele for classificado para aquele balde, se as mensagens recebidas naquele balde devem ficar em quarentena, e uma tabela para escolher a cor usada para mostrar qualquer coisa relacionada àquele balde no centro de controle.
Bucket_StatisticsTableSummary           Esta tabela fornece três conjuntos de estatísticas sobre o desempenho geral do PopFile.  A primeira é a exatidão da classificação, a segunda é quantas mensagens foram classificadas, e para quais baldes, e a terceira é quantas palavras existem em cada balde, e as suas porcentagens relativas.
Bucket_MaintenanceTableSummary          Esta tabela contém formulários que permitem que você crie, exclua ou renomeie baldes, e para procurar uma palavra em todos os baldes e ver as suas probabilidades relativas.
Bucket_AccuracyChartSummary             Esta tabela representa graficamente a exatidão da classificação de mensagens.
Bucket_BarChartSummary                  Esta tabela representa graficamente a uma alocação porcentual para cada um dos diferentes baldes.  Ela é usada tanto para o número de mensagens classificadas como para o número total de palavras.
Bucket_LookupResultsSummary             Esta tabela mostra as probabilidades associadas com qualquer palavra específica do corpus.  Para cada balde, ela mostra a freqüência com que aquela palavra ocorre, a probabilidade de que ela ocorra naquele balde, e o efeito geral na pontuação do balde se aquela palavra existir em uma mensagem.
Bucket_WordListTableSummary             Esta tabela fornece uma relação de todas as palavras para um balde específico, organizada pela primeira letra comum para cada linha.
Magnet_MainTableSummary                 Esta tabela mostra a lista de ímãs que são usados para classificar automaticamente mensagens de acordo com regras fixas.  Cada linha mostra como o ímã está definido, para qual balde ele foi concebido, e um botão para excluir aquele ímã.
Configuration_MainTableSummary          Esta tabela contém alguns formulários que permitem que você controle a configuração do PopFile.
Configuration_InsertionTableSummary     Esta tabela contém botões para determinar se certas modificações são feitas no cabeçalho ou no assunto da mensagem antes que ela seja encaminhada para o programa cliente de mensagens.
Security_MainTableSummary               Esta tabela fornece conjuntos de controles que afetam a segurança da configuração geral do PopFile, se ele deve procurar automaticamente por atualizações do programa, e se estatísticas sobre o desempenho do PopFile devem ser enviadas ao banco de dados central do autor do programa para informação geral.
Advanced_MainTableSummary               Esta tabela fornece uma lista de palavras que o PopFile ignora quando classifica mensagens por causa da sua freqüência relativa nas mensagens em geral.  Elas são organizadas por linha de acordo com a primeira letra das palavras.
