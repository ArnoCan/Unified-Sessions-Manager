#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
# Copyright (C) 2007,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_GENERIC="${BASH_SOURCE}"
_myPKGVERS_GENERIC="01.11.018"
hookInfoAdd $_myPKGNAME_GENERIC $_myPKGVERS_GENERIC

_myPKGBASE_GENERIC="`dirname ${_myPKGNAME_GENERIC}`"


#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedGENERIC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether the split of client and server is supported.
#  This is just a hardcoded attribute and controls the application 
#  matrix of following attribute values of option "-L" locality:
#
#   - CONNECTIONFORWARDING
#   - DISPLAYFORWARDING
#   - SERVERONLY
#   - LOCALONLY
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: If supported
#    1: else
#
#  VALUES:
#
#FUNCEND###############################################################
function clientServerSplitSupportedGENERIC () {
    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	ENUMERATE)return 0;;
	LIST)return 0;;
	SHOW)return 0;;
	INFO)return 0;;
    esac
    return 1;
}


#
#Managed load of sub-packages gwhich are required in almost any case.
#On-demand-loads will be performed within requesting action.
#
hookPackage "${_myPKGBASE_GENERIC}/LIST/list.sh"


#FUNCBEG###############################################################
#NAME:
#  handleGENERIC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Main dispatcher for current plugin. It manages specific actions and
#  context-specific sets of suboptions.
#
#  It has to follow defined interfaces for main framework, due its dynamic
#  detection, load, and initialization.
#  Anything works by naming convention, for files, directories, and function 
#  names so don't alter it.
#
#  Arbitrary subpackages could be defined and chained-loaded. This is due 
#  design decision of plugin developers. Just the entry point is fixed by 
#  common framework.
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
function handleGENERIC () {
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in

      LIST)
	  case ${OPMODE} in
              CHECKPARAM)
                  listCheckParam
		  ;;
              PROLOGUE)
                  #print the prefix
		  if [ -z "${CTYS_SUBCALL}" ];then
		      listMySessions "${C_MODE_ARGS},PROLOGUE"
		  fi
		  ;;
              EPILOGUE)
                  #print the prefix
		  if [ -z "${CTYS_SUBCALL}" ];then
		      listMySessions "${C_MODE_ARGS},EPILOGUE"
		  fi
		  ;;
	      ASSEMBLE)
		  assembleExeccall
		  ;;

	      EXECUTE)
                  if [ -n "${R_TEXT}" ];then
		      echo "${R_TEXT}"|sed 's/-T//'
                  fi
                  EXECCALL="listMySessions ${C_MODE_ARGS}"
		  ;;
	  esac
          ;;

      ENUMERATE)
	  hookPackage "${_myPKGBASE_GENERIC}/ENUMERATE/enumerate.sh"
          #Not critical, thus just pass args, there is anyway not so much to be pre-checked.
	  case ${OPMODE} in
              CHECKPARAM)
                  enumerateCheckParam
		  ;;
              PROLOGUE)
                  #print the prefix
		  if [ -z "${CTYS_SUBCALL}" ];then
		      enumerateMySessions "${C_MODE_ARGS},PROLOGUE"
		  fi
		  ;;
              EPILOGUE)
                  #print the prefix
		  if [ -z "${CTYS_SUBCALL}" ];then
		      enumerateMySessions "${C_MODE_ARGS},EPILOGUE"
		  fi
		  ;;
	      ASSEMBLE)
		  assembleExeccall
		  ;;

	      EXECUTE)
                  if [ -n "${R_TEXT}" ];then
		      echo "${R_TEXT}"|sed 's/-T//'
                  fi
                  EXECCALL="enumerateMySessions ${C_MODE_ARGS}"
		  ;;
	  esac
          ;;

      SHOW|INFO)
	  case ${OPMODE} in
              CHECKPARAM)
		  ;;
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      ASSEMBLE)
		  assembleExeccall
		  ;;

	      EXECUTE)
                  if [ -n "${R_TEXT}" ];then
		      echo "${R_TEXT}"|sed 's/-T//'
                  fi

  		  MYHOOK=${_myPKGBASE_GENERIC}/${ACTION}/${MYOS}
		  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:${MYHOOK}"
                  if [ -d "${MYHOOK}" ];then
		      MYHOOK=${MYHOOK}/${MYOS}.sh
		      if [ -f "${MYHOOK}" ];then
			  hookPackage "${MYHOOK}"
			  ${ACTION}${MYOS}
		      else
			  ABORT=1
			  printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:${MYHOOK}"
			  gotoHell ${ABORT}
		      fi
		  else
		      printWNG 1 $LINENO $BASH_SOURCE 0 "OS=\"${MYOS}\" not supported for ACTION=${ACTION} OPMODE=${OPMODE}"
		  fi
		  gotoHell 0
		  ;;
          esac
          ;;

      *)
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected GENERIC:OPMODE=${OPMODE} ACTION=${ACTION}"
          ;;
  esac
}



#FUNCBEG###############################################################
#NAME:
#  initGENERIC
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
function initGENERIC () {
  local _curInit=$1
  local _raise=$((INITSTATE<_curInit));

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

      case $_curInit in
	  0);;#NOP - Done by shell
	  1)
              #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYPKGPATH}/GENERIC/help/${MYLANG}/010_generic"
	      ;;
	  2);;
	  3);;
	  4);;
	  5);;
	  6);;
      esac
  else
      case $_curInit in
	  *);;
      esac

  fi

}

