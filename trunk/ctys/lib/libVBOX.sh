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


export VBOX_INVENTORY_DEFAULT=${VBOX_INVENTORY_DEFAULT:-/etc/vmware/hostd/vmInventory.xml}
export VBOX_DATASTORE_DEFAULT=${VBOX_DATASTORE_DEFAULT:-/etc/vmware/hostd/datastores.xml}

export VBOX_INVENTORY=${VBOX_INVENTORY:-$VBOX_INVENTORY_DEFAULT}
export VBOX_DATASTORE=${VBOX_DATASTORE:-$VBOX_DATASTORE_DEFAULT}

#
#
#The client detection for Server-2+ is not really unambiguous!!!
#
#


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListVmInventory
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
function ctysVBOXListVmInventory () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    cat ${VBOX_INVENTORY}|\
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
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}

#FUNCBEG###############################################################
#NAME:
#  ctysVBOXFetchVBOXPath4ObjID
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
function ctysVBOXFetchVBOXPath4ObjID () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myOID=$1;
    ctysVBOXListVmInventory | awk -F':' -v oid="$_myOID" '$2==oid{print $3}'
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}

#FUNCBEG###############################################################
#NAME:
#  ctysVBOXFetchVBOXObjID4Path
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
function ctysVBOXFetchVBOXObjID4Path () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$*>"
    local _myPath=$1;
    ctysVBOXListVmInventory | awk -F':' -v p="$_myPath" '$3==p{print $2}'
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$*>"
}



#FUNCBEG###############################################################
#NAME:
#  ctysVBOXFetchRemoteVBOXPath4ObjID
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
function ctysVBOXFetchRemoteVBOXPath4ObjID () {
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
	    local _7321call="${_MYCALLPATHNAME} -t CLI -a \"CREATE=l:VBOXCLI$$,s:ctysVBOXListVmInventory\" -z NOPTY ${C_DARGS} ${_i}'(-T VBOX ${C_DARGS} ${R_OPTS} )'"
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
#  ctysVBOXListDatastores
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
function ctysVBOXListDatastores () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:VBOX_DATASTORE=<$VBOX_DATASTORE>"
    cat ${VBOX_DATASTORE}|\
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
  printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXFetchDatastore
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
function ctysVBOXFetchDatastore () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myPath=$1;
    ctysVBOXListDatastores | awk -F':' -v mp="$_myPath" 'mp~$4{print $3}'
}



#FUNCBEG###############################################################
#NAME:
#  ctysVBOXConvertToDatastore
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
function ctysVBOXConvertToDatastore () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myPath=$1;
    ctysVBOXListDatastores | awk -F':' -v mp="$_myPath" 'mp~$4{x=mp;gsub($4"/","",x);print "["$3"] "x; }'
}



#FUNCBEG###############################################################
#NAME:
#  fetchMAC
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
function fetchMAC  {
    local myID=$1
    $VBOXMGR showvminfo $myID |\
        sed -n '
           s/NIC .*MAC: *\([0-9ABCDEF]\+\).*/mac:\1;/p
           s/VRDP port: *\([0-9]\+\).*/vrdp:\1;/p
           s/VT-x *VPID: *\([ofn]\+\).*/accel:\1;/p
           s/UUID: *\([^ ]\+\).*/uuid:\1;/p
           s/Name: *\([^ ]\+\).*/label:\1;/p
           s@Config file: *\([^ ]\+\).*@id:\1;@p
        '|\
        awk 'BEGIN{x="";}{x=x""$0;}END{print x;}'
}
export -f fetchMAC
export VBOXMGR




