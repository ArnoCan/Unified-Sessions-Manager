########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

function ptrace(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:VMW:CLIENTLST");
    ptrace("_c1=\"" _c1 "\"");
    ptrace("_c2=\"" _c2 "\"");
}

{
    line++;
}

{
    ptrace("input=\"" $0 "\"");

    curEntry="";
    #
    #reminder:4tst
    # cll="echo " $0 "|sed -n \"s/^.*\\\/\\\([^/]*\\\)\\\.vmx.*/\\\1/;p\"";;
    # cll|getline x;
    #

    #fetch label, if given from CLI of running process
    if($9~/^$/){
        call=_c1 " "  $8 " 2>/dev/null";
        x="";        
        call|getline x;
        close(call);        
    }else{
        x=$9;
    }
    ptrace("LABEL="x" for "$8);

    curEntry=curEntry x ";";
    curEntry=curEntry $8;

    #UUID
    curEntry=curEntry ";";
    if(_c2!~/^$/){
        call=_c2 " "  $8 " 2>/dev/null";
        u="";
        call|getline u;
        close(call);        
        curEntry=curEntry u;               
    }
        
    #currently just ONE - the first "0" indexed - is supported
    curEntry=curEntry ";";
    if(_c3!~/^$/){
        call=_c3 " " $8 " 2>/dev/null";
        u="";
        call|getline u;
        close(call);
        if(u~/^$/){
            if(_c4!~/^$/){
                call=_c4 " " $8 " 2>/dev/null";
                call|getline u;
                close(call);
            }
        }
        curEntry=curEntry u;               
        ptrace("MAC-ethernet0.address="u);
    }

    #cport - proprietary and VNC -> could vary for each!!!
    cu="";
    call="getClientTPVMW " x " " $8;
    call|getline cu;
    ptrace("clientTP="cu);
    close(call);        
    if(cu~/^$/){
        curEntry=curEntry ";;"; 
    }else{
        #even though redundant keep it for now seperate, Xen at least could change.
        curEntry=curEntry ";" cu ";" cu;
    }

    curEntry=curEntry ";"; 
    curEntry=curEntry ";" $2 ";" $1;
    {
        call="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"" " 2>/dev/null";
        x1="";
        call|getline x1;
        close(call);        
        curEntry=curEntry ";" x1;
    }
    curEntry=curEntry ";VMW";
    curEntry=curEntry ";CLIENT;; ";
    printf("%s", curEntry);
    found=0;
}

