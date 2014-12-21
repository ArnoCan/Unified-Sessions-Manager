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
    ptrace("Start record with AWK:VMW:SERVERLST");
    ptrace("_c1=\"" _c1 "\"");
    ptrace("_c2=\"" _c2 "\"");
    ptrace("_c3=\"" _c3 "\"");
}

{
    line++;
    ptrace("input=<"$0">");
}

{
    curEntry="";

    call=_c1 " "  $8 " 2>/dev/null";
    x="";    
    call|getline x;
    close(call);
    
    ptrace("LABEL="x" for "$8);
    curEntry=x";";
    curEntry=curEntry""$8";";

    #mac
    if(_c2!~/^$/){
        call=_c2 " " $8 " 2>/dev/null";
        u="";    
        call|getline u;
        close(call);
        curEntry=curEntry""u";";               
        ptrace("UUID="u);
    }else{
        curEntry=curEntry";";               
    }

    #uuid
    if(_c3!~/^$/){
        call=_c3 " " $8 " 2>/dev/null";
        u="";    
        call|getline u;
        close(call);
        if(u~/^$/){
            if(_c4!~/^$/){
                call=_c4 " " $8 " 2>/dev/null";
                u="";    
                call|getline u;
                close(call);
            }
        }
        curEntry=curEntry""u";";
        ptrace("MAC-ethernetX.address="u);
    }else{
        curEntry=curEntry";";               
    }

    #display    
    curEntry=curEntry";";               

    #cport - proprietary and VNC -> could vary for each!!!
    cu="";
    call="getClientTPVMW " x " " $8;
    call|getline cu;
    ptrace("clientTP="cu);
    close(call);        
    if(cu~/^$/){
        curEntry=curEntry";";            
    }else{
        curEntry=curEntry""cu";";
    }

    #sport;pid;uid;
    curEntry=curEntry";"$2";"$1";";
    ptrace("pid="$2);
    ptrace("uid="$1);
    if($1!~/^$/){
        call="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"" " 2>/dev/null";
        ptrace(call);
        x1="";    
        call|getline x1;
        close(call);
        curEntry=curEntry""x1";";
        ptrace("gid="x1);
    }else{
        curEntry=curEntry";";
    }

    curEntry=curEntry"VMW;";
    curEntry=curEntry"SERVER;";
    j=$0;
    jm=gsub("^.* -j *","",j);
    if(jm!=0){
        gsub(" .*$","",j);
        curEntry=curEntry""j";";
        ptrace("jobid="j);        
    }else{
        ptrace("jobid=");
        curEntry=curEntry";";
    }

    ptrace("output=<"curEntry">")
    printf("%s ", curEntry);
    found=0;
}