#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListLocalServers
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
function ctysVBOXListLocalServers () {

#4TEST
local D=0
    listProcesses  "" USRLST ROOT|\
    sed -n '
        s/\(.*\)  *\/[^ ]*VirtualBox  *--comment  *\([^ ]*\) .*(-s|-startvm|--startvm)  *\([^ ]*\).*/\1 \2 \3/p
#        s/\(.*\)  *\/[^ ]*VBoxHeadless .*(-s|-startvm|--startvm)  *\([^ ]*\).*/\1 \2 xxx/p
        s/\(.*\)  *\/[^ ]*VBoxHeadless .*-startvm  *\([^ ]*\).*/\1 \2 xxx/p
    '|\
    awk -v d=$D '
     function ptrace(inp){
       if(!d){
         print line ":" inp | "cat 1>&2"
       }
     }
     BEGIN{x="";}
     {
       if($NF=="xxx"){
         call="fetchMAC "$(NF-1)" 2>/dev/null";
         a="";    
         call|getline a;
         close(call);

         ptrace("a="a);

         if($NF-1!~/[^0-9]/){
           if(a!~/^$/){
             x=a;        
             n=gsub(".*mac:","",x);
             if(n!=0){
               gsub(";.*","",x);
             }
           }

           if(x!~/^$/){
             z=gsub(":",":",x);
             if(z==0){
               new=substr(x,1,2);
               new=new":"substr(x,3,2);
               new=new":"substr(x,5,2);
               new=new":"substr(x,7,2);
               new=new":"substr(x,9,2);
               new=new":"substr(x,11,2);
               x=new
             }        
             ptrace("mac-new="x);
             zwi=$(NF-1)
             $(NF-1)=x
             $NF=zwi
           }else{
             zwi=$(NF-1)
             $(NF-1)="\"\""
             $NF=zwi
           }
         }else{
           if(a!~/^$/){
             x=a;        
             n=gsub(".*uuid:","",x);
             if(n!=0){
               gsub(";.*","",x);
             }
           }
           ptrace("uuid-new="x);
           if(x!~/^$/){
             $NF=x
           }else{
             $NF="\"\""
           }
         }
      }
      x=x""$0;
    }
    END{print x;}
    '

}



#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListServerPaths
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
function ctysVBOXListServerPaths () {
    ctysVBOXListLocalServers|awk '{print $NF}'
}


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListClients
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
function ctysVBOXListClients () {
    listProcesses|\
    sed -n 's/^\(.*\) [^ ]*vmware-remotemks .*vm=_\([0-9][0-9]*\).*/\1 \2/p'
}


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListLocalClients
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
function ctysVBOXListLocalClients () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    listProcesses|\
    sed -n '/-I/!d;s/^\(.*\) [^ ]*vmware-remotemks .*vm=_\([0-9][0-9]*\).*/\1 \2/p'
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListRemoteClients
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
function ctysVBOXListRemoteClients () {
    listProcesses|\
    sed -n '/-I/d;s/^\(.*\) [^ ]*vmware-remotemks .*vm=_\([0-9][0-9]*\).*/\1 \2/p'
}


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListRemoteClientsEx
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
function ctysVBOXListRemoteClientsEx () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    export -f ctysVBOXFetchRemoteVBOXPath4ObjID
    export -f ctysVBOXListVmInventory
    export -f ctysVBOXListRelays
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

    local _hostLst=$(ctysVBOXListRelays|awk -F':' '$1!~/127.0.0/&&$1!~/localhost/{printf("%s ", $1);}')
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_hostLst=<$_hostLst>"

 
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "C_RESOLVER=<$C_RESOLVER>"
    case ${C_RESOLVER} in
        0|OFF)
	    ;;
        1|STAR)
	   ctysVBOXListRemoteClients|sed 's/\([0-9][0-9]*\)$/|&/'|\
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
	   ctysVBOXListRemoteClients|sed 's/\([0-9][0-9]*\)$/|&/'|\
	    awk -F'|' -v hL="${_hostLst}"  -v d="1" '
              function t(i){print i|"cat 1>&2"}
              {
                x=$1;
#performance issue:asks ALL!!!
                t("hL="hL);
                hn=split(hL,HL);
                for(i=1;i<=hn;i++){
                  t("HL["i"]="i);
                  call="ctysVBOXFetchRemoteVBOXPath4ObjID "$2" "HL[i];
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
#  ctysVBOXListLocalClientsEx
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
function ctysVBOXListLocalClientsEx () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    export -f ctysVBOXFetchVBOXPath4ObjID
    export -f ctysVBOXListVmInventory
    export -f printDBG
    export -f listProcesses
    ctysVBOXListLocalClients|sed 's/\([0-9][0-9]*\)$/@&/'|awk -F'@' '
    {
      x=$1;
      call="ctysVBOXFetchVBOXPath4ObjID "$2;
      call|getline x1;
      x=x""x1;
      print x;
    }'
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
}


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListRelays
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
function ctysVBOXListRelays () {
    listProcesses|sed -n '/sed/d;s/^.*vmware-vmrc .*-h *\([^ ]*\) .* -M \([^ ]*\).*/\1:\2/p'
}



#FUNCBEG###############################################################
#NAME:
#  ctysVBOXCheckLocalClient
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
function ctysVBOXCheckLocalClient () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"
    local _myOID=$1
    local _4dbg=$(ctysVBOXListRelays|grep $_myOID)
    _4dbg=$(echo $_4dbg|grep '127.0.0')
    [ -n "$_4dbg" ]
}

