#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_002
#
########################################################################
#
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


_myLIBNAME_help="${BASH_SOURCE}"
_myLIBVERS_help="01.11.002"
libManInfoAdd "${_myLIBNAME_help}" "${_myLIBVERS_help}"

export _myLIBBASE_help="`dirname ${_myLIBNAME_help}`"



#FUNCBEG###############################################################
#NAME:
#  functionHeaders
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Internal development support.
#
#  Well, for Emacs usage primarily, so no backups of type "*~" shown.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <format>
#      sortFunctions0
#      sortFunctions1
#      sortFunctions2
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function functionHeaders () {
    local x=
    local arg=$2

    function fetchFileList () {
        if [ -n "$arg" ];then 
	    x=${arg#*@}
	    if [ -n "$x" -a "$x" != "${arg}" ];then 
                local _ia=;
                local _iax=;
                for _ia in ${x//@/ };do
		    _iax="$_iax "`find ${MYINSTALLPATH} -type f  |grep "$_ia"`;
                done
                x=$_iax
            else
                x=;
	    fi
	fi
        arg=${arg%%@*};
        if [ -z "$x" ];then x=`find ${MYINSTALLPATH} -type f -name '*[!~]' -print`; fi
    }


    case $1 in
	sortFunctions0) 
	    fetchFileList

            for i in $x;do
                cat $i|\
                    awk -v fn=$i '
                       BEGIN{n=0;line=0}
                       {line++;}
                       $1~/^#NAME:/{n=1;getline;line++;}
                       n==1{
                         n=0;
                         printf("%-35s",$2);
                         printf(":%04d:%-50s\n",line,fn);
                       }
                    ';
            done|if [ -n "$arg" ];then grep $arg;else sort;fi
            ;;
	sortFunctions1) 
	    fetchFileList

            for i in $x;do
                L=50;
                cat $i|sed -n '/^#FUNCBEG#*$/,/^#FUNCEND#*$/!d;p'|\
                    awk -v fn=$i '
                       BEGIN{n=0;line=0}
                       {line++;}
                       $1~/^#NAME:/{
                         printf("...%-'$((L+5))'s:%04d:",substr(fn,length(fn)-'$L','$L'+1),line); n=1;getline;
                       }
                       n==1{print $2;n=0}
                    ';
            done|if [ -n "$arg" ];then grep $arg;else sort;fi
            ;;
	sortFunctions2) 
            for i in `find ${MYINSTALLPATH} -type f -print`;do
                cat $i|sed -n '/^#FUNCBEG#*$/,/^#FUNCEND#*$/!d;p'|\
                    awk -v fn=$i '
                       BEGIN{n=0;b=0;buffer[b]="";}
                       $1~/^#FUNCBEG#/&&n==0{
                         n=1;
                         printf("**************************************************************\n");
                         printf("*FILE:%s\n",fn);
                         printf("**************************************************************\n");
                       }
                       {
                         print $0;
                       }
                    ';
            done
            ;;
	sortFunctions3) 
	    fetchFileList

            for i in $x;do
                cat $i|sed -n '/^#FUNCBEG#*$/,/^#FUNCEND#*$/!d;p'|\
                    awk -v fn=$i -v fu=$arg -f ${_myLIBBASE_help}/sortFunctions3.awk;
            done
            ;;
	*)
            ;;
    esac

}

