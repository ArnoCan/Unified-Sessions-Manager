#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_008
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CLI_LIST="${BASH_SOURCE}"
_myPKGVERS_CLI_LIST="01.10.008"
hookInfoAdd $_myPKGNAME_CLI_LIST $_myPKGVERS_CLI_LIST
_myPKGBASE_CLI_LIST="`dirname ${_myPKGNAME_CLI_LIST}`"



#FUNCBEG###############################################################
#NAME:
#  listMySessionsCLI
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
#OUTPUT:
#  RETURN:
#
#  VALUES:
#    output format: "host:label:id:UUID:pid:uid:gid:sessionType:clientServer"
#
#FUNCEND###############################################################
function listMySessionsCLI () {
    local _site=$1 #only this is relevant for CLI

    #controls debugging for awk-scripts
    doDebug $S_CLI  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?


    printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${*}"
    if [ "${C_SESSIONTYPE}" != "CLI" -a "${C_SESSIONTYPE}" != "ALL" ];then 
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected session type:C_SESSIONTYPE=${C_SESSIONTYPE}"
        gotoHell ${ABORT}
    fi

    if [ "${_site}" == S -o "${_site}" == B -o "${_site}" == C ];then
	local SERVERLST=`listProcesses|awk '/[cC][rR][eE][aA][tT][eE]=/&&/[cC][lL][iI]/&&/ -E /&&!/awk/{print;}'`

        printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=${SERVERLST}"
        local SERVERLST1=`echo "${SERVERLST}"|awk -v d="$D" -f ${_myPKGBASE_CLI}/serverlst01-${MYOS}.awk`
        printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST1(RAW)=${SERVERLST1}"
	local SERVERLST2=;


	for i7 in ${SERVERLST1};do
	    local PID=`echo ${i7}|awk -F';' '{print $8}'`
	    case ${MYOS} in
		Linux)
		    local BTCH=`${PS} ${PSEF} |grep "$PID"|grep -v grep |grep  -e "bash -l"|awk '{print $2}'`
		    ;;
		OpenBSD)
		    local BTCH=`${PS} ${PSEF} |grep "$PID"|grep -v grep |grep  -e "bash -l"|awk '{print $2}'`
#		    local BTCH=`${PS} ${PSL} |grep "$PID"|grep -v -e "-E -F ${VERSION}"|grep -v grep |awk '{print $2}'`
		    ;;
		FreeBSD)
		    local BTCH=`${PS} ${PSEF} |grep "$PID"|grep -v grep |grep  -e "bash -l"|awk '{printf("%s ", $2);}'`
#		    local BTCH=`${PS} ${PSL} |grep "$PID"|grep -v -e "-E -F ${VERSION}"|grep -v grep |awk '{printf("%s ", $2);}'`		    
                    ;;
		SunOS)
		    local BTCH=`${PS} ${PSEF} |grep "$PID"|grep -v grep |grep  -e "bash -l"|awk '{print $2}'`
#		    local BTCH=`${PS} ${PSL} |grep "$PID"|grep -v -e "-E -F ${VERSION}"|grep -v grep |awk '{print $2}'`
		    ;;
	    esac
	    printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "PID=${PID} - BTCH=${BTCH} - VERSION=${VERSION}"
	    if [ -n "${BTCH}" ];then
		local _myMaster=`procGetMyMasterPid ctys CLI CLI e:${BTCH},b:${CALLERJOB}`;
		printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "BTCH=${BTCH} _myMaster=\"${_myMaster}\""
		local S2=`echo "${i7}"|awk -F ';' -v m="${_myMaster}" -v p="${BTCH}" '
                {
                   printf("%s",$1);
                   for(i=2;i<=NF;i++){
		     if(i==8)printf(";%s",p);
                     else if(i==2)printf(";%s",m);
                          else printf(";%s",$i);
                   }
                   printf("\n");
                }'`

		printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "S2=\"${S2}\""
		local _curJobID=`echo "${SERVERLST}"|awk -v p="$PID" '$3~p{x=gsub("^.* -j *","");if(x==0)next;gsub(" .*$","");printf("%s",$0);}'`
		printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "_curJobID=\"${_curJobID}\""
		S3=`echo "${S2}"|awk -F';' -v p="${_curJobID}" '{r="";for(i=1;i<=NF;i++){if(i==14&&$i~/^$/){r=r";"p;}else{r=r";"$i;}}gsub("^;","",r);printf("%s",r);}'`

		if [ "${_curJobID}" != "${_curJobID//$PID/}" -o  "${i7}" != "${i7#ssh }" ];then
		    ignore_axy=;#might be async
		else
		    S3="${S3//CLIENT/SERVER}"
		fi
		local RES0=""
		local IFNAME=""
		local CSTR=""
		local EXEP="${S3%;}"
		EXEP="${EXEP##*;}"
		local HRX="${CLI_PRODVERS}"
		local ACC=""
		local ARCH="$(getCurArch)"
		S3="${S3%;*;};${RES0};${IFNAME};${CSTR};${EXEP};${HRX};${ACC};${ARCH}"
		printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "S3=\"${S3}\""

		SERVERLST2="${SERVERLST2} ${S3}"
	    fi
	done
    fi

    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "SESLST(PROCESSED)=\"${SERVERLST2}\""
    for i in ${SERVERLST2};do
	i="${MYHOST};${i}"
	printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "MATCH=${i}"
	echo "${i}"
    done
}
