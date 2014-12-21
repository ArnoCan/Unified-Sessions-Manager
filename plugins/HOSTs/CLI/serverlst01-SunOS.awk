
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

#old    output format: "host:label:id:uuid:pid:uid:gid:sessionType:clientServer"
#old1    output format: "label:id:uuid:pid:uid:gid:sessionType:clientServer"
#    output format: "label;id;uuid;pid;uid;gid;sessionType;clientServer;TCP"
#                    +     +  +    +   +   +   +           +            +

{
    found=0;

    #label
    if($0){
        x0=$0;        
        gsub(".*l:","",x0);
        gsub(" .*","",x0);
        gsub(",.*","",x0);
        
        printf("%s", x0);
        found=1;  
    }

    #id
    if($2!~/^$/){
        id=$2;
        printf(";%s", id);
        found=1;  
    }

    if(found!=0){
        printf(";;;");
        printf(";");
        printf(";");
    
        #pid+uid
        printf(";%s;%s;", $2, $1);
        {
            #gid
            cll="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"";
            cll|getline x1;printf("%s", x1);
            close(cll);            
            printf(";");
        }

        #sessioType
        printf("CLI");

        #clientServer
        printf(";CLIENT;");

        j=$0;
        jm=gsub("^.*-j *","",j);
        if(jm!0){
            gsub(" .*$","",j);
            printf(";%s",j);
        }else{
            printf(";");
        }
        res=res""$8";";

        printf(" ");
    }
    found=0;
}

