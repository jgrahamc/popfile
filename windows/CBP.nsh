#----------------------------------------------------------------------------------------------
#
# CBP.nsh --- This file is used by 'installer.nsi', the NSIS script used to create the
#             Windows installer for POPFile. The CBP package allows the user to select several
#             buckets for use with a "clean" install of POPFile. Three built-in default values
#             can be overridden by creating suitable "!define" statements in 'installer.nsi'.
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
#----------------------------------------------------------------------------------------------
#
# WARNING:
#
# This script requires a version of NSIS 2.0b4 (CVS) which meets the following requirements:
#
# (1) '{NSIS}\makensis.exe' dated 8 July 2003 @ 18:44 (NSIS CVS version 1.203) or later
#     This is required to ensure 'language' strings can be combined with other strings.
#
# (2) '{NSIS}\makensis.exe' dated 21 July 2003 @ 06:44 (NSIS CVS version 1.214) or later
#     This is required to avoid spurious error messages when creating buckets with UNC paths.
#----------------------------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

!ifdef CBP.nsh_included
  !error "$\r$\n$\r$\nFatal error: CBP.nsh has been included more than once!$\r$\n"
!else
!define CBP.nsh_included

#//////////////////////////////////////////////////////////////////////////////////////////////
#
#                           External interface - starts here
#
#//////////////////////////////////////////////////////////////////////////////////////////////


  ; To use the CBP package, only two changes need to be made to "installer.nsi":
  ;
  ;   (1) Ensure the CBP package gets compiled, by inserting this block of code near the start:
  ;
  ;   <start of code block>
  ;
  ;   #----------------------------------------------------------------------------------------
  ;   # CBP Configuration Data (to override defaults, un-comment lines below and modify them)
  ;   #----------------------------------------------------------------------------------------
  ;   #   ; Maximum number of buckets handled (in range 2 to 8)
  ;   #
  ;   #   !define CBP_MAX_BUCKETS 8
  ;   #
  ;   #   ; Default bucket selection (use "" if no buckets are to be pre-selected)
  ;   #
  ;   #   !define CBP_DEFAULT_LIST "inbox|spam|personal|work"
  ;   #
  ;   #   ; List of suggestions for bucket names (use "" if no suggestions are required)
  ;   #
  ;   #   !define CBP_SUGGESTION_LIST \
  ;   #   "admin|business|computers|family|financial|general|hobby|inbox|junk|list-admin|\
  ;   #   miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|\
  ;   #   travel|work"
  ;   #----------------------------------------------------------------------------------------
  ;   # Make the CBP package available
  ;   #----------------------------------------------------------------------------------------
  ;
  ;   !include CBP.nsh
  ;
  ;   <end of code block>
  ;
  ;   (2) Add the "Create POPFile Buckets" page to the list of installer pages:
  ;
  ;         !insertmacro CBP_PAGECOMMAND_SELECTBUCKETS
  ;
  ; These two changes will use the default settings in the CBP package. There are three default
  ; settings which can be overridden by un-commenting the appropriate lines in the inserted code
  ; block.
  ;
  ; Default setting 1:
  ; -----------------
  ;
  ;     !define CBP_MAX_BUCKETS 8
  ;
  ; Maximum number of buckets handled by the installer, a number in the range 2 to 8 inclusive.
  ; If a number outside this range is supplied, the CBP package will use 8 buckets by default.
  ;
  ;
  ; Default setting 2:
  ; -----------------
  ;
  ;     !define CBP_DEFAULT_LIST "inbox|spam|personal|work"
  ;
  ; The default list of bucket names presented when the "Create Bucket" page first appears.
  ; This list should contain a series of valid bucket names, separated by "|" characters.
  ; If no default buckets are required, use "" for this list. Alphabetic order is used here
  ; for convenience but any order can be used. Default buckets are created in order from left
  ; to right and if more than CBP_MAX_BUCKETS names are supplied, the "extra" names will be
  ; ignored. The CBP package will ignore any invalid or duplicated names in this list.
  ;
  ; Default setting 3:
  ; -----------------
  ;
  ;     !define CBP_SUGGESTION_LIST \
  ;     "admin|business|computers|family|financial|general|hobby|inbox|junk|list-admin|\
  ;     miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|\
  ;     travel|work"
  ;
  ; The list of suggested names for buckets, provided as an aid to the user. This list should
  ; contain a series of valid bucket names, separated by "|" characters. If no suggestions are
  ; to be shown, use "" for this list. Alphabetic order is used here for convenience since the
  ; list presented to the user will follow the order given here, from left to right.
  ; The CBP package will ignore any invalid or duplicated names in this list.
  ;
  ; These commented-out "!define" statements are included in the code block to serve as a
  ; reminder of the default values and to make it easier to configure the CBP package.

#//////////////////////////////////////////////////////////////////////////////////////////////
#
#                           External interface - ends here
#
#//////////////////////////////////////////////////////////////////////////////////////////////

  ;============================================================================================
  ; (Informal) Coding standard for the CBP Package
  ;============================================================================================

  ; (1) All functions, macros and define statements use the 'CBP_' prefix
  ;
  ; (2) With the exception of some small library functions, 'defines' are used to give registers
  ;     'meaningful' names and make maintenance easier.
  ;
  ; (3) Similarly, 'defines' are used for constants
  ;
  ; (4) Naming conventions: local registers are give names starting with 'CBP_L_' and
  ;     constants are given names starting with 'CBP_C_'. If global registers are introduced,
  ;     they should use names beginning with 'CBP_G_'.
  ;
  ; (5) All functions preserve register values using the stack (with the sole exception of the
  ;     'leave' function for the custom page - it shares the same registers as the custom page
  ;     creator function in order to simplify the input validation process)
  ;
  ; (6) Parameters are passed on the stack (the sole exception is the custom page's
  ;     'leave' function)

  ;============================================================================================

  ; Name of the INI file used to create the custom page for this package. Normally the
  ; 'CBP_CreateBucketsPage' function will call 'CBP_CreateINIfile' to create this INI file
  ; in the $PLUGINSDIR directory so it will be deleted automatically when the installer ends.

  !define CBP_C_INIFILE   CBP_PAGE.INI

  ; However, if 'installer.nsi' is modified to ensure that an INI file with this name is
  ; provided in the $PLUGINSDIR directory then the CBP package will use this INI file instead
  ; of calling 'CBP_CreateINIfile' to create one. It is up to the user to ensure that any INI
  ; file provided in this way meets the strict requirements of the CBP package otherwise chaos
  ; may well ensue! See the header comments in 'CBP_CreateINIfile' for further details.
  ; It is strongly recommended that any INI file provided by 'installer.nsi' is created by
  ; modifying a copy of the INI file created by the CBP_CreateINIfile function.

#==============================================================================================
# Function CBP_CheckCorpusStatus
#==============================================================================================
#
# This function is used to determine the type of POPFile installation we are performing.
# The CBP package is only used to create POPFile buckets when the installer is used to install
# POPFile in a folder which does not contain any corpus files from a previous installation.
#
# For flexibility, the folder to be searched is passed on the stack instead of being hard-coded.
# If 'popfile.cfg' is found in the specified folder, we use the corpus parameter (if present)
# otherwise we look for corpus files in the sub-folder called 'corpus'.
#
# The full path used when searching for a corpus is stored in the CBP package's INI file
# for use when creating the buckets.
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - the path where 'popfile.cfg' or the corpus is expected to be
#                                   (normally this will be the same as $INSTDIR)
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - string containing one of three possible result codes:
#                                       "clean" (corpus directory not found),
#                                       "empty" (corpus directory exists but is empty), or
#                                       "dirty" (corpus directory is not empty)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   CBP_GetParent                 - used when converting relative path to absolute path
#   CBP_StrBackSlash              - converts all slashes in a string into backslashes
#   CBP_TrimNewlines              - strips trailing Carriage Returns and/or Newlines from string
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CreateBucketsPage         - the function which "controls" the "Create Buckets" page
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#         Push $INSTDIR
#         Call CBP_CheckCorpusStatus
#         Pop $R0
#
#         ($R0 will be "clean", "empty" or "dirty" at this point)
#==============================================================================================

Function CBP_CheckCorpusStatus

  !define CBP_L_CORPUS        $R9
  !define CBP_L_FILE_HANDLE   $R8
  !define CBP_L_RESULT        $R7
  !define CBP_L_SOURCE        $R6
  !define CBP_L_TEMP          $R5

  Exch ${CBP_L_SOURCE}          ; where we are supposed to look for the corpus data
  Push ${CBP_L_RESULT}
  Exch
  Push ${CBP_L_CORPUS}
  Push ${CBP_L_FILE_HANDLE}
  Push ${CBP_L_TEMP}

  StrCpy ${CBP_L_CORPUS} ""

  IfFileExists ${CBP_L_SOURCE}\popfile.cfg 0 check_default_corpus_locn

  ClearErrors
  FileOpen ${CBP_L_FILE_HANDLE} ${CBP_L_SOURCE}\popfile.cfg r

loop:
  FileRead ${CBP_L_FILE_HANDLE} ${CBP_L_TEMP}
  IfErrors cfg_file_done
  StrCpy ${CBP_L_RESULT} ${CBP_L_TEMP} 7
  StrCmp ${CBP_L_RESULT} "corpus " got_old_corpus
  StrCpy ${CBP_L_RESULT} ${CBP_L_TEMP} 13
  StrCmp ${CBP_L_RESULT} "bayes_corpus " got_new_corpus
  Goto loop

got_old_corpus:
  StrCpy ${CBP_L_CORPUS} ${CBP_L_TEMP} "" 7
  Goto loop

got_new_corpus:
  StrCpy ${CBP_L_CORPUS} ${CBP_L_TEMP} "" 13
  Goto loop

cfg_file_done:
  FileClose ${CBP_L_FILE_HANDLE}

  Push ${CBP_L_CORPUS}
  Call CBP_TrimNewlines
  Pop ${CBP_L_CORPUS}
  StrCmp ${CBP_L_CORPUS} "" check_default_corpus_locn

  ; A non-null corpus parameter has been found in 'popfile.cfg'
  ; Strip leading/trailing quotes, if any

  StrCpy ${CBP_L_TEMP} ${CBP_L_CORPUS} 1
  StrCmp ${CBP_L_TEMP} '"' 0 slashconversion
  StrCpy ${CBP_L_CORPUS} ${CBP_L_CORPUS} "" 1
  StrCpy ${CBP_L_TEMP} ${CBP_L_CORPUS} 1 -1
  StrCmp ${CBP_L_TEMP} '"' 0 slashconversion
  StrCpy ${CBP_L_CORPUS} ${CBP_L_CORPUS} -1

