
#FUNCBEG###############################################################
#NAME:
#  getCurDistribution.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Used during bootstrap of each call to get current distribution.
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
CURDIST=;
case $CUROS in
  Linux) 
        #Tested for:CentOS 5
        #Tested for:Scientific Linux 5
        #Tested for:Fedora 8
	if [ -z "$CURDIST" -a -f /etc/redhat-release ];then
	    CURDIST=`cat /etc/redhat-release|head -n 1|awk '{print $1;}'`
	fi

	#Tested for Oracle-Entreprise Linux 5
	if [ -n "$CURDIST" -a  "$CURDIST" == Red ];then
	    if [ -f /etc/redhat-release ];then
		CURDIST=`cat /etc/redhat-release|head -n 1|awk '{print $3""$4;}'`
	    else
		CURDIST=""
	    fi
	fi

        #Tested for:SuSE 9.3+10.3
	if [ -z "$CURDIST" -a -f /etc/SuSE-release ];then
	    CURDIST=`cat /etc/SuSE-release|head -n 1|awk '{print $1;}'`
	fi

        #Tested for:
        #debian 4.0r3,
        #Ubuntu 6.06,
        #Ubuntu 8.04,
	if [ -z "$CURDIST" -a -f /etc/debian_version ];then
	    if [ ! -f /etc/lsb-release ];then
		CURDIST="debian"
	    else
		CURDIST=`awk -F'=' '/DISTRIB_ID/{printf("%s",$2);}' /etc/lsb-release`
		if [ -z "$CURDIST" ];then
		    CURDIST="debian-variant"
		fi
	    fi
	fi

        #Might work for more ...
	if [ -z "$CURDIST" ];then
	    CURF=`ls -1 /etc/*-release 2>/dev/null|grep -v 'lsb-release'`
	    if [ $? -eq 0  ];then
		CURDIST=`cat ${CURF}|head -n 1|awk '{print $1;}'`
		case ${CURDIST} in
#		    Gentoo)
#			;;
		    *)
			CURDIST="Linux_generic"
			;;
		esac
	    fi
	fi
	;;
  FreeBSD|OpenBSD)
	CURDIST="${CUROS}"
	;;
  SunOS)
	CURDIST="${CUROS}"
	if [ -f /etc/release ];then
	    grep  'OpenSolaris' /etc/release >/dev/null 2>/dev/null
	    if [ $? -eq 0 ];then
		CURDIST=OpenSolaris
	    fi
	fi
	;;
  *)
	CURDIST="${CUROS}_generic"
        ;;
esac
[ -n "$_DBG_" ]&&echo "CURDIST=${CURDIST}" >&2


echo -n ${CURDIST}
