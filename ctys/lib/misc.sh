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
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myLIBNAME_misc="${BASH_SOURCE}"
_myLIBVERS_misc="01.06.001a12"
libManInfoAdd "${_myLIBNAME_misc}" "${_myLIBVERS_misc}"

_myLIBNAME_miscBASE="`dirname ${_myLIBNAME_misc}`"


#FUNCBEG###############################################################
#NAME:
#  removeLeadZeros
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
#
#FUNCEND###############################################################
function removeLeadZeros () {
  echo -e "${1}"|sed -n 's/^0*\([^0].*\)\(.\)$/\1\2/p'
}


#FUNCBEG###############################################################
#NAME:
#  getDateTimeOfInode
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:  Inode
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function getDateTimeOfInode () {
  [ -n "$1" -a -e "$1" ]&&{ local x=`ls -l --time-style '+%Y%m%d%H%M%S' $1`;x=${x% *};x=${x##* }; }
  echo -n $x
}


#FUNCBEG###############################################################
#NAME:
#  getMyUGID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetched the User-ID and Group-UID of primary group,
#  as string in the format:
#
#    <uid>;<guid>
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
function getMyUGID () {
    local _ugid=`id|sed -n  's/[^u]*uid=[0-9]*(\([^\)]*\)) *gid=[0-9]*(\([^\)]*\)).*/\1;\2/p'`
    echo -n ${_ugid:-;}
}


#FUNCBEG###############################################################
#NAME:
#  getCurTime
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Displays current system time.
#
#EXAMPLE:
#PARAMETERS:
#OUTPUT:
#  RETURN:
#
#  VALUES:
#    <hour>:<minute>:<second>
#
#FUNCEND###############################################################
function getCurTime () {
    date +'%H:%M:%S'
}


#FUNCBEG###############################################################
#NAME:
#  getDiffTime
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Displays the difference between two timestamps.
#
#EXAMPLE:
#PARAMETERS:
#  $1: subtrahend: <hour>:<minute>:<second>
#  $2: subtractor: <hour>:<minute>:<second>
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    difference: $1 - $2 = <hour>:<minute>:<second>
#
#FUNCEND###############################################################
function getDiffTime () {
  echo "$2:$1"|awk -F':' '{
    end=$4*3600+$5*60+$6
    sta=$1*3600+$2*60+$3

    #assume midnight, and max-diff=24h
    if($4<$1){end=end+24*3600;}

    dif=end-sta

    s=dif%60
    m=((dif-s)/60)%60
    h=((dif-m*60-s)/3600)
    printf("%02d:%02d:%02d",h,m,s);
  }'
}


#FUNCBEG###############################################################
#NAME:
#  replaceMacro
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Replaces a string literal with the pre-defined string. 
#  The replacement string could be a string literal by itself, or simple
#  eval-by-echo string containing simple variables or arbitrary executable
#  code.
#
#  Currently processes only one MACRO for each call, the recursion handles
#  deepness AND repetition.
#
#  Replacement is done FROM-RIGHT-TO-LEFT
#
#EXAMPLE:
#PARAMETERS:
#  $1: Complete macro string: MACRO:<macro-name>[%<macro-file-db>][%(ECHO|EVAL)]
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    Resultstring, which is an execution result, or simply a literal 
#    replacement.
#
#
#FUNCEND###############################################################
function replaceMacro () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:\$@=<${@}>"

    if [ ! -d "${CTYS_MACRO_TMPPATH}" ];then
	mkdir -p "${CTYS_MACRO_TMPPATH}"
	if [ ! -d "${CTYS_MACRO_TMPPATH}" ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot create missing:${CTYS_MACRO_TMPPATH}"
	    gotoHell ${ABORT};
	fi
    fi


    function keysToUppercase () {
        local _myAlias="$*"
        #handle suboption value-keywords
#sadly to be dropped for multi-platform-sed-compatibility, kept as reminder for now        
# 	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:Final:_myAlias=${_myAlias}"
# 	_myAlias="`echo ' '${_myAlias}' '|sed  's/[=,][^:, ]*[:, ]/\U&/;'`"
# 	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:Final:_myAlias=${_myAlias}"
# 	_myAlias="`echo ' '${_myAlias}' '|sed  's/,[^:, ]*/\U&/g;'`"
# 	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:Final:_myAlias=${_myAlias}"
# 	_myAlias="`echo ' '${_myAlias}' '|sed  's/[^:, ]*,/\U&/g;'`"
# 	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:Final:_myAlias=${_myAlias}"


        #handle suboption-keywords
#only unambiguous with "--", but for now canceled.
# 	_myAlias=`echo " ${_myAlias} "|sed  's/\(-. *\)\([^-][^:, ]*\)\([:, ]\)/\1\U\2\3/g;s/^ *//;s/ *$//'`
        
 	_myAlias=`echo -e "${_myAlias}"|sed  's/^ *//;s/ *$//'`
         echo -e "${_myAlias}"
    }

    #break the recursion when ready, or if nothing todo
    if [ "${*//[mM][aA][cC][rR][oO]:/}" == "$*" ];then
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:No MACRO to process."
 
        #the first call handles EVAL
        echo -e "`keysToUppercase $*`"
	return
    fi

    local _myMacro=;
    local _cliM="$*"
    _cliM=${_cliM#*\{[mM][aA][cC][rR][oO]:};
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_cliM=<${_cliM}>"
    if [ "${_cliM}" != "${*}" ];then
	_myMacro=`echo -e " $* "|sed -n 's/^.*{[mM][aA][cC][rR][oO]:\([^,%} ]*\).*$/\1/p'`
    else
	_myMacro=`echo -e " $* "|sed -n 's/^.*[mM][aA][cC][rR][oO]:\([^,% ]*\).*$/\1/p'`
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_myMacro=<${_myMacro}>"


    local _myPrefix=;
    _myPrefix=`echo -e " $* "|sed -n 's/^\(.*\){[mM][aA][cC][rR][oO]:.*/\1/p'`
    if [ -z "${_myPrefix}" ];then
	_myPrefix=`echo -e " $* "|sed -n 's/^\(.*\)[mM][aA][cC][rR][oO]:.*/\1/p'`
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_myPrefix=<${_myPrefix}>"

 
    local _myPostfix=;
    _myPostfix=`echo -e " $* "|sed -n 's/^.*{[mM][aA][cC][rR][oO]:\([^,%} ]*\)}\(.*\)$/\2/p'`
    if [ -z "${_myPostfix}" ];then
	_myPostfix=`echo -e " $* "|sed -n 's/^.*[mM][aA][cC][rR][oO]:\([^,% ]*\)\(.*\)$/\2/p'`
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_myPostfix=<${_myPostfix}>"




    local _myArgs=${_myPostfix%%[, \}]*}
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_myArgs=<${_myArgs}>"

    if [ "$_myArgs" != "${_myPostfix}" ];then
	_myPostfix="${_myPostfix#$_myArgs}"
    else
	local _myArgs=${_myPostfix%% *};
	local _myPostfix="${_myPostfix#* }";
    fi
    _myPostfix="${_myPostfix#\}}";
    if [ "${_myPostfix}" == "${_myPostfix#[\{(]}" ];then
	_myPostfix="${_myPostfix#\}}";
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_myPostfix=<${_myPostfix}>"

    local _myfinal="${_myArgs#*\%\%}"
    if [ "$_myfinal" != "${_myArgs}" ];then
	_myPostfix="%%${_myfinal}${_myPostfix}"
	local _myfinal="${_myArgs%\%\%*}"
    fi

    local _recurLvl=${_recurLvl:-0}
    local MAXRECURSE=${CTYS_MAXRECURSE:-15}
    if((_recurLvl++>MAXRECURSE));then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Internal error Recursion threshhold exceeded, check your environment:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: =>CTYS_MAXRECURSE=\"${CTYS_MAXRECURSE}\""
	gotoHell ${ABORT}
    fi

    #final echo
    local _task=;
    local _buf=${_myArgs//\%[eE][vV][aA][lL]/}
    if [ "$_buf" != "$_myArgs" ];then
	_task=EVAL;
	_myArgs=${_buf};
    fi
    _buf=${_myArgs//\%[eE][cC][hH][oO]/}
    if [ "$_buf" != "$_myArgs" ];then
	_task=ECHO;
	_myArgs=${_buf};
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_task=<${_task}>  _myArgs=<${_myArgs}>"
    if [ -z "$_task" ];then
	_task=ECHO;
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "Set to default:_task=<${_task}> _myArgs=<${_myArgs}>"
    fi

    local _option=;
    _buf=${_myArgs//%[oO][pP][tT][iI][oO][nN][aA][lL]/}
    if [ "$_buf" != "$_myArgs" ];then
	_option=1;
	_myArgs=${_buf};
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_option=<${_option}> _myArgs=<${_myArgs}>"

    #
    #need to evaluate macro filename once only
    #
    if((_recurLvl==1));then
        #alternative MACRO file db
	local _myFile=${_myArgs#%}
	local _myFile=${_myFile#%}
	local _myFile=${_myFile%% }
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_myFile=<${_myFile}> _myMacro=<${_myMacro}>"
	local _myFilePath=;
	if [ -n "${_myFile// /}" -a "$_myFile" != "${_myMacro}" ];then
	    if [ -f "$_myFile" ];then
		_myFilePath=${_myFile}
	    else
		local _mx=`matchFirstFile "${_myFile}" "${CTYS_MACRO_PATH}"`
		if [ $? -eq 0 ];then
		    _myFilePath=${_mx}
		fi
	    fi
	    if [ ! -f "${_myFilePath}" ];then
		ABORT=2
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot access MACRO file db:\"${_myFilePath}\""
		gotoHell ${ABORT}
	    fi
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_myFilePath=<${_myFilePath}>"
	else
	    _myFilePath=${CTYS_MACRO_DB}
	fi

        #my MACRO
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_myMacro=<${_myMacro}>"
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_myFilePath=<${_myFilePath}>"
    fi
    #just single files for the whole set are suported in this version
    local _myAlias=`cat ${_myFilePath}|awk '/^ *#.*/{next;}/^ *$/{next;}{cont=gsub("\\\\\\\\$","");if(cont==0)print;else printf("%s",$0);}'|\
         sed 's/  */ /g;s/ *= */=/'|awk -F'=' -v m=$_myMacro '
              BEGIN{mult=0;}
              $1==m{
                  x=0;
                  mult++;
                  if(mult>1){print " ***MULTIMATCH*** ";}
                  for(i=2;i<=NF;i++){
                    if(x!=1){printf("%s",$i);x=1;}
                    else printf("=%s",$i);
                  }
               }'`

    printINFO 2 $LINENO $BASH_SOURCE 1 "$FUNCNAME:Resolved MACRO:<${_myAlias}>"

    if [ "${_myAlias//MULTIMATCH}" != "${_myAlias}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Multiple definitions of macro detected:\"${_myMacro}\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:   _myAlias=\"${_myAlias}\""
	gotoHell ${ABORT}
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_myAlias=<${_myAlias}>"
    if [ -z "$_myAlias" -a -z "$_option" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing macro:\"${_myMacro}\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: - Macro names are case sensitive"
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Solution:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: - set macro correctly"
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: - use suboption \"OPTIONAL\""
	gotoHell ${ABORT}
    fi

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "replaceMacro ${_myPrefix}${_myAlias}${_myPostfix}"
    _myAlias="`replaceMacro ${_myPrefix}${_myAlias}${_myPostfix}`"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_myAlias=${_myAlias}"

    _myAlias="`keysToUppercase $_myAlias`"
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_myAlias=\"${_myAlias}\""

    case "$_task" in
	EVAL)
	    eval "$_myAlias"
	    ;;
	ECHO)
	    echo -e "$_myAlias"
	    ;;
	*)
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unknown task:\"${_task}\""
	    gotoHell ${ABORT}
	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  testUniqueOnly
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function testUniqueOnly () {
    awk 'BEGIN{cnt=0;}{cnt++;}END{if(cnt<2){print;}else{print "AMBIGUOUS(#"cnt")";exit 1;}}'
}


#FUNCBEG###############################################################
#NAME:
#  procFindTopBottom
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Displays a list of space seperated top-bottom-process lists for the 
#  given parameters.
#
#  This is utilized to find a "master-pid" as the topmost process which has 
#  initiated the current task. This ID is unique locally and is used as a
#  dynamic ID, similar to the DomainID of Xen.
#
#EXAMPLE:
#PARAMETERS:
#  $1: <call>
#      The $0 of processes to be inspected. Multiple processes could be given in 
#      order to be combined by OR. The format is given by "%%" for a replacement 
#      by "|".
#
#         "call1%call2%call3" => "call1|call2|call3"
#
#      Actually this is just a common string to be matched by "$0~call" where call
#      could be "$0~call1|call2|call3|...".
#      This is particularly foreseen for imported wrapper-cally, where the resulting 
#      CLI strig might deviate from the common string-patterns.
#      E.g. "QEMU|vdeq" for VDE-VirtualSquare based wrapper, the only supported in 
#      current ctys version.
#
#  $2: <top-label>
#      The labels for candidates of top-processes, the initiating
#      processes of a specific call-type.
#
#  $3: <bottom-label>
#      The labels for candidates of bottom-processes, the worker processes
#      of a specific call-type.
#
#  $4: [(b:<blacklist>)][,][(w:<whitelist>)][,][(e:<exclusive>)]
#      Optional a list of strings not to be matched.
#
#         "b:non1%non2%non3" => "non1|non2|non3"
#
#      Optional a list of strings to be matched additionally.
#
#         "w:only1%only2%only3" => "only1|only2|only3"
#
#      Optional a list of strings to be matched exclusively.
#
#         "e:only1%only2%only3" => "only1|only2|only3"
#
#  
#  $5: [FROMPROC]
#      Internal call from proc-functions, so no exclusion check for own process.
#
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    record list with format="<toplabel>:<top-pid>:<bottom-label>:<bottom-pid>"
#
#FUNCEND###############################################################
function procFindTopBottom () {
    export recurcheck444_procFindTopBottom=${recurcheck444_procFindTopBottom:-0};
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:(${recurcheck444_procFindTopBottom}):\$=$@"

    #assure recursion interrupt, actually the overall call limit within this process
    if((recurcheck444_procFindTopBottom++>CTYS_MAXRECURSEBASECALLS));then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Seems to be a deadlock by endless recursion, so abort"
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:This is a probable serious system error."
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Anyhow, try to raise the global threshold value for frequent basic calls."
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:=>CTYS_MAXRECURSEBASECALLS=${CTYS_MAXRECURSEBASECALLS}"
	gotoHell ${ABORT}
    fi

    [ "$5" == FROMPROC ]&&local _fromProc=1;

    local _reslst=;
    doDebug $S_LIB $D_BULK $LINENO $BASH_SOURCE
    local D=$?

    local _i21=;
    local _i21set=${4};
    for _i21 in ${_i21set//,/ };do
	if [ -n "$_i21" ];then
	    case  "${_i21%%:*}" in
		b)  local matchlist="${matchlist} -v exclude=${_i21#b:} ";;
		e)  local matchlist="${matchlist} -v exclusive=${_i21#e:} ";;
		w)  local matchlist="${matchlist} -v include=${_i21#w:} ";;
	    esac
	fi
    done
    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:matchlist=${matchlist}"

    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "Check for raw process-list on `uname -n`:=>`echo;${PS} ${PSEF};echo`<="

    case ${MYOS} in
	Linux)
	    _reslst="`${PS} ${PSEF}|awk -v d=${D} -v call=$1 -v toplabel=$2  -v bottomlabel=$3 \
               ${matchlist} \
               -f ${_myLIBNAME_miscBASE}/procFindTopBottom.awk`"
	    ;;
	FreeBSD|OpenBSD)
	    _reslst="`${PS} ${PSL}|awk -v d=${D} -v call=$1 -v toplabel=$2  -v bottomlabel=$3 \
               ${matchlist} \
               -f ${_myLIBNAME_miscBASE}/procFindTopBottom.awk`"
	    ;;
	SunOS)
	    _reslst="`${PS} ${PSL}|awk -v d=${D} -v call=$1 -v toplabel=$2  -v bottomlabel=$3 \
               ${matchlist} \
               -f ${_myLIBNAME_miscBASE}/procFindTopBottom.awk`"
	    ;;
    esac

    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_reslst(RAW)=<$_reslst>"

    if [ -n "${_reslst// /}" -a -z "$_fromProc" ];then
	local _myMaster=`procGetMyMasterPid "${1}" "${2}" "${3}" "w%$$" `

	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_myMaster=<$_myMaster>"
	local _i9=;
	local _reslstX=;
	if [ -n "${_myMaster}" ];then
	    for _i9 in ${_reslst};do
		if [ "${_i9}" != "${_i9//$_myMaster}" ];then
		    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:Suppress myself=<$_i9>"
		    continue;
		fi
		_reslstX="${_reslstX} ${_i9}"
	    done
	    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_reslstX(FINAL)=<$_reslstX>"
	    echo $_reslstX
	else
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Could not evaluate myMaster, which is the entry call for ctys."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:This seems to be a programming error, anyhow, continue for now."
	    return 1;
	fi
    else
	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_reslst(FINAL)=<$_reslst>"
	echo $_reslst
    fi
}


#FUNCBEG###############################################################
#NAME:
#  procGetMyMasterPid
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Displays the topmost so called master processes "master-pid" which has 
#  initiated the current task. This ID is unique locally and is used as a
#  dynamic ID, similar to the DomainID of Xen.
#
#
#  REMARK: Exclude self on application level, it may for some probably be wanted, 
#          to be included in the result, while other's do not.
#
#EXAMPLE:
#PARAMETERS:
#  $1: <call>
#      The $0 of processes to be inspected. Multiple processes could be given in 
#      order to be combined by OR. The format is given by "%%" for a replacement 
#      by "|".
#
#         "call1%%call2%%call3" => "call1|call2|call3"
#
#      Actually this is just a common string to be matched by "$0~call" where call
#      could be "$0~call1|call2|call3|...".
#      This is particularly foreseen for imported wrapper-cally, where the resulting 
#      CLI strig might deviate from the common string-patterns.
#      E.g. "QEMU|vdeq" for VDE-VirtualSquare based wrapper, the only supported in 
#      current ctys version.
#
#  $2: <top-label>
#      The labels for candidates of top-processes, the initiating
#      processes of a specific call-type.
#
#  $3: [<bottom-label>]
#      Optional a bottom identifier, could be the callname or a PID of a process, 
#      when missing PID=$$ of current process is used.
#
#  $4: [(b:<blacklist>)|(w:<whitelist>)]
#      Optional a list of strings not to be matched.
#
#         "b%non1%non2%non3" => "non1|non2|non3"
#
#      Optional a list of strings to be matched only.
#
#         "w%only1%only2%only3" => "only1|only2|only3"
#
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    record list with format="<top-pid>"
#
#FUNCEND###############################################################
function procGetMyMasterPid () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:\$@=<$@>"
    local _pid=${3:-$$}
    local _non=${4}

    local _procLst=`procFindTopBottom "$1" "$2" "$_pid" "${_non}" FROMPROC`
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_procLst=<$_procLst>"
    local _i=;
    local _ambig=0;
    local _myMaster=;
    local _lastMaster=;

    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_pid=<$_pid>"

    if [ -n "$_procLst"  ];then
	for _i in $_procLst;do
	    _myMaster=${_i#*:}
	    _myMaster=${_myMaster%%:*}

            #???
	    if [ "$_myMaster" == "$$" ];then
		break;
	    fi

#due to missing fork, but ...
# 	    if((_ambig>1));then
# 		ABORT=1
# 		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Ambiguous top-level pid found"
# 		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:   _myMaster=\"${_myMaster}\""
# 		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:   _i       =\"${_i}\""
# #4test
# # pstree -l -p ${_myMaster}
# # pstree -l -p $(ps -ef|awk '/sshd/&&$3==1{print $2;}')
# 		gotoHell ${ABORT}
# 	    fi

            if [ "${_myMaster}" != "${_lastMaster}" ];then
		let _ambig++;
	    fi
	    _lastMaster="${_myMaster}"
	    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_myMaster=<$_myMaster>"
	done
    fi
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_myMaster=<$_myMaster>"
    echo -n "${_myMaster}"
}


#FUNCBEG###############################################################
#NAME:
#  getExecArch
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:  executable
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function getExecArch () {
  [ -z "$1" ]&&return;
  local _fpath=`gwhich $1`;
  [ -z "$_fpath" ]&&return;
  file "$_fpath"|awk -v myarch="${MYARCH}" '
      /x86-64/{printf("x86_64");exit;}
      /80386/{printf("i386");exit;}
      {printf("%s",myarch);exit;}
  ';
}


#FUNCBEG###############################################################
#NAME:
#  clipWordLine
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Does a simple clipping, but considers "words" to be the break-start.
#
#  Reads stream from stdin.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:  size of line-entry, includes indent, default=80
#  $2:  indent, any line "1+", default=0
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function clipWordLine () {
    local _size="${1:-80}";
    local _indent="${2:-0}";

    awk -v size="${_size}" -v indent="${_indent}" -f ${_myLIBNAME_miscBASE}/clipWordLine.awk
}



#FUNCBEG###############################################################
#NAME:
#  matchFirstFile
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Matches first file within provided pathlist
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:    file to be found
#  $2-*:  path to be searched
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    PATHNAME of found file, else searched filename
#
#FUNCEND###############################################################
function matchFirstFile () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ARGV=${*}"
    local _fname=$1;shift
    local _mfname=;
    if [ -f "${_fname}" ];then 
	local _m=1;_mfname=$_fname
    else
	for i in ${*//:/ };do
            _mfname="${i}/$_fname"
	    if [ -f "${_mfname}" ];then local _m=1;break;fi
	done
    fi
    if [ -z "${_m}" ];then 
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:no entity present:${_fname}"
	return 0;
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:matched:${_mfname}"
    echo $_mfname
    return 0;
}



#FUNCBEG###############################################################
#NAME:
#  matchFirstFileX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Matches first file within the subtrees of provided pathlist.
#  When no filename provided, all are listed.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:    file to be found, when empty or "ALL" all are listed.
#  $2-*:  path to be searched
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    PATHNAME of found file, else searched filename
#
#FUNCEND###############################################################
function matchFirstFileX () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ARGV=${*}"
    local _fname=$1;shift
    local _mfname=;

    if [ -z "${_fname}" -o "${_fname}" == "ALL" ];then 
	if [ -n "${*//:/ }" ];then
	    _mfname=$(find ${*//:/ } -print)
	fi
	echo $_mfname
	return 0;
    fi

    if [ -f "${_fname}" ];then 
	local _m=1;_mfname=$_fname
    else
	if [ -n "${*//:/ }" ];then
	    _mfname=$(find ${*//:/ } -print|awk 'BEGIN{ig=0;}{if(ig!=0){printf("%s",$0);ig=1;}}')
	fi
        if [ -f "${_mfname}" ];then local _m=1;fi
    fi
    if [ -z "${_m}" ];then 
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:no entity present:${_fname}"
	return 0;
    fi
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:matched:${_mfname}"
    echo $_mfname
    return 0;
}
