#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
#
########################################################################
#
# Copyright (C) 2007,2008,2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VMW_LIST="${BASH_SOURCE}"
_myPKGVERS_VMW_LIST="01.10.013"
hookInfoAdd $_myPKGNAME_VMW_LIST $_myPKGVERS_VMW_LIST
_myPKGBASE_VMW_LIST="`dirname ${_myPKGNAME_VMW_LIST}`"



#FUNCBEG###############################################################
#NAME:
#  listMySessionsVMW
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all VMW sessions.
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
function listMySessionsVMW () {
    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME <$*>"
    local _site=$1;shift

    #controls debugging for awk-scripts
    doDebug $S_VMW  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    #controls marker for subtype, will be used for LIST-ACTION results:
    #current possible:
    #  S<version>: VMware-server
    #              version{1}
    #  W<version>: VMware-workstation
    #              version{6}
    #  P<version>: VMware-player
    #              version{1}
    local SUBTYPE=;

    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME $_site <$*>"
    if [ "${C_SESSIONTYPE}" != "VMW" -a "${C_SESSIONTYPE}" != "ALL" -a "${C_SESSIONTYPE}" != "DEFAULT" ];then 
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected session type:C_SESSIONTYPE=${C_SESSIONTYPE}"
        gotoHell ${ABORT}
    fi

    local _U=`echo $*|sed -n 's/^.* *UUID *.*$/1/p'`

    #Seems OK for now: supports VMware-WS + VMware-Server.
    #When errors occur, first check changes for their process-call-structure!
    #
    #Some former trials as reminder
    #
    # Old production version, 
    # -> OK        for VMware-Server-1.0.x and VMware-WS-5.x, 
    # -> NOT OK    for VMware-WS-6.0:
    #
    #   _SESLST=`listProcesses|grep '.vmx '|grep -v grep`
    #
    # Intermediary restriction on own wrapper:
    # Fixing on own wrapper and beeing blind for rest Is not what is intended!
    #
    #   _SESLST=`listProcesses|awk '/'${MYCALLNAME}'/{print $0;}'|grep '.vmx '|grep -v grep`
    #
    # Currently that's it:


    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "VMW_MAGIC  =${VMW_MAGIC}"
    local CLIENTLST=;
    local SERVERLST=;

    #
    #Now normalize versions CLI from 'ps' call within listProcesses
    #
    #Format:
    #
    #  <UNIX process parameters> <vmx-filepath> [<label>]
    #
    #  => <UNIX process parameters> = "<uid> <pid> <ppid> <c> <stime> <tty> <time>"
    # 

    # 
    #  "<uid> <pid> <ppid> <c> <stime> <tty> <time> <vmx-filepath> <label> <uuid> <mac> <disp> <cport> <sport>"
    #    $1     $2    $3    $4   $5      $6   $7         $8           $9    $10    $11   $12     $13     $14
    #
    #
    #REMARK:
    #  For the client processes the parameters <label=displayName> and <uuid=uuid.bios>
    #  from the vmx-file are passed to the CLI when building the EXECCALL.
    #  This has particularly in case of CONNECTIONFORWARDING the advantage, that later 
    #  no additional remote access is required.
    #
    case ${VMW_MAGIC} in
	VMW_P1*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
		SERVERLST=`listProcesses|sed -n 's/\(.*\)  *\/[^ ]*vmware-vmx *-@ *[^ ]* *\([^ ]*\)/\1 \2/p'`
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		CLIENTLST=`listProcesses|sed 's/--.*$//'|awk -v d=$D -f ${_myPKGBASE_VMW}/clientlst01p.awk`
	    fi
            SUBTYPE=P1;
  	    ;;
	VMW_P2*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
		SERVERLST=`listProcesses|sed -n 's/\(.*\)  *\/[^ ]*vmware-vmx *-# *.*  *\([^ ]*\)$/\1 \2/p'`
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		CLIENTLST=`listProcesses|sed 's/--.*$//'|awk -v d=$D -f ${_myPKGBASE_VMW}/clientlst01p.awk`
	    fi
            SUBTYPE=P2;
  	    ;;
	VMW_P3*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
		SERVERLST=`listProcesses|sed -n 's/\(.*\)  *\/[^ ]*vmware-vmx *-.*  *-# produ.*  *\([^ ]*\)$/\1 \2/p'`
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		CLIENTLST=`listProcesses|sed 's/--.*$//'|awk -v d=$D -f ${_myPKGBASE_VMW}/clientlst01p.awk`
	    fi
            SUBTYPE=P3;
  	    ;;
	VMW_S1*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
                #for S103 the "-s displayName=..." is NOT passed after fork to the backend, 
                #so fetch LABEL and UUID from file - if permissions set.
		SERVERLST=`listProcesses|sed -n 's/\(.*\)  *\/[^ ]*vmware-vmx *-C *\([^ ]*\) .*/\1 \2/p'`
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		CLIENTLST=`listProcesses|sed 's/--.*$//'|awk -v d=$D -f ${_myPKGBASE_VMW}/clientlst01.awk`
	    fi
            SUBTYPE=S1;
  	    ;;
	VMW_S2*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
		SERVERLST=$(ctysVMWS2ListLocalServers)
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		case ${C_RESOLVER} in
		    0|OFF)
			CLIENTLST=$(ctysVMWS2ListLocalClientsEx)
			;;
		    1|STAR)
			CLIENTLST=$(ctysVMWS2ListLocalClientsEx)
			CLIENTLST_UNRES=$(ctysVMWS2ListRemoteClientsEx)
			;;
		    2|CHAIN)
			CLIENTLST=$(ctysVMWS2ListLocalClientsEx; ctysVMWS2ListRemoteClientsEx)
			;;
		esac
	    fi
            SUBTYPE=S2;
  	    ;;
	VMW_WS6*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
                #for WS6 the "-s displayName=..." is passed after fork to the backend, 
                #anyhow, no extra "IF-THEN" now.
 		SERVERLST=`listProcesses|sed -n 's/\(.*\)  *\/[^ ]*vmware-vmx .* \([^ ]*\)$/\1 \2/p'`
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		CLIENTLST=`listProcesses|sed 's/--.*$//'|awk -v d=$D -f ${_myPKGBASE_VMW}/clientlst01.awk`
	    fi
            SUBTYPE=W6;
 	    ;;
	VMW_WS7*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
 		SERVERLST=`listProcesses|sed -n 's/\(.*\)  *\/[^ ]*vmware-vmx .* \([^ ]*\)$/\1 \2/p'`
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		CLIENTLST=`listProcesses|sed 's/--.*$//'|awk -v d=$D -f ${_myPKGBASE_VMW}/clientlst01.awk`
	    fi
            SUBTYPE=W7;
 	    ;;
    esac

    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=<${SERVERLST}>"
    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(RAW)=<${CLIENTLST}>"

    if [ -z "${SERVERLST}" -a -z "${CLIENTLST}" ];then
        printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "No sessions yet."
	return
    fi


    #################################
    #This part is to be reworked!!!
    #################################

    #get-call for displayName from vmx-file
    local _call1="sed -n 's/\t//g;/^#/d;s/displayName *= *\"\\\([^\"]*\\\)\"/\\\1/p' ";

    #get-call for UUID (uuid.bios) from vmx-file
    local _call2="sed -n 's/[ -]//g;s/[^#]*uid.bios *= *\"\\\([^\"]*\\\)\"/\\\1/p' ";

    #get-call for MAC (ethernet0.address) from vmx-file
    local _call3="sed -n 's/[ -]//g;s/^[^#]*ethernet0.address *= *\"\\\([^\"]*\\\)\"/\\\1/p' ";

    #get-call for MAC (ethernet0.generatedAddress) from vmx-file
    local _call4="sed -n 's/[ -]//g;s/^[^#]*ethernet0.generatedAddress *= *\"\\\([^\"]*\\\)\"/\\\1/p' ";

    export -f getClientTPVMW
    export -f printDBG
    export -f printERR
    export -f gotoHell
    export VMW_MAGIC

    ###################################
    #ServerSessions
    ###################################
    [ -n "${SERVERLST}" ]&&SERVERLST=`echo "${SERVERLST}"|\
      awk -v _c1="$_call1" -v _c2="$_call2" -v _c3="$_call3" -v _c4="$_call4" \
          -v d=$D -v s=$SUBTYPE  \
          -f ${_myPKGBASE_VMW}/serverlst01.awk`

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED-0)=\"${SERVERLST}\""
    case $VMW_MAGIC in
	VMW_S[12]*)
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
		printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "il=<${il}>"
		il0=${il##;*};
		il07=${il%;*;*;*;*;*;};
                il17=${il07#*;};
		il8x=${il#$il07;};
 		il8=${il8x%%;*;*};
 		il9x=${il8x#*;};
		printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "il0=${il0}<>${il8}"
		if [ -z "${il0}" ];then
		    if [ -z "${recurDetect226VMWLIST}" ];then 
			recurDetect226VMWLIST=1;
			il0=`fetchLabel4PID ${il8}`
		    fi
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "il0 =${il0}"
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "il17=${il17}"
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "il8 =${il8}"
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "il9x =${il9x}"
		    SERVERLST="${SERVERLST} ${il0};${il17};${il8};${il9x}"
		else
		    SERVERLST="${SERVERLST} $il"
		fi
	    done
	    ;;
    esac
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED)=\"${SERVERLST}\""
    


    ###################################
    #ClientSessions
    ###################################
    [ -n "${CLIENTLST}" ]&&CLIENTLST=`echo "${CLIENTLST}"|\
      awk -v _c1="$_call1" -v _c2="$_call2"  -v _c3="$_call3" -v _c4="$_call4" \
          -v d=$D -v s=$SUBTYPE  \
          -f ${_myPKGBASE_VMW}/clientlst02.awk;
      echo "${CLIENTLST_UNRES}"|\
      awk -v _c1="$_call1" -v _c2="$_call2"  -v _c3="$_call3" -v _c4="$_call4" \
          -v d=$D -v s=$SUBTYPE  \
          -f ${_myPKGBASE_VMW}/clientlstUnres.awk;
      `

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED)=\"${CLIENTLST}\""
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
	_myPid=${i#*;*;*;*;*;*;*;}
	_myPid=${_myPid%%;*}
	printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "_myPid=${_myPid}"
	if [ -n "${_myPid}" ];then
	    _myJobID=`cacheGetAttrFromPersistent LAZY "${_myPid}" JOBID`
	    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "_myJobID=${_myJobID}"
	    cstrg="";
	    hrx=${VMW_PRODVERS};
	    exep=;
	    acc=;
	    arch=;
	    i="${i}${_myJobID}${reserved01};${cstrg};${hrx};${qhrx};${qacc};${qarch}";
 	fi

        i="${MYHOST};${i}"
	printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "MATCH=${i}"
	echo "${i}"
    done
}
