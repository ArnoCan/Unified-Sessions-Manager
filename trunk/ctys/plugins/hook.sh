#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#common hook-base for CORE packages
PKPATH_CORE="`dirname ${BASH_SOURCE}`/CORE"

#common hook-base for GENERIC packages
PKGPATH_GENERIC="`dirname ${BASH_SOURCE}`/GENERIC"


#actually loaded core project specific basic extensions
PACKAGES_CORE=""

#actually loaded project specific applications comon extensions
#e.g. LIST of all appplications.
PACKAGES_GENERIC=""

#actually loadad application specific feature plugins
#visible to the user(human and non-human(Not only aliens of course!))
PACKAGES_KNOWNTYPES=""


#actually loadad application specific feature plugins
#gwhich are not operable, these might not be an error, but just caused by installing
#a generic superset.
#
#The philosophy of installing supersets has definitive advantages, e.g. when chaning the 
#running kernel from Xen to one that is based on another VM. In that case nothing has 
#to be manually configured, the plugin of "deactivated type" just does now nothing (giving 
#a warning of course), whereas the plugin of activated "kernel type" not performs.
#
#The following variable supports a list of all known plugings, gwhich are detected as 
#disabled when starting.
#
PACKAGES_DISABLED=""


#The following variable supports a list of all known plugings, gwhich are ignored 
#due to configuration of variable "<plugin>_IGNORE". 
#
PACKAGES_IGNORED=""



#
#The current init state, gwhich is quite similar to the UNIX init states.
#The plugings have to handle state stanges if required. This is particularly true
#when specific changes to the runtime environment has been made, blocking 
#functionalities for for handling individual and overall states.
#
#REMINDER: One example is the WoL feature, when running Xen-3.0.2, where the bridge
#          of pethX has to be shutdown first, and probably the pethX has to be reset
#          to ethX, in order to handle teh ethtool call successfully.
#
INITSTATE=0;

#
#List of packages, CORE and plugins-hooks plus subpackages.
#
#declare -a PKG_NAME

#
#List of packages, CORE and plugins-hooks plus subpackages.
#
#declare -a PKG_FILES