#FUNCBEG###############################################################
#NAME:
#  printHelpEx
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $@: list of help items.
#      Special keywords suppoerted are:
#
#        all
#          Complete user-interface help, no functions.
#
#        
#        funcList[=<any-function>]
#          List of functionnames, sorted by functionnames.
#          if given <any-function> only.
#
#        funcListMod[=<any-function>]
#          List of functionnames, sorted by filenames.
#          if given <any-function> only.
#
#        funcHead[=<any-function>]
#          List of functionheaders, sorted by filenames.
#          if given <any-function> only.
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function printHelpEx () {
  local _lst=${@//[, ]/ }
  printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "_lst=${_lst}"

  function getDocPath (){
      if [ "${2#/}" == "${2}" ];then
	  local _xdir=${1}/${2}
	  _xdir=${_xdir//\/\//\/}
	  _xdir=${_xdir%/*}
	  echo $_xdir
      else
	  echo ${2%/*}
      fi
  }


  for i in $_lst;do
    KEY=`echo ${1}|tr '[:lower:]' '[:upper:]'`
    case "$KEY" in
     PRINT)       print4Printer;;
     FUNCLIST) 
                  functionHeaders  sortFunctions0;;
     FUNCLIST=*) 
                  functionHeaders  sortFunctions0 ${i#*=};;
     FUNCLISTMOD) 
                  functionHeaders  sortFunctions1;;
     FUNCLISTMOD=*) 
                  functionHeaders  sortFunctions1 ${i#*=};;
     FUNCHEAD) 
                  functionHeaders  sortFunctions2;;
     FUNCHEAD=*) 
                  functionHeaders  sortFunctions3 ${i#*=};;

     HELP)        printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:MAN-Help" "${CTYS_MANVIEWER} -M \"${MYMANPATH}:${MANPATH}\" 7 ctys-help-on"
                  ${CTYS_MANVIEWER} -M "${MYMANPATH}:${MANPATH}" 7 ctys-help-on
                  ;;

     MAN)         printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:MAN-Help" "${CTYS_MANVIEWER} -M \"${MYMANPATH}:${MANPATH}\" ${MYCALLNAME}"
                  ${CTYS_MANVIEWER} -M "${MYMANPATH}:${MANPATH}" ${MYCALLNAME}
                  ;;

     MAN=[1-9])   
	          printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:MAN-Help" "${CTYS_MANVIEWER} -M \"${MYMANPATH}:${MANPATH}\" ${i#MAN=} ${MYCALLNAME}"
         	 ${CTYS_MANVIEWER} -M "${MYMANPATH}:${MANPATH}" ${i#MAN=} ${MYCALLNAME}
                 ;;

     MAN=*)
                  if [ -z "${CTYS_MANVIEWER}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "No supported MAN viewer configured."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Set variable: CTYS_MANVIEWER."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "DEFAULT=man"
	              gotoHell $ABORT
		  fi

		  local pch=0;
		  for ipa in ${MYMANPATH//:/ } ${MANPATH//:/ };do
                      if [ -e "${ipa}" ];then
			  let pch++;
		      fi
		  done
                  if [ $pch -eq 0 ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Missing man root: ${MYMANPATH}"
	              gotoHell $ABORT
		  fi
		  local _x=
		  ${CTYS_MANVIEWER} ${i#*=} 2>&1>/dev/null
		  if [ $? -ne 0 ];then
                      _x=$(find ${MYMANPATH} ${MANPATH//:/ } -type f -name "*${i#*=}*.[1-9]" -print|awk '{if(x!=1){print;}x=1;}')
                      if [ -z "${_x}" ];then
			  ABORT=1;
			  printERR $LINENO $BASH_SOURCE ${ABORT} "Missing requested manpage: $i"
			  gotoHell $ABORT
		      fi
		      _x=${_x%.[1-9]};
		      _x=${_x##*/};

		      if [ -z "${_x}" ];then
  			  printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		      else
			  printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:MAN-Help" "${CTYS_MANVIEWER} -M \"${MYMANPATH}:${MANPATH}\" \"${_x}\""
			  ${CTYS_MANVIEWER} -M "${MYMANPATH}:${MANPATH}" "${_x}"
		      fi
		  else
		      if [ -z "${_x}" ];then
  			  printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		      else
			  printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:MAN-Help" "${CTYS_MANVIEWER} \"${_x}\""
			  ${CTYS_MANVIEWER} "${_x}"
		      fi
		  fi
                  ;;

	  HTML)
                  if [ -z "${CTYS_HTMLVIEWER}" ];then
                        ABORT=1;
	                printERR $LINENO $BASH_SOURCE ${ABORT} "No supported HTML viewer configured."
	                printERR $LINENO $BASH_SOURCE ${ABORT} "Set variable: CTYS_HTMLVIEWER."
                        printERR $LINENO $BASH_SOURCE ${ABORT} "DEFAULT=(firefox|konqueror)"
	                gotoHell $ABORT
		  fi
		  local _x="${MYDOCPATH}/html/man1/${MYCALLNAME}.html"
                  if [ ! -f "${_x}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Missing document: ${_x}"
	              gotoHell $ABORT
		  fi
		  if [ -z "${_x}" ];then
  		      printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		  else
		      printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:HTML-Help" "${CTYS_HTMLVIEWER} ${_x}&"
	              ${CTYS_HTMLVIEWER} ${_x}&
  	          fi
                  ;;

     HTML=[123456789])
                  if [ -z "${CTYS_HTMLVIEWER}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "No supported HTML viewer configured."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Set variable: CTYS_HTMLVIEWER."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "DEFAULT=(firefox|konqueror)"
	              gotoHell $ABORT
		  fi
                  if [ ! -f "${MYDOCPATH}/html/man${i#*=}/${MYCALLNAME}.html" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Missing document: html/man${i#MAN=}/${MYCALLNAME}.html"
	              gotoHell $ABORT
		  fi
		  if [ -z "${_x}" ];then
  		      printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		  else
		      printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:HTML-Help" "${CTYS_HTMLVIEWER} ${MYDOCPATH}/html/man${i#*=}/${MYCALLNAME}.html&"
                      ${CTYS_HTMLVIEWER} ${MYDOCPATH}/html/man${i#*=}/${MYCALLNAME}.html&
		  fi
                  ;;

     HTML=*)
                  if [ -z "${CTYS_HTMLVIEWER}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "No supported HTML viewer configured."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Set variable: CTYS_HTMLVIEWER."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "DEFAULT=(firefox|konqueror)"
	              gotoHell $ABORT
		  fi

		  local pch=0;
		  for ipa in ${MYDOCSEARCH//:/ };do
                      if [ -e "${ipa}" ];then
			  let pch++;
		      fi
		  done
                  if [ $pch -eq 0 ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Missing html root: ${MYDOCSEARCH}"
	              gotoHell $ABORT
		  fi

		  local _x=
		  local _sp=

		  for _sp in ${MYDOCSEARCH//:/ };do
  	              _x=${i#*=};
		      local _xdir=$(getDocPath ${_sp} $_x)
  	              _x=${_x##*/};_x=${_x%.[^/]*}
		      _x0=$_x;
                      _x=$(find ${_xdir} -type f \( -name "${_x}.html" -o -name "${_x}.png" \) -print|awk '{if(x!=1){print;}x=1;}')
		      if [ -z "$_x" ];then
			  _x=$_x0
			  _x=$(find ${_xdir} -type f -name '*'"${_x}"'.html' -o -name '*'"${_x}"'.png' -print|awk '{if(x!=1){print;}x=1;}')
			  if [ -z "${_x}" ];then
			      _x=$_x0
			      _x=$(find ${_xdir} -type f -name '*'"${_x}"'*.html' -o -name '*'"${_x}"'.png' -print|awk '{if(x!=1){print;}x=1;}')
			  fi
		      fi
		      [ -n "${_x}" ]&&break;
		  done
		  if [ -z "${_x}" ];then
		      ABORT=1;
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing requested document: $i"
		      gotoHell $ABORT
		  fi
		  if [ -z "${_x}" ];then
  		      printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		  else
		      printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:HTML-Help" "${CTYS_HTMLVIEWER} \"${_x}\"&"
                      ${CTYS_HTMLVIEWER} "${_x}"&
		  fi
                  ;;

     PDF)         if [ -z "${CTYS_PDFVIEWER}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "No supported PDF viewer configured."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Set variable: CTYS_PDFVIEWER."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "DEFAULT=(kpdf|gpdf)"
	              gotoHell $ABORT
		  fi
		  local _x="${MYDOCPATH}/pdf/man1/${MYCALLNAME}.pdf"
                  if [ ! -f "${_x}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Missing document: pdf/man1/${MYCALLNAME}.pdf"
	              gotoHell $ABORT
		  fi
		  if [ -z "${_x}" ];then
  		      printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		  else
		      printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:PDF-Help" "${CTYS_PDFVIEWER} ${_x}&"
	              ${CTYS_PDFVIEWER} ${_x}&
		  fi
                  ;;

     PDF=[123456789])
                  if [ -z "${CTYS_PDFVIEWER}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "No supported PDF viewer configured."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Set variable: CTYS_PDFVIEWER."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "DEFAULT=(kpdf|gpdf)"
	              gotoHell $ABORT
		  fi
                  if [ ! -f "${MYDOCPATH}/pdf/man${i#*=}/${MYCALLNAME}.pdf" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Missing document: pdf/man1/${MYCALLNAME}.pdf"
	              gotoHell $ABORT
		  fi
		  if [ -z "${_x}" ];then
  		      printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		  else
		      printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:PDF-Help" "${CTYS_PDFVIEWER} ${MYDOCPATH}/pdf/man${i#*=}/${MYCALLNAME}.pdf&"
                      ${CTYS_PDFVIEWER} ${MYDOCPATH}/pdf/man${i#*=}/${MYCALLNAME}.pdf&
		  fi
                  ;;

     PDF=*)
                  if [ -z "${CTYS_PDFVIEWER}" ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "No supported PDF viewer configured."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Set variable: CTYS_PDFVIEWER."
	              printERR $LINENO $BASH_SOURCE ${ABORT} "DEFAULT=(kpdf|gpdf)"
	              gotoHell $ABORT
		  fi

		  local pch=0;
		  for ipa in ${MYDOCSEARCH//:/ };do
                      if [ -e "${ipa}" ];then
			  let pch++;
		      fi
		  done
                  if [ $pch -eq 0 ];then
                      ABORT=1;
	              printERR $LINENO $BASH_SOURCE ${ABORT} "Missing html root: ${MYDOCSEARCH}"
	              gotoHell $ABORT
		  fi

		  local _x=
		  local _sp=
		  for _sp in ${MYDOCSEARCH//:/ };do
  	              _x=${i#*=};
		      local _xdir=$(getDocPath ${_sp} $_x)
  	              _x=${_x##*/};_x=${_x%.[^/]*}
		      _x0=$_x;
                      _x=$(find ${_xdir} -type f -name "${_x}.pdf" -print|awk 'BEGIN{x=0;}{if(x!=1){print;}x=1;}')
		      if [ -z "$_x" ];then
			  _x=$_x0
			  _x=$(find ${_xdir} -type f -name '*'"${_x}"'.pdf' -print|awk 'BEGIN{x=0;}{if(x!=1){print;}x=1;}')
			  if [ -z "${_x}" ];then
			      _x=$_x0
			      _x=$(find ${_xdir} -type f -name '*'"${_x}"'*.pdf' -print|awk 'BEGIN{x=0;}{if(x!=1){print;}x=1;}')
			  fi
		      fi
		      [ -n "${_x}" ]&&break;
		  done
		  if [ -z "${_x}" ];then
  		      printWNG 0 $LINENO $BASH_SOURCE 0 "The requested file is not available"
		  else
		      printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:PDF-Help" "${CTYS_PDFVIEWER} \"${_x}\"&"
                      ${CTYS_PDFVIEWER} "${_x}"&
		  fi
                  ;;

     PATH)        echo "MYDOCPATH = ${MYDOCPATH}"
                  echo "MANPATH   = ${MANPATH}"
                  ;;

     LIST)        echo
		  echo "List of available CTYS-Help files in"
                  echo
		  echo "-+>MYDOCSEARCH = ${MYDOCSEARCH}"
		  echo " |"
		  for _sp in ${MYDOCSEARCH//:/ };do
		      echo " |"
		      echo " +->MYDOCSEARCH=${_sp}"
		  echo " |"
                      find ${_sp} -type f -print|sed 's@'"${MYDOCBASE}"'/*\(.*$\)@\1@'|sed 's@.*@ |   &@'
		  echo " |"
		  done
		  echo
		  echo "For additional man pages refer to:"
		  echo
                  echo "->MANPATH   = ${MANPATH}"
		  echo
                  ;;

     LISTALL)     echo
		  echo "List of available Help files in"
                  echo
		  echo "-+->MYDOCSEARCH = ${MYDOCSEARCH}"
		  echo " +->MYDOCPATH   = ${MYDOCPATH}"
                  echo " +->MANPATH     = ${MANPATH}"
		  echo " |"
		  for _sp in ${MYDOCSEARCH//:/ };do
		      echo " |"
		      echo " +->MYDOCSEARCH=${_sp}"
		      echo " |"
                      find ${_sp} -type f -print|sed 's@'"${MYDOCBASE}"'/*\(.*$\)@\1@'|sed 's@.*@ |   &@'
		      echo " |"
		  done
		  echo " |"
                  echo " +->MANPATH   = ${MANPATH}"
		  echo " |"
                  find ${MANPATH//:/ } -type f -print|sed 's@'"${MYDOCBASE}"'/*\(.*$\)@\1@'|sed 's@.*@ |   &@'
                  ;;

     ALL|'*'|"")  #this is literally "all=='*'==''"
                  _printHelpEx|sed 's///';;

     *)
		  printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:MAN" "${CTYS_MANVIEWER} ${i:-$MYCALLNAME}"
                  ${CTYS_MANVIEWER} ${i:-$MYCALLNAME}

                  if [ $? -ne 0 ];then
                     echo
                     echo "This call variant transparently executes \"man ${i}\""
                     echo "therefore a valid MAN entry is required."
                     echo "Try \"ctys -H list\" for available help."
                     echo 
                     echo "For implicit search and nameexpansion use \"ctys -H man=${i}\""
                     echo 
                  fi
                  ;;
     esac
  done
}



#FUNCBEG###############################################################
#NAME:
#  showToolHelp
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Displays help for a specific tool only. Therefore the following naming
#  convention applies for the filename(shell-regexpr):
#
#    ${MYHELPPATH}/${MYCALLNAME}.txt
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
function showToolHelp () {
    local _myhlp=`echo ${MYHELPPATH}/${MYCALLNAME}-help.txt`
    if [ -n "${_myhlp}" -a -f "${_myhlp}" ];then
	cat ${_myhlp}
    else
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing online help-file:\"${_myhlp}\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "Refer to the manual for required information"
	gotoHell $ABORT
    fi
}

#FUNCBEG###############################################################
#NAME:
#  printVersion
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Displays basic version infomation for all tools.
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
function printVersion () {
    if [ -n "$C_TERSE" ];then
	echo -n ${VERSION}
	return
    fi


cat <<EOF
--------------------------------------------------------------------------

UnifiedSessionsManager Copyright (C) 2007, 2008, 2010 Arno-Can Uestuensoez

This program comes with ABSOLUTELY NO WARRANTY; for details  
refer to provided documentation.
This is free software, and you are welcome to redistribute it
under certain conditions. For details refer to "GNU General Public 
License - version 3" <http://www.gnu.org/licenses/>.

--------------------------------------------------------------------------
PROJECT          = ${FULLNAME} 
--------------------------------------------------------------------------
CALLFULLNAME     = ${CALLFULLNAME}
CALLSHORTCUT     = ${MYCALLNAME}

AUTHOR           = ${AUTHOR}
MAINTAINER       = ${MAINTAINER}
VERSION          = ${VERSION}
DATE             = ${DATE}

LOC              = ${LOC} CodeLines
LOC-BARE         = ${LOCNET} BareCodeLines (no comments and empty lines)
LOD              = ${LOD} DocLines, include LaTeX-sources

EOF
    cat ${MYCONFPATH}/versinfo.txt
cat <<EOF
--------------------------------------------------------------------------
COPYRIGHT        = ${AUTHOR}
LICENCE          = GPL3
--------------------------------------------------------------------------
EXECUTING HOST   = ${MYHOST}
--------------------------------------------------------------------------
EOF
}

