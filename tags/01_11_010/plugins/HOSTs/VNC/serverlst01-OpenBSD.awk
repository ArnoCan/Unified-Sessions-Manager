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

#    output format: "host:label:id:uuid:pid:uid:gid:sessionType:clientServer"
#                     +    +     +  +    +   +   +       +          +

function ptrace(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:VNC:SERVERLST");
}

{
    line++;
    ptrace("input=<"$0">")
}

{
    res="";
    found=0;

    #label
    if($11){
        lbl=$14
        gsub(";", "_", lbl);
        res=lbl;
        found=1;  
    }

    #id
    id=0;
    if($12!~/^$/){
        id=$12;
        gsub("[^:]*:", "", id);
        res=res";"id;
        found=1;  
    }

    if(found!=0){
        if(id=="")
            res=res";;;";
        else
            res=res";;;"id;

        #CPORT
        cp=$0;
        gsub("^.*rfbport *","",cp);
        m=match(cp,"[0-9]*");
        if(m)
            res=res";"substr(cp,RSTART,RLENGTH);
        else{            
            res=res";";
        }
        res=res";";
    
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
        res=res"VNC";

        #clientServer
        res=res";SERVER;";

        j=$0;
        jm=gsub("^.*-j *","",j);
        if(jm!=0){
            gsub(" .*$","",j);
            ptrace("j=<"j">");
            res=res";"j;
        }else{
            ptrace("j=<>");
            res=res";";
        }

        res=res""$8";";

        printf("%s ",res);
        ptrace("output=<"res">")
    }
    found=0;
}