slashconversion:
  Push ${CBP_L_CORPUS}
  Call CBP_StrBackSlash            ; ensure corpus path uses backslashes
  Pop ${CBP_L_CORPUS}

  StrCpy ${CBP_L_TEMP} ${CBP_L_CORPUS} 2
  StrCmp ${CBP_L_TEMP} ".\" sub_folder
  StrCmp ${CBP_L_TEMP} "\\" look_for_corpus_files

  StrCpy ${CBP_L_TEMP} ${CBP_L_CORPUS} 3
  StrCmp ${CBP_L_TEMP} "..\" relative_folder

  StrCpy ${CBP_L_TEMP} ${CBP_L_CORPUS} 1
  StrCmp ${CBP_L_TEMP} "\" instdir_drive

  StrCpy ${CBP_L_TEMP} ${CBP_L_CORPUS} 1 1
  StrCmp ${CBP_L_TEMP} ":" look_for_corpus_files

  ; Assume path can be safely added to $INSTDIR

  StrCpy ${CBP_L_CORPUS} $INSTDIR\${CBP_L_CORPUS}
  Goto look_for_corpus_files

sub_folder:
  StrCpy ${CBP_L_CORPUS} ${CBP_L_CORPUS} "" 2
  StrCpy ${CBP_L_CORPUS} $INSTDIR\${CBP_L_CORPUS}
  Goto look_for_corpus_files

relative_folder:
  StrCpy ${CBP_L_RESULT} $INSTDIR

relative_again:
  StrCpy ${CBP_L_CORPUS} ${CBP_L_CORPUS} "" 3
  Push ${CBP_L_RESULT}
  Call CBP_GetParent
  Pop ${CBP_L_RESULT}
  StrCpy ${CBP_L_TEMP} ${CBP_L_CORPUS} 3
  StrCmp ${CBP_L_TEMP} "..\" relative_again
  StrCpy ${CBP_L_CORPUS} ${CBP_L_RESULT}\${CBP_L_CORPUS}
  Goto look_for_corpus_files

instdir_drive:
  StrCpy ${CBP_L_TEMP} $INSTDIR 2
  StrCpy ${CBP_L_CORPUS} ${CBP_L_TEMP}${CBP_L_CORPUS}
  Goto look_for_corpus_files

check_default_corpus_locn:
  StrCpy ${CBP_L_CORPUS} ${CBP_L_SOURCE}\corpus

look_for_corpus_files:
  ; Save path in INI file for later use by 'CBP_MakePOPFileBucket'

  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
      "CBP Data" "CorpusPath" "${CBP_L_CORPUS}"

  FindFirst ${CBP_L_FILE_HANDLE} ${CBP_L_RESULT} ${CBP_L_CORPUS}\*.*

  ; If the "corpus" directory does not exist "${CBP_L_FILE_HANDLE}" will be empty

  StrCmp ${CBP_L_FILE_HANDLE} "" clean_install

  ; If the "corpus" directory is empty we can still treat this as a "clean" install
  ; (At this point, ${CBP_L_RESULT} will hold "." which we ignore)

  ; NB: We really should be checking that the user has got at least two buckets in their
  ; previous installation, but that is a task for another day...

corpus_check:
  FindNext ${CBP_L_FILE_HANDLE} ${CBP_L_RESULT}
  StrCmp ${CBP_L_RESULT} ".." corpus_check
  StrCmp ${CBP_L_RESULT} "" empty_install

  ; Have found something in the "corpus" directory so this is not a "clean" install

  StrCpy ${CBP_L_RESULT} "dirty"
  goto return_result

empty_install:
  StrCpy ${CBP_L_RESULT} "empty"
  goto return_result

clean_install:
  StrCpy ${CBP_L_RESULT} "clean"

return_result:
  FindClose ${CBP_L_FILE_HANDLE}

  Pop ${CBP_L_TEMP}
  Pop ${CBP_L_FILE_HANDLE}
  Pop ${CBP_L_CORPUS}
  Pop ${CBP_L_SOURCE}
  Exch ${CBP_L_RESULT}  ; place "clean", "empty" or "dirty" on top of the stack

  !undef CBP_L_CORPUS
  !undef CBP_L_FILE_HANDLE
  !undef CBP_L_RESULT
  !undef CBP_L_SOURCE
  !undef CBP_L_TEMP

FunctionEnd

#==============================================================================================
# Function CBP_MakePOPFileBuckets
#==============================================================================================
#
# This function creates the buckets which are to be used by this installation of POPFile.
# The names of the buckets to be created are extracted from the INI file used to create the
# custom page used by the CBP package. It is assumed that the bucket names are found in
# consecutive fields in the INI file.
#
# The INI file also holds the full path to the folder where the buckets are to be created
# (this path is determined by 'CBP_CheckCorpusStatus' because the location is not hard-coded).
#
# Almost no error checking is performed upon the input parameters.
#
# At present a simple result code is returned. This could be replaced by a list of the names
# of the buckets which were not created (as a "|" separated list ?)
#
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - the number of buckets to be created (in range 2 to 8)
#   (top of stack - 1)            - field number where the first bucket name is stored
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - the number of bucket creation failures (in range 0 to 8)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CreateBucketsPage         - the function which "controls" the "Create Buckets" page
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#       Push $R3                      ; field number used to hold name of the first bucket
#       Push $R2                      ; number of buckets to be created (range 2 to 8)
#       Call CBP_MakePOPFileBuckets
#       Pop $R1                       ; number of buckets not created (range 0 to 8)
#==============================================================================================

Function CBP_MakePOPFileBuckets

  !define CBP_L_CORPUS        $R9    ; holds the full path for the 'corpus' folder
  !define CBP_L_COUNT         $R8    ; holds number of buckets not yet created
  !define CBP_L_CREATE_NAME   $R7    ; name of bucket to be created
  !define CBP_L_FILE_HANDLE   $R6
  !define CBP_L_FIRST_FIELD   $R5    ; holds field number where first bucket name is stored
  !define CBP_L_LOOP_LIMIT    $R4    ; used to terminate the processing loop
  !define CBP_L_NAME          $R3    ; used when checking the corpus directory
  !define CBP_L_PTR           $R2    ; used to access the names in the bucket list

  Exch ${CBP_L_COUNT}         ; get number of buckets to be created
  Exch
  Exch ${CBP_L_FIRST_FIELD}   ; get number of the field containing the first bucket name

  Push ${CBP_L_CORPUS}
  Push ${CBP_L_CREATE_NAME}
  Push ${CBP_L_FILE_HANDLE}
  Push ${CBP_L_LOOP_LIMIT}
  Push ${CBP_L_NAME}
  Push ${CBP_L_PTR}

  ; Retrieve the corpus path (as determined by CBP_CheckCorpusStatus)

  !insertmacro MUI_INSTALLOPTIONS_READ ${CBP_L_CORPUS} "${CBP_C_INIFILE}" \
      "CBP Data" "CorpusPath"

  ; Now we create the buckets selected by the user. At present this code is only executed
  ; for a "fresh" install, one where there are no corpus files, so we can simply create a
  ; bucket by creating a corpus directory with the same name as the bucket and putting
  ; a file called "table" there.  The "table" file is empty apart from the bucket header
  ; (this mimics the behaviour of Bayes.pm version 1.152)

  ; Process only the "used" entries in the bucket list

  StrCpy ${CBP_L_PTR} ${CBP_L_FIRST_FIELD}
  IntOp ${CBP_L_LOOP_LIMIT} ${CBP_L_PTR} + ${CBP_L_COUNT}

next_bucket:
  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_CREATE_NAME}" "${CBP_C_INIFILE}" \
      "Field ${CBP_L_PTR}" "Text"
  StrCmp ${CBP_L_CREATE_NAME} "" incrm_ptr

  ; Double-check that the bucket we are about to create does not exist

  FindFirst ${CBP_L_FILE_HANDLE} ${CBP_L_NAME} ${CBP_L_CORPUS}\${CBP_L_CREATE_NAME}\*.*
  StrCmp ${CBP_L_FILE_HANDLE} "" ok_to_create_bucket
  FindClose ${CBP_L_FILE_HANDLE}
  goto incrm_ptr

ok_to_create_bucket:
  FindClose ${CBP_L_FILE_HANDLE}
  ClearErrors
  CreateDirectory ${CBP_L_CORPUS}\${CBP_L_CREATE_NAME}
  FileOpen ${CBP_L_FILE_HANDLE} ${CBP_L_CORPUS}\${CBP_L_CREATE_NAME}\table w
  FileWrite ${CBP_L_FILE_HANDLE} "__CORPUS__ __VERSION__ 1$\r$\n"
  FileClose ${CBP_L_FILE_HANDLE}
  IfErrors  incrm_ptr
  IntOp ${CBP_L_COUNT} ${CBP_L_COUNT} - 1

incrm_ptr:
  IntOp ${CBP_L_PTR} ${CBP_L_PTR} + 1
  IntCmp ${CBP_L_PTR} ${CBP_L_LOOP_LIMIT} finished_now next_bucket

finished_now:
  Pop ${CBP_L_PTR}
  Pop ${CBP_L_NAME}
  Pop ${CBP_L_LOOP_LIMIT}
  Pop ${CBP_L_FILE_HANDLE}
  Pop ${CBP_L_CREATE_NAME}
  Pop ${CBP_L_CORPUS}
  Pop ${CBP_L_FIRST_FIELD}

  Exch ${CBP_L_COUNT}       ; top of stack now has number of buckets we were unable to create

  !undef CBP_L_CORPUS
  !undef CBP_L_COUNT
  !undef CBP_L_CREATE_NAME
  !undef CBP_L_FILE_HANDLE
  !undef CBP_L_FIRST_FIELD
  !undef CBP_L_LOOP_LIMIT
  !undef CBP_L_NAME
  !undef CBP_L_PTR

FunctionEnd

#//////////////////////////////////////////////////////////////////////////////////////////////
#                                                                                             #
#                     NO "USER SERVICEABLE" PARTS BEYOND THIS POINT                           #
#                                                                                             #
#//////////////////////////////////////////////////////////////////////////////////////////////

