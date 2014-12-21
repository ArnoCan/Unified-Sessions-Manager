########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_007
#
########################################################################
#
#     Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################


#FUNCEG###############################################################
#
#PROJECT:
MYPROJECT="Unified Sessions Manager"
#
#NAME:
#  ctys-install.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager - CLI-Installer - Stage-0"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-install.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  sh-script
#
#VERSION:
VERSION=01_11_007
#DESCRIPTION:
#  Install script for ctys. Generic shell script for bootstrap, 
#  should work on almost any bourne-like shell.
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#  refer to online help "-h" and/or "-H"
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################

#
#Deactivate CTYS_INI check
#
export CTYS_INSTALLER=1;


MYOS=`dirname $0`
MYOS=`${MYOS}/getCurOS.sh`

if [ -z "${CTYS_LIBPATH_INSTALL}" ];then
    CTYS_LIBPATH_INSTALL=$(dirname $0)
    if [ "$CTYS_LIBPATH_INSTALL" == "." ];then
	CTYS_LIBPATH_INSTALL=$(dirname $PWD)
    else
	CTYS_LIBPATH_INSTALL=$(dirname $CTYS_LIBPATH_INSTALL)
    fi
    export CTYS_LIBPATH_INSTALL
fi

if [ -z "$BASH" ];then
    echo "*********************************************************************"
    echo "* The UnifiedSessionsManager scripts require the \"bash\".            *"
    echo "* For the installation of this version a user driven setting of the *"
    echo "* \"bash\" shell is required.                                         *"
    echo "*                                                                   *"
    echo "* Call: 1. bash                                                     *"
    echo "*       2. <path>/ctys-install.sh <args>                               *"
    echo "*                                                                   *"
    echo "*********************************************************************"
    exit 1
fi


if [ "$HOME" == "/" ];then
    echo "The UnifiedSessionsManager requires a HOME directory differen from top=\"/\"."
    echo "If you are root, you may create \"/root\" and set this as your home."
    exit 1
fi

case ${MYOS} in
    SunOS)
	export PATH=/usr/xpg4/bin:/opt/sfw/bin:/usr/sbin:/usr/bin:/usr/openwin/bin:$PATH
	;;
esac

function gwhich () {
    case ${MYOS} in
	SunOS)
	    local _xf=`which $*`;
	    case $_xf in
		no*)
		    return 1;
		    ;;
	    esac
	    echo -n -e $_xf
	    ;;
	*)which $*
	    ;;
    esac
}


if [ "${*}" != "`echo ${*}|sed 's/-h//'`" ];then
    dn=`dirname $0`
    ${dn}/ctys-install1.sh -h
    exit 0
fi

if [ "${*}" != "`echo ${*}|sed 's/-H//'`" ];then
    dn=`dirname $0`
    ${dn}/ctys-install1.sh ${*}
    exit 0
fi

if [ "${*}" != "`echo ${*}|sed 's/-X//'`" ];then
    C_TERSE=1
fi
if [ "${*}" != "`echo ${*}|sed 's/-V//'`" ];then
    if [ -n "${C_TERSE}" ];then
	echo -n ${VERSION}
    else
	echo "$0: VERSION=${VERSION}"
    fi
    exit 0
fi

echo
echo "ctys-install.sh"
echo "==============="
echo
echo "First stage - #0"

######################################################################
echo
echo "  - Generic environment pre-checks for basics."
echo
echo "    Check accesibility of some \"very basic\" mandatory utilities"
echo
######################################################################

#mandatory-0
MANDATORY="which bash dirname basename find grep awk sleep uname "
echo "Check for level-0==absolutely-mandatory - else almost nothing might work."
for i in $MANDATORY;do
    gwhich $i 2>&1 >/dev/null
    if [ $? -ne 0 ];then
	echo "Oh, ...."
 	echo "....missing level-0==absolutely-mandatory:\"$i\", so check your basic shell evironment."
	exit 1
    else
	echo "      $i - OK"
    fi
done
echo

#mandatory-1
MANDATORY="ps "
echo "Check for level-1==mandatory - else (for now too!) almost nothing might work."
for i in $MANDATORY;do
    gwhich $i 2>&1 >/dev/null
    if [ $? -ne 0 ];then
	echo "Oh, ...."
	echo "....missing level-1==mandatory:\"$i\", so check your basic shell evironment."
	echo "....you might be probably operating within a restricted-shell."
	exit 1
    else
	echo "      $i - OK"
    fi
done
echo

