#--------------------------------------------------------------------------
# PortugueseBR-pfi.nsh
#
# This file contains the "PortugueseBR" text strings used by the Windows installer
# for POPFile (includes customised versions of strings provided by NSIS and
# strings which are unique to POPFile).
#
# These strings are grouped according to the page/window where they are used
#
# Copyright (c) 2001-2004 John Graham-Cumming
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
#--------------------------------------------------------------------------
#
# Translation created by: Adriano Rafael Gomes <adrianorg@users.sourceforge.net>
# Translation updated by: Adriano Rafael Gomes <adrianorg@users.sourceforge.net>
#
#--------------------------------------------------------------------------
# String Formatting (applies to PFI_LANG_*_MB* text used for message boxes):
#
#   (1) The sequence  $\r$\n        inserts a newline
#   (2) The sequence  $\r$\n$\r\$n  inserts a blank line
#
# (the 'PFI_LANG_CBP_MBCONTERR_2' message box string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------
# String Formatting (applies to PFI_LANG_*_IO_ text used for custom pages):
#
#   (1) The sequence  \r\n      inserts a newline
#   (2) The sequence  \r\n\r\n  inserts a blank line
#
# (the 'PFI_LANG_CBP_IO_INTRO' custom page string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
# Mark the start of the language data
#--------------------------------------------------------------------------

!define PFI_LANG  "PORTUGUESEBR"

#==========================================================================
# Customised versions of strings used on standard MUI pages
#==========================================================================

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by the main POPFile installer (main script: installer.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the main POPFile installer)
#
# The sequence \r\n\r\n inserts a blank line (note that the PFI_LANG_WELCOME_INFO_TEXT string
# should end with a \r\n\r\n$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "Este assistente te guiará durante a instalação do POPFile.\r\n\r\nÉ recomendado que você feche todas as outras aplicações antes de iniciar a Instalação.\r\n\r\n$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "NOTA IMPORTANTE:\r\n\r\nO usuário corrente NÃO tem direitos de 'Administrador'.\r\n\r\nSe suporte a multi-usuário é requerido, é recomendado que você cancele esta instalação e use uma conta de 'Administrador' para instalar o POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the main POPFile installer)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "Escolha o Local de Instalação dos Arquivos de Programa"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "Pasta de Destino para o Programa POPFile"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the main POPFile installer)
#
# The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "Interface de Usuário do POPFile"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Monitor Corpus Conversion' utility (main script: MonitorCC.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Monitor Corpus Conversion' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        "Conversão do Corpus do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "O corpus existente deve ser convertido para funcionar com esta versão do POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "Completada a Conversão do Corpus do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "Clique em Fechar para continuar"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "A Conversão do Corpus do POPFile Falhou"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "Clique em Cancelar para continuar"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Add POPFile User' wizard (main script: adduser.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the 'Add POPFile User' wizard)
#
# The sequence \r\n\r\n inserts a blank line (note that the PFI_LANG_ADDUSER_INFO_TEXT string
# should end with a \r\n\r\n$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "Este assistente vai guiar você pela configuração do POPFile para o usuário '$G_WINUSERNAME'.\r\n\r\nÉ recomendado que você feche todas as outras aplicações antes de continuar.\r\n\r\n$_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "Escolha o Local dos Dados do POPFile para '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "Escolha a pasta para guardar os Dados do POPFile para '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "Esta versão do POPFile usa conjuntos de arquivos de dados separados para cada usuário.$\r$\n$\r$\nO Instalador vai usar a seguinte pasta para os dados do POPFile pertencentes ao usuário'$G_WINUSERNAME'. Para usar uma pasta diferente para este usuário, clique em Procurar e selecione uma outra pasta. $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "Pasta a ser usada para guardar os dados do POPFile para '$G_WINUSERNAME'"

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "Configurando o POPFile para o usuário '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "Por favor espere enquanto os arquivos de configuração do POPFile são atualizados para este usuário"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO "O POPFile foi configurado para o usuário '$G_WINUSERNAME'.\r\n\r\nClique em Finalizar para fechar este assistente."

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "Desinstalar dados do POPFile para o usuário '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "Remover dados de configuração do POPFile para este usuário do seu computador"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "Os dados de configuração do POPFile para o usuário '$G_WINUSERNAME' serão desinstalados da seguinte pasta. $_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "Desinstalando dados do POPFile para o usuário '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "Por favor espere enquanto os arquivos de configuração do POPFile para este usuário são deletados"


