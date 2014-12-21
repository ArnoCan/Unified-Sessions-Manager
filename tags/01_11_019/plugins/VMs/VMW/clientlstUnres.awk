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
    ptrace("Start record with AWK:VMW:CLIENTLST-LOCALLY-UNRESOLVED");
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

    x=$8;
    if(x!=""){
        
        oid=x;
#    gsub("@.*","",x)
        x="ObjID("x")"
        ptrace("LABEL="x" for "$8);

        curEntry=curEntry x ";";
        curEntry=curEntry $8;

        #UUID
        curEntry=curEntry ";";
        
        #currently just ONE - the first "0" indexed - is supported
        curEntry=curEntry ";";

        #cport - proprietary and VNC -> could vary for each!!!
        cu="";
        call=oid;
        curEntry=curEntry ";;"; 

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
    else{
        ptrace("No input.");
    
    }    
}

