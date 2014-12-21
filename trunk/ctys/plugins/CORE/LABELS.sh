#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_07_001b05
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_LABELS="${BASH_SOURCE}"
_myPKGVERS_LABELS="01.07.001b05"
hookInfoAdd "$_myPKGNAME_LABELS" "$_myPKGVERS_LABELS"
_myPKGBASE_LABELS="`dirname ${_myPKGNAME_LABELS}`"

_LABELS="${_myPKGNAME_LABELS}"

#Cache for current running sessions on local host
#normally(almost never) not as big as becoming criticall
CACHE1=""




#FUNCBEG###############################################################
#NAME:
#  fetchID4Label
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  fetchs the ID for a given session label on local host.
#  first match will win.
#
#  The internal usage of the PLUGIN-dispatch function
#
#    listMySessions
#
#  assures the standard format by calling specific interfaces
#  for generation of required record format.
#
#  This is generated at the CLI by the usage of:
#
#    ${MYCALLNAME} -X -a enum=all,full ${MYHOST}
#
#     The current host is the "localhost" but must be 
#     addressed by it's DNS name as filter criteria for
#     search key.
#
#
#  ***ATTENTION***: 
#     The SCOPE is the set of current LOADED-PLUGINS, which could
#     vary even within one call, when subprocesses load a different
#     set of context specific plugins due to manual load.
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#
#OUTPUT:
#  RETURN:
#    0: success
#    1: failure
#  VALUES:
#    <ID>
#FUNCEND###############################################################
function fetchID4Label () {
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:${1}"
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:CACHE1=\"${CACHE1}\""
  if [ -z "$CACHE1" -o "$C_CACHEDOPMEM" == 0 ];then CACHE1=`listMySessions TERSE,MACHINE`;fi
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:CACHE1=\"${CACHE1}\""
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:MYHOST=\"${MYHOST}\""
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:\$1=\"$1\""
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:CALLERJOB=\"${CALLERJOB}\""
  for i in ${CACHE1}; do
    local MATCH=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _h="${MYHOST}" -v _s="${1}" '$1~_h&&$3==_s&&$15!~ji{print $4;}'`
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:i=\"${i}\" =>MATCH=\"${MATCH}\""
    if [ -n "${MATCH}" ];then
      echo ${MATCH};
      return 0;
    fi
  done 
  return 1;
}






#FUNCBEG###############################################################
#NAME:
#  fetchLabel4ID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  fetchs the label for the session given by ID on local host.
#  first match will win.
#
#  This is generated for current host by the usage of:
#    ${MYCALLNAME} -X -a enum=all,full ${MYHOST}
#
#     The current host is the "localhost" but must be 
#     addressed by it's DNS name as filter criteria for
#     search key.
#
#  ***ATTENTION***: 
#     The SCOPE is the set of current LOADED-PLUGINS, which could
#     vary even within one call, when subprocesses load a different
#     set of context specific plugins due to manual load.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <ID>
#
#OUTPUT:
#  RETURN:
#    0: success
#    1: failure
#  VALUES:
#    <LABEL>
#
#FUNCEND###############################################################
function fetchLabel4ID () {
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME ${1}"
  if [ -z "$CACHE1" -o "$C_CACHEDOPMEM" == 0 ];then CACHE1=`listMySessions TERSE,MACHINE`;fi
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "CACHE1=${CACHE1}"
  for i in ${CACHE1}; do
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "i=${i}"
    local MATCH=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _h="${MYHOST}" -v _s="${1}" '$1~_h&&$4~_s&&$15!~ji{print $3;}'`
    if [ -n "${MATCH}" ];then
      echo ${MATCH};
      return 0;
    fi
  done 
  return 1;
}



#FUNCBEG###############################################################
#NAME:
#  fetchLabel4PID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetches the LABEL for the session given by PID on local host.
#
#  Therefore "ctys-wizzard" listMySessions will be utilized.
#
#
#  ***ATTENTION***: 
#     The SCOPE is the set of current LOADED-PLUGINS, which could
#     vary even within one call, when subprocesses load a different
#     set of context specific plugins due to manual load.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <PID>
#
#OUTPUT:
#  RETURN:
#    0: success
#    1: failure
#  VALUES:
#    <LABEL>
#
#FUNCEND###############################################################
function fetchLabel4PID () {
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME ${1}"
  if [ -z "$CACHE1" -o "$C_CACHEDOPMEM" == 0 ];then CACHE1=`listMySessions BOTH,TERSE,MACHINE`;fi
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "CACHE1=${CACHE1}"
  for i in ${CACHE1}; do
      printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "i=${i}"
      local TRIAL=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _pid="${1}" '$11~_pid&&$15!~ji{print $3";"$4;}'`
      if [ -n "${TRIAL}" ];then
	  MATCH=${TRIAL}
	  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "MATCH=\"${MATCH}\""
	  if [ -n "${MATCH%;*}" ];then
	      echo ${MATCH%;*};
	      return 0;
	  fi
      fi
  done

  #not label itself, try to map CS-peer 
  if [ -n "${MATCH}" ];then
      printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "Map peer for:${1} - \"${MATCH}\""
      local _id=${MATCH#*;};_id=${_id%%;*};
      for i in ${CACHE1}; do
	  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "peer:i=${i} - ${_id}"
	  local MATCH=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _id="${_id}" '$2~_id&&$15!~ji{print $1;}'`
	  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "MATCH=\"${MATCH}\""
	  if [ -n "${MATCH}" ];then
	      echo ${MATCH};
	      return 0;
	  fi
      done 
  fi

  return 1;
}

