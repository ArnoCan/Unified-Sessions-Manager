#!/bin/bash

#FUNCBEG###############################################################
#NAME:
#  sritipIt.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Removes debug information for performance enhancements.
#  Foreseen for production only, thus targeted for developers.
#
#  Requires Linux!
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


_OLDPWD=${PWD}


case "$1" in
    #funcbodies
    AWKFILT0)
	shift;
	mv ${1} ${1}.tmp;
	awk -F'\n' '\
           BEGIN{m=0;x="";} \
           /{ *$/&&m==1{print x;m=0;} \
           /{ *$/&&m!=1{x=$0;m=1;next;} \
           /^ *}/&&m==1{m=0;print x" return; "$0;x="";next;} \
           m==1{m=0;print x;} \
          {print;} \
          ' ${1}.tmp > $1;
        #quickAnd..
	chmod 755 $1;
	rm -f ${1}.tmp;
	;;

    #else-fi
    AWKFILT1)
	shift;
	mv ${1} ${1}.tmp;
	awk -F'\n' '\
           BEGIN{m=0;x="";} \
           /else *$/&&m==1{print x;m=0;} \
           /else *$/&&m!=1{x=$0;m=1;next;} \
           /^ *fi/&&m==1{m=0;print $0;x="";next;} \
           m==1{m=0;print x;} \
          {print;} \
          ' ${1}.tmp > $1;
        #quickAnd..
	chmod 755 $1;
	rm -f ${1}.tmp;
	;;

    *)
	find . -type f -name '*.sh*' -print \
	    -exec sed -i '
              /^#!.*$/p
              s/^ *printDBG *..*//g
              /^ *$/d
              /^ *#.*$/d
              /^#.*/d
#             s/^[ \t]*//
              ' {} \; \
            -exec ${0} AWKFILT0 {} \; \
            -exec ${0} AWKFILT1 {} \; 
	;;
esac


exit



if [ "$1" == AWKFILT ];then
  shift;
  mv ${1} ${1}.tmp;
  awk -F'\n' '\
     BEGIN{m=0;x="";} \
     /{ *$/&&m==1{print x;m=0;} \
     /{ *$/&&m!=1{x=$0;m=1;next;} \
     /^ *}/&&m==1{m=0;print x" return; "$0;x="";next;} \
     m==1{m=0;print x;} \
     {print;} \
     ' ${1}.tmp > $1;
  #quickAnd..
  chmod 755 $1;
  rm -f ${1}.tmp;
else
  find . -type f -name '*.sh*' -print \
   -exec sed -i '
     /^#!.*$/p
     s/^ *printDBG *..*//g
     /^ *$/d
     /^ *#.*$/d
     /^#.*/d
#     s/^[ \t]*//
  ' {} \; \
   -exec sed -i 'N;{s/else *\nfi/fi/; }' {} \; \
   -exec ${0} AWKFILT {} \; 
fi