###############################################################################################
#
# "Global" constants for the CBP Package
#
###############################################################################################

#==============================================================================================
# "CBP Configuration Constants"
#==============================================================================================

  ; NB: CBP_DEFAULT_LIST, CBP_SUGGESTION_LIST and CBP_MAX_BUCKETS may be defined
  ;     in 'installer.nsi' to override the CBP default settings.

  ; CBP_MAX_BUCKETS defines the maximum number of buckets handled by the CBP package,
  ; and must be a number in the range 2 to 8 inclusive. If a number outside this range is
  ; supplied, the CBP package will use the default setting of 8 buckets.

  !ifdef CBP_MAX_BUCKETS
    !define BUCKET_LIMIT_${CBP_MAX_BUCKETS}
  !endif

  ; The buckets to be selected by default when the "Create Buckets" page first appears
  ; (use "" if no buckets are to be selected by default). If this list contains more names
  ; than the limit specified by CBP_MAX_BUCKETS, the "extra" names will be ignored.

  !ifdef CBP_DEFAULT_LIST
      !define CBP_C_DEFAULT_BUCKETS `${CBP_DEFAULT_LIST}`
  !else
      !define CBP_C_DEFAULT_BUCKETS "inbox|spam|personal|work"
  !endif

  ; The list of suggested bucket names for the "Create Bucket" combobox to use
  ; (use "" if no names are to appear). If one of these names gets selected, it
  ; is removed from the combobox list (it'll be restored if bucket is de-selected).

  !ifdef CBP_SUGGESTION_LIST
      !define CBP_C_SUGGESTED_BUCKETS `${CBP_SUGGESTION_LIST}`
  !else
      !define CBP_C_SUGGESTED_BUCKETS \
      "admin|business|computers|family|financial|general|hobby|inbox|junk|list-admin|\
      miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|\
      travel|work"
  !endif

#==============================================================================================
# Macro used to insert the "Create Buckets" custom page into the list of installer pages
#==============================================================================================

  !macro CBP_PAGE_SELECTBUCKETS
    Page custom CBP_CreateBucketsPage "CBP_HandleUserInput"
  !macroend

#==============================================================================================
# "Global" constants used when accessing the INI file which defines the custom page layout
#==============================================================================================
# Used to make it easier to (re)design the custom page control layout.
# Values here match the INI file created by the CBP_CreateINIfile function
#----------------------------------------------------------------------------------------------

  ; Constant used to access the "Create Bucket" ComboBox

  !define CBP_C_CREATE_BN                 3

  ; Constants used to control the size of the "Create Bucket" ComboBox List

  !define CBP_C_FULL_COMBO_LIST          160
  !define CBP_C_MIN_COMBO_LIST           120

  ; Field number for the bucket creation progress reports

  !define CBP_C_MESSAGE                   5

  ; Constants specifying the fields which are common to all bucket list sizes

  !define CBP_C_FIRST_BN_CBOX               15    ; field holding the first check box
  !define CBP_C_FIRST_BN_CBOX_MINUS_ONE     14    ; used when processing the check boxes
  !define CBP_C_FIRST_BN_TEXT                7    ; field holding first bucket name
  !define CBP_C_LAST_BN_CBOX_PLUS_ONE       23    ; used when processing the check boxes
  !define CBP_C_LAST_BN_TEXT_PLUS_ONE       15    ; used when clearing out the bucket list

  ; Set up the limit on the number of buckets the installer can process (in the range 2 to 8)
  ; Also set up the two constants used to terminate processing loops

  ; If CBP_MAX_BUCKETS was supplied, BUCKET_LIMIT_x specifies the maximum number of buckets
  ; otherwise the CBP package will use its default setting of 8 buckets.

  !ifdef BUCKET_LIMIT_2
    !define CBP_C_MAX_BNCOUNT               2
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE      9
    !define CBP_MAX_BN_CBOX_PLUS_ONE       17
  !else ifdef BUCKET_LIMIT_3
    !define CBP_C_MAX_BNCOUNT               3
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE     10
    !define CBP_MAX_BN_CBOX_PLUS_ONE       18
  !else ifdef BUCKET_LIMIT_4
    !define CBP_C_MAX_BNCOUNT               4
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE     11
    !define CBP_MAX_BN_CBOX_PLUS_ONE       19
  !else ifdef BUCKET_LIMIT_5
    !define CBP_C_MAX_BNCOUNT               5
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE     12
    !define CBP_MAX_BN_CBOX_PLUS_ONE       20
  !else ifdef BUCKET_LIMIT_6
    !define CBP_C_MAX_BNCOUNT               6
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE     13
    !define CBP_MAX_BN_CBOX_PLUS_ONE       21
  !else ifdef BUCKET_LIMIT_7
    !define CBP_C_MAX_BNCOUNT               7
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE     14
    !define CBP_MAX_BN_CBOX_PLUS_ONE       22
  !else ifdef BUCKET_LIMIT_8
    !define CBP_C_MAX_BNCOUNT               8
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE     15
    !define CBP_MAX_BN_CBOX_PLUS_ONE       23
  !else

    ; If CBP_MAX_BUCKETS was not defined or if it was not in the
    ; range 2 to 8 inclusive, CBP will use an upper limit of 8 for
    ; the bucket list.

    !define CBP_C_MAX_BNCOUNT               8
    !define CBP_C_MAX_BN_TEXT_PLUS_ONE     15
    !define CBP_MAX_BN_CBOX_PLUS_ONE       23
  !endif

  !ifdef CBP_MAX_BUCKETS
    !undef BUCKET_LIMIT_${CBP_MAX_BUCKETS}
  !endif

#==============================================================================================
# Function CBP_CreateINIfile
#==============================================================================================
# Used to create the InstallOptions INI file defining the custom page used to select the names
# of the POPFile buckets which are to be created for a "clean" install of POPFile.
#----------------------------------------------------------------------------------------------
# Inputs:
#   (none)
#----------------------------------------------------------------------------------------------
# Outputs:
#   (none)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CreateBucketsPage         - the function which "controls" the "Create Buckets" page
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Call CBP_CreateINIfile
#
#==============================================================================================

Function CBP_CreateINIfile

  ;--------------------------------------------------------------------------------------------
  ; Current layout of the 22 fields created by this function:
  ;
  ; [ 1] Instructions for this    [ 6] GroupBox enclosing the list of bucket names
  ;      custom page
  ;                               [ 7] Bucket 1 name  [15] Bucket 1 Remove box
  ;                               [ 8] Bucket 2 name  [16] Bucket 2 Remove box
  ; [ 2] "Create" combobox label  [ 9] Bucket 3 name  [17] Bucket 3 Remove box
  ;                               [10] Bucket 4 name  [18] Bucket 4 Remove box
  ; [ 3] the "Create" combobox    [11] Bucket 5 name  [19] Bucket 5 Remove box
  ;                               [12] Bucket 6 name  [20] Bucket 6 Remove box
  ; [ 4] "Deletion" notes         [13] Bucket 7 name  [21] Bucket 7 Remove box
  ;                               [14] Bucket 8 name  [22] Bucket 8 Remove box
  ;
  ;                               [ 5] - Progress report messages
  ;
  ; NB: These controls must all fit into the 300 x 140 unit 'custom page' area.
  ;
  ; NB: The CBP package makes several assumptions about the layout of these fields!
  ;
  ; [1] The 8 fields used to hold the names of the buckets must be consecutive.
  ;
  ; [2] The 8 fields used to hold the "Remove" boxes must also be consecutive.
  ;
  ; [3] The fields used to hold the "Remove" boxes must be the last fields in the
  ;     INI file because the "NumFields" setting is used to control the display
  ;     of these boxes (e.g. to remove all of the boxes, the CBP package sets
  ;     "NumFields" to one less than the field number of the first box.
  ;
  ; NB: The CBP package also stores some data in this file, in a section called "CBP Data"
  ;--------------------------------------------------------------------------------------------

  ; Constants used to position information on the left-half of the page

  !define CBP_INFO_LEFT_MARGIN      0
  !define CBP_INFO_RIGHT_MARGIN   150

  ; Constants used to position the bucket names

  !define CBP_BN_NAME_LEFT        160
  !define CBP_BN_NAME_RIGHT       250

  ; Constants used to position the "Remove" boxes

  !define CBP_BN_REMOVE_LEFT      250
  !define CBP_BN_REMOVE_RIGHT     298

  ; Constants used to define the position of the 8 rows in the bucket list

  !define CBP_BN_ROW_1_TOP        12
  !define CBP_BN_ROW_1_BOTTOM     20

  !define CBP_BN_ROW_2_TOP        26
  !define CBP_BN_ROW_2_BOTTOM     34

  !define CBP_BN_ROW_3_TOP        40
  !define CBP_BN_ROW_3_BOTTOM     48

  !define CBP_BN_ROW_4_TOP        54
  !define CBP_BN_ROW_4_BOTTOM     62

  !define CBP_BN_ROW_5_TOP        68
  !define CBP_BN_ROW_5_BOTTOM     76

  !define CBP_BN_ROW_6_TOP        82
  !define CBP_BN_ROW_6_BOTTOM     90

  !define CBP_BN_ROW_7_TOP        96
  !define CBP_BN_ROW_7_BOTTOM     104

  !define CBP_BN_ROW_8_TOP        110
  !define CBP_BN_ROW_8_BOTTOM     118

  ; Basic macro used to create the INI file

  !macro CBP_WRITE_INI SECTION KEY VALUE
    WriteINIStr "$PLUGINSDIR\${CBP_C_INIFILE}" "${SECTION}" "${KEY}" "${VALUE}"
  !macroend

  ; Macro used to define a standard control for the custom page
  ; (used for ComboBoxes, the GroupBox and the info Labels)

  !macro CBP_DEFINE_CONTROL FIELD TYPE TEXT LEFT RIGHT TOP BOTTOM
    !insertmacro CBP_WRITE_INI "${FIELD}" "Type" "${TYPE}"

    StrCmp "${TYPE}" "ComboBox" 0 +3
    ; ComboBox control
    !insertmacro CBP_WRITE_INI "${FIELD}" "ListItems" "${TEXT}"
    goto +2

    ; GroupBox or Label control
    !insertmacro CBP_WRITE_INI "${FIELD}" "Text" "${TEXT}"

    ; Remainder is common to "ComboBox", "GroupBox" and "Label" controls
    !insertmacro CBP_WRITE_INI "${FIELD}" "Left" "${LEFT}"
    !insertmacro CBP_WRITE_INI "${FIELD}" "Right" "${RIGHT}"
    !insertmacro CBP_WRITE_INI "${FIELD}" "Top" "${TOP}"
    !insertmacro CBP_WRITE_INI "${FIELD}" "Bottom" "${BOTTOM}"
  !macroend

  ; Macro used to define a label which holds one of the 8 bucket names

  !macro CBP_DEFINE_BN_TEXT FIELD TEXT ROW
    !insertmacro CBP_DEFINE_CONTROL "${FIELD}" \
      "Label" \
      "${TEXT}" \
      "${CBP_BN_NAME_LEFT}" "${CBP_BN_NAME_RIGHT}"  \
      "${CBP_BN_${ROW}_TOP}" "${CBP_BN_${ROW}_BOTTOM}"
  !macroend

  ; Macro used to define a checkbox for marking a bucket name for deletion

  !macro CBP_DEFINE_BN_REMOVE FIELD ROW
    !insertmacro CBP_DEFINE_CONTROL "${FIELD}" \
      "CheckBox" \
      "$(PFI_LANG_CBP_IO_REMOVE)" \
      "${CBP_BN_REMOVE_LEFT}" "${CBP_BN_REMOVE_RIGHT}" \
      "${CBP_BN_${ROW}_TOP}" "${CBP_BN_${ROW}_BOTTOM}"
  !macroend

#----------------------------------------------------------------------------------------------
# Now create the INI file for the "Create Buckets" custom page
#----------------------------------------------------------------------------------------------

  ; Issue standard copyright and GPL notices

  !define L_INI_HANDLE  $R9
  Push ${L_INI_HANDLE}

  FileOpen ${L_INI_HANDLE} "$PLUGINSDIR\${CBP_C_INIFILE}" w

  ; WARNING:
  ; This 'FileWrite' uses a string which is only SIX characters less than the maximum allowed !

  FileWrite ${L_INI_HANDLE} \
    "#-------------------------------------------------------------------$\r$\n\
    #$\r$\n\
    # CBP.ini --- generated by the 'CBP_CreateINIfile' function$\r$\n\
    #$\r$\n\
    # Copyright (c) 2001-2003 John Graham-Cumming$\r$\n\
    #$\r$\n\
    #   This file is part of POPFile$\r$\n\
    #$\r$\n\
    #   POPFile is free software; you can redistribute it and/or modify$\r$\n\
    #   it under the terms of the GNU General Public License as published by$\r$\n\
    #   the Free Software Foundation; either version 2 of the License, or$\r$\n\
    #   (at your option) any later version.$\r$\n\
    #$\r$\n\
    #   POPFile is distributed in the hope that it will be useful,$\r$\n\
    #   but WITHOUT ANY WARRANTY; without even the implied warranty of$\r$\n\
    #   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the$\r$\n\
    #   GNU General Public License for more details.$\r$\n\
    #$\r$\n\
    #   You should have received a copy of the GNU General Public License$\r$\n\
    #   along with POPFile; if not, write to the Free Software$\r$\n\
    #   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA$\r$\n\
    #$\r$\n\
    #-------------------------------------------------------------------$\r$\n\
    $\r$\n"

  FileClose ${L_INI_HANDLE}

  Pop ${L_INI_HANDLE}
  !undef L_INI_HANDLE

  ; The INI file header (all fields made visible)

  !insertmacro CBP_WRITE_INI "Settings" "NumFields" "22"
  !insertmacro CBP_WRITE_INI "Settings" "NextButtonText" "$(PFI_LANG_CBP_IO_CONTINUE)"
  !insertmacro CBP_WRITE_INI "Settings" "BackEnabled" "0"
  !insertmacro CBP_WRITE_INI "Settings" "CancelEnabled" "0"

  ; Label giving brief instructions

  !insertmacro CBP_DEFINE_CONTROL "Field 1" \
      "Label" \
      "$(PFI_LANG_CBP_IO_INTRO)" \
      "${CBP_INFO_LEFT_MARGIN}" "${CBP_INFO_RIGHT_MARGIN}" "0" "56"

  ; Label for the "Create Bucket" ComboBox

  !insertmacro CBP_DEFINE_CONTROL "Field 2" \
      "Label" \
      "$(PFI_LANG_CBP_IO_CREATE)" \
      "${CBP_INFO_LEFT_MARGIN}" "${CBP_INFO_RIGHT_MARGIN}" "58" "90"

  ; ComboBox used to create a new bucket

  !insertmacro CBP_DEFINE_CONTROL "Field 3" \
      "ComboBox" \
      "A|B" \
      "${CBP_INFO_LEFT_MARGIN}" "100" "92" "160"

  ; Instruction for deleting bucket names from the list

  !insertmacro CBP_DEFINE_CONTROL "Field 4" \
      "Label" \
      "$(PFI_LANG_CBP_IO_DELETE)" \
      "${CBP_INFO_LEFT_MARGIN}" "${CBP_INFO_RIGHT_MARGIN}" "108" "140"

  ; Label used to display progress reports

  !insertmacro CBP_DEFINE_CONTROL "Field 5" \
      "Label" \
      " " \
      "157" "300" "124" "140"

  ; Box enclosing the list of bucket names defined so far

  !insertmacro CBP_DEFINE_CONTROL "Field 6" \
      "GroupBox" \
      "$(PFI_LANG_CBP_IO_LISTHDR)" \
      "153" "300" "0" "124"

  ; Text for GroupBox lines 1 to 8

  !insertmacro CBP_DEFINE_BN_TEXT "Field 7"  "Bucket 1" "ROW_1"
  !insertmacro CBP_DEFINE_BN_TEXT "Field 8"  "Bucket 2" "ROW_2"
  !insertmacro CBP_DEFINE_BN_TEXT "Field 9"  "Bucket 3" "ROW_3"
  !insertmacro CBP_DEFINE_BN_TEXT "Field 10" "Bucket 4" "ROW_4"
  !insertmacro CBP_DEFINE_BN_TEXT "Field 11" "Bucket 5" "ROW_5"
  !insertmacro CBP_DEFINE_BN_TEXT "Field 12" "Bucket 6" "ROW_6"
  !insertmacro CBP_DEFINE_BN_TEXT "Field 13" "Bucket 7" "ROW_7"
  !insertmacro CBP_DEFINE_BN_TEXT "Field 14" "Bucket 8" "ROW_8"

  ; "Remove" box for GroupBox lines 1 to 8

  !insertmacro CBP_DEFINE_BN_REMOVE "Field 15" "ROW_1"
  !insertmacro CBP_DEFINE_BN_REMOVE "Field 16" "ROW_2"
  !insertmacro CBP_DEFINE_BN_REMOVE "Field 17" "ROW_3"
  !insertmacro CBP_DEFINE_BN_REMOVE "Field 18" "ROW_4"
  !insertmacro CBP_DEFINE_BN_REMOVE "Field 19" "ROW_5"
  !insertmacro CBP_DEFINE_BN_REMOVE "Field 20" "ROW_6"
  !insertmacro CBP_DEFINE_BN_REMOVE "Field 21" "ROW_7"
  !insertmacro CBP_DEFINE_BN_REMOVE "Field 22" "ROW_8"

  FlushINI "$PLUGINSDIR\${CBP_C_INIFILE}"

  !undef CBP_INFO_LEFT_MARGIN
  !undef CBP_INFO_RIGHT_MARGIN
  !undef CBP_BN_NAME_LEFT
  !undef CBP_BN_NAME_RIGHT
  !undef CBP_BN_REMOVE_LEFT
  !undef CBP_BN_REMOVE_RIGHT
  !undef CBP_BN_ROW_1_TOP
  !undef CBP_BN_ROW_1_BOTTOM
  !undef CBP_BN_ROW_2_TOP
  !undef CBP_BN_ROW_2_BOTTOM
  !undef CBP_BN_ROW_3_TOP
  !undef CBP_BN_ROW_3_BOTTOM
  !undef CBP_BN_ROW_4_TOP
  !undef CBP_BN_ROW_4_BOTTOM
  !undef CBP_BN_ROW_5_TOP
  !undef CBP_BN_ROW_5_BOTTOM
  !undef CBP_BN_ROW_6_TOP
  !undef CBP_BN_ROW_6_BOTTOM
  !undef CBP_BN_ROW_7_TOP
  !undef CBP_BN_ROW_7_BOTTOM
  !undef CBP_BN_ROW_8_TOP
  !undef CBP_BN_ROW_8_BOTTOM

FunctionEnd

#==============================================================================================
# Function CBP_CreateBucketsPage
#==============================================================================================
#
# This function "generates" the POPFile Bucket Selection page.
#
# The Bucket Selection page shows a list of up to 8 buckets which have been selected for
# creation, a data entry field for adding names to this list, and a check box beside each
# name so it can be removed from the list. More than one bucket can be deleted at a time.
#
# Users can mark a bucket name to be deleted and at the same time enter a bucket name to be
# created. This has the effect of renaming a bucket.
#
# The "Continue" button at the foot of the page is used to action any requests. If no name
# has been entered to create a new bucket and no buckets have been marked for deletion, it is
# assumed that the user is happy with the current list therefore if at least two buckets are
# in the list, the 'leave' function creates those buckets and then this function exits.
#
# This function enters a display loop, repeatedly displaying the custom page until the 'leave'
# function (CBP_HandleUserInput) indicates that the user has selected enough buckets.
#----------------------------------------------------------------------------------------------
# Inputs:
#   (none)
#----------------------------------------------------------------------------------------------
# Outputs:
#   (none)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_CREATE_BN               - field number of the "Create Bucket" combobox
#   CBP_C_DEFAULT_BUCKETS         - defines the default bucket selection
#   CBP_C_FIRST_BN_CBOX           - field holding the first "Remove" check box
#   CBP_C_FIRST_BN_CBOX_MINUS_ONE - used when determining how many "remove" boxes to show
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#   CBP_MAX_BN_CBOX_PLUS_ONE      - used in loop which clears the ticks in the 'Remove' boxes
#   CBP_C_MAX_BNCOUNT             - maximum number of buckets installer can handle
#   CBP_C_MESSAGE                 - field number for the progress report message
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   CBP_CreateINIfile             - generates the INI file used to define the custom page
#   CBP_CheckCorpusStatus         - used to determine if this is a "clean" install
#   CBP_SetDefaultBuckets         - initialises the bucket list when page first shown
#   CBP_UpdateAddBucketList       - update list of suggested names seen in "Create" combobox
#----------------------------------------------------------------------------------------------
# Called By:
#   'installer.nsi'               - via the CBP_PAGECOMMAND_SELECTBUCKETS macro
#----------------------------------------------------------------------------------------------
#  Usage Example:
#       !insertmacro CBP_PAGECOMMAND_SELECTBUCKETS
#==============================================================================================

Function CBP_CreateBucketsPage

  ; The CBP_CreateBucketsPage function creates a custom page which uses the CBP_HandleUserInput
  ; function as a "leave" function. The CBP package treats CBP_HandleUserInput as an extension
  ; of CBP_CreateBucketsPage so they share the same registers. To simplify maintenance, a pair
  ; of macros are used to specify the shared registers.

  !macro CBP_HUI_SharedDefs
    !define CBP_L_COUNT         $R9    ; counts number of buckets selected
    !define CBP_L_CREATE_NAME   $R8    ; name (input via combobox) of bucket to be created
    !define CBP_L_LOOP_LIMIT    $R7    ; used when checking the "remove" boxes
    !define CBP_L_NAME          $R6    ; a bucket name
    !define CBP_L_PTR           $R5    ; used to access the names in the bucket list
    !define CBP_L_RESULT        $R4
    !define CBP_L_TEMP          $R3
  !macroend

  !macro CBP_HUI_SharedUnDefs
    !undef CBP_L_COUNT
    !undef CBP_L_CREATE_NAME
    !undef CBP_L_LOOP_LIMIT
    !undef CBP_L_NAME
    !undef CBP_L_PTR
    !undef CBP_L_RESULT
    !undef CBP_L_TEMP
  !macroend

  !insertmacro CBP_HUI_SharedDefs

  Push ${CBP_L_COUNT}
  Push ${CBP_L_CREATE_NAME}
  Push ${CBP_L_LOOP_LIMIT}
  Push ${CBP_L_NAME}
  Push ${CBP_L_PTR}
  Push ${CBP_L_RESULT}
  Push ${CBP_L_TEMP}

  IfFileExists "$PLUGINSDIR\${CBP_C_INIFILE}" use_INI_file
  Call CBP_CreateINIfile

use_INI_file:

  ; We only offer to create POPFile buckets if we are not upgrading an existing POPFile system

  Push $INSTDIR
  Call CBP_CheckCorpusStatus
  Pop ${CBP_L_RESULT}
  StrCmp ${CBP_L_RESULT} "dirty" finished_now

  ; The corpus directory does not exist or is empty

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_CBP_TITLE)" "$(PFI_LANG_CBP_SUBTITLE)"

  ; Reset the bucket list to the default settings

  ; The trailing "|" is used to cover the case where ${CBP_C_DEFAULT_BUCKETS} is an empty string

  Push `${CBP_C_DEFAULT_BUCKETS}|`
  Call CBP_SetDefaultBuckets
  Pop ${CBP_L_COUNT}

input_loop:

  ; Update the status message under the list of bucket names

  IntCmp ${CBP_L_COUNT} 0 zero_so_far
  IntCmp ${CBP_L_COUNT} 1 just_one
  IntCmp ${CBP_L_COUNT} ${CBP_C_MAX_BNCOUNT} at_the_limit

  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_C_MESSAGE}" \
      "Text" "$(PFI_LANG_CBP_IO_MSG_1)"
  goto update_lists

