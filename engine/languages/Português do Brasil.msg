# Copyright (c) 2001-2003 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCode                            br
LanguageCharset                         ISO-8859-1

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
Classification                          Classificação
Reclassify                              Reclassificar
Undo                                    Desfazer
Close                                   Fechar
Find                                    Procurar
Filter                                  Filtrar
Yes                                     Sim
No                                      Não
ChangeToYes                             Trocar para Sim
ChangeToNo                              Trocar para Não
Bucket                                  Bucket
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

# The header and footer that appear on every UI page
Header_Title                            Centro de Controle do POPFile
Header_Shutdown                         Desligar
Header_History                          Histórico
Header_Buckets                          Buckets
Header_Configuration                    Configuração
Header_Advanced                         Avançado
Header_Security                         Segurança
Header_Magnets                          Ímãs

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Manual
Footer_Forums                           Forums
Footer_FeedMe                           Me Mantenha!
Footer_RequestFeature                   Pedir uma Característica
Footer_MailingList                      Lista de Email

Configuration_Error1                    O caracter separador deve ser um único caracter
Configuration_Error2                    O porta da interface de usuário deve ser um número entre 1 e 65535
Configuration_Error3                    A porta de escuta POP3 deve ser um número entre 1 e 65535
Configuration_Error4                    O tamanho da página deve ser um número entre 1 e 1000
Configuration_Error5                    O número de dias no histórico deve ser um número entre 1 e 366
Configuration_Error6                    O tempo limite TCP deve ser um número entre 10 e 300
Configuration_POP3Port                  Porta de escuta POP3
Configuration_POP3Update                Alterada a porta para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_Separator                 Caracter separador
Configuration_SepUpdate                 Alterado o separador para %s
Configuration_UI                        Porta da interface web de usuário
Configuration_UIUpdate                  Alterada a porta da interface web de usuário para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_History                   Número de emails por página
Configuration_HistoryUpdate             Alterado o número de emails por página para %s
Configuration_Days                      Número de dias para manter no histórico
Configuration_DaysUpdate                Alterado o número de dias para manter no histórico para %s
Configuration_UserInterface             Interface de Usuário
Configuration_Skins                     Skins
Configuration_SkinsChoose               Escolha o skin
Configuration_Language                  Linguagem
Configuration_LanguageChoose            Escolha a linguagem
Configuration_ListenPorts               Portas de Escuta
Configuration_HistoryView               Exibir Histórico
Configuration_TCPTimeout                Tempo Limite de Conexão TCP
Configuration_TCPTimeoutSecs            Tempo limite de conexão TCP em segundos
Configuration_TCPTimeoutUpdate          Alterado o tempo limite de conexão TCP para %s
Configuration_ClassificationInsertion   Inserção de Classificação
Configuration_SubjectLine               Modificação de linha de assunto
Configuration_XTCInsertion              Inserção de X-Text-Classification
Configuration_XPLInsertion              Inserção de X-POPFile-Link
Configuration_Logging                   Logging
Configuration_None                      Nada
Configuration_ToScreen                  Na Tela
Configuration_ToFile                    Em Arquivo
Configuration_ToScreenFile              Na Tela e em Arquivo
Configuration_LoggerOutput              Saída do Logger
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' já está na lista de palavras ignoradas
Advanced_Error2                         Palavras ignoradas podem somente conter caracteres alfanuméricos, ., _, -, ou @
Advanced_Error3                         '%s' adicionado na lista de palavras ignoradas
Advanced_Error4                         '%s' não estã na lista de palavras ignoradas
Advanced_Error5                         '%s' removido da lista de palavras ignoradas
Advanced_StopWords                      Palavras Ignoradas
Advanced_Message1                       As seguintes palavras são ignoradas de todas as classificações porque ocorrem muito freqüentemente.
Advanced_AddWord                        Adicionar palavra
Advanced_RemoveWord                     Remover palavra

