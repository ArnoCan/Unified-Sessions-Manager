#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011beta
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VBOX_LIST="${BASH_SOURCE}"
_myPKGVERS_VBOX_LIST="01.11.011beta"
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
	VBOX_03*)

	    if [ "${_site}" == S -o "${_site}" == B ];then
		SERVERLST="$(ctysVBOXListLocalServers)"
	    fi
	    if [ "${_site}" == C -o "${_site}" == B ];then
		case ${C_RESOLVER} in
		    0|OFF)
			CLIENTLST="$(ctysVBOXListClientServers)"
			;;
		    1|STAR)
			CLIENTLST="$(ctysVBOXListClientServers)"
			CLIENTLST_UNRES=
			;;
		    2|CHAIN)
			CLIENTLST="$(ctysVBOXListClientServers)"
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
	    return;
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
    [ -n "${SERVERLST}" ]&&SERVERLST=$(echo "${SERVERLST}"|awk -v d=$D -v s=$SUBTYPE -v mode=1 -f ${_myPKGBASE_VBOX}/clientserverlst.awk;)

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED-0)=\"${SERVERLST}\""
    case $VBOX_MAGIC in
	VBOX_03*)
	    local il=;
	    local il0=;
	    local il17=;
	    local il8=;
	    local il8x=;
	    local _c=;

	    for il in ${SERVERLST};do
		if [ -z "$_c" ];then
		    local _c=1;
		    SERVERLST=;
		fi
		printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il=<${il}>"


                local _lbl="${il%%;*}"
		local _pid="${il#*;*;*;*;*;*;*;}";_pid="${_pid%%;*}"
		if [ -z "${lbl}" ];then
		    if [ -z "${recurDetect226VBOXLIST}" ];then 
			recurDetect226VBOXLIST=1;
			lbl=`fetchLabel4PID ${_pid}`
		    fi
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "lbl =${lbl}"
		fi

		local _myIP=;
                local _A0="${il%%;*}"

                #ID
                local _A1="${il#*;}"
		local _A1="${_A1%%;*}"
		local _uu="${il#*;*;}";_uu="${_uu%%;*}"
		if [ -z "$_A1" -a -n "$_uu" ];then
		    local _x=$(fetchCTYSFile $_uu)
		fi
		if [ -z "$_A1" ];then
		    _A1=$_x
		fi

                #TCP
		local _A2="${il%;*;*;*;*;*;*;*;*;*;*}"
		local _A2="${_A2##*;}"
		if [ -z "$_A2" ];then
		    local _m="${il#*;*;*;}"
		    local _m="${_m%%;*}"
		    local _V="${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -p ${DBPATHLST} -i $_m "
		    printFINALCALL 2  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_V}"

		    local _t=$(eval $_V)
		fi

                #IFNAME -Number
		local _ifn="${il##*;}"



		local _A3="${il#*;*;*;*;}";_A3="${_A3%;*;*;*;*;*}"
		local _A4="${il#*;*;*;*;*;*;*;*;*;*;*;*;*;}";_A4="${_A4%;*;*;*}";
		local _exepath="${il#*;*;*;*;*;*;*;*;*;*;*;*;*;*;}";_exepath="${_exepath%;*;*}";

		local _A5="${il%;*}";_A5="${_A5##*;}";


                local _j=;
		if [ -n "${_pid}" ];then
		    _j=`cacheGetAttrFromPersistent LAZY "${_pid}" JOBID`
		    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "JOBID=${_j}"
		fi

                local _ctx=;
                local _hyv=;

		local _curRec="${MYHOST};${_A0};${_A1};${_uu};${_m};${_A3};${_t};${_j};${_ifn};;${_ctx};${_exepath};${_hyv};${_A4};${_A5}"
		SERVERLST="${SERVERLST} $_curRec"
	    done
	    ;;
    esac
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED)=\"${SERVERLST}\""
    


    ###################################
    #ClientSessions
    ###################################
    [ -n "${CLIENTLST}" ]&&CLIENTLST=$(echo "${CLIENTLST}"|awk -v d=$D -v s=$SUBTYPE -v mode=0 -f ${_myPKGBASE_VBOX}/clientserverlst.awk;)

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED-0)=\"${CLIENTLST}\""
    case $VBOX_MAGIC in
	VBOX_03*)
	    local il=;
	    local il0=;
	    local il17=;
	    local il8=;
	    local il8x=;
	    local _c=;

	    for il in ${CLIENTLST};do
		if [ -z "$_c" ];then
		    local _c=1;
		    CLIENTLST=;
		fi
		printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "il=<${il}>"


                local _lbl="${il%%;*}"
		local _pid="${il#*;*;*;*;*;*;*;}";_pid="${_pid%%;*}"
		if [ -z "${lbl}" ];then
		    if [ -z "${recurDetect226VBOXLIST}" ];then 
			recurDetect226VBOXLIST=1;
			lbl=`fetchLabel4PID ${_pid}`
		    fi
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "lbl =${lbl}"
		fi

		local _myIP=;
                local _A0="${il%%;*}"

                #ID
                local _A1="${il#*;}"
		local _A1="${_A1%%;*}"
		local _uu="${il#*;*;}";_uu="${_uu%%;*}"
		if [ -z "$_A1" -a -n "$_uu" ];then
		    local _x=$(fetchCTYSFile $_uu)
		fi
		if [ -z "$_A1" ];then
		    _A1=$_x
		fi

                #TCP
		local _A2="${il%;*;*;*;*;*;*;*;*;*;*}"
		local _A2="${_A2##*;}"
		if [ -z "$_A2" ];then
		    local _m="${il#*;*;*;}"
		    local _m="${_m%%;*}"
		    local _V="${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -p ${DBPATHLST} -i $_m "
		    printFINALCALL 2  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_VHOST}"

		    local _t=$(eval $_V)
		fi

                #IFNAME -Number
		local _ifn="${il##*;}"

		local _A3="${il#*;*;*;*;}";_A3="${_A3%;*;*;*;*;*}"
		local _A4="${il#*;*;*;*;*;*;*;*;*;*;*;*;*;}";_A4="${_A4%;*;*;*}";
		local _exepath="${il#*;*;*;*;*;*;*;*;*;*;*;*;*;*;}";_exepath="${_exepath%;*;*}";

		local _A5="${il%;*}";_A5="${_A5##*;}";

                local _j=;
		if [ -n "${_pid}" ];then
		    _j=`cacheGetAttrFromPersistent LAZY "${_pid}" JOBID`
		    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "JOBID=${_j}"
		fi

                local _ctx=;
                local _hyv=${VBOX_PRODVERS};

		local _curRec="${MYHOST};${_A0};${_A1};${_uu};${_m};${_A3};${_t};${_j};${_ifn};;${_ctx};${_exepath};${_hyv};${_A4};${_A5}"
		CLIENTLST="${CLIENTLST} $_curRec"
	    done
	    ;;
    esac
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
# 	_myPid=${il#*;*;*;*;*;*;*;}
# 	_myPid=${_myPid%%;*}

# 	printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "_myPid=${_myPid}"
# 	if [ -n "${_myPid}" ];then
# 	    _myJobID=`cacheGetAttrFromPersistent LAZY "${_myPid}" JOBID`
# 	    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "_myJobID=${_myJobID}"
# 	    _prej=${i}

# 	    _poj=${i}

# 	    cstrg="";
# 	    hrx=${VBOX_PRODVERS};
# 	    exep=${i%;*;*;};exep=${exep##*;};
# 	    acc=${i%;*;*;*;};acc=${acc##*;};acc=${acc//on/HVM};
# 	    arch=${i%;*;};arch=${arch##*;};
# 	    i="${i%;*;*;*;};${_myJobID}${reserved01};${cstrg};${exep};${hrx};${acc};${arch}";
#  	fi

#         i="${MYHOST};${i}"
	printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "MATCH=${i}"
	echo "${i}"
    done
}
