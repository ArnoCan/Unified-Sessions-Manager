#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
# Copyright (C) 2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################




#FUNCBEG###############################################################
#NAME:
#  getConfFilesList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfFilesList () {
    local fx=;
    for i in "${1%.vdi}.ctys" "${1%.*}.vmx" "${1%.*}.conf" "${1%.*}.ctys" "${1%/*}.ctys" "${CTYSCONF}";do
        [ ! -f "$i" ]&&continue;
	fx="${fx} ${i}"
    done
    echo "${fx}"
}


#FUNCBEG###############################################################
#NAME:
#  getAttrList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getAttrList () {
    tr "'" '"'|\
    sed -n 's/\t//g;s/^ *\([^ ]\+\) *= *"*\([^"]*\)"*.*/\1=\2/p'
}




#FUNCBEG###############################################################
#NAME:
#  getConfValueOfSunOS
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfSunOS () {
    tr "'" '"'|\
    sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'|\
    awk '{if(!x){printf("%s",$0);x=1;}}'
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfMultiSunOS
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  All matches <CR> seperated.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfMultiSunOS () {
    tr "'" '"'|sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfOpenBSD
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfOpenBSD () {
    tr "'" '"'|\
    sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'|\
    awk '{if(!x){printf("%s",$0);x=1;}}'
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfMultiOpenBSD
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  All matches <CR> seperated.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfMultiOpenBSD () {
    tr "'" '"'|sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'
}


#FUNCBEG###############################################################
#NAME:
#  getAttrList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getAttrList () {
    tr "'" '"'|\
    sed -n '
       s/\t//g;
#       s/^ *\([^ ]\+\) *= *"*\([^"]*\)"*.*/\1=\2/;
       s/^ *\([^ ]\+\) *= *\(.*\)$/\1=\2/;
       /===*/d;
       s!^\([^#]*\)#[^@]*[^=]*$!\1!;
       s/^[^=]*)//;
       /^[^=]*$/d;
       /^ *$/d;
       /^ *print  *.*$/d;
       /^ *if  *.*$/d;
       /^ *elif  *.*$/d;
       /^ *[^= ]\+  *[^=]\+=.*$/d;
       p
       '
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfLinux
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfLinux () {
    tr "'" '"'|\
    sed -n 's/\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'|\
    awk '{if(!x){printf("%s",$0);x=1;}}'
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfMultiLinux
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  All matches <CR> seperated.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfMultiLinux () {
    tr "'" '"'|sed -n 's/\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfFreeBSD
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfFreeBSD () {
    tr "'" '"'|\
    sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'|\
    awk '{if(!x){printf("%s",$0);x=1;}}'
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfMultiFreeBSD
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  All matches <CR> seperated.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfMultiFreeBSD () {
    tr "'" '"'|sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'
}



#FUNCBEG###############################################################
#NAME:
#  getAttribute
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of sessiontype/plugin.
#      'NONE' scans files only.
#  $2: Name of attribute, a '.' lists all.
#  $*: Filelist.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getAttribute () {
    local _IP=;
    local _myST=$1;_myST=${_myST:-NONE};shift;
    local _myATTR=$1;_myATTR=${_myATTR:-'.*'};shift;

    for i in ${*};do
	if [ "${_myATTR}" == '.*' ];then
	    cat  "${i}"|getAttrList
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
	    return;
	fi
    done|sort

    for i in ${*};do
	if [ -r "${i}" ];then

	    case $_myST in
		NONE|KVM|QEMU|VMW|XEN)
		    case $MYOS in
			FreeBSD)
			    _IP=`cat  "${i}"|getConfValueOfFreeBSD "$_myATTR"`
			    ;;
			OpenBSD)
			    _IP=`cat  "${i}"|getConfValueOfOpenBSD "$_myATTR"`
			    ;;
			Linux)
			    _IP=`cat  "${i}"|getConfValueOfLinux "$_myATTR"`
			    ;;
			SunOS)
			    _IP=`cat  "${i}"|getConfValueOfSunOS "$_myATTR"`
			    ;;
		    esac
		    ;;

		VBOX)
		    ;;

	    esac
	    #take first
            if [ "$_IP" != "" -a "${_myATTR}" != '.*' ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  setAttribute
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of sessiontype/plugin.
#      'NONE' scans files only.
#  $2: Name of attribute.
#  $3: New value for attribute.
#  $4: Old value of attribute. If provided: has-to-match.
#  $5: <occurance>:=(FIRST|LAST|ALL|#nr); #nv:=1...9999999;
#  $*: Filelist.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function setAttribute () {
    local _IP=;
    local _myST=$1;_myST=${_myST:-NONE};shift;

    local _myATTR=$1;shift;
    if [ -z "$_myATTR" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing attribute name:\"--attribute-name\""
	return
    fi

    local _myATTRNV=$1;shift;
    local _myATTROV=$1;shift;
    local _myOCCUR=$1;shift;

    function setVal () {
	_myOCCUR=$(echo "${_myOCCUR}"|tr 'a-z' 'A-Z');
	_myOCCUR_MAX=$(cat ${i}|grep "${_myATTR}"|wc -l)
	[ "${_myOCCUR}" == FIRST ]&&_myOCCUR=1;
	if [ "${_myOCCUR}" == LAST ];then
	    _myOCCUR="${_myOCCUR_MAX}"
	fi
	if((_myOCCUR>_myOCCUR_MAX));then
	    _myOCCUR="${_myOCCUR_MAX}"
	fi
	if [ -z "${_myOCCUR}" ];then
	    _myOCCUR=1;
	fi

	mv ${i} ${i}.tmp
	awk  -F'=' -v count="$_myOCCUR" -v an="${_myATTR}" -v annv="${_myATTRNV}"  -v anov="${_myATTROV}"  '
           function out(){
             x=$1;
             a=$2;
             if(anov!~/^$/){r=sub(anov,annv,a);}else{r=0;}
             if(r==1){x=x"="a;}
             else{x=x"="annv;}
             for(i=3;i<=NF;i++){x=x"="$i;}
             print x;
           }
           BEGIN{o=0;}
           $1~/^[^#]*#[^@]*/{print;next;}
           NF>1&&$0~/^ *[^ ][^ ]*  *[^=][^=]*/{print;next;}
           NF>1&&$1~an{o++;}
           NF>1&&$1~an&&o==count&&anov~/^$/{out();next;}
           NF>1&&$1~an&&o==count&&$2~anov{out();next;}
           NF>1&&$1~an&&count=="ALL"{out();next;}
           {print;}
           ' ${i}.tmp>${i}
	rm -f ${i}.tmp
    }

    for i in ${*};do
	if [ -r "${i}" ];then

	    case $_myST in
		NONE|KVM|QEMU|VMW|XEN)
		    case $MYOS in
			FreeBSD)
			    setVal "${i}" 
			    break;
			    ;;
			OpenBSD)
			    setVal "${i}" 
			    break;
			    ;;
			Linux)
			    setVal "${i}" 
			    break;
			    ;;
			SunOS)
			    setVal "${i}" 
			    break;
			    ;;
		    esac
		    ;;

		VBOX)
		    ;;

	    esac
	fi
    done
}