#mandatory-2
MANDATORY="vncserver vncviewer"
echo "Check of level-2==mandatory - else (for now too!) no remote-desktops."
for i in $MANDATORY;do
    gwhich $i 2>&1 >/dev/null
    if [ $? -ne 0 ];then
	echo "Oh, ...."
	echo "....missing level-2==mandatory:\"$i\", so check your basic shell evironment."
	echo "....you do at least require \"vncserver\" for \"CONNECTIONFORWARDING\"."
	echo "....\"TightVNC\" or \"RealVNC\""

	echo "Anyhow, for now continue."
#	exit 1
    else
	echo "      $i - OK"
    fi
done
echo



#by convention: CURCALLDIR=$CURINSTTREE/bin
CURCALLDIR=`dirname $0`
CURINSTTREE=`dirname ${CURCALLDIR}`
CURINSTCONF=${CURINSTTREE}/conf/ctys

MANDATORY="${CURCALLDIR}/ctys-install1.sh"
for i in $MANDATORY;do
    gwhich $i 2>&1 >/dev/null
    if [ $? -ne 0 ];then
	echo "Oh, ...."
	echo "....missing \"$i\", so check your basic shell evironment."
	exit 1
    else
	echo "      $i - OK"
    fi
done


echo
echo "Setting distribution."
echo
CUROS=`${CURCALLDIR}/getCurOS.sh`;
echo "   CUROS      = ${CUROS}"

CUROSREL=`${CURCALLDIR}/getCurOSRel.sh`;
echo "   CUROSREL   = ${CUROSREL}"

CURDIST=`${CURCALLDIR}/getCurDistribution.sh`;
echo "   CURDIST    = ${CURDIST}"

CURREL=`${CURCALLDIR}/getCurRelease.sh`;
echo "   CURREL     = ${CURREL}"


echo
# ######################################################################
# echo
# echo "  - Switch \"systools.conf-${MYDIST}.sh\""
# echo
# ######################################################################
# echo
# echo "    Current OS-REL=${CUROS}-${CURREL}"
# echo "     =>${CURINSTCONF}/systools.conf-${MYDIST}.sh.${CURDIST}"
# echo
# if [ ! -f "${CURINSTCONF}/systools.conf-${MYDIST}.sh.${CURDIST}" ];then
#    echo "Missing: ${CURINSTCONF}/systools.conf-${MYDIST}.sh.${CURDIST}"
#    exit 1
# fi

# ###########
# #REMARK:
# #  Do this for a short migration time of legacy only, threafter
# #  use seamlessly the pre-typeID-postfix-approach.
# cp ${CURINSTCONF}/systools.conf.${CURDIST} ${CURINSTCONF}/systools.conf
# ###########


######################################################################
echo
echo "  - Preparation of script headers for bash-path."
echo
echo "    Check accesibility of ctys scripts by their standard shells."
echo
######################################################################
STDPATH="/bin/bash"
CURPATH=`gwhich bash`
if [ "${CURPATH}" == "${STDPATH}" ];then
    echo "      CURRENT(#!${CURPATH}) == ORIGINAL(#!${STDPATH})"
    echo 
    echo "      => No headers to be modified!"
    echo 
    echo "So, armed now."
    echo 
    echo "Second stage:"
    echo 
    echo "  Begin to install..."
    echo 
    echo "###################"
    bash ${CURCALLDIR}/ctys-install1.sh $*
    exit $?
fi


echo "  Adapt script-default shells "
echo 
echo "    from:    \"${STDPATH}\""
echo "    to:      \"${CURPATH}\""
echo 
echo "  For"
echo 
echo "    subtree: \"${CURINSTTREE}\""
echo 


{
    find ${CURINSTTREE} -type f -name '*[!~]'  -exec grep  -l '#!/bin/bash' {} \;
}|\
while read CX;do
    echo "       $CX"

    awk -v cp=${CURPATH} '
          BEGIN   {
             line=0;
          }
          line==0&&$1~/^#!\/bin\/bash/ {
             printf("#!%s\n",cp);
             next;
          }
          {
             print $0
             line++;
          }
    ' ${CX} > ${CX}.$$

    if [ $? == 0 ];then
	cp ${CX}.$$ ${CX}
        rm -f ${CX}.$$
    fi

done





echo 
echo "So, armed now."
echo 
echo "Second stage - #1"
echo 
echo "  Begin to actually install..."
echo 
echo "###################"
echo 

${CURCALLDIR}/ctys-install1.sh $*

echo
echo "*********************************************************************"
echo
echo "Logout now, and login again for init of the required environment."
echo
echo "*********************************************************************"
echo

