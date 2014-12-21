#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_006alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################



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
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchUUID  {
    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi
    local _mycall="$VBOXMGR showvminfo $myID --machinereadable|awk -F'=' '/uuid=/{gsub(\"\\\"\",\"\",\$2);print \$2;}'"
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  getRDPport
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getRDPport  {
    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi

    local _mycall="$VBOXMGR showvminfo $myID --machinereadable|awk -F'=' '/vrdpport=/{gsub(\"\\\"\",\"\",\$2);print \$2;}'"
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  checkIsInInventory
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|pathname(convention!)
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function checkIsInInventory  {
    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi
    local _mycall="$VBOXMGR showvminfo $myID --machinereadable  >/dev/null 2>/dev/null"
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}

#FUNCBEG###############################################################
#NAME:
#  addToInventory
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|pathname(convention!)
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function addToInventory  {
    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi

    local _mycall="$VBOXMGR registervm $myID >/dev/null 2>/dev/null"
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}

export -f fetchMAC
export VBOXMGR



#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListClientServers
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
function ctysVBOXListClientServers () {
    listProcesses|\
    awk -v d=$D '
      function ptrace(inp){
        if(!d){
          print inp | "cat 1>&2"
        }
      }

      /'$$'/{
        next;
      }
      !/virtualbox/{
        next;
      }
      !/VirtualBox/&&!/VBoxSDL/{
        next;
      }
      /-comment/{
        l=$0;
        n=gsub("^.*--comment  *","",l);
        if(x!0){n=gsub("  *.*$","",l);}
      }
      /-startvm /{
        u=$0;
        n=gsub("^.*-startvm  *","",u);
        if(n!=0){n=gsub(" .*$","",u);}
      }
      /-s /{
        u=$0;
        n=gsub("^.*-s  *","",u);
        if(n!=0){n=gsub(" .*$","",u);}
      }

      u!~/........-....-....-..../{
        l=u;
        u="";
      }

      {
        p="";
        for(i=1;i<8;i++){
          p=p" "$i
        }
        if(u!=""||l!=""){
          if(u!=""){
            call="VBoxManage showvminfo --machinereadable "u;
            call=call"|awk -F= -v L="u" \"/IDE[- ]Controller-0-0/{a=\\$2;} /vrdpport/{b=\\$2;} /^name=/{c=\\$2;} /^macaddress1=/{d=\\$2;} /^hwvirtex=/{e=\\$2;} /^ostype=/{if(\\$0~/_64/){f=\\\"x86_64\\\"}else{f=\\\"i386\\\"}} END{print a\\\";\\\"c\\\";\\\"L\\\";\\\"b\\\";\\\"d\\\";\\\"e\\\";\\\"f}\"";
          }else{
            call="VBoxManage showvminfo --machinereadable "l;
            call=call"|awk -F= -v L="l" \"/IDE[ -]Controller-0-0/{a=\\$2;} /vrdpport/{b=\\$2;} /UUID/{c=\\$2;} /^macaddress1=/{d=\\$2;} /^hwvirtex=/{e=\\$2;} /^ostype=/{if(\\$0~/_64/){f=\\\"x86_64\\\"}else{f=\\\"i386\\\"}} END{print a\\\";\\\"L\\\";\\\"c\\\";\\\"b\\\";\\\"d\\\";\\\"e\\\";\\\"f}\"";
          }
          ptrace("call="call);

          x1="";    
          call|getline x1;
          close(call);

          ptrace("x1="x1);
          p=p" "x1";"$8;
          gsub("\"","",p);
          printf("%s\n",p);
        }
        l="";
        u="";
      }
    '
}


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
    ctysVBOXListClientServers
    listProcesses|\
    awk -v d=$D '
      function ptrace(inp){
        if(!d){
          print inp | "cat 1>&2"
        }
      }

      /'$$'/{
        next;
      }
      !/virtualbox/{
        next;
      }
      !/VBoxHeadless/{
        next;
      }
      /-comment/{
        l=$0;
        n=gsub("^.*--comment  *","",l);
        if(x!0){n=gsub("  *.*$","",l);}
      }
      /-startvm /{
        u=$0;
        n=gsub("^.*-startvm  *","",u);
        if(n!=0){n=gsub(" .*$","",u);}
      }
      /-s /{
        u=$0;
        n=gsub("^.*-s  *","",u);
        if(n!=0){n=gsub(" .*$","",u);}
      }

      u!~/........-....-....-..../{
        l=u;
        u="";
      }

      {
        p="";
        for(i=1;i<8;i++){
          p=p" "$i
        }
        if(u!=""||l!=""){
          if(u!=""){
            call="VBoxManage showvminfo --machinereadable "u;
            call=call"|awk -F= -v L="u" \"/IDE[- ]Controller-0-0/{a=\\$2;} /vrdpport/{b=\\$2;} /^name=/{c=\\$2;} /^macaddress1=/{d=\\$2;} /^hwvirtex=/{e=\\$2;} /^ostype=/{if(\\$0~/_64/){f=\\\"x86_64\\\"}else{f=\\\"i386\\\"}} END{print a\\\";\\\"c\\\";\\\"L\\\";\\\"b\\\";\\\"d\\\";\\\"e\\\";\\\"f}\"";
          }else{
            call="VBoxManage showvminfo --machinereadable "l;
            call=call"|awk -F= -v L="l" \"/IDE[ -]Controller-0-0/{a=\\$2;} /vrdpport/{b=\\$2;} /UUID/{c=\\$2;} /^macaddress1=/{d=\\$2;} /^hwvirtex=/{e=\\$2;} /^ostype=/{if(\\$0~/_64/){f=\\\"x86_64\\\"}else{f=\\\"i386\\\"}} END{print a\\\";\\\"L\\\";\\\"c\\\";\\\"b\\\";\\\"d\\\";\\\"e\\\";\\\"f}\"";
          }
          ptrace("call="call);

          x1="";    
          call|getline x1;
          close(call);

          ptrace("x1="x1);
          p=p" "x1";"$8;
          gsub("\"","",p);
          printf("%s\n",p);
        }
        l="";
        u="";
      }
    '
}
