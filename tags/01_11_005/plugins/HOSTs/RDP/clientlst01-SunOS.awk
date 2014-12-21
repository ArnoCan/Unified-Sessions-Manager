########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a11
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#    output format: "host:label:id:uuid:pid:uid:gid:sessionType:clientServer"
#                     +    +     +  +    +   +   +       +          +

function ptrace(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:RDP:CLIENTLST");
}

{
    line++;
    ptrace("input=<"$0">")
}



{
    found=0;
    #label
    if($12){
        lbl=$12
        gsub(";", "_", lbl);
        gsub(":[^:].*$", "", lbl);
        res=lbl;        
        found=1;  
    }

    #id: due to hard-coded truncation of solaris implementation for ps for the args
    #so, this relies on the convention, thus do not change it!!!
    #   <label>:<id>
    id=0;
    if($12){
        id=$12
        gsub(";", "_", id);
        gsub("^[^:]*:", "", id);
        res=res";"id;
        found=1;  
    }
    if(found!=0){
        if(id=="")
            res=res";;;;;";
        else
            res=res";;;"id";;";
        
        #pid+uid
        res=res";"$2";"$1";";
        {
            #gid
            cll="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"";
            cll|getline x1;
            close(cll);            
            res=res""x1";";
        }

        #sessioType
        res=res"RDP";

        #clientServer
        res=res";CLIENT;";
        j=$0;
        jm=gsub("^.*-j *","",j);
        if(jm!=0){
            gsub(" .*$","",j);
            ptrace("j=<"j">")
            res=res";"j;
        }else{
            ptrace("j=<>")
            res=res";";
        }

        res=res""$8";";
        printf("%s ",res);
        ptrace("output=<"res">")
    }
    found=0;
}