#FUNCBEG###############################################################
#NAME:
#  hookGetPathname
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Find first matching pathname in search path.
#  Entry only in first sub-level, no deep-search!!!
#  Returns full pathname
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <ID>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookGetPathname () {
    local _curName=$1
    local _f=;
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Package:${_curName}"

    #attach my hook..
    #..gwhich should remain as the only and one hard-coded.
    for _f in ${LD_PLUGIN_PATH//:/ } ${MYINSTALLPATH}/plugins ;do
        printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Check:${_f}/${_curName}"
        #Ooooops...
        if [ -z "${_f}" ];then 
            ABORT=2;
            printERR $LINENO $BASH_SOURCE ${ABORT} "Something strange occured: EMPTY part of LD_PLUGIN_PATH}=\"${LD_PLUGIN_PATH}\""
            gotoHell ${ABORT};
#            return 1;
        fi

        #look for filename only
        if [ -f "${_f}/${_curName}" ];then 
  	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Package: hook=${_f}/${_curName}"
            echo -n "${_f}/${_curName}"
            return 0;
        fi

        #look for directory
        if [ -f "${_f}/${_curName}/hook.sh" ];then 
  	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Package: hook=${_f}/${_curName}"
            echo -n "${_f}/${_curName}"
            return 0;
        fi
    done
    return 1;
}




#FUNCBEG###############################################################
#NAME:
#  hookEnumeratePackages
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Find first matching package in search path.
#  The CORE plugins will be handlede in an specific way, because they might
#  be already useable when loading and initializing any feature package.
#
#  There are two cases handled:
#
#  1.) Argument given:
#      Enumerate anything contained within that directories, gwhich theirself
#      are contained within each search path. Particularly helpful for 'CORE'.
#
#  2.) No arguments provided
#      Enumerate the whole set of search paths, including defaults 
#      without any subdirectory 'CORE'.
#
#EXAMPLE:
#
#GLOBALS:
#  LD_PLUGIN_PATH
#    Same syntax and Similiar semantics as LD_LIBRARY_PATH.
#
#PARAMETERS:
# [$1]: Name of category to be scanned. Currently available CORE, GENERIC, 
#       and IGNORED, else anything within the LD_PLUGIN_PATH variable will be 
#       scanned.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookEnumeratePackages () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Enumerate plugins:${*}"

    if [ "${1// /}" == "IGNORED" ];then
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:IGNORED-mactch:${1// /}"
	local _lstIgnored=1;shift
    fi
    local _curNames=$@;
    local _curEnum=;
    local _f=;
    local _g=;

    if [ -z "${_curNames}" ] ;then
        #aything else than CORE
        local _tmp1=""
	for _f in ${LD_PLUGIN_PATH//:/ } ;do
	    _tmp1="${_tmp1} `echo -n ${_f}/[A-Z0-9]*[^~#]`"
	done

        printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ENUM=${_tmp1}"
	for _f in ${_tmp1} ;do
 	    if [  -f "${_f}" ];then
		continue
	    fi
	    local _type=${_f##*/}

	    if [ -n "`eval echo \\\${${_type}_IGNORE}`" ];then
		if [ -n "${_lstIgnored}" ];then
		    printWNG 2 $LINENO $BASH_SOURCE 0 "IGNORE-CONFIGURED:${_type}->\"${_f}\""
		    _curEnum="${_curEnum} ${_type}"
		fi
		continue
	    fi
	    if [ -n "${_lstIgnored}" ];then
		continue
	    fi
	    _curEnum="${_curEnum} `echo ${_f}|sed -n '/CORE/d;/plugins\/hook/d;p'`"
	done
    else
	for _f in ${_curNames} ;do
            #even though it is basically possible to disable CORE plugins too, think 
            #twice before doing it.
	    local _type=${_f##*/}
	    if [ -n "`eval echo \\\${${_type}_IGNORE}`" ];then
		if [ -n "${_lstIgnored}" ];then
		    printWNG 2 $LINENO $BASH_SOURCE 0 "IGNORE-CONFIGURED:${_type}->\"${_f}\""
		    _curEnum="${_curEnum} ${_type}"
		fi
		continue
	    fi
	    if [ -n "${_lstIgnored}" ];then
		continue
	    fi
            if [ ${_f} == "CORE" ];then
                #CORE entity
                for _g in `echo -n ${MYINSTALLPATH}/plugins/${_f}/[0-9A-Z]*[^~#]`;do
		    _curEnum="${_curEnum} `hookGetPathname ${_f}/${_g##/*/}`"
		done
            else
               #anything except CORE as resulting of what exactly is given
		_curEnum="${_curEnum} `hookGetPathname ${_f}`"
            fi

	done
    fi
    _curEnum="`echo ${_curEnum}|sort -u`"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ENUM=${_curEnum}"
    echo -n "${_curEnum}"
    return 0;
}


#FUNCBEG###############################################################
#NAME:
#  hookInfoCheck
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
function hookInfoCheck () {
    local _s=${#PKG_FILES[@]}
    local _i=0;

    for((_i=0;_i<_s;_i++));do
        [ "${PKG_FILES[$_i]}" == "${1}" ]&&return 0;
    done
    return 1;
}


#FUNCBEG###############################################################
#NAME:
#  hookInfoCheckPKG
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether already loaded.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: PKG-name
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookInfoCheckPKG () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@ $@"
    
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
    local _present=`echo " ${PACKAGES_KNOWNTYPES} "|sed -n 's/^.* \('$1'\) .*$/\1/p'`
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME _present=${_present}"
    echo "${_present}"
    if [ -n "${_present}" ];then
	return 0
    fi
    return 1
}




#FUNCBEG###############################################################
#NAME:
#  hookGetPluginType
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
# $1: Name of plugin or type-path or subpackage-path
#     Requires absolute paths, when a path is given
#  
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    canonical name of plugin type, which is one of the sub-directories
#    of LD_PLUGIN_PATH
#
#FUNCEND###############################################################
function hookGetPluginType () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Search:${*}"
    if [ -z "$1" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing argument"
	gotoHell ${ABORT};

    fi

    local _1=;
    _1=${1%.sh}
    _1=${_1%/hook}
    local _present=`hookEnumeratePackages`
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_present:${_present}"
    local _f=;
    for _f in ${_present} ;do
	_f=${_f%.sh};
	_f=${_f%/hook};

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_1:${_1}"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_f:${_f}"
        if [ "${_1//$_f}" != "${_1}" ];then
            #matched, well some ambiguity still there
	    if [ "${_1%$_f}" != "${_1}" ];then
                #OK, is plugins base
		echo ${_f##*/}
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-PKG:${_f##*/}"
		return 
	    else
                #Possibly plugins subpackage, still ambigous

		local _main=${_1%/*}

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-BASE-PKG:${_main}"


		if [ "${_1%$_f}" != "${_1}" ];then
                    #OK, is plugins subpackage
		    echo ${_f##*/}
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-SUB-PKG:${_f##*/}"
		    return 
		fi
	    fi

        fi
    done
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  hookPackage
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Loads an list of plugins as given explicitly.
#  Therefore the following naming convention is applied:
#
#  for each list-element
#    1. IF:  check whether it is a filepathname
#            if YES => load(source) it
#               No repetition-checks, but due to basic convention
#               no repetition should occur at all for managed 
#               top-level packages.
#            next one...
#    2. ELSE:check whether it is a directory containing a file
#            named "hook" literally
#            if YES => load(source) it
#            next one...
#    3. OOPS.....
#            Aaaaa.., than gotoHell!!!
#            But do not forget to GIVE a HINT!!!
#
#
#EXAMPLE:
#
#PARAMETERS:
# $1: List of names
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookPackage () {
    local _features=;
    local _f=;
    local _ret=0;

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Loading plugins:${*}"

    function loadIt () {
	local _f=$1
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:${1}"

        #native trial - assume path given
	if [ -f "${_f}" ]; then
	    hookInfoCheck ${_f};
	    if [ $? != 0 ];then
		. ${_f}
                #only need to be updated when not yet present
		local _type=`hookGetPluginType "${_f}"`
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:loaded:${_type}"
		if [ "${PACKAGES_KNOWNTYPES//$_type}" == "${PACKAGES_KNOWNTYPES}" ];then
                    #not yet known
		    PACKAGES_KNOWNTYPES="${PACKAGES_KNOWNTYPES} ${_type}"
		fi
	    fi
	    return
	else
	    _f=${_f}/hook.sh
	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:try:${_f}"
	    if [ -f "${_f}"  ];then
		hookInfoCheck ${_f}
		if [ $? != 0 ];then
		    . ${_f}
                    #only need to be updated when not yet present
		    local _type=`hookGetPluginType "${_f}"`
		    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:loaded:${_type}"
		    if [ "${PACKAGES_KNOWNTYPES//$_type}" == "${PACKAGES_KNOWNTYPES}" ];then
                        #not yet known
			PACKAGES_KNOWNTYPES="${PACKAGES_KNOWNTYPES} ${_type}"
		    fi
		fi
		return
	    fi
	fi
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:missing:${1}"
	return 1
    }

    for _f in $@;do
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Source:$_f"
        #native trial - assume path given
	loadIt "${_f}"
	if [ $? != 0 ];then 
            #assume now name only given, so have to find the path
	    local _tmp1=;
	    local _p=;

            #fetch all possible full paths
	    for _p in ${LD_PLUGIN_PATH//:/ } ;do
		_tmp1="${_tmp1} `echo -n ${_p}/[A-Z0-9]*[^~#]`"
	    done

            #check for each
 	    for _p in ${_tmp1} ;do
		if [ "${_p##*/}"  == "${_f}" ];then
		    local _myPath=`hookGetPathname "${_f}"`
 		    loadIt "${_myPath}"
		    let _ret+=$?;
                    break;
		fi
	    done
	fi
        _features="${_features} ${_f##/*/}"
    done

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Loaded plugins:_features=\"${_features}\""
    return ${_ret}
}



#FUNCBEG###############################################################
#NAME:
#  hookPackages
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Loads an list of plugins as defined by general naming convention and
#  semantics of ctys for directory names and contained plugins.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: List of names
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookPackages () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"

    local _ignored=`hookEnumeratePackages IGNORED`
    local _core=`hookEnumeratePackages CORE`
    local _generic=`hookEnumeratePackages GENERIC`
    local _availFeatures=`hookEnumeratePackages`
    local _loadFeatures=;
    local _i=;
    local _j=;
    local _g=;


    PACKAGES_IGNORED=${_ignored}
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "PACKAGES_IGNORED=\"${PACKAGES_IGNORED}\""

    for _j in ${_core};do
        PACKAGES_CORE="${PACKAGES_CORE} ${_j##/*/}"
    done
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Hook core plugins:PACKAGES_CORE=\"${PACKAGES_CORE}\"..."
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Hook core plugins:_core=\"${_core}\"..."
    hookPackage ${_core}
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "...loaded."

    for _g in ${_generic};do
        PKGPATH_GENERIC="${PKGPATH_GENERIC} ${_g##/*/}"
    done

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Hook core plugins:PACKAGES_GENERIC=\"${PACKAGES_GENERIC}\"..."
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Hook generic plugins:_generic=\"${_generic}\"..."
    hookPackage ${_generic}
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "...loaded."


    if [ -n "${CTYS_MULTITYPE}" -a "${CTYS_MULTITYPE}" == DEFAULT ];then 
	MCHK=${DEFAULT_C_SESSIONTYPE}
    else
	MCHK=${CTYS_MULTITYPE}
    fi
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "CTYS_MULTITYPE  =${CTYS_MULTITYPE} - MCHK(${MCHK})"

    if [ -n "${C_SESSIONTYPE}" -a "${C_SESSIONTYPE}" == DEFAULT ];then 
	SCHK=${DEFAULT_C_SESSIONTYPE}
    else
	SCHK=${CTYS_MULTITYPE}
    fi
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "C_SESSIONTYPE=${C_SESSIONTYPE} - SCHK(${SCHK})"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "_availFeatures=${_availFeatures})"

    for _j in ${_availFeatures};do
        #This is due to resource limits when loading multiple plugins,
        #for additional information refer to "preFetchAndLoadTypeOption"
        #description.

	if [ -n "${MCHK}" ];then 
            if [ "${MCHK}" != ALL ];then 
		for _i in ${MCHK//,/ };do
		    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "try: ${_j##/*/} == ${_i}"
		    if [ "${_j##/*/}" == "${_i}" ];then 
			local _matchP=1;
			printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "match..."
		    fi
		done
		if [ -z "${_matchP}" ];then continue;fi
                unset _matchP;
	    fi
	else
	    if [ "${SCHK}" != ALL -a "${_j##/*/}" != "${SCHK}" ];then 
		continue;
	    fi
	fi
	_loadFeatures="${_loadFeatures} ${_j}"
    done
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Hook feature plugins:_availFeatures =\"${_availFeatures}\""
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Hook feature plugins:_loadFeatures  =\"${_loadFeatures}\""
    hookPackage ${_loadFeatures}
    PACKAGES_KNOWNTYPES="${PACKAGES_KNOWNTYPES//+( |\t)/ }"
    PACKAGES_KNOWNTYPES="${PACKAGES_KNOWNTYPES##+( |\t)}"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "Hook feature plugins:PACKAGES_KNOWNTYPES=\"${PACKAGES_KNOWNTYPES}\""
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "...loaded."
}



#FUNCBEG###############################################################
#NAME:
#  hookInitPropagate
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Propagates the given init-state to all registered - a.k.a. managed - 
#  plugins.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: InitState
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookInitPropagate () {
  local _i=;
  for _i in ${PACKAGES_KNOWNTYPES} ${PACKAGES_GENERIC};do
      eval init${_i} $1
      if [ $? -ne 0 ];then
	  PACKAGES_DISABLED="${PACKAGES_DISABLED} $_i"
      fi
  done
}

#FUNCBEG###############################################################
#NAME:
#  hookInitPropagate4Package
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Propagates the given init-state to all registered - a.k.a. managed - 
#  plugins.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: List of names
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookInitPropagate4Package () {
  local _pkglst="$*";
  local _i=;

  for _p in $_pkglst;do
      for _i in 1 2 3 4 5 6;do
	  eval init${_p} $_i
	  if [ $? -ne 0 ];then
	      PACKAGES_DISABLED="${PACKAGES_DISABLED} $_i"
	  fi
      done
  done
}


#FUNCBEG###############################################################
#NAME:
#  hookGetKnownTypes
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
function hookGetKnownTypes () {
  echo ${PACKAGES_KNOWNTYPES};
}



#FUNCBEG###############################################################
#NAME:
#  hookGetDisabledTypes
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
function hookGetDisabledTypes () {
  echo ${PACKAGES_DISABLED};
}


#FUNCBEG###############################################################
#NAME:
#  hookGetIgnoredTypes
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
function hookGetIgnoredTypes () {
  echo ${PACKAGES_IGNORED};
}


#FUNCBEG###############################################################
#NAME:
#  hookInfoAdd
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Adds an entry to info array, where all plugins will be registered
#  with basic information, gwhich is for now:
#
#  <pkg-name> <pkg-version>
#
#EXAMPLE:
#
#PARAMETERS:
# <pkg-name> 
# <pkg-version>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookInfoAdd () {
  local _s=${#PKG_NAME[@]}
  if [ -n "$1" ];then
    PKG_NAME[$_s]="${1#$MYPKGPATH/}"
    PKG_FILES[$_s]="${1}"
  fi
  if [ -n "$2" ];then
    PKG_VERS[$_s]="$2"
  fi
}

#FUNCBEG###############################################################
#NAME:
#  hookInfoList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all entries from PKG_NAME/VERS.
#
#EXAMPLE:
#
#GLOBALS:
#  C_PRINTINFO
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function hookInfoList () {
    local _s=${#PKG_NAME[@]}
    local _i=0;

    echo "PLUGINS(dynamic-loaded - ctys specific):"
    echo
    printf "  %02s   %-43s%s\n" "Nr" "Plugin" "Version"
    echo "  ------------------------------------------------------------"
    for((_i=0;_i<_s;_i++));do
        if [ "${PKG_NAME[$_i]%%/*}" != "${_cur}" ];then local _cur="${PKG_NAME[$_i]%%/*}";echo;fi
	printf "  %02d   %-43s%s" $_i ${PKG_NAME[$_i]} ${PKG_VERS[$_i]}
	[ "${C_PRINTINFO}" == 2 ]&&printf " %s" "${PKG_FILES[$_i]}"
	printf "\n"
    done
    echo
}


#FUNCBEG###############################################################
#NAME:
#  hookInitPropagate
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  The main initialization of this file. Therefore the init is divided into 
#  several steps in analogy to UNIX-BSD style. Even though not very common,
#  this seems here somewhat appropriate, due to the circumstance, that the 
#  origin of these plugins is from UNIX systems administrations tools, and
#  more or less allways related to some system functionality or even init-states.
#
#  In addition the generic on-the-fly load concept of libraries and plugins only
#  by presence opens some potential interaction faults, gwhich might be avoided or
#  limited at least when having a global reliable init state - by convention of 
#  course.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <init-level>
#
#     0: OPSTATE_PREINITCALL
#        Only basic environment allocations such as variables and functions allocations
#        are performed. This is almost only what the shell does when "source"-ing a file.
#
#     1: OPSTATE_STANDALONE
#        This is performed as final step after load. Any generic initialization with local
#        and maybe some basic external prerequisites are performed.
#        
#
#     2: OPSTATE_EXTCALLABLE
#        After this the current file could be accessed by external interfaces.
#
#        Any initialization gwhich requires more than basic external prerequisites for 
#        initial operational state.
#
#        This call is optional, if that any specific action is required at all. But if 
#        required, than has to be called explicitly.
#        
#     3: OPSTATE_NETOK
#        After this any required networking functionality is accessible. So any function
#        requiring any kind of network related initialization, like account registration
#        of the human/automated-caller is finished, or self registration in case of 
#        pre-reuisite services is finished.
#        Validation of reliabilty of this state is included.
#
#     4: OPSTATE_DBOK
#        After this any required database functionality is accessible. So any function
#        requiring any kind of database related initialization is finished.
#        Validation of reliabilty of this state is included.
#
#     5: OPSTATE_GUIOK
#        After this any required GUI functionality is accessible. So any function
#        requiring any kind of GUI related initialization is finished.
#        Validation of reliabilty of this state is included.
#
#     6: OPSTATE_PREPREBOOT
#        This indicates the plugins to prepare for a reboot.
#
#     7-9: 
#        not supported.
#
# $2: [NOEXIT]
#     When this literal is set no exit will be performed in case of an init-error.
#     Else current process will be terminated.
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function initPACKAGES () {
    local _curInit=$1;shift
    local _initConsequence=$1;

    local _raise=$((INITSTATE<_curInit));

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

    if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

	case $_curInit in
	    0);;#NOP - Done by shell
	    1)
		hookPackages;
		hookInitPropagate ${_curInit} ${_initConsequence}
		;;
	    2)hookInitPropagate ${_curInit} ${_initConsequence};;
	    3)hookInitPropagate ${_curInit} ${_initConsequence};;
	    4)hookInitPropagate ${_curInit} ${_initConsequence};;
	    5)hookInitPropagate ${_curInit} ${_initConsequence};;
	    6)hookInitPropagate ${_curInit} ${_initConsequence};;
	esac
    else
        #currently passthrough only
	case $_curInit in
	    *)hookInitPropagate ${_curInit} ${_initConsequence};;
	esac

    fi

    INITSTATE=$_curInit
}


#FUNCBEG###############################################################
#NAME:
#  initPackages
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
function initPackages () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _ret=1;
    local MYROOTHOOK=${1};

    for n in 1 2 3 4 5;do
  	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Packages: entering init(${n})..."
        initPACKAGES $n
    done
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Packages: ...init finished."
}


