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

{
    found=0;

    #label
    if($16){
        x0=$16;        
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
        if(id=="")
            printf(";;;");
        else
            printf(";;;%s",id);           

        printf(";");
        printf(";");
    
        #pid+uid
        printf(";%s;%s;", $2, $1);
        {
            #gid
            cll="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"";
            cll|getline x1;printf("%s", x1);
            printf(";");
        }

        #sessioType
        printf("X11");

        #clientServer
        printf(";CLIENT");
        printf(" ");
    }
    found=0;
}

