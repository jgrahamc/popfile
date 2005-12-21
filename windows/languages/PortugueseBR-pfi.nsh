#--------------------------------------------------------------------------
# PortugueseBR-pfi.nsh
#
# This file contains the "PortugueseBR" text strings used by the Windows installer
# and other NSIS-based Windows utilities for POPFile (includes customised versions
# of strings provided by NSIS and strings which are unique to POPFile).
#
# These strings are grouped according to the page/window and script where they are used
#
# Copyright (c) 2003-2005 John Graham-Cumming
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
#--------------------------------------------------------------------------
#
# Translation created by: Adriano Rafael Gomes <adrianorg@users.sourceforge.net>
# Translation updated by: Adriano Rafael Gomes <adrianorg@users.sourceforge.net>
#
#--------------------------------------------------------------------------
# String Formatting (applies to PFI_LANG_*_MB* text used for message boxes):
#
#   (1) The sequence  ${MB_NL}          inserts a newline
#   (2) The sequence  ${MB_NL}${MB_NL}  inserts a blank line
#
# (the 'PFI_LANG_CBP_MBCONTERR_2' message box string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------
# String Formatting (applies to PFI_LANG_*_IO_ text used for custom pages):
#
#   (1) The sequence  ${IO_NL}          inserts a newline
#   (2) The sequence  ${IO_NL}${IO_NL}  inserts a blank line
#
# (the 'PFI_LANG_CBP_IO_INTRO' custom page string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------
# Some strings will be customised at run-time using data held in Global User Variables.
# These variables will have names which start with '$G_', e.g. $G_PLS_FIELD_1
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
# Mark the start of the language data
#--------------------------------------------------------------------------

!define PFI_LANG  "PORTUGUESEBR"

#--------------------------------------------------------------------------
# Symbols used to avoid confusion over where the line breaks occur.
# (normally these symbols will be defined before this file is 'included')
#
# ${IO_NL} is used for InstallOptions-style 'new line' sequences.
# ${MB_NL} is used for MessageBox-style 'new line' sequences.
#--------------------------------------------------------------------------

!ifndef IO_NL
  !define IO_NL     "\r\n"
!endif

!ifndef MB_NL
  !define MB_NL     "$\r$\n"
!endif

###########################################################################
###########################################################################

