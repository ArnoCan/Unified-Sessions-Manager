#FUNCBEG###############################################################
#NAME:
#  getCurGID.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Returns the group-ID.
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

MYOS=`dirname $0`
MYOS=`${MYOS}/getCurOS.sh`

case ${MYOS} in
    SunOS)
	/usr/xpg4/bin/id -g -n
	;;
    *)
	id -g -n
	;;
esac

