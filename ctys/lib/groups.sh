#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_016
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_GROUPS="${BASH_SOURCE}"
_myPKGVERS_GROUPS="01.11.016"
libManInfoAdd "$_myPKGNAME_GROUPS" "$_myPKGVERS_GROUPS"

export _idxHosts=-1;
export _idxGroups=-1;

#FUNCBEG###############################################################
#NAME:
#  fetchGroupMembers
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function looks in the path ${MYGROUPS} for the given groupname 
#  and 
#
#    1. when none file with given name found, just returns the name
#       itself as the only member
#
#    2. when a file found, reads in the listed members and returns the
#       scanned list.
#
#
#PARAMETERS:
#
#
#  $1: <group-file-name>
#      Will be searched in the directory ${MYGROUPPATH} only.
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    List of group members space seperated list within one line.
#
#FUNCEND###############################################################
function fetchGroupMembers () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ARGV=${*}"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"

    local _grpfile=;
    local i=;

    local _fetched=;
    local x=;

    local MAXRECURSE=${CTYS_MAXRECURSE:-15};
    function getIncludeTree () {
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ARGV=${*}"
	local _lvlcnt=${_lvlcnt:-0};
	if((_lvlcnt++>MAXRECURSE));then
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Exceeding nesting level of \"#include ...\" for:$_grpfile"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "For simplicity just recursion level is checked:MAXRECURSE=${MAXRECURSE}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Loop conditions are within the responsibility of the caller."
	    gotoHell ${ABORT} 
	fi

	local _infilelst=$*;
	local _resultlst=;
	local i=;
	local j=;
        local jf=;

	for j in $_infilelst;do
	    local _jd=${j%/*}
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:j               =${j}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_jd             =${_jd}"

            #lazy only, little too much temporary environment, but correct matches!
	    if [ -n "${_jd}" -a "${_jd}" != "${j}" -a "${_jd}" != "." -a "${CTYS_GROUPS_PATH//$_jd/}" == "${CTYS_GROUPS_PATH}" ];then
		CTYS_GROUPS_PATH="${PWD}/${_jd}${CTYS_GROUPS_PATH:+:$CTYS_GROUPS_PATH}"
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    fi
	    local _j=${j%:*}
	    jf="`matchFirstFile $_j ${CTYS_GROUPS_PATH}`";
	    if [ ! -f "${jf}"  ];then
		jf="`matchFirstFile ${_j#*@} ${CTYS_GROUPS_PATH}`";
	    fi
	    if [ -z "${jf}" ];then
		break;
	    fi
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:jf=${jf}"
	    if [ ! -f "${jf}" ];then
		if((_lvlcnt>1));then
		    ABORT=2
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing included group:${j} => ${jf}"
		    return ${ABORT} 
		else
		    echo $j
		fi
	    else
		echo $jf
		local _inclst="`sed -n '/^#[^i]/d;s/\"//g;s/,/ /g;s/^#include  *\(.*\)/\1/p' $jf` ";
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_inclst=${_inclst}"
		for i in $_inclst;do
		    getIncludeTree $i
		done
	    fi
	done
    }

    if [ -z "${*}" ];then
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:No input"
	return
    fi

    if [ -z "${CTYS_GROUPS_PATH}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing variable:CTYS_GROUPS_PATH"
	gotoHell ${ABORT} 
    fi

    local _matchone=;
    for i in ${CTYS_GROUPS_PATH//:/ };do
	if [ ! -d "${i}" ];then
	    ABORT=1
	    printWNG 2 $LINENO $BASH_SOURCE 0 "Missing directory:CTYS_GROUPS_PATH(${i})"
	else
	    _matchone=1;
	fi
    done
    if [ -z "${_matchone}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "No directory available from:CTYS_GROUPS_PATH=<${CTYS_GROUPS_PATH}>"
	gotoHell  ${ABORT} 
    fi

    if [ -z "${C_ALLOWAMBIGIOUS}" ];then
	_grpfile=`getIncludeTree ${*}`
    else
	_grpfile=`getIncludeTree ${*}|sort -u`
    fi

    if [ -z "${_grpfile}" -a $? -ne 0 ];then 
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "No definition found, cancel expansion:${*}"
	return ${ABORT} 
    fi

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_grpfile=${_grpfile}"

    if [ "${_grpfile#-}" != "${_grpfile}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "It seems that options appear as arguments:${_grpfile}"
	return ${ABORT} 
    fi

    local x=;
    for i in ${_grpfile};do
	if [ -f "$i" ];then
	    x="${x}"`awk '
		/^#.*$/          {next;} 
		/^[[:space:]]*$/ {next;} 
                {printf("°°%s",$0);}
		' ${i}`
	else
	    x="${x}°°${i}"
	fi
    done
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:trial as group:\"${x}\""
    x=${x//\"}
    x=`echo ${x}|sed 's/  */ /g;s/^ *//;s/ *$//;s/^°*//;s/°*$//'`
    if [ -n "${x// /}" -a "${x%)}" == "${x}" ];then
	x="${x}°°"
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "x=<${x}>"

    #let the shell permutate
    if [ "${x//CONTEXT/}" != "${x}" ];then

	local cont=;
	cont=`echo " ${x} "|sed -n '
	s/CONTEXT["'\'']*(\([^)]*\))["'\'']*/-_-@ \1 @-_-/g;
	s/@-_-[^-]*-_-@//g;
	s/^[^-]*-_-@//;
	s/@-_-[^-]*[^_]*$//;
	p'`
	x=`echo " ${x} "|sed -n 's/CONTEXT["'\'']*([^)]*)["'\'']*//g;s/ *, */,/g;s/^,*//;s/ *$//;p'`

	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "context=<${cont}>"
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "targets=<${x}>"
	if [ -z "${x}" ];then
            return
	fi

	x=`echo " $x "|sed 's/(/()/g'|awk -F'(' -v c="$cont" '
		{
		    for(i=1;i<=NF;i++){
			x=$i;
			t0=gsub(")[^)]*$","",x);
			tmatch=gsub("^)","",x);
			if(tmatch!=0){
				gsub(" ","-_-_",x);
				context="("x")"
				gsub(".*)","",$i);
				result=result""context""$i;
				}else{
				result=result""$i;
			    }
		    }
		    gsub("  "," ",result);
		    gsub("^ *","",result);
		    gsub(" *$","",result);
		    gsub("°°","()°°",result);
		    gsub(")()",")",result);
		    gsub(",$","",result);
		    gsub("[(]","("c,result);
		    gsub("%,%"," ",result);
		    gsub("-_-_"," ",result);
		    gsub("°°"," ",result);

 		}
		END{
		    gsub("^([^)]*)"," ",result);
		    gsub("^ *)"," ",result);
		    print result;
		}
		'`
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "x=<${x}>"
	cont=;
    fi

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "Eliminate braces of chained context-options"
    x="${x%%°}";x="${x##°}"
    x=`echo $x|sed 's/'\''(/(/g;s/)'\''/)/g;s/"(/(/g;s/)"/)/g;s/)(/ /g;s/°°*/ /g;s/ *//;s/ *$//;s/^,*//;s/,*$//;'`
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:found group:\"${x}\""
    if [ "${x//,/}" != "${x}" ];then 
	echo "{${x}}"
        return
    fi
    echo "${x}"
}



#FUNCBEG###############################################################
#NAME:
#  expandGroups
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function expands all available groups within an intermixed argument 
#  list containing hosts, groups, and subtasks. Context specific optionlists 
#  in common parantheis-notation for each entry is supported, additional common 
#  option could be provided, which will be permutated as chained context options 
#  to be added to eventually present options.
#
#  When the same option occurs multiple times, the last will overwrite 
#  any previous value and wins. Anyhow, some might be checked for exclusive only
#  appearence and therefore may lead to an detected error condition.
#
#PARAMETERS:
#  $1: <arglist>
#      Arguments to be expanded.
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    Expanded list, where each context block is permutated to all members.
#
#FUNCEND###############################################################
function expandGroups () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ARGV=${*}"
    local _hostlst=$*;
    if [ ! -d "${CTYS_GROUPS_TMPPATH}" ];then
	mkdir -p "${CTYS_GROUPS_TMPPATH}"
	if [ ! -d "${CTYS_GROUPS_TMPPATH}" ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot create missing:${CTYS_GROUPS_TMPPATH}"
	    gotoHell ${ABORT};
	fi
    fi

    local _myTmpSubNameBase=${CTYS_GROUPS_TMPPATH}/`date +%Y%m%d%H%M%S`-${RANDOM}
    local _myFIdx=0;

    function checkForClear () {
	local _nx=0;
	local i=;
	CTYS_CLEARTMPGROUPS=${CTYS_CLEARTMPGROUPS:-100}
	for i in ${CTYS_GROUPS_TMPPATH}/*;do let _nx++;done; 
	if((_nx>CTYS_CLEARTMPGROUPS));then
	    find ${CTYS_GROUPS_TMPPATH} -type f -ctime +1 -exec rm {} \;
	fi
    }

    function extractSubtask () {
        local _myKey=${1};
        _myKey=${_myKey// /};

	if [ "${_hostlst}" == "${_hostlst//$_myKey/}" ];then
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:No-Match:<${_myKey}>"
	    return
	fi

	checkForClear

	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-GROUPS-KEY:<${_myKey}>"
        local _myContext=;
        case ${_myKey} in
	    SUBTASK)R_OPTS="${R_OPTS} -w  ";_myContext="(-w)";;#for now !!!
	    SUBGROUP)R_OPTS="${R_OPTS} -w ";_myContext="(-w)";;#for now !!!
	    VMSTACK)R_OPTS="${R_OPTS} -w ";_myContext="(-b STACK)";;
	    *)
		ABORT=2;
		printERR $LINENO $BASH_SOURCE ${ABORT} "SUBTASK-KEY not supportes:${_myKey}"
		gotoHell ${ABORT};
		;;
	esac
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:R_OPTS:<${R_OPTS}>"
	local _mySubLst=x;
	while [ -n "${_mySubLst// }" ];do 
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_mySubLst=${_mySubLst}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst=${_hostlst}"
	    if [ "${_hostlst#*$_myKey[\"\']}" ==  "${_hostlst}" ];then
		if [ "${_hostlst#*$_myKey(}" ==  "${_hostlst}" ];then
 		    _mySubLst=`echo " ${_hostlst} "|sed -n 's/^.*\('"${_myKey}"'{[^}]*}\).*/\1/p'`;
		else
 		    _mySubLst=`echo " ${_hostlst} "|sed -n 's/^.*\('"${_myKey}"'\)\(([^)])\)\({[^}]*}\).*/\2-_-\1\3/p'`;
		    local _stackArgs="${_mySubLst%-_-*}"
		    _mySubLst="${_mySubLst#*-_-}"
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_stackArgs=${_stackArgs}"
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_mySubLst=${_mySubLst}"
		fi
	    else
 		if [ "${_hostlst#*$_myKey\'(}" !=  "${_hostlst}" ];then
 		    _mySubLst=`echo " ${_hostlst} "|sed -n 's/^.*\('"${_myKey}"'[^(]*\)\(([^)]*)\)\({[^}]*}\).*/\2-_-\1\3/p'`;
 		    local _stackArgs="${_mySubLst%-_-*}"
 		    _mySubLst="${_mySubLst#*-_-}"
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_stackArgs=${_stackArgs}"
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_mySubLst=${_mySubLst}"
  		else
		    if [ "${_hostlst#*$_myKey\"(}" !=  "${_hostlst}" ];then
 			_mySubLst=`echo " ${_hostlst} "|sed -n 's/^.*\('"${_myKey}"'[^(]*\)\(([^)]*)\)\({[^}]*}\).*/\2-_-\1\3/p'`;
			local _stackArgs="${_mySubLst%-_-*}"
			_mySubLst="${_mySubLst#*-_-}"
 			printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_stackArgs=${_stackArgs}"
 			printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_mySubLst=${_mySubLst}"
 		    else
  			_mySubLst=`echo " ${_hostlst} "|sed -n 's/^.*\('"${_myKey}"'["'\'']{[^}]*}["'\'']\{0,1\}\).*/\1/p'`;
 		    fi
 		fi
	    fi

	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_mySubLst =${_mySubLst}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst  =${_hostlst}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_stackArgs=${_stackArgs}"
	    if [ -n "${_stackArgs}" ];then
		_hostlst=`echo " ${_hostlst} "|sed 's/'"${_stackArgs}"'//'`;
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst =${_hostlst}"
	    fi
	    if [ -n "${_mySubLst}" ];then
		local _myTmpSubName=`printf "%s-%04d" ${_myTmpSubNameBase} ${_myFIdx}`
		local _myTmpSubNameA="${_myTmpSubName}"
		local _myTmpSubGroup="${_myTmpSubName##*/}"

		let _myFIdx++;
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myTmpSubNameA=<${_myTmpSubNameA}>"
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myTmpSubGroup=<${_myTmpSubGroup}>"
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myContext    =<${_myContext}>"

		if [ "${_hostlst#*$_myKey[\"\']}" ==  "${_hostlst}" ];then
		    _hostlst=`echo " ${_hostlst} "|sed 's/'"${_myKey}"'{[^}]*}/'"${_myTmpSubGroup}${_myContext}"'/'`;
		else
		    local _chk1=;
		    _chk1="${_hostlst#$_myKey}"
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_chk1=${_chk1}"
		    local _myx=;
		    if [ "${_chk1}" != "${_chk1#\"}" ];then
			_myx="\\\"";
		    else
			if [ "${_chk1}" != "${_chk1#\'}" ];then
			    _myx="\\\'";
			fi
		    fi
                    if [ "${_chk1}" != "${_chk1#\}\(}" ];then
			_hostlst=`echo " ${_hostlst} "|sed 's/'"${_myKey}"'["'\'']{[^}]*}/'"${_myTmpSubGroup}${_myx}${_myContext}"'/'`;
		    fi
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst=${_hostlst}"

		    if [ -n "${_chk1}" ];then
			_hostlst=`echo " ${_hostlst} "|sed 's/'"${_myKey}"'["'\'']{[^}]*}["'\'']\{0,1\}/'"${_myTmpSubGroup}${_myContext}"'/'`;
		    else
			_hostlst=`echo " ${_hostlst} "|sed 's/'"${_myKey}"'["'\'']{[^}]*}["'\'']\{0,1\}/'"${_myTmpSubGroup}${_myContext}"'/'`;
		    fi
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst=${_hostlst}"
		fi

		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst=${_hostlst}"

 		echo "${_myTmpSubName##*/}">${_myTmpSubNameA}
 		echo "${_myTmpSubName##*/}.${_myKey}">${_myTmpSubName}

		_mySubLst="${_mySubLst#$_myKey}"
		_mySubLst="${_mySubLst#*\{}"
		_mySubLst="${_mySubLst%\}*}"
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_mySubLst=${_mySubLst}"

 		if [ -n "${_stackArgs}" ];then
 		    echo "CONTEXT${_stackArgs} ${_mySubLst}">${_myTmpSubName}.${_myKey}
 		else
 		    echo "${_mySubLst}">${_myTmpSubName}.${_myKey}
 		fi

# 		echo "${_mySubLst}">${_myTmpSubName}.${_myKey}
	    fi
	done
    }

    extractSubtask SUBTASK
    extractSubtask SUBGROUP
    extractSubtask VMSTACK

    #list of bare hosts
    local _namelst=`echo ${_hostlst}|sed 's/["'\'']*([^(]*)["'\'']* */ /g'`
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst=<${_hostlst}>"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_namelst=${_namelst}"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:RESOLVE-AND-PERMUTATE:${_namelst}"
    local _curglst=;
    local i7=;
    for i7 in $_namelst;do
        #get groupmembers
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:i7=${i7}"
        local _port=${i7#*:};
        if [ "$_port" == "${i7}" ];then
	    _port=;
            i7=${i7%:*};
	fi
        _curglst=`fetchGroupMembers $i7`;
        if [ -n "${_curglst## }" ];then
            #replace members as shell expansion list
	    local _gx="${_curglst}"

	    if [ -n "$_port" ];then
		_gx=$(echo " $_gx "|sed 's/"(/:'"$_port"'&/g;s/(/:'"$_port"'(/g;'|sed "s/'(/:"$_port"&/g;s/\(,[^ ]\),/\1:"$_port",/g;")
		_gx=$(echo " $_gx "|sed 's/\(:[0-9]\+\)\(:[0-9]\+\)/\1/g;')
	    fi

	    _gx="${_gx//\'/}";
	    _gx="${_gx//\"/}";
	    _gx=`echo " $_gx "|sed 's/(/()/g'|awk -F'('  '
	    {
		for(i=1;i<=NF;i++){
		    x=$i;
		    t0=gsub(")[^)]*$","",x);
		    tmatch=gsub("^)","",x);
		    if(tmatch!=0){
			    gsub(" ","-_-_",x);
			    gsub(",","\\\,",x);
                            gsub("/","\\\\/",x);
			    context="("x")"
			    gsub(".*)","",$i);
			    result=result""context""$i;
		    }else{
			    result=result""$i;
		    }
		}
		gsub("  "," ",result);
		gsub("^,","",result);
		gsub(",$","",result);
	    }
	    END{
		print result;
	    }
	    '`
	    _gx="${_gx//,,/,}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:i7=${i7}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_gx=${_gx}"
	    if [ "${_gx//[^\\],/}" != "${_gx}" ];then
		_hostlst=`echo ${_hostlst}|sed 's|'"${i7}"'|'"${_gx}"'|'`
	    else
                #Handle single-elem-lists
		_gx="${_gx#\{}";_gx="${_gx%\}}"
		_hostlst=`echo "${_hostlst}"|sed 's|'"${i7}"'|'"${_gx}"'|'`
	    fi
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst=<${_hostlst}>"
	fi
    done
    _hostlst=`echo $_hostlst|sed 's/} *{/ /g;s/["'\''](/(/g;s/)["'\'']/)/g;s/(/"(/g;s/)/)"/g;s/  *)/)/g'`

    _hostlst=`eval echo -e ${_hostlst}`
    _hostlst="${_hostlst//-_-_/ }";
    _hostlst="${_hostlst//\\,/,}";
    _hostlst="${_hostlst//\\\//\/}";
    _hostlst="${_hostlst//)(/ }";
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_hostlst=<${_hostlst}>"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "\"eval echo \$_hostlst=\"<${_hostlst}>"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "Eliminate braces of chained context-options"
    _hostlst=`echo $_hostlst|sed 's/'\''(/(/g;s/)'\''/)/g;s/"(/(/g;s/)"/)/g;s/)(/ /g;s/^{\(.*\)}$/\1/;'`
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "  => _hostlst=<${_hostlst}>"

    #quick - check it
    _hostlst=$(echo " $_hostlst "|sed 's/\([^\\]\)[{}]/\1 /g;s/^ *([^)]*) *//')
    if [ -n "${_hostlst// /}" ];then
	echo ${_hostlst}
    fi
}



#FUNCBEG###############################################################
#NAME:
#  listGroupMembers
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function lists the members of all available groups within the 
#  search path "CTYS_GROUPS_PATH"
#
#
#
#PARAMETERS:
#
#  $1:  DEEP:    output format:
#                  "<size-kbytes> <#records> <group-filename>"
#                where <#records> is the nested sum of all includes ad levels.
#
#    :  DEEP4CALL:    output format:
#    :  DEEP5CALL:    output format:
#
#  $*:  List of groups to be displayed
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    Expanded list, where each context block is permutated to all members.
#
#FUNCEND###############################################################
function listGroupMembers () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<${@}>"
    local _param=$1;shift
    local _groupsel="${*}";
    local _curGrpIdx=0;

    local i7=;
    local _sb=${CTYS_GROUPS_PATH}

    #absolute
    if [ "${_groupsel#\/}" != "${_groupsel}" ];then
	_sb=${_groupsel}
    fi


    for i7 in ${_sb//:/ };do
        [ -z "$C_TERSE" ]&&echo
        [ -z "$C_TERSE" ]&&echo $(setFontAttrib BOLD "${i7}");echo

        cd "${i7}"
	local i8=;
	local _gl=;

        local _groups=$(
	    local _gx=;
	    if [ -z "${_groupsel}" ];then
		find .  -type f -name '*[!~]' -printf '%h:%f\n'
	    else
		for _gx in ${_groupsel//%/ };do
  		    #is it a path
		    if [ "${_gx//\/}" != "${_gx}" ];then
		        #is it a file
			if [ -f "${_gx}" ];then
			    echo "${_gx%/*}:${_gx##*/}";
			else
			    if [ -d "${_gx}" ];then
				find ${_gx}  -type f -printf '%h:%f\n'
			    fi
			fi
		    else
			_gl="${_gx## }";
			_gl="${_gl%% }";
			_gl="${_gl//\%/ }";
			_gl="${_gl// /' -o -name '}";
			_gl="\\( -name '${_gl}' \\)";
			ex="find .  -type f ${_gl} -printf '%h:%f\n'"

			eval ${ex}
		    fi
		done
	    fi|sed 's@\./@@g'|sort)


        for i8 in $_groups;do
	    local _relpath=${i8%:*};
	    local _cur=${i8#*:};

	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_relpath        =${_relpath}"

            #lazy only, little too much temporary environment, but correct matches!
	    if [ -n "${_relpath}" -a "${_relpath}" != "." -a "${CTYS_GROUPS_PATH//$_relpath/}" == "${CTYS_GROUPS_PATH}" ];then
		CTYS_GROUPS_PATH="${PWD}/${_relpath}${CTYS_GROUPS_PATH:+:$CTYS_GROUPS_PATH}"
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    fi

	    _cur=${_cur##*:}
	    if [ "${_relpath}" != "." ];then
		_cur=${_relpath}/${_cur##*:}
	    fi

	    i8=${i8//:/\/}

	    _curglst=`fetchGroupMembers $_cur`;
	    if [ "${_curglst#\(}" != "${_curglst}" ];then
		if [ "${_curglst#\{}" != "${_curglst}" ];then
		    _curglst=${_curglst#\{};
		    _curglst=${_curglst%\}};
		    _curglst=$(for i in ${_curglst//,/ };do echo $i;done|sort|tr '\n' ' ')
		    _curglst="{${_curglst%% }}";
		else
		    _curglst=$(for i in ${_curglst//,/ };do echo $i;done|sort|tr '\n' ' ')
		    _curglst=${_curglst%% };
		fi
		_curglst=${_curglst// /,};
	    fi
	    case $_param in
		DEEP)
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:${i8}:${_curglst}"
		    echo "       ${i8}:GROUP(${i8})${_curglst}"
		    ;;

		DEEP4CALL)
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:${i8}:${_curglst}"
  		    _curglst=${_curglst//\(/\'(};
			_curglst=${_curglst//\)/)\'};

		    if [ -z "$C_TERSE" ];then 
 			echo "       ${i8}:GROUP(${i8})${_curglst}"
		    else
 			echo "GROUP(${i8})${_curglst}"
		    fi
		    ;;

		DEEP5XCALL)
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:${i8}:${_curglst}"
  		    _curglst=${_curglst//\(/\'(};
			_curglst=${_curglst//\)/)\'};
		    _curglst=${_curglst#\{}
		    _curglst=${_curglst%\}}

		    let _idxGroups++;
		    [ -z "$C_TERSE" ]&&printf "%05d      %s:\n" ${_idxGroups} ${i8}
                    local _curGroups=$(echo "${_curglst}"|sed "
                         s/ \+,/||/g
                         s/, \+/||/g
                         s/)' \+,/)'||/g
                         s/)' \+/)'||/g
                         s/.*/,&,/;
                         s/,\([^(),]\+([^)]\+)'\),/||\1||/g
                         s/^,//;s/,$//;
                         s/.*/||&||/;
                         s/||\([^(),]\+\),/||\1||/g;
                         s/||\([^(),]\+\),/||\1||/g;
                         s/||||/||/g;
                         s/\(||[^(),]*\),/\1||/g
                         s/\(||[^(),]*\),/\1||/g
                         s/^||//;s/||$//;
                         s/||/\n/g
                       ");
                    OIFS=$IFS
                    IFS="
"
                    for icG in $_curGroups;do
			local _hLst=$(echo $icG|awk '$0!~/[()-]/{for(i=1;i<=NF;i++){print $i};next}{print;}')
			for ihLst in $_hLst;do
			    let _idxHosts++;
                            echo $ihLst|   awk -v h="$_idxHosts"  -v X="${C_TERSE:+1}" '
                         BEGIN{idx=0}
                         {
                           if(X!=1){
                              printf("  %05d      ctys %s\n",h, $0);
                           }else{
                              printf("ctys %s\n",$0);
                           }
                         }
                         '
			done
		    done
		    IFS=$OIFS
		    [ -z "$C_TERSE" ]&&echo
		    ;;


		DEEP5CALL)
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:${i8}:${_curglst}"
  		    _curglst=${_curglst//\(/\'(};
		    _curglst=${_curglst//\)/)\'};
		    _curglst=${_curglst#\{}
		    _curglst=${_curglst%\}}

		    [ -z "$C_TERSE" ]&&echo "       ${i8}:"
                    echo "${_curglst}"|sed "
                         s/ \+,/||/g
                         s/, \+/||/g
                         s/)' \+,/)'||/g
                         s/)' \+/)'||/g
                         s/.*/,&,/;
                         s/,\([^(),]\+([^)]\+)'\),/||\1||/g
                         s/^,//;s/,$//;
                         s/.*/||&||/;
                         s/||\([^(),]\+\),/||\1||/g;
                         s/||\([^(),]\+\),/||\1||/g;
                         s/||||/||/g;
                         s/\(||[^(),]*\),/\1||/g
                         s/\(||[^(),]*\),/\1||/g
                         s/^||//;s/||$//;
                         s/||/\n/g
                       "|\
                       awk '$0!~/[()-]/{for(i=1;i<=NF;i++){print $i};next}{print;}'|\
                       awk -v X="${C_TERSE:+1}" '
                         BEGIN{idx=0}
                         {
                           if(X!=1){
                              printf("          %d:  ctys %s\n",idx, $0);idx++;
                           }else{
                              printf("ctys %s\n",$0);idx++;
                           }
                         }
                         '
		    [ -z "$C_TERSE" ]&&echo
		    ;;

		*)
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:${i8}:${_curglst}"
		    if [ -z "$C_TERSE" ];then 
 			echo "       ${i8}:GROUP(${i8})${_curglst}"
		    else
 			echo "GROUP(${i8})${_curglst}"
		    fi
		    ;;
	    esac
	done
    done
}



#FUNCBEG###############################################################
#NAME:
#  listGroups
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function lists all all available groups within the search path
#  "CTYS_GROUPS_PATH"
#
#
#
#PARAMETERS:
#  $1:  SHORT|CONTENT|DEEP|DEEP3
#
#       SHORT:   output format:
#                  "<size-kbytes> <#host-records-cur-file>/<#includes-cur-file> <#deepsum>  <group-filename>"
#       DEEP:    output format:
#                  "<size-kbytes> <#records> <group-filename>"
#                where <#records> is the nested sum of all includes ad levels.
#
#       DEEP3:   output format:
#
#
#       CONTENT: output format:
#                  "<size-kbytes> <#records> <group-filename>"
#                where <#records> is the nested sum of all includes ad levels.
#
#  $*:  List of groups to be displayed
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    Expanded list, where each context block is permutated to all members.
#
#FUNCEND###############################################################
function listGroups () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME: \$*=$*"
    local _range=$1;shift
    local _groupsel="${*}";


    function getContentCount () {
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=$*"
        local _param=$1;shift
	local _groupsel="${*}";

        local _cur=;
	local _hstcnt=0;
	local _inccnt=0;
	local _deepsum=0;

	cd ${_param}

	local _sb=${CTYS_GROUPS_PATH}
	local _gl=;

        local _groups=$(
	    local _gx=;
	    if [ -z "${_groupsel}" ];then
		find .  -type f -name '*[!~]' -printf '%k:%h:%f\n'
	    else
		for _gx in ${_groupsel//%/ };do
   		    #is it a path
		    if [ "${_gx//\/}" != "${_gx}" ];then
		        #is it a file
			if [ -f "${_gx}" ];then
			    find ${_gx%/*}  -type f -name ${_gx##*/} -printf '%k:%h:%f\n'
			else
			    if [ -d "${_gx}" ];then
				find ${_gx}  -type f -printf '%k:%h:%f\n'
			    fi
			fi
		    else
			_gl="${_gx## }";
			_gl="${_gl%% }";
			_gl="${_gl//\%/ }";
			_gl="${_gl// /' -o -name '}";
			_gl="\\( -name '${_gl}' \\)";
			ex="find .  -type f ${_gl} -printf '%k:%h:%f\n'"
			eval ${ex}
		    fi
		done
	    fi|sed 's@\./@@g'|sort)


        for _cur in $_groups;do
	    local _size=${_cur%%:*}
	    local _relpath=${_cur#*:};_relpath=${_relpath%:*}

	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_relpath        =${_relpath}"

            #lazy only, little too much temporary environment, but correct matches!
	    if [ -n "${_relpath}" -a "${_relpath}" != "." -a "${CTYS_GROUPS_PATH//$_relpath/}" == "${CTYS_GROUPS_PATH}" ];then
		CTYS_GROUPS_PATH="${PWD}/${_relpath}${CTYS_GROUPS_PATH:+:$CTYS_GROUPS_PATH}"
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    fi

	    _cur=${_cur##*:}
	    if [ "${_relpath}" != "." ];then
		_cur=${_relpath}/${_cur##*:}
	    fi
	    if [ -f "${_cur}" ];then
		_hstcnt=$(cat  $_cur|sed -n '/^#/d;s/\"//g;s/,/ /g;/^$/d;s/([^)]*)//g;/CONTEXT.*/d;p'|sed "s/'//g"|wc -w);
		_inccnt=$(sed -n '/^#[^i]/d;s/\"//g;s/,/ /g;s/^#include  *\(.*\)/\1/p' $_cur|wc -w);
	        _deepsum=`fetchGroupMembers $_cur|sed 's/{//g;s/}//g;s/,/ /g;s/([^)]*)//g;/CONTEXT.*/d;'|sed "s/'//g"|wc -w`;
	    fi
	    if [ -z "$C_TERSE" ];then
		if [ -z "$_tit" ];then
		    printf "\n"
		    local _tit=1;
		    printf "  %5s  %6s  #%5s/#%-8s  #%5s  %s\n"  gIDX size hosts includes total cur
		    printf "  ----------------------------------------------------------------------\n"
		fi
		let _idxGroups++;
		printf "  %5d  %5dk  %6d/%-9d  %6s  %s\n"  ${_idxGroups} ${_size} ${_hstcnt// } ${_inccnt// } ${_deepsum// } "$_cur"
	    else
		printf "%s\n"  "$_cur"
	    fi
	done
	return
    }

    function getContent () {
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=$*"
        local _param=${1:-.};shift
	local _groupsel="${*}";

	cd ${_param}

        local _cur=;
        local _hstlst=;
        local _inclst=;

	local _sb=${CTYS_GROUPS_PATH}
	local _gl=;
	{
	    local _gx=;
	    if [ -z "${_groupsel}" ];then
		find .  -type f -name '*[!~]' -printf '%k:%h:%f\n'
	    else
		for _gx in ${_groupsel//%/ };do
 		#is it a path
		    if [ "${_gx//\/}" != "${_gx}" ];then
		    #is it a file
			if [ -f "${_gx}" ];then
			    find ${_gx%/*}  -type f -name ${_gx##*/} -printf '%k:%h:%f\n'
			else
			    if [ -d "${_gx}" ];then
				find ${_gx}  -type f -printf '%k:%h:%f\n'
			    fi
			fi
		    else
			_gl="${_gx## }";
			_gl="${_gl%% }";
			_gl="${_gl//\%/ }";
			_gl="${_gl// /' -o -name '}";
			_gl="\\( -name '${_gl}' \\)";
			ex="find .  -type f ${_gl} -printf '%k:%h:%f\n'"
			eval ${ex}
		    fi
		done
	    fi
	}|sed 's@:\./@:@g'|sort|\
        while read _cur;do
	    local _size=${_cur%%:*}
	    local _relpath=${_cur#*:};_relpath=${_relpath%:*}

	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_relpath        =${_relpath}"

            #lazy only, little too much temporary environment, but correct matches!
	    if [ -n "${_relpath}" -a "${_relpath}" != "." -a "${CTYS_GROUPS_PATH//$_relpath/}" == "${CTYS_GROUPS_PATH}" ];then
		CTYS_GROUPS_PATH="${PWD}/${_relpath}${CTYS_GROUPS_PATH:+:$CTYS_GROUPS_PATH}"
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH}"
	    fi

	    _cur=${_cur##*:}
	    if [ "${_relpath}" != "." ];then
		_cur=${_relpath}/${_cur##*:}
	    fi

	    if [ -f "${_cur}" ];then
		case $_range in
		    CONTENT)
			_hstlst="`sed -n '/^#/d;s/\"//g;s/,/ /g;p' $_cur` ";
			_inclst="`sed -n '/^#[^i]/d;s/\"//g;s/,/ /g;s/^#include  *\(.*\)/\1/p' $_cur` ";
			;;
		    DEEP|DEEP3)
			_hstlst=`fetchGroupMembers $_cur|sed 's/{//g;s/}//g;s/\(([^)]*\),\([^(]*)\)/\1_--_\2/g;s/,/ /g;s/_--_/,/g;'`;
			;;
		esac
	    fi
	    printf "  %4dk %s\n" ${_size}  "$_cur"
	    if [ -n "${_hstlst// }" ];then
		local _hstlst="`echo $_hstlst|sed -n 's/[^[:alnum:]]*/ /;p'` ";
		case $_range in
		    DEEP)
			if [ "${_hstlst#\(}" != "${_hstlst}" ];then
			    if [ "${_hstlst#\{}" != "${_hstlst}" ];then
				_hstlst=${_hstlst#\{};
				_hstlst=${_hstlst%\}};
				_hstlst=$(for i in ${_hstlst};do echo $i;done|sort|tr '\n' ' ')
				_hstlst="{${_hstlst%% }}";
			    else
				_hstlst=$(for i in ${_hstlst};do echo $i;done|sort|tr '\n' ' ')
			    fi
			fi
			printf "        h{%s}\n"  "${_hstlst}"
			;;
		    DEEP3)
                        local _i9=;
			if [ "${_hstlst#\(}" != "${_hstlst}" ];then
			    if [ "${_hstlst#\{}" != "${_hstlst}" ];then
				_hstlst=${_hstlst#\{};
				_hstlst=${_hstlst%\}};
				_hstlst=$(for i in ${_hstlst};do echo $i;done|sort|tr '\n' ' ')
				_hstlst="{${_hstlst%% }}";
			    else
				_hstlst=$(for i in ${_hstlst};do echo $i;done|sort|tr '\n' ' ')
			    fi
			fi
                        local _hstlst1=`echo ${_hstlst}|sed "s/ *\([^ '(]*'([^)']*)'\) */_-_\1/g;s/ /__--__/g;s/_-_/ /g;s/)'/)' /g"`;
                        for _i9 in ${_hstlst1};do
			    local sizeX=80;
			    local indentX=2;
			    printf "        %s\n"  "${_i9//__--__/ }"
			done|clipWordLine ${sizeX} ${indentX}
			;;
		esac
	    fi
	    if [ -n "${_inclst// }" ];then
		_inclst="`echo $_inclst|sed -n 's/[^[:alnum:]]*/ /;p'` ";
		printf "        i{%s}\n"  "${_inclst}"
	    fi
            echo
	    done
	    return
    }

    local i7=;
    local _sb=${CTYS_GROUPS_PATH}

    #absolute
    if [ "${_groupsel#\/}" != "${_groupsel}" ];then
	_sb=${_groupsel}
    fi


    for i7 in ${_sb//:/ };do
	[ -z "$C_TERSE" ]&&echo
        [ -z "$C_TERSE" ]&&echo $(setFontAttrib BOLD "${i7}")
        case $_range in
	    SHORT)
		getContentCount  ${i7} ${_groupsel}
		;;
	    CONTENT|DEEP|DEEP3|DEEP4)
		getContent  ${i7} ${_groupsel}
		;;
	esac
    done
}



#FUNCBEG###############################################################
#NAME:
#  checkAndSetIsHostOrGroup
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function checks whether it is a host or it is a group.
#  For non-hosts a keyword is used to wrap for delayed evaluation.
#
#PARAMETERS:
#  $1:  <host>|<group>
#       A leading user will be removed for host-checks.
#       A group checke dis performed first for full scope, when fails 
#       in an second attempt for host-only.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#    0: none
#    1: host
#    2: subgroup==subtask
#    3: stackgroup
#  VALUES:
#    host, or wrapped entry:
#
#    - SUBGROUP{<group>}
#      To be passed to a subcall as a sub-group with it's specific 
#      execution context.
#
#FUNCEND###############################################################
function checkAndSetIsHostOrGroup () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=$*"
    if [ -z "${1## }" ];then
	return 1
    fi
    local _ret=0;
    local ABORT=1
    local _myTarget=${1#*@}

    if [ -z "${_myTarget}" -o "${_myTarget}" == localhost ];then
	echo -n localhost
	return 0
    fi


    callErrOutWrapper $LINENO $BASH_SOURCE host ${_myTarget}>>/dev/null
    _ret=$?
    local _X=;
    if [ "$_ret" -ne 0 ]; then
	_X=$(netGetHostIP ${_myTarget});
	_ret=$?
    fi

    if [ "${_ret}" -ne 0 ]; then
        #check for subtask
        local _delayedGroup1=`fetchGroupMembers ${1}`
        if [ -z "${_delayedGroup1}" ];then
            local _delayedGroup1=`fetchGroupMembers ${_myTarget}`
            if [ -z "${_delayedGroup1}" ];then
		ABORT=2;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown host and/or group='${1}'"
		printINFO 0 $LINENO $BASH_SOURCE 1 "When using groups check path-prefix,"
		printINFO 0 $LINENO $BASH_SOURCE 1 "path-prefix is required for 'ctys' start-calls."
		printINFO 0 $LINENO $BASH_SOURCE 1 "Call 'ctys-groups' for listing available by search."
		printINFO 0 $LINENO $BASH_SOURCE 1 "Another common reason for this is usage of SPACES in pathnames,"
		printINFO 0 $LINENO $BASH_SOURCE 1 "SPACES in pathnames are not supported for now."
#		gotoHell ${ABORT};
		_myTarget=${1};
		return ${ABORT};
	    fi
	else
	    _myTarget=${1}
 	    _ret=0;
	fi
	printINFO 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:sub-context:SUB-TASK=<${_myTarget}>"
	printINFO 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:${_myTarget}=<${_delayedGroup1}>"
	local _strbuf=${1};
	case ${_strbuf##*.} in
	    SUBGROUP|SUBTASK)
		echo -n -e "SUBGROUP{${1}}"
		_ret=2;
		;;
	    VMSTACK)
		echo -n -e "VMSTACK{${1}}"
		_ret=3;
		;;
	    *)
		echo -n -e "SUBGROUP{${1}}"
		_ret=2;
		;;
	esac
    else
        echo -n -e "${1}"
    fi       
    return $_ret;
}

#FUNCBEG###############################################################
#NAME:
#  fetchGroupMemberHosts
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#PARAMETERS:
#  $1: <host> or <group>
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    List of group member hosts space seperated list within one line.
#
#FUNCEND###############################################################
function fetchGroupMemberHosts () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=$*"
    local hostlist=$(expandGroups ${*//%/ })
    if [ -n "${hostlist}" ];then
	hostlist=$(echo " ${hostlist} "|sed 's/([^)]*)/ /g')
	hostlist="${hostlist//,/ }"
	hostlist="${hostlist//  / }"
	hostlist="${hostlist//  / }"
	if [ -n "${hostlist// /}" ];then
	    echo -n -e "${hostlist}"
	fi
    fi
}