#FUNCBEG###############################################################
#NAME:
#  fetchID4PID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetches the ID for the session given by PID on local host.
#
#  Therefore "ctys-wizzard" listMySessions will be utilized.
#
#
#  ***ATTENTION***: 
#     The SCOPE is the set of current LOADED-PLUGINS, which could
#     vary even within one call, when subprocesses load a different
#     set of context specific plugins due to manual load.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <PID>
#
#OUTPUT:
#  RETURN:
#    0: success
#    1: failure
#  VALUES:
#    <ID>
#
#FUNCEND###############################################################
function fetchID4PID () {
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME ${1}"
  if [ -z "$CACHE1" -o "$C_CACHEDOPMEM" == 0 ];then CACHE1=`listMySessions BOTH,TERSE,MACHINE`;fi
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "CACHE1=${CACHE1}"
  for i in ${CACHE1}; do
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "i=${i}"
    local MATCH=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _pid="${1}" '$11~_pid&&$15!~ji{print $4;}'`
    if [ -n "${MATCH}" ];then
      echo ${MATCH};
      return 0;
    fi
  done 
  return 1;
}


#FUNCBEG###############################################################
#NAME:
#  fetchDisplay4Label
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  fetchs the display number for client of a given session label on local host.
#  first match will win.
#
#  The internal usage of the PLUGIN-dispatch function
#
#    listMySessions
#
#  assures the standard format by calling specific interfaces
#  for generation of required record format.
#
#
#  ***ATTENTION***: 
#     The SCOPE is the set of current LOADED-PLUGINS, which could
#     vary even within one call, when subprocesses load a different
#     set of context specific plugins due to manual load.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#
#OUTPUT:
#  RETURN:
#    0: success
#    1: failure
#  VALUES:
#    <ID>
#FUNCEND###############################################################
function fetchDisplay4Label () {
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME:\$@=${@}"
    case "${1}" in
	ALL)local _scope=1;shift;;
	CHILD)local _scope=2;shift;;
    esac
    if [ -z "$CACHE1" -o "$C_CACHEDOPMEM" == 0 ];then CACHE1=`listMySessions TERSE,MACHINE`;fi
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "CACHE1    = <${CACHE1}>"
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "MYHOST    = <${MYHOST}> - \$1=<${1}>"
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "CALLERJOB = <${CALLERJOB}>"
    for i in ${CACHE1}; do
	printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "i=${i}"
	local MATCH=;
	case "$_scope" in
	    2)MATCH=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _h="${MYHOST}" -v _s="${1// }" '$1~_h&&$3==_s&&$15~ji{print $8;}'`;;
	    1)MATCH=`echo $i|awk -F';' -v _h="${MYHOST}" -v _s="${1// }" '$1~_h&&$3==_s{print $8;}'`;;
	    *)MATCH=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _h="${MYHOST}" -v _s="${1// }" '$1~_h&&$3==_s&&$15!~ji{print $8;}'`;;
	esac
	if [ -n "${MATCH}" ];then
	    echo ${MATCH};
	    return 0;
	fi
    done 
    return 1;
}




#FUNCBEG###############################################################
#NAME:
#  fetchCport4Label
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  fetchs the access port for client of a given session label on local host.
#  first match will win.
#
#  The internal usage of the PLUGIN-dispatch function
#
#    listMySessions
#
#  assures the standard format by calling specific interfaces
#  for generation of required record format.
#
#
#  ***ATTENTION***: 
#     The SCOPE is the set of current LOADED-PLUGINS, which could
#     vary even within one call, when subprocesses load a different
#     set of context specific plugins due to manual load.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#
#OUTPUT:
#  RETURN:
#    0: success
#    1: failure
#  VALUES:
#    <ID>
#FUNCEND###############################################################
function fetchCport4Label () {
echo "4TEST:$LINENO:1=$1">&2
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME ${1}"
  if [ -z "$CACHE1" -o "$C_CACHEDOPMEM" == 0 ];then CACHE1=`listMySessions TERSE,MACHINE`;fi
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "CACHE1=${CACHE1}"
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "MYHOST=${MYHOST} - \$1=\"${1}\""
echo "4TEST:$LINENO:CACHE1=$CACHE1">&2
  for i in ${CACHE1}; do
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "i=${i}"
echo "4TEST:$LINENO:i=$i">&2
    local MATCH=`echo $i|awk -F';' -v ji="${CALLERJOB}" -v _h="${MYHOST}" -v _s="${1// }" '$1~_h&&$3==_s&&$15!~ji{print $9;}'`
    if [ -n "${MATCH}" ];then
      echo ${MATCH};
      return 0;
    fi
  done 
  return 1;
}





#FUNCBEG###############################################################
#NAME:
#  checkUniqueness4Label
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether a running ctys instance already occupied the requested
#  label.
#
#  ***ATTENTION***: 
#     The SCOPE is the set of current LOADED-PLUGINS, which could
#     vary even within one call, when subprocesses load a different
#     set of context specific plugins due to manual load.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <label>
#
#OUTPUT:
#  RETURN:
#    0:  Label not yet present.
#    1:  Label already in use.
#  VALUES:
#
#FUNCEND###############################################################
function checkUniqueness4Label () {
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME ${1}"

  if [ -z "`fetchID4Label ${1}`" ];then
    printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME Label available:${1}"
    return 0;
  fi
  printDBG $S_CORE ${D_BULK} $LINENO $_LABELS "$FUNCNAME Label already in use:${1}"
  return 1;
}