zero_so_far:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_C_MESSAGE}" \
      "Text" "$(PFI_LANG_CBP_IO_MSG_2)"
  goto update_lists

just_one:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_C_MESSAGE}" \
      "Text" "$(PFI_LANG_CBP_IO_MSG_3)"
  goto update_lists

at_the_limit:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_C_MESSAGE}" \
      "Text" "$(PFI_LANG_CBP_IO_MSG_4) ${CBP_C_MAX_BNCOUNT} $(PFI_LANG_CBP_IO_MSG_5)"

update_lists:

  ; Ensure no bucket selected for creation

  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_C_CREATE_BN}" "State" ""

  ; Ensure no buckets are marked for deletion

  StrCpy ${CBP_L_PTR} ${CBP_C_FIRST_BN_CBOX}

clear_loop:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
        "Field ${CBP_L_PTR}" "State" "0"
  IntOp ${CBP_L_PTR} ${CBP_L_PTR} + 1
  IntCmp ${CBP_L_PTR} ${CBP_MAX_BN_CBOX_PLUS_ONE} clear_finished
  Goto clear_loop

clear_finished:

  ; Ensure that only the appropriate "Remove" boxes are shown

  IntOp ${CBP_L_TEMP} ${CBP_L_COUNT} + ${CBP_C_FIRST_BN_CBOX_MINUS_ONE}
  WriteINIStr "$PLUGINSDIR\${CBP_C_INIFILE}" "Settings" "NumFields" "${CBP_L_TEMP}"

  ; Update new bucket suggestions (must be done AFTER updating the number of "Remove" boxes)

  Call CBP_UpdateAddBucketList

  ; Display the "Bucket Selection Page" and wait for user to enter data and click "Continue".
  ; The 'leave' function (CBP_HandleUserInput) updates ${CBP_L_RESULT} after checking user input

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "${CBP_C_INIFILE}"
  StrCmp ${CBP_L_RESULT} "wait" input_loop

