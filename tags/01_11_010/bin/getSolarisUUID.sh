#FUNCBEG###############################################################
#NAME:
#  getSolarisUUID.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Wrapper for Solaris UUID.
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


/usr/bin/prodreg browse|awk '/Solaris 10 System Software/{print $3;}'