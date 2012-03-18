#--------------------------------------------------------------------------
#
# pfi-nsis-library.nsh --- This is a collection of library functions based
#                          upon functions shipped with the NSIS compiler.
#                          The functions in this library have been given
#                          names starting 'NSIS_' to identify their source.
#
#--------------------------------------------------------------------------
#                      NSIS 'Include' files used:
#
#                      (1) ${NSISDIR}\Include\FileFunc.nsh
#                      (2) ${NSISDIR}\Include\TextFunc.nsh
#
#                      The above NSIS files support a 'macro-based' syntax,
#                      e.g.
#
#                      ${GetParent} "C:\Program Files\Winamp\uninstwa.exe" $R0
#
#                      This library makes it easier to use these functions in
#                      a traditional 'function-based' environment,e.g.
#
#                      Push "C:\Program Files\Winamp\uninstwa.exe"
#                      Call GetParent
#                      Pop $R0
#--------------------------------------------------------------------------

  !define C_NSIS_LIBRARY_VERSION     "0.2.4"

  ;----------------------------------------------
  ; Use the following standard NSIS header files:
  ;----------------------------------------------

  !include  FileFunc.nsh
  !include  TextFunc.nsh

#=============================================================================================
#
# Functions used only during 'installation':
#
#    Installer Function: NSIS_GetRoot
#
#=============================================================================================

!ifdef ADDUSER | INSTALLER | PORTABLE | RESTORE

  #--------------------------------------------------------------------------
  # Installer Function: NSIS_GetRoot
  #
  # This function returns the root directory of a given path.
  # The given path must be a full path. Normal paths and UNC paths are supported.
  #
  # NB: The path is assumed to use backslashes (\)
  #
  # Inputs:
  #         (top of stack)          - input path
  #
  # Outputs:
  #         (top of stack)          - root part of the path (eg "X:" or "\\server\share")
  #
  # Usage:
  #
  #         Push "C:\Program Files\Directory\Whatever"
  #         Call NSIS_GetRoot
  #         Pop $R0
  #
  #         ($R0 at this point is ""C:")
  #
  #--------------------------------------------------------------------------

  Function NSIS_GetRoot

    !define L_INPUT   $R9
    !define L_OUTPUT  $R8

    Exch ${L_INPUT}
    Push ${L_OUTPUT}
    Exch

    ${GetRoot} ${L_INPUT} ${L_OUTPUT}

    Pop ${L_INPUT}
    Exch ${L_OUTPUT}

    !undef L_INPUT
    !undef L_OUTPUT

  FunctionEnd
!endif

#=============================================================================================
#
# Macro-based Functions which may be used by installer or uninstaller (in alphabetic order)
#
#    Macro:                NSIS_GetParameters
#    Installer Function:   NSIS_GetParameters
#    Uninstaller Function: un.NSIS_GetParameters
#
#    Macro:                NSIS_GetParent
#    Installer Function:   NSIS_GetParent
#    Uninstaller Function: un.NSIS_GetParent
#
#    Macro:                NSIS_IsNT
#    Installer Function:   NSIS_IsNT
#    Uninstaller Function: un.NSIS_IsNT
#
#    Macro:                NSIS_TrimNewlines
#    Installer Function:   NSIS_TrimNewlines
#    Uninstaller Function: un.NSIS_TrimNewlines
#
#=============================================================================================


#--------------------------------------------------------------------------
# Macro: NSIS_GetParameters
#
# The installation process and the uninstall process may need a function which extracts
# the parameters (if any) supplied on the command-line. This macro makes maintenance
# easier by ensuring that both processes use identical functions, with the only difference
# being their names.
#
# NOTE:
# The !insertmacro NSIS_GetParameters "" and !insertmacro NSIS_GetParameters "un." commands are
# included in this file so the NSIS script can use 'Call NSIS_GetParameters' and
# 'Call un.NSIS_GetParameters' without additional preparation.
#
# Inputs:
#         none
#
# Outputs:
#         top of stack)     - all of the parameters supplied on the command line (may be "")
#
# Usage (after macro has been 'inserted'):
#
#         Call NSIS_GetParameters
#         Pop $R0
#
#         (if 'setup.exe /SSL' was used to start the installer, $R0 will hold '/SSL')
#--------------------------------------------------------------------------

!macro NSIS_GetParameters UN
  Function ${UN}NSIS_GetParameters

    !define L_OUTPUT  $R9

    Push ${L_OUTPUT}

    ${GetParameters} ${L_OUTPUT}

    Exch ${L_OUTPUT}

    !undef L_OUTPUT

  FunctionEnd
!macroend

!ifndef CREATEUSER & ONDEMAND
    #--------------------------------------------------------------------------
    # Installer Function: NSIS_GetParameters
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_GetParameters ""
!endif

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninnstaller Function: un.NSIS_GetParameters
    #
    # This function is used during the uninstallation process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_GetParameters "un."
!endif