finished_now:

  Pop ${CBP_L_TEMP}
  Pop ${CBP_L_RESULT}
  Pop ${CBP_L_PTR}
  Pop ${CBP_L_NAME}
  Pop ${CBP_L_LOOP_LIMIT}
  Pop ${CBP_L_CREATE_NAME}
  Pop ${CBP_L_COUNT}

  !insertmacro CBP_HUI_SharedUnDefs

FunctionEnd

#==============================================================================================
# Function CBP_HandleUserInput
#==============================================================================================
#
# This is the "leave" function for the custom page created by 'CBP_CreateBucketsPage'.
#
# Note that 'CBP_HandleUserInput' is treated as an extension of 'CBP_CreateBucketsPage' so it
# does NOT use the stack to save/restore the registers which it uses - instead it shares the
# same registers used by CBP_CreateBucketsPage.
#
# The 'CBP_CreateBucketsPage' function enters a loop which repeatedly displays the custom page
# until this "leave" function indicates that the necessary buckets have been created. Once the
# user has selected enough buckets, 'CBP_CreateBucketsPage' will exit from the loop and the
# installation will proceed to the next page.
#----------------------------------------------------------------------------------------------
# Inputs:
#   (none)
#----------------------------------------------------------------------------------------------
# Outputs:
#   ${CBP_L_RESULT}               - holds "completed" when user has selected enough buckets,
#                                   holds "wait" if user has not selected enough buckets
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#
#   WARNING:
#   This function shares the local registers used by the 'CBP_CreateBucketsPage' function,
#   as listed in the 'CBP_HUI_SharedDefs' macro which is defined in 'CBP_CreateBucketsPage'.
#
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_CREATE_BN               - field number of the "Create Bucket" combobox
#   CBP_C_FIRST_BN_CBOX           - field holding the first "Remove" check box
#   CBP_C_FIRST_BN_TEXT           - field number of first entry in list of names
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#   CBP_C_MAX_BNCOUNT             - maximum number of buckets installer can handle
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   CBP_FindBucket                - looks for a name in the bucket list
#   CBP_MakePOPFileBuckets        - creates the buckets which POPFile will use
#   CBP_StrCheckName              - used to validate name entered via "Create" combobox
#----------------------------------------------------------------------------------------------
# Called By:
#   (this is the "leave" function for the custom page created by "CBP_CreateBucketsPage")
#==============================================================================================

Function CBP_HandleUserInput

  !insertmacro CBP_HUI_SharedDefs   ; this macro is defined in CBP_CreateBucketsPage

  ; Check the user input... starting with the "Remove" check boxes as deletion has higher
  ; priority (we allow user to "Delete an existing bucket" and "Create a new bucket" when the
  ; bucket list is full)

  StrCpy ${CBP_L_NAME} ${CBP_C_FIRST_BN_TEXT}
  StrCpy ${CBP_L_PTR} ${CBP_C_FIRST_BN_CBOX}
  IntOp ${CBP_L_LOOP_LIMIT} ${CBP_C_FIRST_BN_CBOX} + ${CBP_L_COUNT}

look_for_ticks:
  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_TEMP}" "${CBP_C_INIFILE}" \
      "Field ${CBP_L_PTR}" "State"
  IntCmp ${CBP_L_TEMP} 1 process_deletions
  IntOp ${CBP_L_NAME} ${CBP_L_NAME} + 1
  IntOp ${CBP_L_PTR} ${CBP_L_PTR} + 1
  IntCmp ${CBP_L_PTR} ${CBP_L_LOOP_LIMIT} no_deletes look_for_ticks

no_deletes:
  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_CREATE_NAME}" "${CBP_C_INIFILE}" \
      "Field ${CBP_C_CREATE_BN}" "State"
  StrCmp ${CBP_L_CREATE_NAME} "" no_user_input create_bucket

process_deletions:
  Push ${CBP_L_NAME}

  ; Work through the current entries in the bucket list, removing any entries for which the
  ; "Remove" checkbox has been ticked. The end result will be a list of bucket names without
  ; any gaps in the list. If all names are removed then an empty list will be shown.
  ; NB: The ticks in the 'Remove' boxes are cleared by the 'CBP_CreateBucketsPage' function.

pd_loop:
  IntOp ${CBP_L_NAME} ${CBP_L_NAME} + 1
  IntOp ${CBP_L_PTR} ${CBP_L_PTR} + 1
  IntCmp ${CBP_L_PTR} ${CBP_L_LOOP_LIMIT} tidy_up
  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_TEMP}" "${CBP_C_INIFILE}" \
      "Field ${CBP_L_PTR}" "State"
  IntCmp ${CBP_L_TEMP} 1 pd_loop
  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_TEMP}" "${CBP_C_INIFILE}" \
      "Field ${CBP_L_NAME}" "Text"
  Exch ${CBP_L_NAME}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
      "Field ${CBP_L_NAME}" "Text" "${CBP_L_TEMP}"
  IntOp ${CBP_L_NAME} ${CBP_L_NAME} + 1
  Exch ${CBP_L_NAME}
  goto pd_loop

