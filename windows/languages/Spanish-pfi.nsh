#--------------------------------------------------------------------------
# Spanish-pfi.nsh
#
# This file contains additional "Spanish" text strings used by the Windows installer
# for POPFile (these strings are unique to POPFile).
#
# See 'Spanish-mui.nsh' for the strings which modify standard NSIS MUI messages.
#
# These strings are grouped according to the page/window where they are used
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

!define PFI_LANG  "SPANISH"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1        "¿Desea ver las Notas sobre esta versión de POPFile?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2        "'Si' recomendado si está actualizando POPFile (puede que $\r$\nnecesite hacer una copia de seguridad ANTES DE actualizar)"

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile              "Instalar los archivos esenciales de POPFile, incluyendo una versión mínima de Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                "Instalar skins de POPFile que le permitirán cambiar el aspecto del interface de usuario de POPFile."
!insertmacro PFI_LANG_STRING DESC_SecLangs                "Instalar versiones de idiomas no-Ingleses para el IU de POPFile."

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE       "Opciones de Instalación para POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE    "Deje estas estas opciones así, a menos que necesite cambiarlas"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3     "Elija el nº de puerto por defecto para conexiones POP3 (recomendado el 110)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI      "Elija el puerto por defecto para conectar al 'Interface de Usuario' (recomendado el 8080)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP  "Cargar automaticamente POPFile en cada inicio de Windows"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING  "ADVERTENCIA IMPORTANTE"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE  "SI ESTÁ ACTUALIZANDO POPFILE --- EL INSTALADOR CERRARÁ LA VERSION EXISTENTE"

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_1    "Hallada una instalación previa en"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_2    "¿ Permite desinstalarla ?"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_3    "'Si' recomendado"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1    "No se puede usar este puerto POP3"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2    "El puerto debe ser un número entre 1 y 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3    "Cambie por favor su elección del puerto POP3."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1     "No se puede usar el puerto del 'Interface de  Usuario'"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2     "El puerto debe ser un número entre 1 y 65535"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3     "Cambie por favor su elección de puerto para 'Interface de Usuario'."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1    "Los puertos para POP3 e 'Interface de  Usuario' tiene que ser diferentes."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2    "Cambie por favor su elección de puertos."

