
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
#
# output format: "label;id;uuid;pid;uid;gid;sessionType;clientServer;TCP;jobid"
#                    +     +  +    +   +   +   +           +            +

function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:CLI-SERVERLST");
    ptrace("_c1=\"" _c1 "\"");
    ptrace("_c2=\"" _c2 "\"");
}

{
    line++;
    ptrace("input=<"$0">");
}

{
    found=0;
    res="";

    #label
    if($0){
        x0=$0;        
        gsub(".*l:","",x0);
        gsub(" .*","",x0);
        gsub(",.*","",x0);
        res=x0;
        found=1;  
    }

    #id
    if($2!~/^$/){
        id=$2;
        res=res";"id;
        found=1;  
    }else{
        res=res";";
    }
    

    if(found!=0){
        res=res";;;;;";
    
        #pid+uid
        res=res";"$2";"$1";";
        {
            #gid
            cll="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"";
            cll|getline x1;
            close(cll);            
            res=res""x1";";
        }

        #sessionType
        res=res"CLI";

        #clientServer
        res=res";CLIENT;";

        j=$0;
        jm=gsub("^.* -j *","",j);
        if(jm!=0){
            gsub(" .*$","",j);
            res=res";"j;
            ptrace("jobid="j);
        }else{
            ptrace("jobid=");
            res=res";";
        }
        res=res";"$8";";
        ptrace("output=<"res">")
        printf("%s ",res);
    }
    found=0;
}