tidy_up:
  Pop ${CBP_L_NAME}
  IntOp ${CBP_L_TEMP} ${CBP_L_NAME} - ${CBP_C_FIRST_BN_TEXT}

clear_bucket:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_L_NAME}" "Text" ""
  IntOp ${CBP_L_NAME} ${CBP_L_NAME} + 1
  IntOp ${CBP_L_COUNT} ${CBP_L_COUNT} - 1
  IntCmp ${CBP_L_TEMP} ${CBP_L_COUNT} all_tidy_now clear_bucket

all_tidy_now:

  ; Bucket list has no gaps in it now.
  ; User is allowed to delete bucket(s) and create a bucket in one operation

  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_CREATE_NAME}" "${CBP_C_INIFILE}" \
      "Field ${CBP_C_CREATE_BN}" "State"
  StrCmp ${CBP_L_CREATE_NAME} "" get_next_bucket_cmd

create_bucket:
  Push ${CBP_L_CREATE_NAME}
  Call CBP_FindBucket
  Pop ${CBP_L_PTR}
  StrCmp ${CBP_L_PTR} 0 does_not_exist name_exists

does_not_exist:
  IntCmp ${CBP_L_COUNT} ${CBP_C_MAX_BNCOUNT} too_many
  Push ${CBP_L_CREATE_NAME}
  Call CBP_StrCheckName
  Pop ${CBP_L_NAME}
  StrCmp ${CBP_L_NAME} "" bad_name
  IntOp ${CBP_L_PTR} ${CBP_L_COUNT} + ${CBP_C_FIRST_BN_TEXT}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
      "Field ${CBP_L_PTR}" "Text" "${CBP_L_NAME}"
  IntOP ${CBP_L_COUNT} ${CBP_L_COUNT} + 1
  goto get_next_bucket_cmd

name_exists:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_CBP_MBDUPERR_1) $\"${CBP_L_CREATE_NAME}$\" $(PFI_LANG_CBP_MBDUPERR_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBDUPERR_3)"
  goto get_next_bucket_cmd

too_many:
  MessageBox MB_OK|MB_ICONINFORMATION \
      "$(PFI_LANG_CBP_MBMAXERR_1) ${CBP_C_MAX_BNCOUNT} $(PFI_LANG_CBP_MBMAXERR_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBMAXERR_3) ${CBP_C_MAX_BNCOUNT} $(PFI_LANG_CBP_MBMAXERR_2)"
  goto get_next_bucket_cmd

bad_name:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_CBP_MBNAMERR_1) $\"${CBP_L_CREATE_NAME}$\" $(PFI_LANG_CBP_MBNAMERR_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBNAMERR_3)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBNAMERR_4)"
  goto get_next_bucket_cmd

no_user_input:
  IntCmp ${CBP_L_COUNT} 0 need_buckets
  IntCmp ${CBP_L_COUNT} 1 too_few
  MessageBox MB_YESNO|MB_ICONQUESTION \
      "${CBP_L_COUNT} $(PFI_LANG_CBP_MBDONE_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBDONE_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBDONE_3)" IDYES finished_buckets
  goto get_next_bucket_cmd

need_buckets:
  MessageBox MB_OK|MB_ICONINFORMATION \
      "$(PFI_LANG_CBP_MBCONTERR_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBCONTERR_2)"
  goto get_next_bucket_cmd

too_few:
  MessageBox MB_OK|MB_ICONINFORMATION "$(PFI_LANG_CBP_MBCONTERR_3)"
  goto get_next_bucket_cmd

get_next_bucket_cmd:
  StrCpy ${CBP_L_RESULT} "wait"
  Return

finished_buckets:
  Push ${CBP_C_FIRST_BN_TEXT}
  Push ${CBP_L_COUNT}
  Call CBP_MakePOPFileBuckets
  Pop ${CBP_L_RESULT}
  StrCmp ${CBP_L_RESULT} "0" finished_now
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_CBP_MBMAKERR_1) ${CBP_L_RESULT} $(PFI_LANG_CBP_MBMAKERR_2) ${CBP_L_COUNT} \
      $(PFI_LANG_CBP_MBMAKERR_3)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBMAKERR_4)"

finished_now:
  StrCpy ${CBP_L_RESULT} "completed"
  Return

  !insertmacro CBP_HUI_SharedUnDefs   ; this macro is defined in CBP_CreateBucketsPage

FunctionEnd

#==============================================================================================
# Function CBP_SetDefaultBuckets
#==============================================================================================
# Used to create the initial bucket list. The default buckets are added to the list of selected
# buckets then the remaining entries are cleared. The "Remove" check boxes are also reset.
# This function ignores any invalid names in the list of default bucket names.
#
# For convenience this function also validates the list of suggested bucket names and stores the
# results in the INI file used for the "Create Buckets" custom page.
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - string containing the default bucket names,
#                                   separated by "|" chars
#                                   (string is "" or "|" if no defaults required)
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - number of default buckets created,
#                                   in the range 0 to ${CBP_C_MAX_BNCOUNT}
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_FIRST_BN_CBOX           - field number of first "Remove" check box
#   CBP_C_FIRST_BN_TEXT           - field number of first name in list of selected buckets
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#   CBP_C_LAST_BN_TEXT_PLUS_ONE   - used to terminate the loop when clearing out unused entries
#   CBP_C_MAX_BN_TEXT_PLUS_ONE    - used to terminate the loop when adding default bucket names
#   CBP_C_SUGGESTED_BUCKETS       - string holding suggested bucket names, may be empty or "|"
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   CBP_ExtractBN                 - extracts a bucket name from a "|" separated list
#   CBP_FindBucket                - used to check for duplicate names in the default bucket list
#   CBP_StrCheckName              - used to validate name from the list of default buckets
#   CBP_StrStr                    - used to check for duplicate names in suggestions list
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CreateBucketsPage         - the function which "controls" the "Create Buckets" page
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Push "personal|spam|work"
#    Call CBP_SetDefaultBuckets
#    Pop $R0
#
#   ; $R0 holds '3' at this point, indicating that three default buckets were created
#
#==============================================================================================

Function CBP_SetDefaultBuckets

  !define CBP_L_BOX_PTR     $R9   ; used to access the "Remove" check boxes
  !define CBP_L_COUNT       $R8   ; counts number of buckets added to list
  !define CBP_L_NAME        $R7   ; a bucket name (from default list or from suggestions list)
  !define CBP_L_NAMELIST    $R6   ; the list of default bucket names
  !define CBP_L_PTR         $R5   ; used to process suggestions and access names in bucket list
  !define CBP_L_RESULT      $R4
  !define CBP_L_SUGGLIST    $R3   ; the list of (potential) suggested names

  Exch ${CBP_L_NAMELIST}    ; Get list of default names (will be "" or "|" if no names in list)
  Push ${CBP_L_COUNT}
  Exch
  Push ${CBP_L_BOX_PTR}
  Push ${CBP_L_NAME}
  Push ${CBP_L_PTR}
  Push ${CBP_L_RESULT}
  Push ${CBP_L_SUGGLIST}

  ; Validate the list of suggested bucket names (used to update the "Create Bucket" ComboBox)
  ; and store the results in the INI file for later use by the CBP_UpdateAddBucketList function

  StrCpy ${CBP_L_PTR} ""    ; used to hold the list of validated names
  StrCpy ${CBP_L_SUGGLIST} `${CBP_C_SUGGESTED_BUCKETS}|`
  StrCmp ${CBP_L_SUGGLIST} "|" suggestions_done
  StrCmp ${CBP_L_SUGGLIST} "||" suggestions_done

next_sugg:
  Push ${CBP_L_SUGGLIST}
  Call CBP_ExtractBN            ; extract next name from the list of suggested bucket names
  Pop ${CBP_L_SUGGLIST}
  Pop ${CBP_L_NAME}
  StrCmp ${CBP_L_NAME} "" suggestions_done
  Push ${CBP_L_NAME}
  Call CBP_StrCheckName         ; check if name is valid, return "" if invalid
  Pop ${CBP_L_NAME}
  StrCmp ${CBP_L_NAME} "" next_sugg
  Push "${CBP_L_PTR}|"
  Push "|${CBP_L_NAME}|"
  Call CBP_StrStr
  Pop ${CBP_L_RESULT}
  StrCmp ${CBP_L_RESULT} "" 0 next_sugg   ; if name is a duplicate, go look for next name
  StrCpy ${CBP_L_PTR} ${CBP_L_PTR}|${CBP_L_NAME}
  StrCmp ${CBP_L_SUGGLIST} "" suggestions_done next_sugg

suggestions_done:

  ; Now store the validated list of suggestions for bucket names.
  ; An empty suggestions list is represented by "|"

  StrCmp ${CBP_L_PTR} "" 0 save_suggestions
  StrCpy ${CBP_L_PTR} "|"

save_suggestions:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
      "CBP Data" "Suggestions" "${CBP_L_PTR}"

  ; Set up the default bucket list using the data supplied by the calling routine.
  ; If too many default names are supplied, we quietly ignore the "extra" ones.
  ; If duplicated names are supplied, only the first instance is used.

  StrCpy ${CBP_L_COUNT} 0
  StrCpy ${CBP_L_PTR} ${CBP_C_FIRST_BN_TEXT}
  StrCpy ${CBP_L_BOX_PTR} ${CBP_C_FIRST_BN_CBOX}

  StrCmp ${CBP_L_NAMELIST} "|" clear_unused_entry

