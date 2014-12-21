#FUNCBEG###############################################################
#NAME:
#  getCurCTYSVariant.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Prints the variant of CTYS.
#  Current variants are:
#
#    BASE
#    DOC
#
#    DEVELOP
#     This is just temporary for development branch, indicating
#     that parts might not be in place and/or operabel as expected.
#
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

CTYS_VARIANT=BASE

echo -n "${CTYS_VARIANT}"
