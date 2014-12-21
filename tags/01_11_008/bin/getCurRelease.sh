#FUNCBEG###############################################################
#NAME:
#  getCurRelease.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Used during bootstrap of each call to get current Release.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################

CALLDIR=`dirname $0`

CUROS=`${CALLDIR}/getCurOS.sh`
CURDIST=`${CALLDIR}/getCurDistribution.sh`
CURREL=;
case $CUROS in
    Linux) 
	if [ -z "$CURREL" -a -f /etc/redhat-release ];then
	    case "${CURDIST}" in
		Scientific) #Tested for:Scientific Linux 5
		    CURREL=`rpm -q sl-release|sed -n 's/^sl-release-\([0-9.]\+\)-\([0-9]\+\).*$/\1\.\2/p'`
		    ;;
		CentOS) #Tested for:CentOS 5
		    CURREL=`rpm -q centos-release|sed -n 's/^centos-release-\([0-9]\+\)-\([0-9]\+\).*$/\1\.\2/p'`
		    ;;
		Fedora) #Tested for:Fedora 8
		    CURREL=`rpm -q fedora-release|sed -n 's/^fedora-release-\([0-9]\+\)-\([0-9]\+\).*$/\1\.\2/p'`
		    ;;
		EnterpriseLinux) #Tested for:Oracle Enterprise Linux 5.4
		    CURREL=`rpm -q enterprise-release|sed -n 's/^enterprise-release-\([0-9]\+\)-\([0-9.]\+\).*$/\1\.\2/p'`
		    ;;
		*) 
		    CURREL=`cat /etc/redhat-release|head -n 1|awk '{print $3;}'`
		    ;;
	    esac
	fi


        #Tested for:SuSE 9.3+10.3
	if [ -z "$CURREL" -a -f /etc/SuSE-release ];then
	    CURREL=`cat /etc/SuSE-release|awk -F'=' '/VERSION/{print $2;}'`
	fi

        #Tested for:
        #debian 4.0r3,
        #debian 5.0.0   -> lack of minor-release-version '.0' -> returns '5.0'!!!
        #               => needs some effort e.g. for PATH-Usage!!!,
        #                  Refer to SL, which returns the complete Release-Number
        #
        #Ubuntu 6.06,
        #Ubuntu 8.04,
        #Ubuntu 9.10,
	if [ -z "$CURREL" -a -f /etc/debian_version ];then
	    if [ ! -f /etc/lsb-release ];then
		CURREL="`cat /etc/debian_version`"
                CURREL=${CURREL// /}
	    else
		CURREL=`awk -F'=' '/DISTRIB_RELEASE/{printf("%s",$2);}' /etc/lsb-release`
		if [ -z "$CURREL" ];then
		    CURREL="x.x"
		fi
	    fi
	fi

        #Might work for more ...
	if [ -z "$CURREL" ];then
	    CURF=`ls -1 /etc/*-release 2>/dev/null|grep -v 'lsb-release'`
	    if [ $? -eq 0  ];then
		CURREL=`cat ${CURF}|head -n 1|awk '{printf("%s",$3);}'`
            else
		CURREL="Linux"
            fi
	fi
	;;
    FreeBSD|OpenBSD)
	CURREL="`uname -r`"
	;;
    SunOS)
	case "$CURDIST" in
	    OpenSolaris)
		if [ -f /etc/release ];then
		    _x=$(gsed -n  's/OpenSolaris  *\([0-9.]\+\)  *.*/\1/p' /etc/release)
		    echo -n ${_x// /}
		else
		    echo -n UNKNOWN
		fi
		;;
	    *)
		CURREL="`uname -r`"
		;;
	esac

	;;
  *)
	CURREL="generic"
        ;;
esac
[ -n "$_DBG_" ]&&echo "CURREL=${CURREL}" >&2



echo -n ${CURREL}