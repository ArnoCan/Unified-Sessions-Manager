#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_006alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_RDP_CANCEL="${BASH_SOURCE}"
_myPKGVERS_RDP_CANCEL="01.11.006alpha"
hookInfoAdd $_myPKGNAME_RDP_CANCEL $_myPKGVERS_RDP_CANCEL
_myPKGBASE_RDP_CANCEL="`dirname ${_myPKGNAME_RDP_CANCEL}`"


#FUNCBEG###############################################################
#NAME:
#  cancelRDP
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
function cancelRDP () {
    local _CSB=${1:-BOTH};shift
    local ACT=${1:-POWEROFF};shift
    local SLST=${@};

    #anyhow, build client and server caches of form: "<id>:<pid>"
    #prefix and postfix spaces are REQUIRED for following regexpr!!!
    local _clientPidCache=" `listMySessions ID,PID,CLIENT,TERSE` "
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "_clientPidCache=<${_clientPidCache}>"

    local _serverPidCache=" `listMySessions ID,PID,SERVER,TERSE` "
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "_serverPidCache=<${_serverPidCache}>"



    function killRequiredRDP () {
	printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
	local _CSB=${1:-BOTH};shift
	local ACT=${1:-POWEROFF};shift
	local ID=${1#*:};shift
	ID=${ID// };
	printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ID=$ID"


        #check it, even though it seems not required,
        #an error might be difficult to find else.
	if [ -n "${ID//[0-9]}" ];then
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Invalid ID:<${1}>"
	    gotoHell ${ABORT}
	fi

	echo 
	printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ID=$ID"

        #first kill clients in any case
        #multiple clients for a shared server will be handled by default as one logical unit
 	local _cx=;
#	local _clientPid=`for _cx in ;do echo ${_cx}|sed -n 's/^.* *'$ID';\([0-9]*\) *.*$/\1/gp';done`
	local _clientPid=`for _cx in ${_clientPidCache};do echo ${_cx}|sed -n 's/^.* *'$ID';\([0-9]*\) *.*$/\1/gp';done`
	printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_clientPid=$_clientPid"
	if [ -n "${_clientPid}" ];then
	    for _cx in ${_clientPid};do
		printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CLIENT:kill ${_cx}"
		echo "kill client:${ID}=>PID=${_cx}"

		case ${ACT} in
		    POWEROFF)kill -9  ${_cx};;
		    *)kill ${_cx};;
		esac
	    done
	fi
    }

    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "SLST=<${SLST}>"
    local _il=;
    for _il in $SLST;do
        killRequiredRDP ${_CSB:-BOTH} ${ACT:-POWEROFF} ${_il}
    done
}


#FUNCBEG###############################################################
#NAME:
#  cutCancelSessionRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Supports: POWEROFF, CANCEL, CUT, LEAVE
#
#  Due to lack of inherent-suspend-awareness of RDP the only applicable
#  procedure is "kill", just the distinction between CLIENT, and BOTH
#  is made.
#
#  The consequences are completeley within the responsibility of the 
#  caller.
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
function cutCancelSessionRDP () {
  local OPMODE=$1;shift
  local ACTION=$1;shift

  local A;
  local KEY;
  local ARG;

  local _CSB=BOTH;
  unset _softonly;
  unset _poweroff;


  case ${OPMODE} in
      CHECKPARAM)
	  ;;

	ASSEMBLE)
	    assembleExeccall
	    ;;

	PROPAGATE)
	    assembleExeccall PROPAGATE
	    ;;

      EXECUTE)
          if [ -n "${R_TEXT}" ];then
	      echo "${R_TEXT}"|sed 's/-T//'
          fi
              #Killing server alone is senseless, so client else both is applicable.
	  local _CSB=BOTH;
	  local SLST=;

          printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=<${C_MODE_ARGS}>"
	  A=`cliSplitSubOpts ${C_MODE_ARGS}`;
          for i in ${A};do
	      KEY=`cliGetKey ${i}`
	      ARG=`cliGetArg ${i}`
	      case $KEY in

                   ##################
                   # Common methods #  
                   ##################
                  REBOOT|RESET|INIT|SUSPEND|PAUSE|S3|S4)
		      printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "SOFTONLY"
                      local _softonly=1;
		      ;;

                  POWEROFF|S5)
		      printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "POWEROFF"
                      local _poweroff=1;
                      local _powoffdelay="${ARG}";
		      ;;

                   #####################
                   # <machine-address> #
                   #####################
		  BASEPATH|BASE|B|TCP|T|MAC|M|UUID|U|FILENAME|FNAME|F|PATHNAME|PNAME|P)
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEY} NOT supported"
		      gotoHell ${ABORT}
		      ;;

                  I|ID)
		      ARGLST=`echo ${ARG}|sed 's/,/ /g' `
		      printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "ARGLST=${ARGLST}"
              	      SLST="${SLST} ${ARGLST}";
		      ;;

		  L|LABEL)
		      local _lbl=${ARG};
		      if [ -z "${C_NOEXEC}" ];then
#              		  SLST1="`fetchID4Label ${_lbl}`"
              		  SLST1="`fetchCport4Label ${_lbl}`"
			  if [ -z "${SLST1}" ];then
			      ABORT=1
			      printERR $LINENO $BASH_SOURCE ${ABORT} "ID could not be evaluated for label(${_lbl})"
			      printERR $LINENO $BASH_SOURCE ${ABORT} "HINT: Not present or you are not the process owner."
			      gotoHell ${ABORT}
			  fi
			  printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "SLST1=${SLST1}"
              		  SLST="${SLST} ${SLST1}"
		      fi
		      ;;


                   #####################
                  ALL)
		      SLST="`listMySessions ID,BOTH,TERSE|awk '{if(follow)printf(\" i:%s\",$1);else printf(\"i:%s\",$1);follow=1;}'`"
		      printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "SLST(ALL)=${SLST}"
		      SLST=`for i in ${SLST};do echo "$i ";done|sort -u`
		      printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "SLST(CORRELATED)=${SLST}"
		      ;;

                  CLIENT)
                      _CSB=CLIENT;
		      ;;

                  SERVER)
                      _CSB=SERVER;
		      ;;

                  BOTH)
                      _CSB=BOTH;
		      ;;

		  *)
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown suboption:<${i}>"
		      gotoHell ${ABORT}
		      ;;
	      esac
          done

	  printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "SLST=<${SLST}>"
	  if [ -n "${_softonly}" -a -n "${_poweroff}" ];then
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "Suboptions CUT|POWEROFF|REBOOT|RESET|SUSPEND has to be used exclusive."
	      gotoHell ${ABORT}
	  fi
	  if [ -n "${_poweroff}" ];then
	      local X=POWEROFF
	  else
	      local X=SOFTONLY
	  fi

          #currently the only and one for RDP, might be extended.
          local _il=;
	  for _il in $SLST;do
              cancelRDP ${_CSB:-BOTH} ${X:-POWEROFF:$_powoffdelay} ${_il}
	  done
          gotoHell 0
	  ;;
  esac
}
