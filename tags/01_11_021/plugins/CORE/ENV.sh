#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_ENV="${BASH_SOURCE}"
_myPKGVERS_ENV="01.02.002c01"
hookInfoAdd "$_myPKGNAME_ENV" "$_myPKGVERS_ENV"

#FUNCBEG###############################################################
#NAME:
#  _showEnv
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function _showEnv () {
  local _level=${1:-$D_UID};shift
  local _linePrefix="${1}";shift



awk -v _r=${_level} '{if(_r!=-2)printf("printDBG $S_CORE %d $LINENO $BASH_SOURCE \"%s\"\n",_level,$0)}'<< END0
 
------------------------------------------------------------
|                   Current Environment                    |
------------------------------------------------------------
END0


awk -v _r=${_level} -v _p="${_linePrefix}"  '
  {
    if(_r!=-2) printf("printDBG $S_CORE %d $LINENO $BASH_SOURCE \" %s\"\n",_level,$0);
    else       printf("%s%s\n",_p,$0);
  }
'<< END1 

MYPROJECT                        =
AUTHOR                           =
MAINTAINER                       =
FULLNAME                         =
CALLFULLNAME                     =
LICENCE                          =
VERSION                          =

------

_SUPRESSVERBOSESTARTUP           = ${_SUPRESSVERBOSESTARTUP}

CALLERCACHE                      = $CALLERCACHE
CALLERCACHEREUSE                 = $CALLERCACHEREUSE
CALLERDATETIME                   = $CALLERDATETIME
CALLERJOBID                      = ${CALLERJOBID}
CALLERJOB_IDX                    = $CALLERJOB_IDX
C_ALLOWAMBIGIOUS              = ${C_ALLOWAMBIGIOUS}
C_ASYNC                       = ${C_ASYNC}
C_CACHEAUTO                   = $C_CACHEAUTO
C_CACHEDOP                    = $C_CACHEDOP
C_CACHEKEEP                   = $C_CACHEKEEP
C_CACHERAW                    = $C_CACHERAW
C_CACHEONLY                   = $C_CACHEONLY
C_CACHEPROCESSED              = $C_CACHEPROCESSED
C_CLIENTLOCATION              = ${C_CLIENTLOCATION}
C_EXECLOCAL                   = ${C_EXECLOCAL}
C_FORCE                       = ${C_FORCE}
C_GEOMETRY                    = ${C_GEOMETRY}
C_LISTSES                     = ${C_LISTSES}
C_MDESK                       = ${C_MDESK}
C_MODE                        = ${C_MODE}
C_MODE_ARGS                   = ${C_MODE_ARGS}
C_NOEXEC                      = ${C_NOEXEC}
C_PARALLEL                    = $C_PARALLEL
C_PRINTINFO                   = ${C_PRINTINFO}
C_REMOTE                      = ${C_REMOTE}
C_REMOTERESOLUTION            = ${C_REMOTERESOLUTION}
C_SCOPE                       = ${C_SCOPE}
C_SCOPE_ARGS                  = ${C_SCOPE_ARGS}
C_SCOPE_CONCAT                = ${C_SCOPE_CONCAT}
C_SESSIONFLAG                 = ${C_SESSIONFLAG}
C_SESSIONID                   = ${C_SESSIONID}
C_SESSIONIDARGS               = ${C_SESSIONIDARGS}
C_SESSIONTYPE                 = ${C_SESSIONTYPE}
C_SSH                         = ${C_SSH}
C_SSH_PSEUDOTTY               = ${C_SSH_PSEUDOTTY}
C_TERSE                       = ${C_TERSE}
C_DARGS                       = ${C_DARGS}
DBG                           = ${WNG}
INF                           = ${INF}
WNG                           = ${WNG}
M                             = ${M}
C_WMC_DESK                       = ${C_WMC_DESK}
C_XTOOLKITOPTS                   = ${C_XTOOLKITOPTS}
CTYS_GROUPS_PATH                 = ${CTYS_GROUPS_PATH}
CTYS_MULTITYPE                   = ${CTYS_MULTITYPE}
CTYS_SUBCALL                     = ${CTYS_SUBCALL}

DATE                             = ${DATE}
DATETIME                         = ${DATETIME}
DAYOFWEEK                        = ${DAYOFWEEK}
D_UI                       = ${D_UI}
D_FLOW                      = ${D_FLOW}
D_UID                      = ${D_UID}
D_DATA                  = ${D_DATA}
D_MAINT                    = ${D_MAINT}
D_FRAME                 = ${D_FRAME}
D_BULK                 = ${D_BULK}
DBPATHLST                        = ${DBPATHLST}
DEFAULT_C_MODE_ARGS           = ${DEFAULT_C_MODE_ARGS}
DEFAULT_C_MODE_ARGS_ENUMERATE = ${DEFAULT_C_MODE_ARGS_ENUMERATE}
DEFAULT_C_MODE_ARGS_LIST      = ${DEFAULT_C_MODE_ARGS_LIST}
DEFAULT_C_SCOPE               = ${DEFAULT_C_SCOPE}
DEFAULT_C_SESSIONTYPE         = ${DEFAULT_C_SESSIONTYPE}
DEFAULT_DBPATHLST                = ${DEFAULT_DBPATHLST}
DEFAULT_KILL_DELAY_POWEROFF      = ${DEFAULT_KILL_DELAY_POWEROFF}
DEFAULT_LIST_CONTENT             = ${DEFAULT_LIST_CONTENT}

EXECCALLBASE                     = ${EXECCALLBASE}
EXECCALL                         = ${EXECCALL}
EXECLINK                         = ${EXECLINK}

DATETIME                         = $DATETIME

L_VERS                           = ${L_VERS:-$VERSION}
LOCAL_PORTREMAP                  = ${LOCAL_PORTREMAP}

MYCALLNAME                       = ${MYCALLNAME}
MYLIBEXECPATH                       = ${MYLIBEXECPATH}
MYLIBEXECPATHNAME                   = ${MYLIBEXECPATHNAME}
MYCONFPATH                       = ${MYCONFPATH}
MYDIST                           = ${MYDIST}
MYHELPPATH                       = ${MYHELPPATH}
MYHOST                           = ${MYHOST}
MYINSTALLPATH                    = ${MYINSTALLPATH}
MYBOOTSTRAP                      = ${MYBOOTSTRAP}
MYLANG                           = ${MYLANG}
MYLIBPATH                        = ${MYLIBPATH}
MYMACROPATH                      = ${MYMACROPATH}
MYOPTSFILES                      = ${MYOPTSFILES}
MYOS                             = ${MYOS}
MYPKGPATH                        = ${MYPKGPATH}
MYREL                            = ${MYREL}

PACKAGES_KNOWNTYPES              = ${PACKAGES_KNOWNTYPES}
PR_OPTS                          = ${PR_OPTS}

R_CALL                           = ${R_CALL}
R_CLIENT_DELAY                   = ${R_CLIENT_DELAY}
R_CREATE_MAX                     = ${R_CREATE_MAX}
R_CREATE_TIMEOUT                 = ${R_CREATE_TIMEOUT}
R_HOSTS                          = ${R_HOSTS}
R_OPTS                           = ${R_OPTS}
R_PATH                           = $R_PATH
R_TEXT                           = ${R_TEXT}
R_USERS                          = ${R_USERS}

SSH_ONESHOT_TIMEOUT              = ${SSH_ONESHOT_TIMEOUT}

TARGET_OS                        = ${TARGET_OS}
TIME                             = ${TIME}

X_DESKTOPSWITCH_DELAY            = ${X_DESKTOPSWITCH_DELAY}
X_OPTS                           = ${X_OPTS}

VMW_OPT                          = ${VMW_OPT}
VNCSERVER                        = ${VNCSERVER}
VNCSERVER_OPT                    = ${VNCSERVER_OPT}
VNCVIEWER                        = ${VNCVIEWER}
VNCVIEWER_OPT                    = ${VNCVIEWER_OPT}




END1

(
splitPath         34  "PATH"            "$PATH";
checkPathElements     PATH              $PATH;
splitPath         34  "LD_LIBRARY_PATH" "$LD_LIBRARY_PATH";
checkPathElements     LD_LIBRARY_PATH   "$LD_LIBRARY_PATH";
)|\
awk -v _r=${_level} -v _p="${_linePrefix}"  '
  {
    if(_r!=-2) printf("printDBG $S_CORE %d $LINENO $BASH_SOURCE \" %s\"\n",_level,$0);
    else       printf("%s%s\n",_p,$0);
  }
' 

awk -v _r=${_level} '{if(_r!=-2)printf("printDBG $S_CORE %d $LINENO $BASH_SOURCE \"%s\"\n",_level,$0)}'<< END2
------------------------------------------------------------

END2
  
}


#FUNCBEG###############################################################
#NAME:
#  showEnv
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function showEnv () {
  local _level="${1:-$D_UID}";shift
  local _linePrefix="${1}";shift

  doDebug $S_CORE  ${_level} $LINENO $BASH_SOURCE
  if [ "$?" -eq "0" ];then
    if [ "${_level}" == "-2" ];then 
      _showEnv ${_level} "${_linePrefix}";
    else
      eval "`_showEnv ${_level} \"${_linePrefix}\"; `";
    fi
  fi
}