History_Filter                          &nbsp;(apenas mostrando o bucket <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(procurado pelo assunto %s)
History_Title                           Mensagens Recentes
History_Jump                            Ir para a mensagem
History_ShowAll                         Exibir Tudo
History_ShouldBe                        Deveria ser
History_NoFrom                          sem linha de
History_NoSubject                       sem linha de assunto
History_ClassifyAs                      Classificar como
History_MagnetUsed                      Ímã usado
History_ChangedTo                       Alterado para <font color="%s">%s
History_Already                         Já reclassificado como <font color="%s">%s</font>
History_RemoveAll                       Remover Tudo
History_RemovePage                      Remover a Página
History_Remove                          Para remover entradas do histórico clique
History_SearchMessage                   Procurar Assunto
History_NoMessages                      Nenhuma mensagem
History_ShowMagnet                      Magnetizado
History_Magnet                          &nbsp;(apenas mostrando mensagens classificadas por ímã)

Password_Title                          Senha
Password_Enter                          Digite a senha
Password_Go                             Ir!
Password_Error1                         Senha incorreta

Security_Error1                         A porta segura deve ser um número entre 1 e 65535
Security_Stealth                        Modo Stealth/Operação Servidor
Security_NoStealthMode                  Não (Modo Stealth)
Security_ExplainStats                   (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: bc (o número total de buckets que você tem), mc (o número total de mensagens que o POPFile classificou) e ec (o número total de erros de classificação).  Isto fica guardado em um arquivo e eu vou usar para publicar algumas estatísticas sobre como as pessoas usam o POPFile e o quão bem ele funciona.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as estatístcas e os endereços IP de cada um.)
Security_ExplainUpdate                  (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: ma (o número maior da versão do seu POPFile), mi (o número menor da versão do seu POPFile) e bn (o número do build da sua versão do POPFile). O POPFile recebe uma resposta na forma de um gráfico que aparece no topo da página se uma nova versão estiver disponível.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as verificações de versão e os endereços IP de cada um.)
Security_PasswordTitle                  Senha da Interface de Usuário
Security_Password                       Senha
Security_PasswordUpdate                 Alterada a senha para %s
Security_AUTHTitle                      Autenticação Segura de Senha/AUTH
Security_SecureServer                   Servidor Seguro
Security_SecureServerUpdate             Alterado o servidor seguro para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SecurePort                     Porta segura
Security_SecurePortUpdate               Alterada a porta para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_POP3                           Aceitar conexões POP3 de máquinas remotas
Security_UI                             Aceitar conexões HTTP (Interface de Usuário) de máquinas remotas
Security_UpdateTitle                    Verificação Automática de Atualização
Security_Update                         Verificar diariamente atualizações para o POPFile
Security_StatsTitle                     Reportar Estatísticas
Security_Stats                          Enviar estatísticas para o John diariamente

Magnet_Error1                           Ímã '%s' já existe no bucket '%s'
Magnet_Error2                           O novo ímã '%s' conflita com o ímã '%s' no bucket '%s' e pode causar resultados ambíguos.  O novo ímã não foi adicionado.
Magnet_Error3                           Criar novo ímã '%s' no bucket '%s'
Magnet_CurrentMagnets                   Ímãs Atuais
Magnet_Message1                         Os seguintes ímãs fazem os emails serem sempre classificados no bucket especificado.
Magnet_CreateNew                        Criar Novo Ímã
Magnet_Explanation                      Três tipos de ímã estão disponíveis: <ul><li>De um endereço ou nome:</b> Por exemplo: adriano@companhia.com para pegar um endereço específico, <br />companhia.com para pegar todo mundo que manda email de companhia.com, <br />Adriano Gomes para pegar uma pessoa específica, Adriano para pegar todos os Adrianos.</li><li><b>Para um endereço ou nome:</b> Como um ímã De: mas para o endereço Para: de um email.</li><li><b>Palavras no assunto:</b> Por exemplo: olá para pegar todas as mensagens com olá no assunto.</li></ul>
Magnet_MagnetType                       Tipo do ímã
Magnet_Value                            Valor
Magnet_Always                           Sempre vai para o bucket

Bucket_Error1                           Nomes de buckets somente podem conter as letras de a até z minúsculas mais - e _
Bucket_Error2                           O bucket %s já existe
Bucket_Error3                           Criado o bucket %s
Bucket_Error4                           Por favor digite uma palavra que não seja em branco
Bucket_Error5                           Renomeado o bucket %s para %s
Bucket_Error6                           Deletado o bucket %s
Bucket_Title                            Sumário
Bucket_BucketName                       Nome do Bucket
Bucket_WordCount                        Contagem de Palavras
Bucket_WordCounts                       Contagens de Palavras
Bucket_UniqueWords                      Palavras Únicas
Bucket_SubjectModification              Modificação do Assunto
Bucket_ChangeColor                      Trocar Cor
Bucket_NotEnoughData                    Dados insuficientes
Bucket_ClassificationAccuracy           Precisão da Classificação
Bucket_EmailsClassified                 Emails classificados
Bucket_EmailsClassifiedUpper            Emails Classificados
Bucket_ClassificationErrors             Erros de classificação
Bucket_Accuracy                         Precisão
Bucket_ClassificationCount              Contagem da Classificação
Bucket_ResetStatistics                  Reiniciar Estatísticas
Bucket_LastReset                        Último Reinício
Bucket_CurrentColor                     A cor atual de %s é %s
Bucket_SetColorTo                       Ajustar a cor de %s para %s
Bucket_Maintenance                      Manutenção
Bucket_CreateBucket                     Criar bucket com o nome
Bucket_DeleteBucket                     Excluir o bucket chamado
Bucket_RenameBucket                     Renomear o bucket chamado
Bucket_Lookup                           Procurar
Bucket_LookupMessage                    Procurar por palavra nos buckets
Bucket_LookupMessage2                   Procurar no resultado por
Bucket_LookupMostLikely                 <b>%s</b> é mais provável de aparecer em <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> não aparece em nenhum dos buckets
Bucket_DisabledGlobally                 Desabilitado globalmente
Bucket_To                               para
Bucket_Quarantine                       Quarentena

SingleBucket_Title                      Detalhes para %s
SingleBucket_WordCount                  Contagem de palavras do bucket
SingleBucket_TotalWordCount             Contagem total de palavras
SingleBucket_Percentage                 Percentual do total
SingleBucket_WordTable                  Tabela de Palavras para %s
SingleBucket_Message1                   Palavras com asterico (*) foram usadas para classificação durante esta sessão do POPFile.  Clique em qualquer palavra para procurar sua probabilidade para todos os buckets.
SingleBucket_Unique                     %s únicas

Header_MenuSummary                      Esta tabela é o menu de navegação que possibilita acesso a cada uma das diferentes páginas do centro de controle.
History_MainTableSummary                Esta tabela mostra o remetente e o assunto das mensagens recebidas recentemente e permite que elas sejam revisadas e reclassificadas.  Clicar na linha de assunto vai mostrar o texto inteiro da mensagem, juntamente com informação sobre por que ela foi classificada como o foi.  A coluna 'Deveria ser' permite que você especifique a que bucket a mensagem pertence, ou desfazer esta mudança.  A coluna 'Remover' permite que você exclua mensagens específicas do histórico se você não precisar mais delas.
History_OpenMessageSummary              Esta tabela contém o texto integral de uma mensagem, com as palavras que são usadas para classificação destacadas de acordo com o bucket que foi mais relevante para elas. 
Bucket_MainTableSummary                 Esta tabela fornece uma visão geral dos buckets de classificação.  Cada linha mostra o nome do bucket, a contagem total de palavras para aquele bucket, o número real de palavras individuais em cada bucket, se o assunto do email vai ser modificado quando ele for classificado para aquele bucket, se as mensagens recebidas naquele bucket devem ficar em quarentena, e uma tabela para escolher a cor usada para mostrar qualquer coisa relacionada àquele bucket no centro de controle.
Bucket_StatisticsTableSummary           Esta tabela fornece três conjuntos de estatísticas sobre o desempenho geral do PopFile.  A primeira é a exatidão da classificação, a segunda é quantos emails foram classificados, e para quais buckets, e a terceira é quantas palavras existem em cada bucket, e as suas porcentagens relativas.
Bucket_MaintenanceTableSummary          Esta tabela contém formulários que permitem que você crie, exclua ou renomeie buckets, e para procurar uma palavra em todos os buckets e ver as suas probabilidades relativas.
Bucket_AccuracyChartSummary             Esta tabela representa graficamente a exatidão da classificação de email.
Bucket_BarChartSummary                  Esta tabela representa graficamente a uma alocação porcentual para cada um dos diferentes buckets.  Ela é usada tanto para o número de emails classificados como para o número total de palavras.
Bucket_LookupResultsSummary             Esta tabela mostra as probabilidades associadas com qualquer palavra específica do corpus.  Para cada bucket, ela mostra a freqüência com que aquela palavra ocorre, a probabilidade de que ela ocorra naquele bucket, e o efeito geral na pontuação do bucket se aquela palavra existir em um email.
Bucket_WordListTableSummary             Esta tabela fornece uma relação de todas as palavras para um bucket específico, organizada pela primeira letra comum para cada linha.
Magnet_MainTableSummary                 Esta tabela mostra a lista de ímãs que são usados para classificar automaticamente mensagens de acordo com regras fixas.  Cada linha mostra como o ímã está definido, para qual bucket ele foi concebido, e um botão para excluir aquele ímã.
Configuration_MainTableSummary          Esta tabela contém alguns formulários que permitem que você controle a configuração do PopFile.
Configuration_InsertionTableSummary     Esta tabela contém botões para determinar se certas modificações são feitas no cabeçalho ou no assunto da mensagem antes que ela seja encaminhada para o programa cliente de email.
Security_MainTableSummary               Esta tabela fornece conjuntos de controles que afetam a segurança da configuração geral do PopFile, se ele deve procurar automaticamente por atualizações do programa, e se estatísticas sobre o desempenho do PopFile devem ser enviadas ao banco de dados central do autor do programa para informação geral.
Advanced_MainTableSummary               Esta tabela fornece uma lista de palavras que o PopFile ignora quando classifica mensagens por causa da sua freqüência relativa nos emails em geral.  Elas são organizadas por linha de acordo com a primeira letra das palavras.

