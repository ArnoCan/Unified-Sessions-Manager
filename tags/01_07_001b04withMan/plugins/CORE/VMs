#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a13
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VMs="${BASH_SOURCE}"
_myPKGVERS_VMs="01.02.002c01"
hookInfoAdd "$_myPKGNAME_VMs" "$_myPKGVERS_VMs"



#FUNCBEG###############################################################
#NAME:
#  pnameIsUnique
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks provided "PNAME" for uniqueness.
#
#  Does not return when ambiguous.
#
#EXAMPLE:
#
#GLOBALS:
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
function pnameIsUnique () {
    local _utst=`echo "$*"|testUniqueOnly`
    case $_utst in
	AMBIGUOUS*)
	    ABORT=1;
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "Query filesystem for key UNIQUE \"${_chkKey}\" is $_utst"
            local _ecnt=1;
            local _ei=;
	    for _ei in $_pname;do
 		printERR $LINENO $BASH_SOURCE ${ABORT} "#${_ecnt} \"p:${_ei}\""
		let _ecnt++;
	    done
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "VMSTATE is ignored for implicit filesystem-search due to several reasons."
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check/consider following solutions:"
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "  1. Set backups to be ignored by \"MAGICID-IGNORE\", this is required"
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "     also for the generation of unambiguous cacheDB entries."
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "  2. Force usage of local nameservice cacheDB only by \"-c local\"."
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "  3. Update the remote nameservice cacheDB."
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "  4. Check requested KEY within configuration files, such as LABEL,"
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "     for uniqueness."
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "  5. Use fully qualified pathname \"p:/<absolute-pathname>\""
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "     when nothing else should be changed."
	    gotoHell ${ABORT};
	    ;;
    esac
}
