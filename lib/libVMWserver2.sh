#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_005
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


_VNC_CLIENT_MODE=;


export VMW_INVENTORY_DEFAULT=${VMW_INVENTORY_DEFAULT:-/etc/vmware/hostd/vmInventory.xml}
export VMW_DATASTORE_DEFAULT=${VMW_DATASTORE_DEFAULT:-/etc/vmware/hostd/datastores.xml}

export VMW_INVENTORY=${VMW_INVENTORY:-$VMW_INVENTORY_DEFAULT}
export VMW_DATASTORE=${VMW_DATASTORE:-$VMW_DATASTORE_DEFAULT}

#
#
#The client detection for Server-2+ is not really unambiguous!!!
#
#


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListVmInventory
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListVmInventory () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    cat ${VMW_INVENTORY}|\
awk '
  BEGIN{
    e=0;
    cur0="";
    cur1="";
  }
  /<ConfigEntry/{
    e=1;
    entry=$0
    gsub("^.*id=\"","",entry);
    gsub("\"","",entry);
    gsub(">","",entry);
  }
  e==1&&/objID/{
    cur0=$0
    gsub("^.*<objID>","",cur0);
    gsub("</objID>","",cur0);
  }
  e==1&&/vmxCfgPath/{
    cur1=$0
    gsub("^.*<vmxCfgPath>","",cur1);
    gsub("</vmxCfgPath>","",cur1);
  }
  /<\/ConfigEntry/{
    e=0;
    print entry":"cur0":"cur1    
  }'
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}

#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2FetchVMWPath4ObjID
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2FetchVMWPath4ObjID () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myOID=$1;
    ctysVMWS2ListVmInventory | awk -F':' -v oid="$_myOID" '$2==oid{print $3}'
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}

#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2FetchVMWObjID4Path
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2FetchVMWObjID4Path () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$*>"
    local _myPath=$1;
    ctysVMWS2ListVmInventory | awk -F':' -v p="$_myPath" '$3==p{print $2}'
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$*>"
}



#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2FetchRemoteVMWPath4ObjID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets VMX-filepath from remote inventory data.
#  Of course some performance tuning could be done....
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <ObjID>
#  $*: <hostlist>
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <pathname-vmx>
#      The path of the VMX-file for the server.
#
#FUNCEND###############################################################
function ctysVMWS2FetchRemoteVMWPath4ObjID () {
    if [ -z "${1}" ];then
	return
    fi
    local _myOID=$1;shift
    local _myHosts=$*
    if [ -z "${_myHosts}" ];then
	return
    fi

    if [ -n "${MYCALLNAME}" ];then
	local _i="";
	for _i in ${_myHosts};do
	    local _7321call="${_MYCALLPATHNAME} -t CLI -a \"CREATE=l:VMWCLI$$,s:ctysVMWS2ListVmInventory\" -z NOPTY ${C_DARGS} ${_i}'(-T VMW ${C_DARGS} ${R_OPTS} )'"
	    local _x=$(eval ${_7321call})
	    local _y=$(echo "$_x"|awk -F':' -v oid=$_myOID '$2==oid{print $3}')
	    echo "$_y"
	done
    else
   	echo "ERROR:Missing MYCALLPATHNAME=${MYCALLPATHNAME}">&2
        exit 1
    fi
}



#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListDatastores
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListDatastores () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:VMW_DATASTORE=<$VMW_DATASTORE>"
    cat ${VMW_DATASTORE}|\
sed -n '/<LocalDatastores>/,/<\/LocalDatastores>/p'|\
awk -v d=${DBG} -v dx=${D_MAINT} '
function ptrace(inp){
    if(d>dx){
        print line ":" inp | "cat 1>&2"
    }
}
  BEGIN{
    e=0;
    cur0="";
    cur1="";
  }

{
    ptrace("entry="$0);
}
  /<e id=/{
    e=1;
    entry=$0
    gsub("^.*e id=\"","",entry);
    gsub("\"","",entry);
    gsub(">","",entry);
    ptrace("entry="entry);
  }
  e==1&&/<id>/{
    cur0=$0
    ptrace("cur0="cur0);
    gsub("^.*<id>","",cur0);
    gsub("</id>.*","",cur0);
    ptrace("cur0="cur0);
  }
  e==1&&/<name>/{
    cur1=$0
    ptrace("cur1="$0);
    gsub("^.*<name>","",cur1);
    gsub("</name>","",cur1);
    ptrace("cur1="cur1);
  }
  e==1&&/<path>/{
    cur2=$0
    ptrace("cur2="$0);
    gsub("^.*<path>","",cur2);
    gsub("</path>","",cur2);
    ptrace("cur2="cur2);
  }
  /<\/e>/{
    e=0;
    rec=entry":"cur0":"cur1":"cur2;
    ptrace("rec="rec);
    print rec 
  }'
  printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2FetchDatastore
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2FetchDatastore () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myPath=$1;
    ctysVMWS2ListDatastores | awk -F':' -v mp="$_myPath" 'mp~$4{print $3}'
}