; Banner message displayed whilst uninstalling old version

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_1     "Aguarde por favor."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_2     "Tardará unos pocos segundos..."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE   "Comprobando si se está actualizando..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE      "Instalando los archivos esenciales de POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL      "Instalando el minimo de archivos Perl..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT     "Creando enlaces para POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FFCBACK   "Making corpus backup. This may take a few seconds..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS     "Instalando skins para POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS     "Instalando archivos de lenguaje para IU de POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC    "Presione Siguiente para continuar"

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_1          "Cerrando versión anterior de POPFile usando puerto"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1          "hallado archivo de una instalación anterior."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2          "¿Desea actualizarlo?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3          "Clic 'Si' para actualizarlo (el anterior se guardará como"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4          "Clic 'No' para seguir con el anterior (el nuevo se guardará como"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_1           "Copia de seguridad de"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_2           "ya existe"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_3           "¿OK para sobrescribirla?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_4           "Clic 'Si' para sobrescribirla, clic 'No' para saltar el hacer una copia"

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1         "Unable to shutdown POPFile automatically."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2         "Please shutdown POPFile manually now."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3         "When POPFile has been shutdown, click 'OK' to continue."

!insertmacro PFI_LANG_STRING PFI_LANG_MBFFCERR_1          "Error detected when the installer tried to backup the old corpus."

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE           "Creación de las Categorías para Clasificación de POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE        "POPFile necesita AL MENOS DOS categorías para poder clasificar en ellas su correo"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO        "Tras la instalacion, es facil cambiar el numero de categorías (y sus nombres) para acomodarlo a sus necesidades.\r\n\r\nLos nombres de las Categorías deben ser palabras unicas, con minusculas, números del 0 al 9, guiones y subrayado."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE       "Cree una nueva categoría seleccionando un nombre de la lista inferior o tecleando un nombre de su eleccion."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE       "Para borrar una o mas categorías de la lista, marque la correspondiente casilla(s) 'Borrar' y pinche en el boton 'Continuar'."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR      "Categorías a usar por POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE       "Borrar"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE     "Continuar"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1        "No es necesario añadir mas categorías"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2        "Debe definir AL MENOS DOS categorías"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3        "Como minimo se necesita una categoría mas"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4        "El instalador no puede crear mas de"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5        "categorías"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1      "Una categoría de nombre"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2      "ya se ha definido."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3      "Elija por favor otro nombre para la nueva categoría."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1      "El instalador solo puede crear hasta"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2      "categorías."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3      "Una vez que haya instalado POPFile, puede crear mas de"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1      "El nombre"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2      "no es válido como nombre para una categoría."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3      "Los nombres de Categorías sólo pueden contener las letras de la a a la z en minúsculas mas - y _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4      "Elija por favor un nombre diferente para la nueva categoría."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1     "POPFile necesita AL MENOS DOS categorías antes de poder clasificar su correo en ellas."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2     "Por favor ponga nombre a la categoría a crear,$\r$\n$\r$\neligiéndolo de la lista desplegable de nombres$\r$\n$\r$\no tecleando el suyo propio."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3     "Debe definir AL MENOS DOS categorías antes de poder continuar instalando POPFile."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1        "categorías se han definido para usarlas con POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2        "¿Quiere configurar POPFile para usarlas?"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3        "Clic 'No' si desea cambiar su selección de categorías."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1      "El instalador ha sido incapaz de crear"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2      "de las"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3      "categorías que usted eligió."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4      "Una vez que se haya instalado POPFile usted podra usar su panel de control del $\r$\n$\r$\n'Interface de Usuario'para crear la(s) categoría(s) que falten."

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_TITLE         "Reconfigurar Outlook Express"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_SUBTITLE      "POPFile puede reconfigurar Outlook Express por usted"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_INTRO      "POPFile ha detectado las siguientes cuentas de correo en Outlook Express y puede configurarlas automaticamente para que funcionen con POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_CHECKBOX   "Reconfigurar esta cuenta para funcionar con POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_EMAIL      "Dirección Email:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_SERVER     "Servidor POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_USERNAME   "Usuario POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_RESTORE    "Si desinstala POPFile se restaurarán los valores originales"

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_1     "cuenta para la"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_2     "identidad"

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE        "Ya se puede arrancar POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE     "El Interface de Usuario de POPFile solo funciona si POPFile esta funcionando"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO     "¿Arrancar ahora POPFile?"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO        "No (el 'Interface de Usuario' no se puede utilizar si no se inicia POPFile)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX    "Arrancar POPFile (en una ventana)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND   "Arrancar POPFile en segundo plano (no se muestra ventana)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1    "Una vez que se haya iniciado POPFile, puede ver el 'Interface de Usuario' mediante"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2    "(a) doble-clic el el icono de POPFile en la bandeja de sistema, o"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3    "(b) usando Inicio --> Programas --> POPFile --> POPFile User Interface."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1     "Preparándose para iniciar POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2     "Puede que tarde unos segundos..."

#--------------------------------------------------------------------------
# Custom Page - Flat file corpus needs to be converted to new format
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_TITLE       "POPFile Corpus Conversion"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_SUBTITLE    "The existing corpus must be converted to work with this version of POPFile"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_1   "POPFile will now be started in a console window to convert the existing corpus."
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_2   "THIS PROCESS MAY TAKE SEVERAL MINUTES (if the corpus is large)."
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_3   "WARNING"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_4   "Do NOT close the POPFile console window!"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_5   "When 'POPFile Engine v0.20.0 running' appears in the console window, this means"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_6   "- POPFile is ready for use"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_7   "- POPFile can be safely shutdown using the Start Menu"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_1        "Cerrando POPFile..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_2        "Borrando elementos del 'Menu de Inicio' para POPFile..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_3        "Borrando archivos esenciales de POPFile..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_4        "Recuperando valores de Outlook Express..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_5        "Borrando skins de POPFile..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_6        "Borrando archivos minimos de Perl..."

; Uninstall Log Messages

!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_1             "Cerrando POPFile usando puerto"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_2             "Abierto"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_3             "Recuperado"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_4             "Cerrado"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_5             "Eliminando todos los archivos de la carpeta de POPFile"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_6             "Nota: incapaz de eliminar todos los archivos de la carpeta de POPFile"

; Message Box text strings

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_1      "No parece que POPFile esté instalado en esta carpeta"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_2      "Continuar de todas formas (no recomendado) ?"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_ABORT_1           "Desinstalación abortada por el usuario"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMDIR_1        "¿Quiere eliminar todos los archivos en su carpeta de POPFile?$\r$\n$\r$\n(Si quiere guardar algo que usted haya creado, haga clic en No)"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_1        "Nota"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_2        "no se pudo eliminar."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Spanish-pfi.nsh'
#--------------------------------------------------------------------------