loop:
  StrCmp ${CBP_L_NAMELIST} "" clear_unused_entry
  Push ${CBP_L_NAMELIST}
  Call CBP_ExtractBN        ; get next default name from the "|" separated list
  Pop ${CBP_L_NAMELIST}
  Call CBP_StrCheckName     ; check if name is valid
  Pop ${CBP_L_NAME}
  StrCmp ${CBP_L_NAME} "" loop  ; ignore invalid names
  Push ${CBP_L_NAME}
  Call CBP_FindBucket
  Pop ${CBP_L_RESULT}
  StrCmp ${CBP_L_RESULT} 0 0 loop ; ignore duplicates

  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
        "Field ${CBP_L_PTR}" "Text" "${CBP_L_NAME}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
        "Field ${CBP_L_BOX_PTR}" "State" "0"
  IntOp ${CBP_L_COUNT} ${CBP_L_COUNT} + 1
  IntOp ${CBP_L_BOX_PTR} ${CBP_L_BOX_PTR} + 1
  IntOp ${CBP_L_PTR} ${CBP_L_PTR} + 1
  IntCmp ${CBP_L_PTR} ${CBP_C_MAX_BN_TEXT_PLUS_ONE} finished_defaults
  StrCmp ${CBP_L_NAMELIST} "" clear_unused_entry
  Goto loop

  ; Now clear the remaining entries in the list
  ; (we process all 8 entries to ensure we start with a clean slate)

clear_unused_entry:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_L_PTR}" "Text" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" "Field ${CBP_L_BOX_PTR}" "State" "0"
  IntOp ${CBP_L_PTR} ${CBP_L_PTR} + 1
  IntOp ${CBP_L_BOX_PTR} ${CBP_L_BOX_PTR} + 1

finished_defaults:
  IntCmp ${CBP_L_PTR} ${CBP_C_LAST_BN_TEXT_PLUS_ONE} finished_now clear_unused_entry

finished_now:
  Pop ${CBP_L_SUGGLIST}
  Pop ${CBP_L_RESULT}
  Pop ${CBP_L_PTR}
  Pop ${CBP_L_NAME}
  Pop ${CBP_L_BOX_PTR}
  Pop ${CBP_L_NAMELIST}
  Exch ${CBP_L_COUNT}     ; top of stack now has number of default buckets created

  !undef CBP_L_BOX_PTR
  !undef CBP_L_COUNT
  !undef CBP_L_NAME
  !undef CBP_L_NAMELIST
  !undef CBP_L_PTR
  !undef CBP_L_RESULT
  !undef CBP_L_SUGGLIST

FunctionEnd

#==============================================================================================
# Function CBP_StrCheckName
#==============================================================================================
# Converts a string containing a bucket name to lowercase and ensures it only contains
# characters in the ranges 'a' to 'z' and '0' to '9', plus the '-' and '_' characters.
# If any invalid characters are found, this function returns "" instead of the converted name.
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - string containing a bucket name (may be an invalid name)
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - valid form of bucket name (or "" if input was not valid)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (None)
#
# Local Registers Destroyed:
#   (None)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   (None)
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CreateBucketsPage         - the function which "controls" the "Create Buckets" page
#   CBP_SetDefaultBuckets         - sets up default buckets and validates the suggestions list
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Push "THIS_IS_A_STRING"
#    Call CBP_StrCheckName
#    Pop $R0
#
#   ($R0 at this point is "this_is_a_string")
#
#   If the string contains invalid characters, a null string is returned.
#
#==============================================================================================

Function CBP_StrCheckName

  ; Bucket names can contain only lowercase letters, digits (0-9), underscores (_) & hyphens (-)

  !define CBP_VALIDCHARS    "abcdefghijklmnopqrstuvwxyz_-0123456789"

  Exch $0   ; The input string
  Push $1   ; Number of characters in ${CBP_VALIDCHARS}
  Push $2   ; Holds the result (either "" or a valid bucket name derived from the input string)
  Push $3   ; A character from the input string
  Push $4   ; The offset to a character in the "validity check" string
  Push $5   ; A character from the "validity check" string
  Push $6   ; Holds the current "validity check" string

  StrLen $1 "${CBP_VALIDCHARS}"
  StrCpy $2 ""

next_input_char:
  StrCpy $3 $0 1              ; Get next character from the input string
  StrCmp $3 "" done
  StrCpy $6 ${CBP_VALIDCHARS}$3  ; Add character to end of "validity check" to guarantee a match
  StrCpy $0 $0 "" 1
  StrCpy $4 -1

next_valid_char:
  IntOp $4 $4 + 1
  StrCpy $5 $6 1 $4   ; Extract next "valid" character (from "validity check" string)
  StrCmp $3 $5 0 next_valid_char
  IntCmp $4 $1 invalid_name 0 invalid_name  ; if match is with the char we added, name is bad
  StrCpy $2 $2$5      ; Use "valid" character to ensure we store lowercase letters in the result
  goto next_input_char

invalid_name:
  StrCpy $2 ""

done:
  StrCpy $0 $2      ; Result is either a valid bucket name or ""
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch $0           ; place result on top of the stack

  !undef CBP_VALIDCHARS

FunctionEnd

#==============================================================================================
# Function CBP_ExtractBN
#==============================================================================================
# Extracts a bucket name from a list of names separated by "|" characters.
#
# If the list of names starts with a "|", this will be ignored and the next name, if any,
# will be returned. If the list contains the sequence "||" this will be treated as "|".
# The sequence "|||" will be treated as an empty name.
#
# Some examples:
#
#     input: "box|car|van"      output: bucket name = "box", revised list = "car|van"
#     input: "box||car|van"     output: bucket name = "box", revised list = "|car|van"
#     input: "|car|van"         output: bucket name = "car", revised list = "van"
#     input: "van"              output: bucket name = "van", revised list = ""
#     input: "box|||car|van"    output: bucket name = "box", revised list = "||car|van"
#     input: "||car|van"        output: bucket name = "",    revised list = "car|van"
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - string containing bucket names separated by "|" chars
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - input string, minus the first bucket name and associated "|"
#   (top of stack - 1)            - first bucket name found in the string (minus the "|")
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (None)
#
# Local Registers Destroyed:
#   (None)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   (None)
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_SetDefaultBuckets         - sets up default buckets (if any)
#   CBP_UpdateAddBucketList       - updates the list of names in "Create Bucket" combobox
#----------------------------------------------------------------------------------------------
#  Usage example:
#
#    Push "|business|junk|personal"   ; using "business|junk|personal" will give same result
#    Call CBP_ExtractBN
#    Pop $R0
#    Pop $R1
#
#   ($R0 at this point is "junk|personal")
#   ($R1 at this point is "business")
#
#   If no name found in the list, $R1 is ""
#   If last name has been extracted from the list, $R0 is ""
#
#==============================================================================================

Function CBP_ExtractBN

  Exch $0             ; get list of bucket names
  Push $1
  Push $2

  ; If the list of names starts with "|" character, ignore the "|"

  StrCpy $2 $0 1
  StrCmp $2 "|" 0 start_now
  StrCpy $0 $0 "" 1

start_now:

  StrCpy $1 ""        ; Reset the output name

Loop:
  StrCpy $2 $0 1      ; Get next character from the list
  StrCmp $2 "" Done
  StrCpy $0 $0 "" 1
  StrCmp $2 "|" Done
  StrCpy $1 $1$2      ; Append character to the output name
  Goto Loop

Done:
  Pop $2
  Exch $1             ; put output name on stack
  Exch
  Exch $0             ; put modified list of names on stack

FunctionEnd

#==============================================================================================
# Function CBP_FindBucket
#==============================================================================================
# Given a bucket name, look for it in the current list and return the field number of the
# matching bucket entry (if name not found, return 0).
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - the bucket name to be found
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - field number of matching bucket name
#                                   (If not found then = 0, else it is a number
#                                   between CBP_C_FIRST_BN_TEXT and CBP_C_MAX_BN_TEXT)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_FIRST_BN_CBOX_MINUS_ONE - used when determining how many bucket names to search
#   CBP_C_FIRST_BN_TEXT           - field number of first entry in list of names
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CreateBucketsPage         - the function which "controls" the "Create Buckets" page
#   CBP_SetDefaultBuckets         - sets up default buckets (if any)
#   CBP_UpdateAddBucketList       - updates the list of names shown by the "Create" combobox
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Push "a_bucket_name"
#    Call CBP_FindBucket
#    Pop $R0
#
#    ; $R0 is 0 if name not found, else it is field number of the name
#
#==============================================================================================

Function CBP_FindBucket

  !define CBP_L_LISTNAME    $R9     ; a name from the bucket list
  !define CBP_L_LOOP_LIMIT  $R8     ; used to terminate processing loop
  !define CBP_L_NAME        $R7     ; the name we are trying to find
  !define CBP_L_PTR         $R6     ; used to access the name fields in the list

  Exch ${CBP_L_NAME}      ; get name of bucket we are to look for
  Push ${CBP_L_PTR}
  Exch
  Push ${CBP_L_LISTNAME}
  Push ${CBP_L_LOOP_LIMIT}

  ; Set loop limit to one more than the field number of last name in the bucket list, using
  ; the number of "Remove" boxes on display to determine how many names, if any, are in the list

  ReadINIStr ${CBP_L_LOOP_LIMIT} "$PLUGINSDIR\${CBP_C_INIFILE}" "Settings" "NumFields"
  IntOp ${CBP_L_LOOP_LIMIT} ${CBP_L_LOOP_LIMIT} - ${CBP_C_FIRST_BN_CBOX_MINUS_ONE}
  IntOp ${CBP_L_LOOP_LIMIT} ${CBP_L_LOOP_LIMIT} + ${CBP_C_FIRST_BN_TEXT}

  ; Loop through the bucket list and check if the bucket name matches the one we are looking for

  StrCpy ${CBP_L_PTR} ${CBP_C_FIRST_BN_TEXT}

check_next_bucket:
  IntCmp ${CBP_L_PTR} ${CBP_L_LOOP_LIMIT} not_found
  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_LISTNAME}" "${CBP_C_INIFILE}" \
      "Field ${CBP_L_PTR}" "Text"
  StrCmp ${CBP_L_NAME} ${CBP_L_LISTNAME} all_done
  IntOp ${CBP_L_PTR} ${CBP_L_PTR} + 1
  goto check_next_bucket

not_found:
  StrCpy ${CBP_L_PTR} 0

all_done:
  Pop ${CBP_L_LOOP_LIMIT}
  Pop ${CBP_L_LISTNAME}
  Pop ${CBP_L_NAME}
  Exch ${CBP_L_PTR}   ; top of stack is now field number of bucket name or 0 if name not found

  !undef CBP_L_LISTNAME
  !undef CBP_L_LOOP_LIMIT
  !undef CBP_L_NAME
  !undef CBP_L_PTR

FunctionEnd