#--------------------------------------------------------------------------
# CONTENTS:
#
#   "General Purpose" strings
#
#   "Shared" strings used by more than one script
#
#   "POPFile Installer" strings used by the main POPFile installer/uninstaller (installer.nsi)
#
#   "SSL Setup" strings used by the standalone "SSL Setup" wizard (addssl.nsi)
#
#   "Get SSL" strings used when downloading/installing SSL support (getssl.nsh)
#
#   "Add User" strings used by the 'Add POPFile User' installer/uninstaller (adduser.nsi)
#
#   "Corpus Conversion" strings used by the 'Monitor Corpus Conversion' utility (MonitorCC.nsi)
#
#--------------------------------------------------------------------------

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; General Purpose:  (used for banners and page titles/subtitles in several scripts)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_BE_PATIENT           "Espere por favor."
!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_A_FEW_SECONDS   "Isto pode levar alguns segundos..."

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message displayed when wizard does not seem to belong to the current installation [adduser.nsi, runpopfile.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "Erro: Não foi encontrada uma versão compatível de ${C_PFI_PRODUCT}!"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown (before the WELCOME page) if another installer is running [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "Uma outra cópia do instalador do POPFile já está rodando!"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if 'SetEnvironmentVariableA' fails [installer.nsi, adduser.nsi, MonitorCC.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "Erro: Impossível setar uma variável de ambiente"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Standard MUI Page - DIRECTORY
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Used in message box shown if SFN support has been disabled [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBNOSFN    "Para instalar no drive '$G_PLS_FIELD_1'${MB_NL}${MB_NL}por favor selecione uma pasta que não tenha espaços no nome"

; Used in message box shown if existing files found when installing [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "Você quer atualizá-la?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Standard MUI Page - INSTFILES
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; When upgrading an existing installation, change the normal "Install" button to "Upgrade" [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_UPGRADE     "Atualizar"

; Installation Progress Reports displayed above the progress bar [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    "Verificando se esta é uma instalação para atualização..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "Criando os atalhos do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      "Instalando os arquivos de línguas do POPFile..."

; Installation Progress Reports displayed above the progress bar [installer.nsi, adduser.nsh, getssl.nsh]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "Clique em Avançar para continuar"

; Progress Reports displayed above the progress bar when downloading/installing SSL support [addssl.nsi, getssl.nsh]

!insertmacro PFI_LANG_STRING PFI_LANG_PROG_CHECKIFRUNNING  "Verificando se o POPFile está rodando..."

; Installation Log Messages [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_SHUTDOWN    "Desligando a versão anterior do POPFile usando a porta"

; Installation Log Messages [installer.nsi, addssl.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_PROG_SAVELOG         "Salvando o arquivo de log da instalação..."

; Message Box text strings [installer.nsi, adduser.nsi, pfi-library.nsh]

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "Impossível desligar o $G_PLS_FIELD_1 automaticamente."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "Por favor desligue o $G_PLS_FIELD_1 manualmente agora."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "Quando o $G_PLS_FIELD_1 tiver sido desligado, clique 'OK' para continuar."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if problem detected when trying to save the log file [installer.nsi, addssl.nsi, backup.nsi, restore.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MB_SAVELOG_ERROR     "Erro: detectado um problema ao salvar o arquivo de log"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message boxes shown if uninstallation is not straightforward [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "'$G_WINUSERNAME' está tentando remover dados pertencentes a outro usuário"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "Não parece que o POPFile esteja instalado nesta pasta"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "Continuar mesmo assim (não recomendado) ?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if uninstaller is cancelled by the user [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "Desinstalação cancelada pelo usuário"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Standard MUI Page - UNPAGE_INSTFILES [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHUTDOWN     "Desligando o POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHORT        "Deletando entradas no 'Menu Iniciar' para o POPFile..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if uninstaller failed to remove files/folders [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; TempTranslationNote: PFI_LANG_UN_MBREMERR_A = PFI_LANG_UN_MBREMERR_1 + ": $G_PLS_FIELD_1 " + PFI_LANG_UN_MBREMERR_2

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_A        "Nota: $G_PLS_FIELD_1 não pode ser removido."

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Message box shown (before the WELCOME page) offering to display the release notes [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "Exibir as Notas de Liberação do POPFile ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "É recomendado responder Sim se você estiver atualizando o POPFile (pode ser necessário você fazer uma cópia de segurança ANTES de atualizar)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - WELCOME [installer.nsi]
;
; The PFI_LANG_WELCOME_INFO_TEXT string should end with a '${IO_NL}${IO_NL}$_CLICK' sequence).
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "Este assistente te guiará durante a instalação do POPFile.${IO_NL}${IO_NL}É recomendado que você feche todas as outras aplicações antes de iniciar a Instalação.${IO_NL}${IO_NL}$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "NOTA IMPORTANTE:${IO_NL}${IO_NL}O usuário corrente NÃO tem direitos de 'Administrador'.${IO_NL}${IO_NL}Se suporte a multi-usuário é requerido, é recomendado que você cancele esta instalação e use uma conta de 'Administrador' para instalar o POPFile."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Custom Page - Check Perl Requirements [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title displayed in the page header (there is no sub-title for this page)

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "Detectados Componentes do Sistema Desatualizados"

; Text strings displayed on the custom page

; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_A =  PFI_LANG_PERLREQ_IO_TEXT_1
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_B =  PFI_LANG_PERLREQ_IO_TEXT_2
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_C =  PFI_LANG_PERLREQ_IO_TEXT_3
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_D =  PFI_LANG_PERLREQ_IO_TEXT_4
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_E =  PFI_LANG_PERLREQ_IO_TEXT_5 + " $G_PLS_FIELD_1${IO_NL}${IO_NL}"
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_F =  PFI_LANG_PERLREQ_IO_TEXT_6
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_G =  PFI_LANG_PERLREQ_IO_TEXT_7

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_A    "O browser padrão é usado para exibir a Interface de Usuário do POPFile (seu centro de controle).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_B    "O POPFile não requer um browser específico, ele funcionará com praticamente qualquer browser.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_C    "Uma versão mínima do Perl está para ser instalada (o POPFile é escrito em Perl).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_D    "O Perl fornecido com o POPFile faz uso de alguns componentes do Internet Explorer e requer o Internet Explorer 5.5 (ou uma versão mais atual)."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_E    "O instalador detectou que este sistema tem o Internet Explorer $G_PLS_FIELD_1${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_F    "É possível que algumas características do POPFile não funcionem corretamente neste sistema.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_G    "Se você tiver algum problema com o POPFile, uma atualização para uma versão mais nova do Internet Explorer pode ajudar."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - COMPONENTS [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               "Instala os arquivos principais necessários para o POPFile, incluindo uma versão mínima do Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                 "Instala skins do POPFile que permitem a você trocar a aparência da interface de usuário do POPFile."
!insertmacro PFI_LANG_STRING DESC_SecLangs                 "Instala versões da interface de usuário em outras línguas."

!insertmacro PFI_LANG_STRING DESC_SubSecOptional           "Componentes extra do POPFile (para usuários avançados)"
!insertmacro PFI_LANG_STRING DESC_SecIMAP                  "Instala o módulo IMAP do POPFile"
!insertmacro PFI_LANG_STRING DESC_SecNNTP                  "Instala o proxy NNTP do POPFile"
!insertmacro PFI_LANG_STRING DESC_SecSMTP                  "Instala o proxy SMTP do POPFile"
!insertmacro PFI_LANG_STRING DESC_SecSOCKS                 "Instala componentes extras do Perl que permitem aos proxies do POPFile usar SOCKS"
!insertmacro PFI_LANG_STRING DESC_SecSSL                   "Baixa e instala os componentes do Perl e bibliotecas SSL que permitem ao POPFile se conectar a servidores de e-mail"
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                "Instala o módulo XMLRPC do POPFile (para acessar a API do POPFile) e o suporte do Perl requerido."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - DIRECTORY (for POPFile program files) [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title shown in the page header and Text shown above the box showing the folder selected for the installation

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "Escolha o Local de Instalação dos Arquivos de Programa"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "Pasta de Destino para o Programa POPFile"

; Message box warnings used when verifying the installation folder chosen by user

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "Instalação anterior encontrada em"

; Text strings used when user has NOT selected a component found in the existing installation

!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_1            "Você quer atualizar o componente $G_PLS_FIELD_1 existente?"
!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_2            "(usar componentes desatualizados do POPFile pode causar problemas)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Custom Page - Setup Summary [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header
; $G_WINUSERNAME holds the Windows login name and $G_WINUSERTYPE holds 'Admin', 'Power', 'User', 'Guest' or 'Unknown'

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_TITLE        "Sumário da Configuração para '$G_WINUSERNAME' ($G_WINUSERTYPE)"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SUBTITLE     "Estas configurações serão usadas para instalar o POPFile"

; Display selected installation location and whether or not an upgrade will be performed
; $G_ROOTDIR holds the installation location, e.g. C:\Program Files\POPFile

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_NEWLOCN      "Nova instalação do POPFile em $G_PLS_FIELD_2"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_UPGRADELOCN  "Atualização da instalação existente do POPFile em $G_PLS_FIELD_2"

; By default all of these components are installed (but Kakasi is only installed when Japanese/Nihongo language is chosen)

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_BASICLIST    "Componentes básicos do POPFile a serem instalados:"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_POPFILECORE  "Arquivos do programa POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_MINPERL      "Perl Mínimo"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_DEFAULTSKIN  "Tema Padrão"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_DEFAULTLANG  "Linguagem Padrão"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_EXTRASKINS   "Temas Adicionais"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_EXTRALANGS   "Linguagens Adicionais"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_KAKASI       "Pacote Kakasi"

; By default none of the optional components is installed (user has to select them)

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_OPTIONLIST   "Componentes opcionais do POPFile a serem instalados:"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_NONE         "(nenhum)"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_IMAP         "Módulo IMAP"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_NNTP         "Proxy NNTP"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SMTP         "Proxy SMTP"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SOCKS        "Suporte a SOCKS"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SSL          "Suporte a SSL"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_XMLRPC       "Módulo XMLRPC"

; The last line in the summary explains how to change the installation selections

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_BACKBUTTON   "Para fazer alterações, use o botão 'Voltar' para retornar para as páginas anteriores"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - INSTFILES [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header after installing all the files

!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_TITLE     "Arquivos de Programa Instalados"
!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_SUBTITLE  "${C_PFI_PRODUCT} deve ser configurado antes de ser usado"

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       "Instalando os arquivos principais do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       "Instalando os arquivos mínimos do Perl..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      "Instalando os arquivos de skins do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     "Instalando os arquivos XMLRPC do POPFile..."

; Message box used to get permission to delete the old minimal Perl before installing the new one

!insertmacro PFI_LANG_STRING PFI_LANG_MINPERL_MBREMOLD     "Deletar tudo na pasta antiga do Perl mínimo antes de instalar a nova versão?${MB_NL}${MB_NL}($G_PLS_FIELD_1)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - UNPAGE_INSTFILES [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CORE         "Deletando arquivos principais do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SKINS        "Deletando arquivos de skins do POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_PERL         "Deletando arquivos mínimos do Perl..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_SHUTDOWN      "Desligando o POPFile usando a porta"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTDIR    "Removendo todos os arquivos da pasta do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTERR    "Nota: impossível remover todos os arquivos da pasta do POPFile"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "Você quer remover todos os arquivos da sua pasta do POPFile ?${MB_NL}${MB_NL}$G_ROOTDIR${MB_NL}${MB_NL}(Se você tiver qualquer coisa que você criou e quer manter, clique Não)"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - WELCOME
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_WELCOME_TITLE        "Bem-vindo ao Assistente $(^NameDA)"
!insertmacro PFI_LANG_STRING PSS_LANG_WELCOME_TEXT         "Este utilitário vai baixar e instalar os arquivos necessários para permitir que o POPFile use SSL ao acessar servidores de e-mail.${IO_NL}${IO_NL}Esta versão não configura nenhuma conta para usar SSL, ela apenas instala os componentes do Perl e DLLs necessárias.${IO_NL}${IO_NL}Este produto baixa e instala software desenvolvido pelo Projeto OpenSSL para uso no Toolkit OpenSSL (http://www.openssl.org/)${IO_NL}${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}${IO_NL}   POR FAVOR DESLIGUE O POPFILE AGORA${IO_NL}${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}$_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - LICENSE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_LICENSE_SUBHDR       "Por favor leia os termos da licensa antes de usar $(^NameDA)."
!insertmacro PFI_LANG_STRING PSS_LANG_LICENSE_BOTTOM       "Se você aceita os termos do acordo, clique o check box abaixo. Você deve aceitar o acordo para usar $(^NameDA). $_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - DIRECTORY
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_TITLE       "Escolha a instalação existente do POPFile 0.22 (ou posterior)"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_SUBTITLE    "Suporte a SSL deve ser adicionado somente a uma instalação existente do POPFile"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_TEXT_TOP    "Suporte a SSL deve ser instalado usando a mesma pasta onde está instalado o programa POPFile${MB_NL}${MB_NL}Este utilitário vai adicionar suporte a SSL à versão do POPFile que está instalado na seguinte pasta. Para instalar em uma instalação diferente do POPFile, clique em Procurar e selecione outra pasta. $_CLICK"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_TEXT_DESTN  "Pasta de instalação do POPFile 0.22 (ou posterior) existente"

!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_MB_WARN_1   "O POPFile 0.22 (ou posterior) parece NÃO estar instalado em ${MB_NL}${MB_NL}$G_PLS_FIELD_1"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_MB_WARN_2   "Você tem certeza de que quer usar esta pasta?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - INSTFILES
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Initial page header

!insertmacro PFI_LANG_STRING PSS_LANG_STD_HDR              "Instalando suporte a SSL (para o POPFile 0.22 ou porterior)"
!insertmacro PFI_LANG_STRING PSS_LANG_STD_SUBHDR           "Por favor espere enquanto os arquivos do SSL são baixados e instalados..."

; Successful completion page header

!insertmacro PFI_LANG_STRING PSS_LANG_END_HDR              "Instalação do suporte a SSL no POPFile completa"
!insertmacro PFI_LANG_STRING PSS_LANG_END_SUBHDR           "Suporte a SSL no POPFile instalado com sucesso"

; Unsuccessful completion page header

!insertmacro PFI_LANG_STRING PSS_LANG_ABORT_HDR            "A instalação do suporte a SSL no POPFile falhou"
!insertmacro PFI_LANG_STRING PSS_LANG_ABORT_SUBHDR         "A tentativa de adicionar suporte a SSL no POPFile falhou"

; Progress reports

!insertmacro PFI_LANG_STRING PSS_LANG_PROG_INITIALISE      "Inicializando..."
!insertmacro PFI_LANG_STRING PSS_LANG_PROG_CHECKIFRUNNING  "Verificando se o POPFile está rodando..."
!insertmacro PFI_LANG_STRING PSS_LANG_PROG_USERCANCELLED   "Instalação do suporte a SSL no POPFile cancelada pelo usuário"
!insertmacro PFI_LANG_STRING PSS_LANG_PROG_SUCCESS         "Instalado suporte a SSL no POPFile"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - FINISH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_FINISH_TITLE         "Completando o Assistente $(^NameDA)"
!insertmacro PFI_LANG_STRING PSS_LANG_FINISH_TEXT          "Suporte a SSL para o POPFile foi instalado.${IO_NL}${IO_NL}Você pode iniciar o POPFile agora e configurar o POPFile e seu cliente de e-mail para usar SSL.${IO_NL}${IO_NL}Clique Finalizar para fechar este assistente."

!insertmacro PFI_LANG_STRING PSS_LANG_FINISH_README        "Informação importante"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Miscellaneous Strings
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_MUTEX                "Outra copia do assistente de Configuração SSL está rodando!"

!insertmacro PFI_LANG_STRING PSS_LANG_COMPAT_NOTFOUND      "Aviso: Não encontrada versão compatível do POPFile !"

!insertmacro PFI_LANG_STRING PSS_LANG_ABORT_WARNING        "Tem certeza que você quer sair do Assistente $(^NameDA)?"

!insertmacro PFI_LANG_STRING PSS_LANG_PREPAREPATCH         "Atualizando Module.pm (para evitar downloads SSL com baixa velocidade)"
!insertmacro PFI_LANG_STRING PSS_LANG_PATCHSTATUS          "Estado do patch do Module.pm: $G_PLS_FIELD_1"
!insertmacro PFI_LANG_STRING PSS_LANG_PATCHCOMPLETED       "O arquivo Module.pm foi atualizado"
!insertmacro PFI_LANG_STRING PSS_LANG_PATCHFAILED          "O arquivo Module.pm não foi atualizado"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Get SSL: Strings used when downloading and installing the optional SSL files [getssl.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Progress reports

!insertmacro PFI_LANG_STRING PFI_LANG_PROG_CHECKINTERNET   "Verificando conexão à Internet..."
!insertmacro PFI_LANG_STRING PFI_LANG_PROG_STARTDOWNLOAD   "Baixando arquivo $G_PLS_FIELD_1 de $G_PLS_FIELD_2"
!insertmacro PFI_LANG_STRING PFI_LANG_PROG_FILECOPY        "Copiando $G_PLS_FIELD_2 arquivos..."
!insertmacro PFI_LANG_STRING PFI_LANG_PROG_FILEEXTRACT     "Extraindo arquivos do pacote $G_PLS_FIELD_2..."

!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_SEVERAL_SECONDS "(isto pode levar vários segundos)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Get SSL: Message Box strings used when installing SSL Support [getssl.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MB_INTERNETCONNECT   "Os arquivos para Suporte SSL serão baixados da Internet${MB_NL}${MB_NL}Por favor conecte na Internet e clique 'OK'${MB_NL}${MB_NL}ou clique 'Cancelar' para cancelar esta parte da instalação"

!insertmacro PFI_LANG_STRING PFI_LANG_MB_NSISDLFAIL_1      "O download do arquivo $G_PLS_FIELD_1 falhou"
!insertmacro PFI_LANG_STRING PFI_LANG_MB_NSISDLFAIL_2      "(erro: $G_PLS_FIELD_2)"

!insertmacro PFI_LANG_STRING PFI_LANG_MB_UNPACKFAIL        "Erro detectado durante a instalação de arquivos na pasta $G_PLS_FIELD_1"

!insertmacro PFI_LANG_STRING PFI_LANG_MB_REPEATSSL         "Impossível instalar os arquivos SSL opcionais!${MB_NL}${MB_NL}Para tentar novamente mais tarde, execute o comando${MB_NL}${MB_NL}$G_PLS_FIELD_1 /SSL"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Get SSL: NSISdl strings (displayed by the plugin which downloads the SSL files) [getssl.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; The NSISdl plugin shows two progress bars, for example:
;
;     Downloading libeay32.dll
;
;     118kB (14%) of 816kB @ 3.1kB/s (3 minutes remaining)
;
; The default strings used by the plugin:
;
;   downloading - "Downloading %s"
;   connecting  - "Connecting ..."
;   second      - "second"
;   minute      - "minute"
;   hour        - "hour"
;   plural      - "s"
;   progress    - "%dkB (%d%%) of %dkB @ %d.%01dkB/s"
;   remaining   - " (%d %s%s remaining)"
;
; Note that the "remaining" string starts with a space
;
; Some languages might not be translated properly because plurals are formed simply
; by adding the "plural" value, so "hours" is translated by adding the value of the
; "PFI_LANG_NSISDL_PLURAL" string to the value of the "PFI_LANG_NSISDL_HOUR" string.
; This is a limitation of the NSIS plugin which is used to download the files.
;
; If this is a problem, the plural forms could be used for the PFI_LANG_NSISDL_SECOND,
; PFI_LANG_NSISDL_MINUTE and PFI_LANG_NSISDL_HOUR strings and the PFI_LANG_NSISDL_PLURAL
; string set to a space (" ") [using "" here will generate compiler warnings]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_DOWNLOADING   "Baixando %s"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_CONNECTING    "Conectando..."
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_SECOND        "segundo"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_MINUTE        "minuto"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_HOUR          "hora"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_PLURAL        "s"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_PROGRESS      "%dkB (%d%%) de %dkB @ %d.%01dkB/s"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_REMAINING     " (%d %s%s faltando)"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - WELCOME [adduser.nsi]
;
; The PFI_LANG_ADDUSER_INFO_TEXT string should end with a '${IO_NL}${IO_NL}$_CLICK' sequence).
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "Este assistente vai guiar você pela configuração do POPFile para o usuário '$G_WINUSERNAME'.${IO_NL}${IO_NL}É recomendado que você feche todas as outras aplicações antes de continuar.${IO_NL}${IO_NL}$_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - DIRECTORY [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the wizard

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "Escolha o Local dos Dados do POPFile para '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "Escolha a pasta para guardar os Dados do POPFile para '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "Esta versão do POPFile usa conjuntos de arquivos de dados separados para cada usuário.${MB_NL}${MB_NL}O Instalador vai usar a seguinte pasta para os dados do POPFile pertencentes ao usuário'$G_WINUSERNAME'. Para usar uma pasta diferente para este usuário, clique em Procurar e selecione uma outra pasta. $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "Pasta a ser usada para guardar os dados do POPFile para '$G_WINUSERNAME'"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - INSTFILES [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "Configurando o POPFile para o usuário '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "Por favor espere enquanto os arquivos de configuração do POPFile são atualizados para este usuário"

; When resetting POPFile to use newly restored 'User Data', change "Install" button to "Restore"

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_RESTORE     "Restaurar"

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "Fazendo o backup do corpus. Isto pode levar alguns segundos..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SQLBACKUP  "Fazendo cópia de segurança da base de dados SQLite antiga..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FINDCORPUS "Procurando por corpus existente em arquivo plano ou BerkeleyDB..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_MAKEBAT    "Gerando o arquivo batch 'pfi-run.bat'..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_REGSET     "Atualizando configurações no registro e variáveis de ambiente..."

; Message Box text strings

; TempTranslationNote: PFI_LANG_MBSTPWDS_A = "POPFile 'stopwords' " + PFI_LANG_MBSTPWDS_1
; TempTranslationNote: PFI_LANG_MBSTPWDS_B = PFI_LANG_MBSTPWDS_2
; TempTranslationNote: PFI_LANG_MBSTPWDS_C = PFI_LANG_MBSTPWDS_3 + " 'stopwords.bak')"
; TempTranslationNote: PFI_LANG_MBSTPWDS_D = PFI_LANG_MBSTPWDS_4 + " 'stopwords.default')"

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_A           "POPFile 'stopwords' encontrado arquivo de uma instalação anterior."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_B           "Atualizar este arquivo ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_C           "Clique 'Sim' para atualizar (o arquivo antigo será salvo como 'stopwords.bak')"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_D           "Clique 'Não' para manter o arquivo antigo (o arquivo novo será salvo como 'stopwords.default')"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           "Erro detectado quando o instalador tentou fazer o backup do corpus antigo."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Message box warnings used when verifying the installation folder chosen by user [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "Dados de configuração anteriores encontrados em"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_4   "Encontrados dados de configuração restaurados"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_5   "Você quer usar os dados restaurados?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile Installation Options [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_A = PFI_LANG_OPTIONS_MBPOP3_1 + " '$G_POP3'."
; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_B = PFI_LANG_OPTIONS_MBPOP3_2
; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_C = PFI_LANG_OPTIONS_MBPOP3_3

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_A     "A porta POP3 não pode ser definida '$G_POP3'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_B     "A porta deve ser um número entre 1 e 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_C     "Por favor altere sua seleção de porta POP3."

; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_A = PFI_LANG_OPTIONS_MBGUI_1 + " '$G_GUI'."
; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_B = PFI_LANG_OPTIONS_MBGUI_2
; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_C = PFI_LANG_OPTIONS_MBGUI_3

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_A      "A porta 'Interface de Usuário' não pode ser definida '$G_GUI'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_B      "A porta deve ser um número entre 1 e 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_C      "Por favor altere sua seleção de porta para 'Interface de Usuário'."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "A porta POP3 deve ser diferente da porta 'Interface de Usuário'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "Por favor altere sua seleção de portas."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Initialization required by POPFile Classification Bucket Creation [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; POPFile requires at least TWO buckets in order to work properly. PFI_LANG_CBP_DEFAULT_BUCKETS
; defines the default buckets and PFI_LANG_CBP_SUGGESTED_NAMES defines a list of suggested names
; to help the user get started with POPFile. Both lists use the | character as a name separator.

; Bucket names can only use the characters abcdefghijklmnopqrstuvwxyz_-0123456789
; (any names which contain invalid characters will be ignored by the installer)

; Empty lists ("") are allowed (but are not very user-friendly)

; The PFI_LANG_CBP_SUGGESTED_NAMES string uses alphabetic order for the suggested names.
; If these names are translated, the translated names can be rearranged to put them back
; into alphabetic order. For example, the Portuguese (Brazil) translation of this string
; starts "admin|admin-lista|..." (which is "admin|list-admin|..." in English)

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_DEFAULT_BUCKETS  "spam|pessoal|trabalho|outros"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUGGESTED_NAMES  "admin|admin-lista|compras|computadores|entrada|escola|familia|financeiro|geral|lixo|miscelanea|nao_spam|negocios|outros|passa-tempo|pessoal|recreacao|seguranca|spam|trabalho|viagem"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile Classification Bucket Creation [CBP.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE            "Criação de Balde de Classificação do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE         "O POPFile precisa PELO MENOS DOIS baldes para poder classificar seus emails"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO         "Depois da instalação, o POPFile torna fácil alterar o número de baldes (e seus nomes) para satisfazer suas necessidades.${IO_NL}${IO_NL}Os nomes dos baldes devem ser palavras únicas, usando letras minúsculas, dígitos de 0 a 9, hífens e sublinhados."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE        "Crie um novo balde selecionando um nome da lista abaixo ou digitando um nome de sua escolha."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE        "Para deletar um ou mais baldes da lista, marque a(s) caixa(s) 'Remover' relevante(s) e clique no botão 'Continuar'."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR       "Baldes a serem usados pelo POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE        "Remover"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE      "Continuar"

; Text strings used for status messages under the bucket list

; TempTranslationNote: PFI_LANG_CBP_IO_MSG_A = PFI_LANG_CBP_IO_MSG_1
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_B = PFI_LANG_CBP_IO_MSG_2
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_C = PFI_LANG_CBP_IO_MSG_3
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_D = PFI_LANG_CBP_IO_MSG_4 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_IO_MSG_5

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_A         "Não é necessário adicionar mais nenhum balde"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_B         "Você deve definir PELO MENOS DOIS baldes"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_C         "Pelo menos mais um balde é requerido"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_D         "O instalador não pode criar mais que $G_PLS_FIELD_1 baldes"

; Message box text strings

; TempTranslationNote: PFI_LANG_CBP_MBDUPERR_A = PFI_LANG_CBP_MBDUPERR_1 + " '$G_PLS_FIELD_1' " + PFI_LANG_CBP_MBDUPERR_2
; TempTranslationNote: PFI_LANG_CBP_MBDUPERR_B = PFI_LANG_CBP_MBDUPERR_3

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_A       "Um balde chamado '$G_PLS_FIELD_1' já foi definido."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_B       "Por favor escolha um nome diferente para o novo balde."

; TempTranslationNote: PFI_LANG_CBP_MBMAXERR_A = PFI_LANG_CBP_MBMAXERR_1 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAXERR_2
; TempTranslationNote: PFI_LANG_CBP_MBMAXERR_B = PFI_LANG_CBP_MBMAXERR_3 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAXERR_2

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_A       "O instalador pode somente criar até $G_PLS_FIELD_1 baldes."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_B       "Uma vez que o POPFile tenha sido instalado, você poderá criar mais que $G_PLS_FIELD_1 baldes"

; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_A = PFI_LANG_CBP_MBNAMERR_1 + " '$G_PLS_FIELD_1' " + PFI_LANG_CBP_MBNAMERR_2
; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_B = PFI_LANG_CBP_MBNAMERR_3
; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_C = PFI_LANG_CBP_MBNAMERR_4

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_A       "O nome '$G_PLS_FIELD_1' não é um nome válido para um balde."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_B       "Nomes de balde somente podem conter as letras de a até z minúsculas, números de 0 a 9, mais - e _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_C       "Por favor escolha um nome diferente para o novo balde."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "O POPFile requer PELO MENOS DOIS baldes para poder classificar seus emails."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "Por favor entre o nome de um balde para ser criado,${MB_NL}${MB_NL}escolhendo um nome sugerido da lista${MB_NL}${MB_NL}ou digitando um nome de sua escolha."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "Você deve definir PELO MENOS DOIS baldes antes de continuar sua instalação do POPFile."

; TempTranslationNote: PFI_LANG_CBP_MBDONE_A = "$G_PLS_FIELD_1 " + PFI_LANG_CBP_MBDONE_1
; TempTranslationNote: PFI_LANG_CBP_MBDONE_B = PFI_LANG_CBP_MBDONE_2
; TempTranslationNote: PFI_LANG_CBP_MBDONE_C = PFI_LANG_CBP_MBDONE_3

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_A         "$G_PLS_FIELD_1 baldes foram definidos para uso do POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_B         "Você quer configurar o POPFile para usar estes baldes ?"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_C         "Clique 'Não' se você quer alterar sua seleção de baldes."

; TempTranslationNote: PFI_LANG_CBP_MBMAKERR_A = PFI_LANG_CBP_MBMAKERR_1 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAKERR_2 + " $G_PLS_FIELD_2 " + PFI_LANG_CBP_MBMAKERR_3
; TempTranslationNote: PFI_LANG_CBP_MBMAKERR_B = PFI_LANG_CBP_MBMAKERR_4

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_A       "O instalador não foi capaz de criar $G_PLS_FIELD_1 de $G_PLS_FIELD_2 baldes que você selecionou."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_B       "Uma vez que o POPFile tenha sido instalado, você pode usar seu painél de controle${MB_NL}${MB_NL} na 'Interface de Usuário' para criar o(s) balde(s) que faltar(em)."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Email Client Reconfiguration [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "Configuração do Cliente de Email"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "O POPFile pode reconfigurar vários clientes de email para você"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "Clientes de email marcados (*) podem ser reconfigurados automaticamente, assumindo que contas simples sejam usadas.${IO_NL}${IO_NL}É altamente recomendado que contas que requeiram autenticação sejam configuradas manualmente."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "IMPORTANTE: POR FAVOR FECHE OS CLIENTES DE EMAIL RECONFIGURÁVEIS AGORA${IO_NL}${IO_NL}Esta característica ainda está em desenvolvimento (algumas contas do Outlook podem não serem detectadas).${IO_NL}${IO_NL}Por favor verifique se a reconfiguração foi bem sucedida (antes de usar o cliente de email)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    "Reconfiguração do cliente de email cancelada pelo usuário"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Text used on buttons to skip configuration of email clients [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   "Pular Todos"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   "Pular Cliente"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Message box warnings that an email client is still running [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         "AVISO: o Outlook Express parece estar rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         "AVISO: o Outlook parece estar rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         "AVISO: o Eudora parece estar rodando!"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "Por favor FECHE o programa de email e clique 'Repetir' para reconfigurá-lo"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(Você pode clicar 'Ignorar' para reconfigurá-lo, mas isto não é recomendado)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "Clique 'Anular' para pular a reconfiguração deste programa de email"

; Following three strings are used when uninstalling

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "Por favor FECHE o programa de email e clique 'Repetir' para restaurar a configuração"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(Você pode clicar 'Ignorar' para restaurar a configuração, mas isto não é recomendado)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "Clique 'Anular' para pular a restauração da configuração original"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Reconfigure Outlook/Outlook Express [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_FOOTNOTE   "Marque a(s) caixa(s) para reconfigurar a(s) conta(s).${IO_NL}Se você desinstalar o POPFile as configurações originais serão restauradas."

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

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Reconfigure Eudora [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile can now be started [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE         "O POPFile pode ser iniciado agora"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE      "A Interface de Usuário do POPFile somente funciona se o POPFile tiver sido iniciado"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO      "Iniciar o POPFile agora ?"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO         "Não (a 'Interface de Usuário' não pode ser usada se o POPFile não for iniciado)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX     "Executar o POPFile (em uma janela)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND    "Executar o POPFile em segundo plano (nenhuma janela é exibida)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOICON     "Executar o POPFile (não exibir o ícone na bandeja do sistema)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_TRAYICON   "Executar o POPFile com o ícone na bandeja do sistema"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1     "Uma vez que o POPFile tenha sido iniciado, você pode exibir a 'Interface de Usuário'"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2     "(a) dando um duplo-clique no ícone do POPFile na bandeja do sistema,   OU"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3     "(b) usando Iniciar --> Programas --> POPFile --> Interface de Usuário do POPFile."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1      "Preparando para iniciar o POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2      "Isto pode levar alguns segundos..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - FINISH [adduser.nsi]
;
; The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name of the user running the wizard

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO "O POPFile foi configurado para o usuário '$G_WINUSERNAME'.${IO_NL}${IO_NL}Clique em Finalizar para fechar este assistente."

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "Interface de Usuário do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_WEB_LINK_TEXT "Clique aqui para visitar o web site do POPFile"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard) [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the uninstall wizard

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "Desinstalar dados do POPFile para o usuário '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "Remover dados de configuração do POPFile para este usuário do seu computador"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "Os dados de configuração do POPFile para o usuário '$G_WINUSERNAME' serão desinstalados da seguinte pasta. $_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard) [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the uninstall wizard

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "Desinstalando dados do POPFile para o usuário '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "Por favor espere enquanto os arquivos de configuração do POPFile para este usuário são deletados"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - UNPAGE_INSTFILES [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTEXPRESS   "Restaurando configurações do Outlook Express..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTLOOK      "Restaurando configurações do Outlook..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EUDORA       "Restaurando configurações do Eudora..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_DBMSGDIR     "Deletando o corpus e o diretório 'Mensagens Recentes'..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CONFIG       "Deletando dados de condiguração..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EXESTATUS    "Verificando o estado do programa..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_REGISTRY     "Deletando entradas do POPFile no registro..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_EXPRUN        "O Outlook Express ainda está rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_OUTRUN        "O Outlook ainda está rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_EUDRUN        "O Eudora ainda está rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_IGNORE        "O usuário pediu restauração enquanto o programa de email estava em execução"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_OPENED        "Aberto"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_RESTORED      "Restaurado"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_CLOSED        "Fechado"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DATAPROBS     "Problemas nos dados"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERDIR    "Removendo todos os arquivos do diretório 'User Data' do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERERR    "Nota: impossível remover todos os arquivos do diretório 'User Data' do POPFile"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "Problema no 'Outlook Express'!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "Problema no 'Outlook'!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "Problema no 'Eudora'!"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "Não foi possível restaurar toda a configuração original"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "Exibir o relatório de erros?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "Algumas configurações do cliente de email não foram restauradas!"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Detalhes podem ser encontrados na pasta $INSTDIR )"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "Clique em 'Não' para ignorar estes erros e deletar tudo"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "Clique em 'Sim' para manter estes dados (para tentar outra vez mais tarde)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "Você quer remover todos os arquivos do seu diretório 'User Data' do POPFile?${MB_NL}${MB_NL}$G_USERDIR${MB_NL}${MB_NL}(Se você tiver qualquer coisa que você criou e quer manter, clique em Não)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDELMSGS_1       "Você quer remover todos os arquivos do seu diretório 'Mensagens Recentes'?"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Corpus Conversion: Standard MUI Page - INSTFILES [MonitorCC.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        "Conversão do Corpus do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "O corpus existente deve ser convertido para funcionar com esta versão do POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "Completada a Conversão do Corpus do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "Clique em Fechar para continuar"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "A Conversão do Corpus do POPFile Falhou"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "Clique em Cancelar para continuar"

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "Uma outra cópia do 'Monitor de Conversão do Corpus' já está rodando!"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "O 'Monitor de Conversão do Corpus' é parte do instalador do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "Erro: o arquivo de dados da conversão do Corpus não existe!"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "Erro: falta o caminho do POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "Ocorreu um erro ao iniciar o processo de conversão do corpus"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "Ocorreu um erro fatal durante o processo de conversão do corpus!"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "Tempo restante estimado: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "minutos"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(esperando pelo primeiro arquivo a ser convertido)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "Existem $G_BUCKET_COUNT arquivos de balde para serem convertidos"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "Depois de $G_ELAPSED_TIME.$G_DECPLACES minutos existem $G_STILL_TO_DO arquivos para converter"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "Depois de $G_ELAPSED_TIME.$G_DECPLACES minutos existe um arquivo para converter"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "A Conversão do Corpus levou $G_ELAPSED_TIME.$G_DECPLACES minutos"

###########################################################################
###########################################################################

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'PortugueseBR-pfi.nsh'
#--------------------------------------------------------------------------
