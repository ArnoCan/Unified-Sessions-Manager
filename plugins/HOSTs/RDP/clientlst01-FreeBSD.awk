########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_006alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#    output format: "label:id:uuid:pid:uid:gid:sessionType:clientServer:JobID"


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
    res="";
    found=0;

    #label
    lbl=$0;
    gsub("^.*-T  *","",lbl);
    gsub("[^ ]*$","",lbl);
    ptrace("match=<"lbl">");
    cport=lbl;
    gsub(":.*$","",lbl);
    gsub("^.*:","",cport);
    gsub(" *$","",cport);
    ptrace("lbl=<"lbl">");
    ptrace("cport=<"cport">");
    
    if(lbl!~/^$/){
        res=lbl;        
        found=1;  
    }

    #id
    res=res";";
                     
    if(found!=0){
        if(id=="")
            res=res";;;;"cport";";
        else
            res=res";;;"id";"cport";";
        
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
            res=res";"j;
            ptrace("j=<"j">")
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
