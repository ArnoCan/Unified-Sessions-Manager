#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_005
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


_myLIBNAME_cli="${BASH_SOURCE}"
_myLIBVERS_cli="01.11.005"
libManInfoAdd "${_myLIBNAME_cli}" "${_myLIBVERS_cli}"
_myLIBBASE_cli="`dirname ${_myLIBNAME_cli}`"


#FUNCBEG###############################################################
#NAME:
#  splitArgsWithOpts
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function supports the split of a string as arguments
#  with sub-options attached to arbitrary arguments by grouping
#  them with parenthesis.
#
#  The application for analysing a list of arguments for a given
#  function might look like:
#
#    R_HOSTS='  host01(-a -b 12 -c A=1,2,3)'" host2 x@host3 host4(-a -b)"
#    local i=x;
#    let _ARGSOPTIND=1;
#    while [ -n "${i}" -o ${_ARGSOPTIND} -eq 1 ]  ;do
#      i="`splitArgsWithOpts ${_ARGSOPTIND} ${R_HOSTS}`"
#      if [ -z "${i}" ];then break;fi
#      echo "<$i>"
#      let _ARGSOPTIND=_ARGSOPTIND+1;
#    done
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Index of item to be extracted, this has the following transformation:
#
#      "a b( -o1 -o2 xyz -o3 xyz -o4 ) c d ( -o1 xyz -o2 )":
#      -----------------------------------------------------
#      => $1=1: a => 'a '
#      => $1=2: 'b( -o1 -o2 xyz -o3 xyz -o4 )' => 'b -o1 -o2 xyz -o3 xyz -o4 '
#      => $1=3: 'c' => 'c '
#      => $1=4: 'd ( -o1 xyz -o2 )' => 'd -o1 xyz -o2 '
#
#
#  $*: A list of arguments with optional specific sub-options for 
#      any arbitrary argument in the form:
#
#      "a b( -o1 -o2 xyz -o3 xyz -o4 ) c d ( -o1 xyz -o2 )"
#      '  host01(-a -b 12 -c A=1,2,3)'" host2 x@host3 host4(-a -b)"
#      '  host01 (-a -b 12 -c A=1,2,3)'" host2 x@host3 host4(-a -b)"
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function splitArgsWithOpts () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME <${*}>"
    local A=$1;shift
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME <${*}>"

    #controls debugging for awk-scripts
    doDebug $S_LIB  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?
    echo "${*}"|\
      awk -v d=${D} -v a="$A" -f ${_myLIBBASE_cli}/splitArgsWithOpts.awk|\
      sed 's/["](/(/;s/)["]/)/;'|sed "s/['](/(/;s/)[']/)/;"
}


#FUNCBEG###############################################################
#NAME:
#  getArgOpts
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Helper which removes $1
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function getArgOpts () {
 echo $*|awk '
 {
  if(match($0,"[(]")) {
     x=$0;
     sub("^[^(]*\\( *","",x);
     sub(" *[)].*$","",x);    
     if(x)printf("%s",x);
  }
 }
 '
}