#==========================================================================
# Strings used for custom pages, message boxes and banners
#==========================================================================

#--------------------------------------------------------------------------
# General purpose banner text (also suitable for page titles/subtitles)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_1     "Espere por favor."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_2     "Isto pode levar alguns segundos..."

#--------------------------------------------------------------------------
# Message displayed when 'Add User' does not seem to be part of the current version
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "Erro: Não foi encontrada uma versão compatível de ${C_PFI_PRODUCT}!"

#--------------------------------------------------------------------------
# Message displayed when installer exits because another copy is running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "Uma outra cópia do instalador do POPFile já está rodando!"

#--------------------------------------------------------------------------
# Message box warning that a previous installation has been found
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "Instalação anterior encontrada em"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "Você quer atualizá-la?"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "Dados de configuração anteriores encontrados em"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "Exibir as Notas de Liberação do POPFile ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "É recomendado responder Sim se você estiver atualizando o POPFile (pode ser necessário você fazer uma cópia de segurança ANTES de atualizar)"

#--------------------------------------------------------------------------
# Custom Page - Check Perl Requirements
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "Detectados Componentes do Sistema Desatualizados"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_1    "O browser padrão é usado para exibir a Interface de Usuário do POPFile (seu centro de controle).\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_2    "O POPFile não requer um browser específico, ele funcionará com praticamente qualquer browser.\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_3    "Uma versão mínima do Perl está para ser instalada (o POPFile é escrito em Perl).\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_4    "O Perl fornecido com o POPFile faz uso de alguns componentes do Internet Explorer e requer o Internet Explorer 5.5 (ou uma versão mais atual)."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_5    "O instalador detectou que este sistema tem o Internet Explorer"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_6    "É possível que algumas características do POPFile não funcionem corretamente neste sistema.\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_7    "Se você tiver algum problema com o POPFile, uma atualização para uma versão mais nova do Internet Explorer pode ajudar."

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               "Instala os arquivos principais necessários para o POPFile, incluindo uma versão mínima do Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                 "Instala skins do POPFile que permitem a você trocar a aparência da interface de usuário do POPFile."
!insertmacro PFI_LANG_STRING DESC_SecLangs                 "Instala versões da interface de usuário em outras línguas."
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                "Instala o módulo XMLRPC do POPFile (para acessar a API do POPFile) e o suporte do Perl requerido."

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE        "Opções de Instalação do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE     "Não altere estas opções a menos que você precise realmente mudá-las"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3      "Escolha a porta padrão para conexões POP3 (recomendado 110)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI       "Escolha a porta padrão para conexões da 'Interface de Usuário' (recomendado 8080)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP   "Executar o POPFile automaticamente quando o Windows iniciar"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING   "AVISO IMPORTANTE"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE   "SE ESTIVER ATUALIZANDO O POPFILE --- O INSTALADOR VAI DESLIGAR A VERSÃO EXISTENTE"

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1     "A porta POP3 não pode ser definida"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2     "A porta deve ser um número entre 1 e 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3     "Por favor altere sua seleção de porta POP3."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1      "A porta 'Interface de Usuário' não pode ser definida"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2      "A porta deve ser um número entre 1 e 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3      "Por favor altere sua seleção de porta para 'Interface de Usuário'."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "A porta POP3 deve ser diferente da porta 'Interface de Usuário'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "Por favor altere sua seleção de portas."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    "Verificando se esta é uma instalação para atualização..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       "Instalando os arquivos principais do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       "Instalando os arquivos mínimos do Perl..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "Criando os atalhos do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "Fazendo o backup do corpus. Isto pode levar alguns segundos..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      "Instalando os arquivos de skins do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      "Instalando os arquivos de línguas do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     "Instalando os arquivos XMLRPC do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "Clique em Avançar para continuar"

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_1           "Desligando a versão anterior do POPFile usando a porta"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1           "encontrado arquivo de uma instalação anterior."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2           "Atualizar este arquivo ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3           "Clique 'Sim' para atualizar (o arquivo antigo será salvo como"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4           "Clique 'Não' para manter o arquivo antigo (o arquivo novo será salvo como"

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "Impossível desligar o POPFile automaticamente."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "Por favor desligue o POPFile manualmente agora."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "Quando o POPFile tiver sido desligado, clique 'OK' para continuar."

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           "Erro detectado quando o instalador tentou fazer o backup do corpus antigo."

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE            "Criação de Balde de Classificação do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE         "O POPFile precisa PELO MENOS DOIS baldes para poder classificar seus emails"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO         "Depois da instalação, o POPFile torna fácil alterar o número de baldes (e seus nomes) para satisfazer suas necessidades.\r\n\r\nOs nomes dos baldes devem ser palavras únicas, usando letras minúsculas, dígitos de 0 a 9, hífens e sublinhados."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE        "Crie um novo balde selecionando um nome da lista abaixo ou digitando um nome de sua escolha."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE        "Para deletar um ou mais baldes da lista, marque a(s) caixa(s) 'Remover' relevante(s) e clique no botão 'Continuar'."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR       "Baldes a serem usados pelo POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE        "Remover"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE      "Continuar"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1         "Não é necessário adicionar mais nenhum balde"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2         "Você deve definir PELO MENOS DOIS baldes"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3         "Pelo menos mais um balde é requerido"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4         "O instalador não pode criar mais que"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5         "baldes"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1       "Um balde chamado"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2       "já foi definido."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3       "Por favor escolha um nome diferente para o novo balde."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1       "O instalador pode somente criar até"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2       "baldes."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3       "Uma vez que o POPFile tenha sido instalado, você poderá criar mais que"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1       "O nome"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2       "não é um nome válido para um balde."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3       "Nomes de balde somente podem conter as letras de a até z minúsculas, números de 0 a 9, mais - e _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4       "Por favor escolha um nome diferente para o novo balde."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "O POPFile requer PELO MENOS DOIS baldes para poder classificar seus emails."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "Por favor entre o nome de um balde para ser criado,$\r$\n$\r$\nescolhendo um nome sugerido da lista$\r$\n$\r$\nou digitando um nome de sua escolha."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "Você deve definir PELO MENOS DOIS baldes antes de continuar sua instalação do POPFile."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1         "baldes foram definidos para uso do POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2         "Você quer configurar o POPFile para usar estes baldes ?"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3         "Clique 'Não' se você quer alterar sua seleção de baldes."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1       "O instalador não foi capaz de criar"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2       "de"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3       "baldes que você selecionou."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4       "Uma vez que o POPFile tenha sido instalado, você pode usar seu painél de controle$\r$\n$\r$\n na 'Interface de Usuário' para criar o(s) balde(s) que faltar(em)."

#--------------------------------------------------------------------------
# Custom Page - Email Client Reconfiguration
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "Configuração do Cliente de Email"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "O POPFile pode reconfigurar vários clientes de email para você"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "Clientes de email marcados (*) podem ser reconfigurados automaticamente, assumindo que contas simples sejam usadas.\r\n\r\nÉ altamente recomendado que contas que requeiram autenticação sejam configuradas manualmente."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "IMPORTANTE: POR FAVOR FECHE OS CLIENTES DE EMAIL RECONFIGURÁVEIS AGORA\r\n\r\nEsta característica ainda está em desenvolvimento (algumas contas do Outlook podem não serem detectadas).\r\n\r\nPor favor verifique se a reconfiguração foi bem sucedida (antes de usar o cliente de email)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    "Reconfiguração do cliente de email cancelada pelo usuário"

#--------------------------------------------------------------------------
# Text used on buttons to skip configuration of email clients
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   "Pular Todos"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   "Pular Cliente"

#--------------------------------------------------------------------------
# Message box warnings that an email client is still running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         "AVISO: o Outlook Express parece estar rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         "AVISO: o Outlook parece estar rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         "AVISO: o Eudora parece estar rodando!"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "Por favor FECHE o programa de email e clique 'Repetir' para reconfigurá-lo"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(Você pode clicar 'Ignorar' para reconfigurá-lo, mas isto não é recomendado)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "Clique 'Anular' para pular a reconfiguração deste programa de email"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "Por favor FECHE o programa de email e clique 'Repetir' para restaurar a configuração"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(Você pode clicar 'Ignorar' para restaurar a configuração, mas isto não é recomendado)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "Clique 'Anular' para pular a restauração da configuração original"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook/Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_TITLE         "Reconfigurar o Outlook Express"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_SUBTITLE      "O POPFile pode reconfigurar o Outlook Express para você"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_TITLE         "Reconfigurar o Outlook"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_SUBTITLE      "O POPFile pode reconfigurar o Outlook para você"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_IO_CANCELLED  "Reconfiguração do Outlook Express cancelada pelo usuário"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_IO_CANCELLED  "Reconfiguração do Outlook cancelada pelo usuário"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_BOXHDR     "contas"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_ACCOUNTHDR "Conta"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_EMAILHDR   "Endereço de Email"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_SERVERHDR  "Servidor"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_USRNAMEHDR "Nome do Usuário"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_FOOTNOTE   "Marque a(s) caixa(s) para reconfigurar a(s) conta(s).\r\nSe você desinstalar o POPFile as configurações originais serão restauradas."

; Message Box to confirm changes to Outlook/Outlook Express account configuration

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBIDENTITY    "Identidade Outlook Express:"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBACCOUNT     "Conta Outlook Express:"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBIDENTITY    "Usuário Outlook:"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBACCOUNT     "Conta Outlook:"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBEMAIL       "Endereço de email:"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBSERVER      "Servidor POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBUSERNAME    "Nome de usuário POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOEPORT      "Porta POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOLDVALUE    "correntemente"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBQUESTION    "Reconfigurar esta conta para funcionar com o POPFile ?"

; Title and Column headings for report/log files

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_LOG_BEFORE    "Configuração do Outlook Express antes de qualquer alteração ser feita"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_LOG_AFTER     "Alterações feitas na Configuração do Outlook Express"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_LOG_BEFORE    "Configuração do Outlook antes de qualquer alteração ser feita"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_LOG_AFTER     "Alterações feitas na Configuração do Outlook"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_END       "(fim)"

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_LOG_IDENTITY  "'IDENTIDADE'"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_LOG_IDENTITY  "'USUÁRIO OUTLOOK'"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_ACCOUNT   "'CONTA'"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_EMAIL     "'ENDEREÇO DE EMAIL'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_SERVER    "'SERVIDOR POP3'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_USER      "'NOME DE USUÁRIO POP3'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_PORT      "'PORTA POP3'"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_NEWSERVER "'NOVO SERVIDOR POP3'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_NEWUSER   "'NOVO NOME DE USUÁRIO POP3'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_NEWPORT   "'NOVA PORTA POP3'"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Eudora
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE          "Reconfigurar o Eudora"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE       "O POPFile pode reconfigurar o Eudora para você"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED   "Reconfiguração do Eudora cancelada pelo usuário"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1     "O POPFile detectou a seguinte personalidade do Eudora"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2     " e pode automaticamente configurá-la para funcionar com o POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX    "Reconfigurar esta personalidade para funcionar com o POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT    "Personalidade <dominante>"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA     "personalidade"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL       "Endereço de email:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER      "Servidor POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME    "Nome de usuário POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT    "Porta POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE     "Se você desinstalar o POPFile as configurações originais serão restauradas"

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE         "O POPFile pode ser iniciado agora"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE      "A Interface de Usuário do POPFile somente funciona se o POPFile tiver sido iniciado"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO      "Iniciar o POPFile agora ?"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO         "Não (a 'Interface de Usuário' não pode ser usada se o POPFile não for iniciado)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX     "Executar o POPFile (em uma janela)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND    "Executar o POPFile em segundo plano (nenhuma janela é exibida)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1     "Uma vez que o POPFile tenha sido iniciado, você pode exibir a 'Interface de Usuário'"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2     "(a) dando um duplo-clique no ícone do POPFile na bandeja do sistema,   OU"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3     "(b) usando Iniciar --> Programas --> POPFile --> Interface de Usuário do POPFile."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1      "Preparando para iniciar o POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2      "Isto pode levar alguns segundos..."

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Corpus Conversion Monitor' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "Uma outra cópia do 'Monitor de Conversão do Corpus' já está rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "O 'Monitor de Conversão do Corpus' é parte do instalador do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "Erro: o arquivo de dados da conversão do Corpus não existe!"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "Erro: falta o caminho do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "Erro: Impossível setar uma variável de ambiente"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOKAKASI     "Erro: falta o caminho do Kakasi"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "Ocorreu um erro ao iniciar o processo de conversão do corpus"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "Ocorreu um erro fatal durante o processo de conversão do corpus!"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "Tempo restante estimado: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "minutos"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(esperando pelo primeiro arquivo a ser convertido)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "Existem $G_BUCKET_COUNT arquivos de balde para serem convertidos"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "Depois de $G_ELAPSED_TIME.$G_DECPLACES minutos existem $G_STILL_TO_DO arquivos para converter"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "Depois de $G_ELAPSED_TIME.$G_DECPLACES minutos existe um arquivo para converter"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "A Conversão do Corpus levou $G_ELAPSED_TIME.$G_DECPLACES minutos"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_1        "Desligando o POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_2        "Deletando entradas no 'Menu Iniciar' para o POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_3        "Deletando arquivos principais do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_4        "Restaurando configurações do Outlook Express..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_5        "Deletando arquivos de skins do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_6        "Deletando arquivos mínimos do Perl..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_7        "Restaurando configurações do Outlook..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_8        "Restaurando configurações do Eudora..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_1             "Desligando o POPFile usando a porta"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_2             "Aberto"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_3             "Restaurado"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_4             "Fechado"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_5             "Removendo todos os arquivos da pasta do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_6             "Nota: impossível remover todos os arquivos da pasta do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_7             "Problemas nos dados"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_8             "Removendo todos os arquivos do diretório 'User Data' do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_9             "Nota: impossível remover todos os arquivos do diretório 'User Data' do POPFile"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "'$G_WINUSERNAME' está tentando remover dados pertencentes a outro usuário"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "Não parece que o POPFile esteja instalado nesta pasta"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "Continuar mesmo assim (não recomendado) ?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "Desinstalação cancelada pelo usuário"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "Problema no 'Outlook Express'!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "Problema no 'Outlook'!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "Problema no 'Eudora'!"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "Não foi possível restaurar toda a configuração original"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "Exibir o relatório de erros?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "Algumas configurações do cliente de email não foram restauradas!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Detalhes podem ser encontrados na pasta $INSTDIR )"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "Clique em 'Não' para ignorar estes erros e deletar tudo"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "Clique em 'Sim' para manter estes dados (para tentar outra vez mais tarde)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "Você quer remover todos os arquivos da sua pasta do POPFile ?$\r$\n$\r$\n(Se você tiver qualquer coisa que você criou e quer manter, clique Não)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "Você quer remover todos os arquivos do seu diretório 'User Data' do POPFile?$\r$\n$\r$\n(Se você tiver qualquer coisa que você criou e quer manter, clique em Não)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_1        "Nota"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_2        "não pode ser removido."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'PortugueseBR-pfi.nsh'
#--------------------------------------------------------------------------