#--------------------------------------------------------------------------
# Macro: NSIS_GetParent
#
# The installation process and the uninstall process may both use a function which extracts
# the parent directory from a given path. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NB: The path is assumed to use backslashes (\)
#
# NOTE:
# The !insertmacro NSIS_GetParent "" and !insertmacro NSIS_GetParent "un." commands are
# included in this file so the NSIS script can use 'Call NSIS_GetParent' and
# 'Call un.NSIS_GetParent' without additional preparation.
#
# Inputs:
#         (top of stack)          - string containing a path (e.g. C:\A\B\C)
#
# Outputs:
#         (top of stack)          - the parent part of the input string (e.g. C:\A\B)
#                                   or an empty string if only a filename was supplied
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\Program Files\Directory\Whatever"
#         Call un.NSIS_GetParent
#         Pop $R0
#
#         ($R0 at this point is ""C:\Program Files\Directory")
#
#--------------------------------------------------------------------------

!macro NSIS_GetParent UN
  Function ${UN}NSIS_GetParent

    !define L_INPUT   $R9
    !define L_OUTPUT  $R8

    Exch ${L_INPUT}
    Push ${L_OUTPUT}
    Exch

    ${GetParent} ${L_INPUT} ${L_OUTPUT}

    Pop ${L_INPUT}
    Exch ${L_OUTPUT}

    !undef L_INPUT
    !undef L_OUTPUT

  FunctionEnd
!macroend


!ifdef ADDSSL | ADDUSER | BACKUP | CREATEUSER | DBANALYSER | DBSTATUS | INSTALLER | LFNFIXER | MONITORCC | ONDEMAND | PFIDIAG | PORTABLE | RESTORE | RUNPOPFILE | RUNSQLITE
    #--------------------------------------------------------------------------
    # Installer Function: NSIS_GetParent
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_GetParent ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninnstaller Function: un.NSIS_GetParent
    #
    # This function is used during the uninstallation process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_GetParent "un."
!endif


#--------------------------------------------------------------------------
# Macro: NSIS_IsNT
#
# The installation process and the uninstall process both use a function which checks if
# the installer is running on a Win9x system or a more modern OS. This macro makes maintenance
# easier by ensuring that both processes use identical functions, with the only difference
# being their names.
#
# Returns 0 if running on a Win9x system, otherwise returns 1
#
# NOTE:
# The !insertmacro NSIS_IsNT "" and !insertmacro NSIS_IsNT "un." commands are included in this file
# so 'installer.nsi' can use 'Call NSIS_IsNT' and 'Call un.NSIS_IsNT' without additional preparation.
#
# Inputs:
#         None
#
# Outputs:
#         (top of stack)   - 0 (running on Win9x system) or 1 (running on a more modern OS)
#
#  Usage (after macro has been 'inserted'):
#
#         Call un.NSIS_IsNT
#         Pop $R0
#
#         ($R0 at this point is 0 if installer is running on a Win9x system)
#
#--------------------------------------------------------------------------

!macro NSIS_IsNT UN
  Function ${UN}NSIS_IsNT
    Push $0
    ReadRegStr $0 HKLM \
      "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
    StrCmp $0 "" 0 IsNT_yes
    ; we are not NT.
    Pop $0
    Push 0
    Return

  IsNT_yes:
      ; NT!!!
      Pop $0
      Push 1
  FunctionEnd
!macroend

!ifndef BACKUP & CREATEUSER & DBANALYSER & DBSTATUS & LFNFIXER & MONITORCC & MSGCAPTURE & ONDEMAND & PLUGINCHECK & PORTABLE & RESTORE & RUNSQLITE & SHUTDOWN & STOP_POPFILE
    #--------------------------------------------------------------------------
    # Installer Function: NSIS_IsNT
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_IsNT ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.NSIS_IsNT
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_IsNT "un."
!endif

#--------------------------------------------------------------------------
# Macro: NSIS_TrimNewlines
#
# The installation process and the uninstall process may both use a function to trim newlines
# from lines of text. This macro makes maintenance easier by ensuring that both processes use
# identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro NSIS_TrimNewlines "" and !insertmacro NSIS_TrimNewlines "un." commands are
# included in this file so the NSIS script can use 'Call NSIS_TrimNewlines' and
# 'Call un.NSIS_TrimNewlines' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may end with one or more newlines
#
# Outputs:
#         (top of stack)   - the input string with the trailing newlines (if any) removed
#
# Usage (after macro has been 'inserted'):
#
#         Push "whatever$\r$\n"
#         Call un.NSIS_TrimNewlines
#         Pop $R0
#         ($R0 at this point is "whatever")
#
#--------------------------------------------------------------------------

!macro NSIS_TrimNewlines UN
  Function ${UN}NSIS_TrimNewlines

    !define L_INPUT   $R9
    !define L_OUTPUT  $R8

    Exch ${L_INPUT}
    Push ${L_OUTPUT}
    Exch

    ${TrimNewlines} ${L_INPUT} ${L_OUTPUT}

    Pop ${L_INPUT}
    Exch ${L_OUTPUT}

    !undef L_INPUT
    !undef L_OUTPUT

  FunctionEnd
!macroend

!ifndef LFNFIXER & MONITORCC & RUNSQLITE & STOP_POPFILE & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: NSIS_TrimNewlines
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_TrimNewlines ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninnstaller Function: un.NSIS_TrimNewlines
    #
    # This function is used during the uninstallation process
    #--------------------------------------------------------------------------

    !insertmacro NSIS_TrimNewlines "un."
!endif


#--------------------------------------------------------------------------
# End of 'pfi-nsis-library.nsh'
#--------------------------------------------------------------------------