#FUNCBEG###############################################################
#NAME:
#  getArg
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Helper for shift 1 of an ordinary string
#
#  spaces not removed
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function getArg () {
  echo -n ${1%(*}
}





#FUNCBEG###############################################################
#NAME:
#  fetchArgs
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetches options to given arrays for further processing.
#
#  Call: fetchArgs <DEFAULT-OPTS> -- <NEW-OPTS>
#
#  Intermixed options with additional suboptions of following
#  form are handled.
#
#   "-keyword1 suboption1 -keyword2 -keyword3=value3"
#
#  suboptions may be just one word. Options like keyword3 and 
#  it's value are recognized as one option, this means they could
#  be just handeled together with their assignments.
#
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <DEFAULT-OPTS> 
#     Options written as normal CLI options, to be appended to 
#     new options, if missing.
# $2: -- 
# $3: <NEW-OPTS>
#     Options written as normal CLI options, to be completed.
#
#OUTPUT:
#  GLOBALS:
#  Due to missing by-reference-parameter prefer global in order to 
#  save ugly redundancy!!!
#
#  Reference options, either required defaults to completed on NEW,
#  or options to be removed, refer to the appropriate function.
#
declare -a DEF0
declare -a DEF1
#
#
#  New options to be checked.
#
declare -a NEW0
declare -a NEW1
# 
#  Resulting options, could be done within another, but due to
#  possible option+suboption+argument combination will be seperated.
#  This array will be filled by specific processing functions.
#
declare -a OUT0
declare -a OUT1
#
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchArgs () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${@}"
    local i=0;
    local j=0;

    let i=0;
    let j=0;

    #fetch def
    while [ -n "$1" -a "$1" != "--" ];do
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "i=<$i>"
	if [ -n "${1%%[!-]*}"  ];then
	    DEF0[$i]=$1;
	else
	    if((i>0));then
		let i=i-1;
		DEF1[$i]=$1;
	    fi
 	fi
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "DEF[$i]=${DEF0[$i]} ${DEF1[$i]}"
	let i+=1;
	shift
    done

    shift;
    let i=0;

    #fetch new
    local relToOpt=0;
    while [ -n "$1" -a "$1" != "--" ];do
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "i=$i"
	if [ -n "${1##*([!-])}"  ];then
	    NEW0[$i]=${1##*([!-]) };
	    NEW0[$i]=${NEW0[$i]%% };
            relToOpt=1;
	else
	    if [ $relToOpt -eq 1 ];then
                #so it is a suboption
		let i=i-1;
		NEW1[$i]=${1%%)};
		relToOpt=0;
            else
                #here it is a simple argument, either a keyword or a value
		NEW0[$i]=$1;
            fi
	fi
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "NEW[$i]=${NEW0[$i]}:${NEW1[$i]}"
	let i+=1;
	shift
    done
}