#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ConvertToDatastore
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ConvertToDatastore () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myPath=$1;
    ctysVMWS2ListDatastores | awk -F':' -v mp="$_myPath" 'mp~$4{x=mp;gsub($4"/","",x);print "["$3"] "x; }'
}



#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListLocalServers
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListLocalServers () {
    listProcesses  "" USRLST ROOT|\
    sed -n 's/\(.*\)  *\/[^ ]*vmware-vmx *-# product=2;name=VMware Server[^@]*@  *[^ ]*  *\([^ ]*\)/\1 \2/p'
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListServerPaths
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListServerPaths () {
    ctysVMWS2ListLocalServers|awk '{print $NF}'
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListClients
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListClients () {
    listProcesses|\
    sed -n 's/^\(.*\) [^ ]*vmware-remotemks .*vm=_\([0-9][0-9]*\).*/\1 \2/p'
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListLocalClients
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListLocalClients () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    listProcesses|\
    sed -n '/-I/!d;s/^\(.*\) [^ ]*vmware-remotemks .*vm=_\([0-9][0-9]*\).*/\1 \2/p'
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListRemoteClients
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListRemoteClients () {
    listProcesses|\
    sed -n '/-I/d;s/^\(.*\) [^ ]*vmware-remotemks .*vm=_\([0-9][0-9]*\).*/\1 \2/p'
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListRemoteClientsEx
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListRemoteClientsEx () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    export -f ctysVMWS2FetchRemoteVMWPath4ObjID
    export -f ctysVMWS2ListVmInventory
    export -f ctysVMWS2ListRelays
    export -f printDBG
    export -f printERR
    export -f doDebug
    export -f gotoHell
    export -f listProcesses
    export MYCALLPATHNAME
    export MYCALLNAME
    export MYCALLPATH
    export MYLIBEXECPATHNAME
    export _MYCALLPATHNAME
    export C_DARGS
    export R_OPTS

    local _hostLst=$(ctysVMWS2ListRelays|awk -F':' '$1!~/127.0.0/&&$1!~/localhost/{printf("%s ", $1);}')
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "_hostLst=<$_hostLst>"

 
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "C_RESOLVER=<$C_RESOLVER>"
    case ${C_RESOLVER} in
        0|OFF)
	    ;;
        1|STAR)
	   ctysVMWS2ListRemoteClients|sed 's/\([0-9][0-9]*\)$/|&/'|\
           awk -F'|' -v hL="${_hostLst}" -v d="1" '
              function t(i){if(!d){print i|"cat 1>&2"}}
              {
                x=$1;
#performance issue:asks ALL!!!
                t("hL="hL);
                hn=split(hL,HL);
                for(i=1;i<=hn;i++){
                  t("HL["i"]="i);
                  x=x""$2"@"HL[i];
                  t("x="x);
                  print x;
                }
              }'
	    ;;
	2|CHAIN)
	   ctysVMWS2ListRemoteClients|sed 's/\([0-9][0-9]*\)$/|&/'|\
	    awk -F'|' -v hL="${_hostLst}"  -v d="1" '
              function t(i){print i|"cat 1>&2"}
              {
                x=$1;
#performance issue:asks ALL!!!
                t("hL="hL);
                hn=split(hL,HL);
                for(i=1;i<=hn;i++){
                  t("HL["i"]="i);
                  call="ctysVMWS2FetchRemoteVMWPath4ObjID "$2" "HL[i];
                  call|getline x1;
                  if(x1!~/^ *$/){
                    x=x""x1;
                    print x;
                    t("x="x);
                  }
                }
              }'
	    ;;
	*)
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected session RESOLVER type:C_RESOLVER=${C_RESOLVER}"
	    gotoHell ${ABORT}
	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListLocalClientsEx
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListLocalClientsEx () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    export -f ctysVMWS2FetchVMWPath4ObjID
    export -f ctysVMWS2ListVmInventory
    export -f printDBG
    export -f listProcesses
    ctysVMWS2ListLocalClients|sed 's/\([0-9][0-9]*\)$/@&/'|awk -F'@' '
    {
      x=$1;
      call="ctysVMWS2FetchVMWPath4ObjID "$2;
      call|getline x1;
      x=x""x1;
      print x;
    }'
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}


#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2ListRelays
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2ListRelays () {
    listProcesses|sed -n '/sed/d;s/^.*vmware-vmrc .*-h *\([^ ]*\) .* -M \([^ ]*\).*/\1:\2/p'
}



#FUNCBEG###############################################################
#NAME:
#  ctysVMWS2CheckLocalClient
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
#  VALUES:
#
#FUNCEND###############################################################
function ctysVMWS2CheckLocalClient () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myOID=$1
    local _4dbg=$(ctysVMWS2ListRelays|grep $_myOID)
    _4dbg=$(echo $_4dbg|grep '127.0.0')
    [ -n "$_4dbg" ]
}