#==============================================================================================
# Function CBP_UpdateAddBucketList
#==============================================================================================
# Updates the combobox list containing suggested names for buckets, ensuring that the list only
# shows names which have not yet been used. Called every time the page is updated.
#----------------------------------------------------------------------------------------------
# Inputs:
#   (none)
#----------------------------------------------------------------------------------------------
# Outputs:
#   (none)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   CBP_C_CREATE_BN               - field number of combobox used to enter new bucket names
#   CBP_C_FULL_COMBO_LIST         - make combobox list full size
#   CBP_C_INIFILE                 - name of the INI file used to create the custom page
#   CBP_C_MIN_COMBO_LIST          - make combobox list one entry high (because it is empty)
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   CBP_ExtractBN                 - extracts a bucket name from a "|" separated list
#   CBP_FindBucket                - checks if a name appears in the bucket list
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CreateBucketsPage         - the function which "controls" the "Create Buckets" page
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Call CBP_UpdateAddBucketList
#
#==============================================================================================

Function CBP_UpdateAddBucketList

  !define CBP_L_PTR         $R9       ; field number of name in bucket list, or 0 if not found
  !define CBP_L_SUGGLIST    $R8       ; the list of (potential) suggested names
  !define CBP_L_SUGGNAME    $R7       ; one name from the list of suggested names
  !define CBP_L_UNUSEDSUGG  $R6       ; unused suggestions (i.e. those not in bucket list)

  Push ${CBP_L_PTR}
  Push ${CBP_L_SUGGLIST}
  Push ${CBP_L_SUGGNAME}
  Push ${CBP_L_UNUSEDSUGG}

  ; Reset the list of suggested names which have not yet been used

  StrCpy ${CBP_L_UNUSEDSUGG} ""

  ; Set up the default list of suggested bucket names (if any).
  ; An empty list is represented by "|" in the INI file

  !insertmacro MUI_INSTALLOPTIONS_READ "${CBP_L_SUGGLIST}" "${CBP_C_INIFILE}" \
      "CBP Data" "Suggestions"
  StrCmp ${CBP_L_SUGGLIST} "|" suggestions_done

next_sugg:
  Push ${CBP_L_SUGGLIST}
  Call CBP_ExtractBN            ; extract next name from the list of suggested bucket names
  Pop ${CBP_L_SUGGLIST}
  Pop ${CBP_L_SUGGNAME}
  StrCmp ${CBP_L_SUGGNAME} "" suggestions_done
  Push ${CBP_L_SUGGNAME}
  Call CBP_FindBucket
  Pop ${CBP_L_PTR}
  StrCmp ${CBP_L_PTR} 0 not_found next_sugg

not_found:
  StrCpy ${CBP_L_UNUSEDSUGG} ${CBP_L_UNUSEDSUGG}|${CBP_L_SUGGNAME}
  StrCmp ${CBP_L_SUGGLIST} "" suggestions_done next_sugg

suggestions_done:

  StrCpy ${CBP_L_UNUSEDSUGG} ${CBP_L_UNUSEDSUGG} "" 1

  ; Now update the combobox with the list of suggestions for bucket names

  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
      "Field ${CBP_C_CREATE_BN}" "ListItems" "${CBP_L_UNUSEDSUGG}"

  ; Adjust size of the ComboBox List to keep the display tidy

  StrCmp ${CBP_L_UNUSEDSUGG} "" min_size
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
      "Field ${CBP_C_CREATE_BN}" "Bottom" "${CBP_C_FULL_COMBO_LIST}"
  goto end_update

min_size:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "${CBP_C_INIFILE}" \
      "Field ${CBP_C_CREATE_BN}" "Bottom" "${CBP_C_MIN_COMBO_LIST}"

end_update:

  Pop ${CBP_L_UNUSEDSUGG}
  Pop ${CBP_L_SUGGNAME}
  Pop ${CBP_L_SUGGLIST}
  Pop ${CBP_L_PTR}

  !undef CBP_L_PTR
  !undef CBP_L_SUGGLIST
  !undef CBP_L_SUGGNAME
  !undef CBP_L_UNUSEDSUGG

FunctionEnd

#==============================================================================================
# Function CBP_StrStr
#==============================================================================================
# Used to search within a string. Returns "" if string is not found, otherwise returns matching
# substring (which may be longer than the string we searched for).
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - string to be searched for
#   (top of stack - 1)            - string in which to search
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - "" if string not found, else the matching substring
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   (none)
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_SetDefaultBuckets         - sets up default buckets (if any)
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Push "this is a long string"
#    Push "long"
#    Call CBP_StrStr
#    Pop $R0
#
#   ($R0 at this point is "long string")
#
#==============================================================================================

Function CBP_StrStr
  Exch $R1    ; $R1 = needle, top of stack = old$R1, haystack
  Exch        ; Top of stack = haystack, old$R1
  Exch $R2    ; $R2 = haystack, top of stack = old$R2, old$R1

  Push $R3
  Push $R4
  Push $R5

  StrLen $R3 $R1
  StrCpy $R4 0

    ; $R1 = needle
    ; $R2 = haystack
    ; $R3 = len(needle)
    ; $R4 = cnt
    ; $R5 = tmp

loop:
  StrCpy $R5 $R2 $R3 $R4
  StrCmp $R5 $R1 done
  StrCmp $R5 "" done
  IntOp $R4 $R4 + 1
  Goto loop

done:
  StrCpy $R1 $R2 "" $R4

  Pop $R5
  Pop $R4
  Pop $R3

  Pop $R2
  Exch $R1
FunctionEnd

#==============================================================================================
# Function CBP_TrimNewlines
#==============================================================================================
# Used to remove any Carriage-Returns and/or Newlines from the end of a string
# (if string does not have any trailing Carriage-Returns or Newlines, it is returned unchanged)
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - string which may end with Carriage-Returns and/or Newlines
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - string with no Carriage Returns or Newlines at the end
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   (none)
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CheckCorpusStatus         - checks if we are performing a "clean" installation
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Push "whatever$\r$\n"
#    Call CBP_TrimNewlines
#    Pop $R0
#
#   ($R0 at this point is "whatever")
#
#==============================================================================================

Function CBP_TrimNewlines
  Exch $R0
  Push $R1
  Push $R2
  StrCpy $R1 0

loop:
  IntOp $R1 $R1 - 1
  StrCpy $R2 $R0 1 $R1
  StrCmp $R2 "$\r" loop
  StrCmp $R2 "$\n" loop
  IntOp $R1 $R1 + 1
  IntCmp $R1 0 no_trim_needed
  StrCpy $R0 $R0 $R1

no_trim_needed:
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

#==============================================================================================
# Function CBP_StrBackSlash
#==============================================================================================
# Used to convert all slashes in a string to backslashes
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - string containing slashes (e.g. "C:/This/and/That")
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - string containing backslashes (e.g. "C:\This\and\That")
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   (none)
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CheckCorpusStatus         - checks if we are performing a "clean" installation
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Push "C:/Program Files/Directory/Whatever"
#    Call CBP_StrBackSlash
#    Pop $R0
#
#   ($R0 at this point is ""C:\Program Files\Directory"\Whatever)
#
#==============================================================================================

Function CBP_StrBackSlash
  Exch $R0    ; Input string with slashes
  Push $R1    ; Output string using backslashes
  Push $R2    ; Current character

  StrCpy $R1 ""
  StrCmp $R0 $R1 nothing_to_do

loop:
  StrCpy $R2 $R0 1
  StrCpy $R0 $R0 "" 1
  StrCmp $R2 "/" found
  StrCpy $R1 "$R1$R2"
  StrCmp $R0 "" done loop

found:
  StrCpy $R1 "$R1\"
  StrCmp $R0 "" done loop

done:
  StrCpy $R0 $R1

nothing_to_do:
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

#==============================================================================================
# Function CBP_GetParent
#==============================================================================================
# Used to extract the parent directory from a path.
#
# NB: Path is assumed to use backslashes (\)
#----------------------------------------------------------------------------------------------
# Inputs:
#   (top of stack)                - string containing a path (e.g. C:\A\B\C)
#----------------------------------------------------------------------------------------------
# Outputs:
#   (top of stack)                - the parent part of the input string (e.g. C:\A\B)
#----------------------------------------------------------------------------------------------
# Global Registers Destroyed:
#   (none)
#
# Local Registers Destroyed:
#   (none)
#----------------------------------------------------------------------------------------------
# Global CBP Constants Used:
#   (none)
#----------------------------------------------------------------------------------------------
# CBP Functions Called:
#   (none)
#----------------------------------------------------------------------------------------------
# Called By:
#   CBP_CheckCorpusStatus         - checks if we are performing a "clean" installation
#----------------------------------------------------------------------------------------------
#  Usage Example:
#
#    Push "C:\Program Files\Directory\Whatever"
#    Call CBP_GetParent
#    Pop $R0
#
#   ($R0 at this point is ""C:\Program Files\Directory")
#
#==============================================================================================

Function CBP_GetParent
  Exch $R0
  Push $R1
  Push $R2

  StrCpy $R1 -1

loop:
  StrCpy $R2 $R0 1 $R1
  StrCmp $R2 "" exit
  StrCmp $R2 "\" exit
  IntOp $R1 $R1 - 1
  Goto loop

exit:
  StrCpy $R0 $R0 $R1
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

#==============================================================================================
# Now destroy all the local/internal "!defines" which were created at the start of this file
#==============================================================================================

  !undef CBP_C_INIFILE

  !undef CBP_C_DEFAULT_BUCKETS
  !undef CBP_C_SUGGESTED_BUCKETS

  !undef CBP_C_CREATE_BN

  !undef CBP_C_FULL_COMBO_LIST
  !undef CBP_C_MIN_COMBO_LIST

  !undef CBP_C_MESSAGE

  !undef CBP_C_FIRST_BN_CBOX
  !undef CBP_C_FIRST_BN_CBOX_MINUS_ONE
  !undef CBP_C_FIRST_BN_TEXT
  !undef CBP_C_LAST_BN_CBOX_PLUS_ONE
  !undef CBP_C_LAST_BN_TEXT_PLUS_ONE

  !undef CBP_C_MAX_BNCOUNT
  !undef CBP_C_MAX_BN_TEXT_PLUS_ONE
  !undef CBP_MAX_BN_CBOX_PLUS_ONE

!endif
#==============================================================================================
# End of CBP.nsh
#==============================================================================================
