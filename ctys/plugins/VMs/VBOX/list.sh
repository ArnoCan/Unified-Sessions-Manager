#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
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

_myPKGNAME_VBOX_LIST="${BASH_SOURCE}"
_myPKGVERS_VBOX_LIST="01.11.006alpha"
hookInfoAdd $_myPKGNAME_VBOX_LIST $_myPKGVERS_VBOX_LIST
_myPKGBASE_VBOX_LIST="`dirname ${_myPKGNAME_VBOX_LIST}`"



#FUNCBEG###############################################################
#NAME:
#  listMySessionsVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all VBOX sessions.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: C|S|B
#     determines the filter to be applied.
#     C: clients
#     S: servers
#     B: both
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function listMySessionsVBOX () {
    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME <$*>"
    local _site=$1;shift

    #controls debugging for awk-scripts
    doDebug $S_VBOX  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    local SUBTYPE=;

    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME $_site <$*>"
    if [ "${C_SESSIONTYPE}" != "VBOX" -a "${C_SESSIONTYPE}" != "ALL" -a "${C_SESSIONTYPE}" != "DEFAULT" ];then 
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected session type:C_SESSIONTYPE=${C_SESSIONTYPE}"
        gotoHell ${ABORT}
    fi

    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "VBOX_MAGIC  =${VBOX_MAGIC}"
    local CLIENTLST=;
    local SERVERLST=;

    #
    #Now normalize versions CLI from 'ps' call within listProcesses
    #
    #Format:
    #
    #  <UNIX process parameters> <vdi-filepath>;[<label>];[<UUID>];[<vrdpport>];[<macaddress1>];
    #
    #  => <UNIX process parameters> = "<uid> <pid> <ppid> <c> <stime> <tty> <time>"
    # 

    # 
    #  "<uid> <pid> <ppid> <c> <stime> <tty> <time> <vdi-filepath> <label> <uuid> <mac> <disp> <cport> <sport>"
    #    $1     $2    $3    $4   $5      $6   $7         $8           $9    $10    $11   $12     $13     $14
    #

    case ${VBOX_MAGIC} in
	VBOX_030102)

	    if [ "${_site}" == S -o "${_site}" == B ];then
		SERVERLST=$(ctysVBOXListLocalServers)
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		case ${C_RESOLVER} in
		    0|OFF)
			CLIENTLST=$(ctysVBOXListClientServers)
			;;
		    1|STAR)
			CLIENTLST=$(ctysVBOXListClientServers)
			CLIENTLST_UNRES=
			;;
		    2|CHAIN)
			CLIENTLST=$(ctysVBOXListClientServers)
			;;
		esac
	    fi
            SUBTYPE=;
  	    ;;
	*)
	    if [ "$VBOX_STATE" != DISABLED ];then
                #ooooops!!!!!!
		ABORT=2
		printERR $LINENO $BASH_SOURCE ${ABORT} "mismatch:VBOX_MAGIC=${VBOX_MAGIC}"
		return ${ABORT}
#		gotoHell ${ABORT}
	    fi
	    ;;
    esac

    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=<${SERVERLST}>"
    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(RAW)=<${CLIENTLST}>"

    if [ -z "${SERVERLST}" -a -z "${CLIENTLST}" ];then
        printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "No sessions yet."
	return
    fi


    #################################
    #This part is to be reworked!!!
    #################################

    export -f getClientTPVBOX
    export -f printDBG
    export -f printERR
    export -f gotoHell
    export VBOX_MAGIC

    ###################################
    #ServerSessions
    ###################################
    [ -n "${SERVERLST}" ]&&SERVERLST=`echo "${SERVERLST}"|\
      awk -v d=$D -v s=$SUBTYPE -f ${_myPKGBASE_VBOX}/serverlst01.awk`

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED-0)=\"${SERVERLST}\""
    case $VBOX_MAGIC in
	VBOX_030102)
            #now in canonical format and does not need exported funcs
            #correct reduced cli-footprint of forked vmw server
	    local il=;
	    local il0=;
	    local il17=;
	    local il8=;
	    local il8x=;
	    for il in ${SERVERLST};do
		if [ -z "$_c" ];then
		    local _c=1;
		    SERVERLST=;
		fi
		printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il=<${il}>"
		il0=${il##;*};
		il07=${il%;*;*;*;*;*;*;*;*;};
                il17=${il07#*;*;*;*;};
		il8x=${il#$il07;};
 		il8=${il8x%%;*;*;*;*;*};
 		il9x=${il8x#*;*;*;*;};
		printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il0=${il0}<>${il8}"
		if [ -z "${il0}" ];then
		    if [ -z "${recurDetect226VBOXLIST}" ];then 
			recurDetect226VBOXLIST=1;
			il0=`fetchLabel4PID ${il8}`
		    fi
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il0 =${il0}"
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il17=${il17}"
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il8 =${il8}"
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il9x =${il9x}"
		    SERVERLST="${SERVERLST} ${il0};${il17};${il8};${il9x}"
		else
		    SERVERLST="${SERVERLST} $il"
		fi
	    done
	    ;;
    esac
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED)=\"${SERVERLST}\""
    


    ###################################
    #ClientSessions
    ###################################
    [ -n "${CLIENTLST}" ]&&CLIENTLST=`echo "${CLIENTLST}"|\
      awk -v d=$D -v s=$SUBTYPE -f ${_myPKGBASE_VBOX}/clientlst02.awk;
      `
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED)=\"${CLIENTLST}\""
    local i=;
    local _myPid=;
    local _myJobID=;
    local reserved01=";;"
    local cstrg=;
    local hrx=;
    local exep=;
    local acc=;
    local arch=;

    for i in ${SERVERLST} ${CLIENTLST};do
	_myPid=${i#*;*;*;*;*;*;*;*;*;}
	_myPid=${_myPid%%;*}
	printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "_myPid=${_myPid}"
	if [ -n "${_myPid}" ];then
	    _myJobID=`cacheGetAttrFromPersistent LAZY "${_myPid}" JOBID`
	    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "_myJobID=${_myJobID}"
	    cstrg="";
	    hrx=${VBOX_PRODVERS};
	    exep=${i%;*;};exep=${exep##*;};
	    acc=${i%;*;*;};acc=${acc##*;};acc=${acc//on/HVM};
	    arch=${i%;};arch=${arch##*;};
	    i="${i%;*;*;*;};${_myJobID}${reserved01};${cstrg};${exep};${hrx};${acc};${arch}";
 	fi

        i="${MYHOST};${i}"
	printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "MATCH=${i}"
	echo "${i}"
    done
}
