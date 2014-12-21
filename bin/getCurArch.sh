#FUNCBEG###############################################################
#NAME:
#  getCurArch.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Used during bootstrap of each call to get current architecture.
#  Might change and become some cumbersome for versions grouping
#  etc. over lifecycle, so wrap it.
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

#avoid errors on OpenSolaris
xarch=$(uname -m|tr '\n' ' ')
echo -n -e ${xarch// /}
