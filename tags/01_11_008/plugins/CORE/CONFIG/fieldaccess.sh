#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a14
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CONFIG="${BASH_SOURCE}"
_myPKGVERS_CONFIG="01.06.001a14"


#default fall back
CTYSCONF=${CTYSCONF:-/etc/ctys.d/[pv]m.conf}





#FUNCBEG###############################################################
#NAME:
#  getField
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the value of a field from a record retrieved by ENUMERATE.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Field number or Field-Key as listed for the ENUMERATE 
#      action in manual.
#  $2: Record in common external ENUMERATE/cacheDB MACHINE format.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    if valid: field value
#
#FUNCEND###############################################################
function getField () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _f=$1;shift
    local _rec=$*
    local _res=;

    #avaoid sub-shell
    case $_f in
	1|PM|HOST)
	    ;;
	2|TYPE)
	    _res=${_rec#*;}
	    ;;
	3|LABEL)
	    _res=${_rec#*;*;}
	    ;;
	4|ID)
	    _res=${_rec#*;*;*;}
	    ;;
	5|UUID)
	    _res=${_rec#*;*;*;*;}
	    ;;
	6|MAC)
	    _res=${_rec#*;*;*;*;*;}
	    ;;
	7|TCP)
	    _res=${_rec#*;*;*;*;*;*;}
	    ;;

	8|DISPLAY)
 	    _res=${_rec#*;*;*;*;*;*;*;}
	    ;;
	9|CPORT)
 	    _res=${_rec#*;*;*;*;*;*;*;*;}
	    ;;
	10|SPORT)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;}
	    ;;
	11|VNCBASE)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;}
	    ;;
	12|DIST)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	13|DISTREL)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	14|OS)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	15|OSREL)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	16|VERNO)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	17|SERNO)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	18|CATEGORY)
 	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	19|VMSTATE)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	20|HYPERREL)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	21|STACKCAP)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	22|STACKREQ)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	23|HWCAP)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	24|HWREQ)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	25|EXECLOCATION)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	26|RELOCCAP)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	27|SSHPORT)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	28|NETNAME)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	29|RESERVED07)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	30|RESERVED08)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	31|RESERVED09)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	32|RESERVED10)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	33|IFNAME)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	34|CTYSRELEASE)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	35|NETMASK)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	36|GATEWAY)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	37|RELAY)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	38|ARCH)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	39|PLATFORM)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	40|VRAM)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	41|VCPU)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	42|CONTEXTSTRING)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	43|USERSTRING)
	    _res=${_rec#*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;*;}
	    ;;
	*)
	    return 1;
	    ;;
    esac
    _res=${_res%%;*}
    echo -n -e "${_res}"
    return 0
}