#FUNCBEG###############################################################
#NAME:
#  cliOptionsReplace
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Replaces any present option in <NEW-OPTS> given by and with
#  any option from <DEFAULT-OPTS>.
#
#  Call: cliOptionsReplace <DEFAULT-OPTS> -- <NEW-OPTS>
#
#  intermixed options with additional suboptions of following
#  form are handled.
#
#   "-keyword1 suboption1 -keyword2"
#
#  suboptions may be just one word.
#
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <DEFAULT-OPTS> 
#     Options written as normal CLI options, to be appended to 
#     new options, if missing.
# $2: -- 
# $3: <NEW-OPTS>
#     Options written as normal CLI options, to be completed.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    new CLI options with additional default values not provided.
#
#FUNCEND###############################################################
function cliOptionsReplace () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${@}"

    fetchArgs $@
    local curLen=0;
    local nLen=${#NEW0[@]};
    local dLen=${#DEF0[@]};
    local i=0;
    local j=0;
    let curLen=0;
    let i=0;
    let j=0;
    local _match=0;

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "curLen=${curLen} nLen=${nLen} dLen=${dLen}"
    for((i=0;i<nLen;i++));do
	for((j=0;j<dLen;j++));do
            printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "(i,j)=($i,$j) ${NEW0[$i]} == ${DEF0[$j]}"
	    if [ "${NEW0[$i]}" == "${DEF0[$j]}" ];then
                printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "match i=$i"
		_match=1;
		break;
	    fi
	done
        if [ "$_match" == 1 ];then 
	    OUT0[$curLen]=${DEF0[$j]};
	    OUT1[$curLen]=${DEF1[$j]};
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT[${curLen}]=${OUT0[${curLen}]} ${OUT1[${curLen}]}"
	    _match=0;
	else 
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "i=$i  curLen=$curLen"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "NEW[$i]=${NEW0[$i]} ${NEW1[$i]}"
	    OUT0[$curLen]=${NEW0[$i]};
	    OUT1[$curLen]=${NEW1[$i]};
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT[$curLen]=${OUT0[$curLen]} ${OUT1[$curLen]}"
	fi
        let curLen+=1;
    done

    local OUT=
    local oLen=${#OUT0[@]};
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "curLen=${curLen} nLen=${nLen} dLen=${dLen}"
    for((i=0;i<oLen;i++));do
	OUT="${OUT} ${OUT0[$i]} ${OUT1[$i]}"
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT($i)=${OUT}"
    done
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT=${OUT}"


    echo "${OUT}"
}

#FUNCBEG###############################################################
#NAME:
#  cliOptionsAddMissing
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Adds any option from <DEFAULT-OPTS> that is not present in 
#  <NEW-OPTS>.
#
#  Call: cliOptionsAddMissing <DEFAULT-OPTS> -- <NEW-OPTS>
#
#  intermixed options with additional suboptions of following
#  form are handled.
#
#   "-keyword1 suboption1 -keyword2 arg1 arg2 arg3"
#
#  suboptions may be just one word.
#
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <DEFAULT-OPTS> 
#     Options written as normal CLI options, to be appended to 
#     new options, if missing.
# $2: -- 
# $3: <NEW-OPTS>
#     Options written as normal CLI options, to be completed.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    new CLI options with additional default values not provided.
#
#FUNCEND###############################################################
function cliOptionsAddMissing () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${@}"

    fetchArgs $@
    local curLen=0;
    local nLen=${#NEW0[@]};
    local dLen=${#DEF0[@]};
    local _match=0;
    local i=0;
    local j=0;

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "curLen=${curLen} nLen=${nLen} dLen=${dLen}"
    for((j=0;j<dLen;j++));do
	for((i=0;i<nLen;i++));do
            printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "(i,j)=($i,$j) ${NEW0[$i]}" == "${DEF0[$j]}"
	    if [ "${NEW0[$i]}" == "${DEF0[$j]}" ];then
                printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "match i=$i"
		_match=1;
		break;
	    fi
	done
        if [ "$_match" == 1 ];then 
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "match=>keep: DEF0[$i]=(${NEW0[$j]} ${NEW1[$j]})}"
	    _match=0;
	else 
	    OUT0[${curLen}]=${DEF0[$j]};
	    OUT1[${curLen}]=${DEF1[$j]};
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "add new:OUT[${curLen}]=${OUT0[${curLen}]} ${OUT1[${curLen}]}"
            let curLen+=1;
	fi
    done

    for((i=0;i<nLen;i++));do
	OUT0[${curLen}]=${NEW0[$i]};
	OUT1[${curLen}]=${NEW1[$i]};
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT[${curLen}]=${OUT0[${curLen}]} ${OUT1[${curLen}]}"
        let curLen+=1;
    done

    local OUT=
    local oLen=${#OUT0[@]};
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "curLen=${curLen} nLen=${nLen} dLen=${dLen}"
    for ((i=0;i<oLen;i++));do
	OUT="${OUT} ${OUT0[$i]} ${OUT1[$i]}"
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT=${OUT}"
    done
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT=${OUT}"


    echo "${OUT}"
}



#FUNCBEG###############################################################
#NAME:
#  cliOptionsStrip
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Call: cliOptionsStrip <TO-REMOVE-OPTS> -- <NEW-OPTS>
#
#  Each argument given by <TO-REMOVE-OPTS> will be removed 
#  from <NEW-OPTS> if present. The <TO-REMOVE-OPTS> might 
#  contain in current implementation only the option, related
#  suboptions will be removed too.
#
#  This will be used for CLI calls of scripts encapsulating a 
#  call, whereas the called command has less options than the 
#  encapsulating script.
#
#  Intermixed options with additional suboptions of following
#  form are spported.
#
#   "-keyword1 suboption1 -keyword2"
#
#  suboptions may be just one word.
#
#
#EXAMPLE:
#  Encapsulating vncviewer with some basic options processing and 
#  a debug option, which is not known to vncviewer:
#
#    ctys-callVncviewer.sh -d 3 -name "HUGO" -depth 24 -localhost ...
#    Contains:
#       ...
#       OPTS=`cliStripOptions -d -- $@`
#       #results to:OPTS="-name "HUGO" -depth 24 -localhost ..."
#       #
#       #refer to "cliOptionsReplace" from this module
#       OPTS=`cliOptionsReplace <DEFAULT-OPTIONS> -- ${OPTS}`
#       #
#       vncviewer ${OPTS}
#       ..
#
#  The debugging option, which is "-d 3" is unknown to the 
#  encapsulated binary vncviewer, therefor it has to be stripped 
#  of before handing over the arguments to vncviewer.
#
#PARAMETERS:
# $1: REMOVE|KEEP
#     - REMOVE
#       Remove the listed options, keep any other in new CLI 
#       options list returned.
#
#     - KEEP
#       Keep the listed options, remove any other in new CLI 
#       options list returned.
#
# $2: <REFERENCE-OPTS> 
#     Options written as normal CLI options, to be stripped off 
#     or kept, depens on $1.
# $3: -- 
# $4: <NEW-OPTS>
#     Options written as normal CLI options, to be stripped.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    new CLI options with removed options.
#
#
#TODO:
#  1. Reuse parts of "cliOptionsReplace" when effort available.
#
#
#FUNCEND###############################################################
function cliOptionsStrip () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${@}"
    local C=;
    
    case ${1} in
	REMOVE)C=0;;
	KEEP)C=1;;
	*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: Unknown keyword"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  -> \$1==$1"
	    gotoHell ${ABORT}
	    ;;
    esac
    shift


    fetchArgs $@

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${NEW0[0]} ${NEW1[0]}"

    local raw=${#NEW0[@]}
    local defs=${#DEF0[@]}
    local curLen=0;
    local _4remove=0;
    local i=0;
    local j=0;
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "raw=${raw} defs=${defs}"
    for ((i=0;i<${raw};i++));do
	for ((j=0;j<${defs};j++));do
 	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "<${NEW0[${i}]}> <${DEF0[${j}]}>"
	    if [ "${NEW0[$i]}" == "${DEF0[$j]}" ];then
		case $C in 
		    0)#REMOVE
 			printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "curLen=${curLen}:REMOVE:${NEW0[${i}]} ${NEW1[${i}]}"
			_4remove=1;
			break;
			;;
		    1)#KEEP
			OUT0[${curLen}]=${NEW0[$i]};
			OUT1[${curLen}]=${NEW1[$i]};
			printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$curlen:OUT0(${OUT0[${curLen}]})-OUT1(${OUT1[${curLen}]})"
			let curLen++;
			;;
		esac
 	    fi
	done

	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "C=${C} - _4remove=${_4remove}"

        #if NOT matched by REMOVE for REMOVE only 
	if [ "$C" == "0" -a "${_4remove}" == "0" ];then
	    OUT0[${curLen}]=${NEW0[$i]};
	    OUT1[${curLen}]=${NEW1[$i]};
	    let curLen++;
	fi
	_4remove=0;
    done

    local OUT=;
    for ((i=0;i<${curLen};i++));do
	OUT="${OUT} ${OUT0[$i]} ${OUT1[$i]}"
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT($i)=${OUT}"
    done
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT=${OUT}"
    echo "${OUT}"
}





#FUNCBEG###############################################################
#NAME:
#  cliOptionsPassAllowed
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
# Call: cliOptionsPassAllowed <ALLOWED-OPTS-ONLY> -- <NEW-OPTS>
#  Each argument from <NEW-OPTS> will checked against <ALLOWED-OPTS-ONLY>
#  and only passed-through if contained within <ALLOWED-OPTS-ONLY>.
#  When a suboption is given in <ALLOWED-OPTS-ONLY>, this is literally 
#  checked only. When differences occur, the whole option is withdrawn.
#
#  This will be used for CLI calls to scripts encapsulating another with
#  any argument related to the encapsulation.  
#
#  intermixed options with additional suboptions of following
#  form are handled.
#
#   "-keyword1 suboption1 -keyword2"
#
#  suboptions may be just one word.
#
#
#EXAMPLE:
#  Encapsulating vncviewer with some basic options processing and a debug
#  option, which is not known to vncviewer:
#
#    ctys-callVncviewer.sh -d 3 -name "HUGO" -depth 24 -localhost ...
#    Contains:
#       ...
#       OPTS=`cliStripOptions @<control-opt> -d 3 -- $@`
#       #results to:OPTS="-name "HUGO" -httpd -depth 24 -localhost ..."
#                                      ^^^^^^
#       OPTS=`cliOptionsPassAllowed @<control-opt>  -name -nohttpd -depth -localhost -- $@`
#                                          ^^^^^^^^
#
#       #results to:OPTS="-name "HUGO" -depth 24 -localhost ..."
#
#       #
#       #refer to "cliOptionsReplace" from this module
#       OPTS=`cliOptionsReplace @<control-opt>  <DEFAULT-OPTIONS> -- ${OPTS}`
#       #
#       vncviewer ${OPTS}
#       ..
#
#  The debugging option, which is "-d 3" is unknown to the encapsulated
#  binary vncviewer, therefor it has to be stripped of before handing over
#  the arguments to vncviewer.
#
#  The "-httpd" option is not allowed, thus will be stripped off.
#
#PARAMETERS:
# $1: @<control-opt> 
#     Controls the behaviour in case of a match:
#     @EXIT   Exit here.
#     @WARN   Print a printWNG 1 and continue. This is default.
#     @QUIET  Just continue by ignoring it.
#  
# $2: <TO-REMOVE-OPTS> 
#     Options written as normal CLI options, to be stripped off.
# $3: -- 
# $4: <NEW-OPTS>
#     Options written as normal CLI options, to be stripped.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    new CLI options with removed options.
#
#
#TODO:
#  1. Reuse parts of "cliOptionsReplace" when effort available.
#  2. Introduce wildcards for <ALLOWED-OPTS-ONLY>
#
#
#FUNCEND###############################################################
function cliOptionsPassAllowed () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${@}"
    local i=0;
    local j=0;

    case $1 in
	@EXIT)local EXIT=1;;
	@QUIET)local QUIET=1;;
	@WARN|?*);;
	'')
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing behaviour definition for match:${*}"
	    gotoHell ${ABORT}
	    ;;
    esac
    shift

    fetchArgs $@

    local raw=${#NEW0[@]}
    local curLen=0;
    for((j=0;j<${#DEF0[@]};j++));do
	for((i=0;i<${raw};i++));do
	    if [ "${NEW0[$i]}" == "${DEF0[$j]}" ];then
		if [ -n "${EXIT}" ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: Forbidden option detected:"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  -> NEW0[$i]=${NEW0[$i]}"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  -> NEW1[$i]=${NEW1[$i]}"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: <ALLOWED-OPTS-ONLY>=${DEF0[@]}"
		    gotoHell ${ABORT}
		else
		    if [ -z "${QUIET}" ];then
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: Forbidden option detected:"
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  -> NEW0[$i]=${NEW0[$i]}"
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  -> NEW1[$i]=${NEW1[$i]}"
		    fi
		fi
            else
		OUT0[${curlen}]=${NEW0[$i]};
		OUT1[${curlen}]=${NEW1[$i]};
                let curlen++;
	    fi
	done
    done

    local OUT=
    for ((i=0;i<${#OUT0[@]};i++));do
	OUT="${OUT} ${OUT0[$i]} ${OUT1[$i]}"
    done
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT=${OUT}"
    echo "${OUT}"
}





#FUNCBEG###############################################################
#NAME:
#  cliSplitSubOpts
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Splits comma seperated subopts, therefore the following syntax 
#  elements are known
#
#   ','  Seperates multiple suboptions, could be masked by 
#        either '\' or ','. Is than reduced as the last step 
#        on execution target.
#
#   ',,' or '\,'
#       Masks a comma, preserving it from interpreted by the 
#       "simplistic" command line scanner.
#
#       Therefore all single occurances are replace by spaces, 
#       than any remaining masked/double occurance is replaced 
#       by one. When using a '\' there must be multiple entries, 
#       due to multiple shell evaluation, which is at least 2x, 
#       thus '\\\\' is the minimum for a resulting single '\' 
#       on final executing site.
#
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <sub-options>
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    splitted list with de-masked syntax elements.
#
#FUNCEND###############################################################
function cliSplitSubOpts () {
    local A=`echo ${1}|sed 's/\([^,\]\),\([^,]\)/\1 \2/g;s/,,/,/g'`
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<${A}>"
    echo "${A}"
}




#FUNCBEG###############################################################
#NAME:
#  cliOptionsUpdate
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Updates any present AND adds any missing to a given list of options 
#  <PRESENT-OPTS> from a list of update-options <UPDATE-OPTS>.
#
#  Call: cliOptionsUpdate <UPDATE-OPTS> -- <NEW-OPTS>
#
#  intermixed options with additional suboptions of following
#  form are handled.
#
#   "-keyword1 suboption1 -keyword2 arg1 arg2 arg3"
#
#  suboptions may be just one word.
#
#
#  For now this calls the sub-calls:
#
#    1. cliOptionsReplace
#    2. cliOptionsAddMissing
#
#  could be tuned, but other priorities win for now.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <UPDATE-OPTS>
#     Options written as normal CLI options, to be updated on
#     present options by replacement and/or append.
# $2: -- 
# $3: <NEW-OPTS> 
#     Options written as normal CLI options, to be updated by
#     update options, if "old" or missing.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    new CLI options with additional default values not provided.
#
#FUNCEND###############################################################
function cliOptionsUpdate () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _uo=;
    local _no=;

    _uo="${*} "
    _uo="${_uo%-- *}"
    _uo="${_uo%% }"
    _uo="${_uo## }"

    _no="${*} "
    _no="${_no#*-- }"
    _no="${*%% }"
    _no="${*## }"

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_uo=<${_uo}>"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_no=<${_no}>"

    #Call: cliOptionsReplace <DEFAULT-OPTS> -- <NEW-OPTS>
    local _buf=`cliOptionsReplace $@`
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${_buf}"


    #Call: cliOptionsAddMissing <DEFAULT-OPTS> -- <NEW-OPTS>
    local _buf=`cliOptionsAddMissing "$_uo" -- "$_buf"`

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${_buf}"
    _buf=$(cliOptionsClearRedundant $_buf)
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${_buf}"
    echo "${_buf}"
}







#FUNCBEG###############################################################
#NAME:
#  cliGetKey
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the key of an suboption, if no argument returns just the key.
#  The retuned key has to be case insensitive, thus returned just 
#  as uppercase for canonical processing.
#  Therefore the following syntax elements are known:
#
#   ':' Seperates a key from it's argument, which is the first occurance
#       of a ':' seperated field $1.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <sub-options>
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    splitted list with de-masked syntax elements.
#
#FUNCEND###############################################################
function cliGetKey () {
    local A=`echo ${1}|awk -F':' '{print $1}'|tr '[:lower:]' '[:upper:]'`
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<${A}>"
    echo "${A}"
}



#FUNCBEG###############################################################
#NAME:
#  cliGetArg
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the argument of an suboption, if none, than the 
#  empty string is returned. The returned string is final and ready 
#  to use syntax stripped off from intermediary transport coding.
#  Therefore the following syntax elements are known
#
#  The usage of a double-characters for masking reserved values should 
#  be preferred, due to the required multiple occurance of the backslash, 
#  which will be passed through an unpredictable number of evaluations.
#
#
#   ':' Seperates a key from it's argument, which is the 
#       first occurance of a ':' seperated field $2. Additional
#       colons ':' within the argument are ignored.
#
#       MAC addresses of the form "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}"
#       are recognized and handled as one argument.
#
#
#   ',,' or '\,'
#       Masks a comma, preserving it from interpreted by the "simplistic"
#       command line scanner.
#
#
#   '::' or '\:'
#       Masks a colon, preserving it from interpreted by the "simplistic"
#
#
#   '%' Mask/padding character for spaces within arguments. 
#       A valid non-mask character could be masked by a '\' or
#       by double-usage of itself '%'.
#
#
#EXAMPLE:
#
#PARAMETERS:
# $1-*: <sub-options>
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    splitted list with de-masked syntax elements.
#
#FUNCEND###############################################################
function cliGetArg () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local A=${*}
    local _tmpSep="_-_-_";
    A=${A//::/$_tmpSep}
    A=${A//\\:/$_tmpSep}
    A=`echo ${A}|awk -F':' '
              {
                 out="";
                 matched=0;
                 for(i=2;i<8;i++){
                   if($i!=""&&$i~/[0-9a-fA-F][0-9a-fA-F]/){
                      out=out":"$i;
                      matched++;
                   }
                 }
                 if(matched==6){
                   print out
                 }else{
                   print $2;
                 }
              }
        '|sed 's/^://;s/\([^%]\)%\([^%]\)/\1 \2/g;s/\([^%]\)%\([^%]\)/\1 \2/g;s/%%/%/g'`
    if [ "${A}" == "${1}" ];then A=;fi

    if [ "${A%[\"\']}" != "${A}" ];then 
	if [ "${A#[\"\']}" == "${A}" ];then 
	    A="${A%[\"\']}";
	fi
    fi

    A=${A//$_tmpSep/:}

    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<${A}>"
    echo "${A}"
}


#FUNCBEG###############################################################
#NAME:
#  cliGetOptValue
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the value of an option, if none just null.
#  The last occurance is taken in case of repetition.
#
#  For now old-style only.
#
#EXAMPLE:
#
#PARAMETERS:
# $1:   <option>
# $2-*: <cli-options>
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    value provided with option
#
#FUNCEND###############################################################
function cliGetOptValue () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _o=$1;shift;
    local x="${*}";
    x="${x##*$_o }";
    if [ "${x}" == "${*}" ];then
	return
    fi
    x=${x## };
    x=${x%% *};
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<${x}>"
    echo -n -e "${x}"
}



#FUNCBEG###############################################################
#NAME:
#  cliOptionsClearRedundant
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reduces multiple occurances to the LAST option.
#  The option itself is checked only, the content is not considered.
#
#  Remote options are kept untouched.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <ORIGINAL-OPTS>
#     Options written as normal CLI options, to be stripped.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    new CLI options with each option unique only.
#
#FUNCEND###############################################################
function cliOptionsClearRedundant () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${@}"

 
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"

    fetchArgs $@ -- ""

    local curLen=0;
    local nLen=${#NEW0[@]};
    local dLen=${#DEF0[@]};
    local _match=0;
    local i=0;
    local j=0;

    local _s=;

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "curLen=${curLen} nLen=${nLen} dLen=${dLen}"
    for((j=0;j<dLen;j++));do
	if [ -n "${DEF0[$j]}" ];then
	    _s="${DEF0[$j]}";
	fi
	for((i=0;i<j;i++));do
            printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "(i,j)=($i,$j) ${DEF0[$i]} =? ${_s}"
	    [ -z "${DEF0[$i]}" ]&&continue;
	    if [ "${DEF0[$i]}" == "${_s}" ];then
                printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "match i=$i"
		DEF0[$i]=;
	    fi
	done
    done

    local OUT=
    for ((j=0;j<dLen;j++));do
	if [ -n "${DEF0[$j]}" ];then
	    OUT="${OUT} ${DEF0[$j]} ${DEF1[$j]}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT=${OUT}"
	fi
    done
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "OUT=${OUT}"
    echo "${OUT}"
}

