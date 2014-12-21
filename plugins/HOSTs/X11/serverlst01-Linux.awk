########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a13
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#    output format: "label;id;uuid;pid;uid;gid;sessionType;clientServer;JobID"
#                    1     2  3    4   5   6   7           8            9

function ptrace(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:X11:SERVERLST");
}

{
    line++;
    ptrace("input=<"$0">")
}


{
    found=0;
    res="";
    
    #id+job+label
    x0=$0;
    f=gsub("^.*CTYS-X11-","",x0);
    if(f>0){
        gsub(" .*$","",x0);
        j=x0;
        gsub("-.*$","",j);
        id=j;
        xm=match(id,"^[^:]*:[^:]*:");
        if(xm!=0){            
        id=substr(id,RSTART,RLENGTH-1);
        }else{
            id="";
        }
        gsub("[^-]*-","",x0);
        found=1;  
    }
    ptrace("label=<"x0">")
    ptrace("id=<"id">")
    ptrace("jobid=<"j">")
    res=x0";"id;

    ptrace("found("found")");
    if(found!=0){
        res=res";;;;;";
    
        #pid+uid
        res=res";"$2";"$1;
        {
            #gid
            cll="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"";
            cll|getline x1;
            close(cll);            
            res=res";"x1;
        }

        #sessionType
        res=res";X11";

        #clientServer
        res=res";CLIENT;";

        #job
        res=res";"j;
        res=res";"$8";";
        res=res" ";
        printf("%s",res);
    }
    ptrace("res=<"res">");
    found=0;
}

