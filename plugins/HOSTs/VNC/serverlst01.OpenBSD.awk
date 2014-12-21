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
    if($11){
#        printf("%s", gensub(";", "_", "g", $11));
        lbl=$14
        gsub(";", "_", lbl);
        printf("%s", lbl);
        found=1;  
    }

    #id
    id=0;
    if($12!~/^$/){
#        id=gensub(":", "", "g", $9);
        id=$12;
        gsub("[^:]*:", "", id);
        printf(";%s", id);
        found=1;  
    }

    if(found!=0){
        if(machine==0){
            printf(";NO-UUID");
            printf(";NO-MAC");
            if(id=="")
                printf(";NO-DISP");
            else
                printf(";%s", id);
        }else{
            if(id=="")
                printf(";;;");
            else
                printf(";;;%s",id);           
        }

        #CPORT
#        cp=gensub("^.*rfbport *","","g");
        cp=$0;
        gsub("^.*rfbport *","",cp);
        m=match(cp,"[0-9]*");
        if(m)
            printf(";%s", substr(cp,RSTART,RLENGTH));
        else{            
            if(machine==0){
                printf(";NO-CPORT");
            }else{
                printf(";");
            }
        }
        if(machine==0){
            printf(";NO-SPORT");
        }else{
            printf(";");
        }
    
        #pid+uid
        printf(";%s;%s;", $2, $1);
        {
            #gid
            cll="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"";
            cll|getline x1;printf("%s", x1);
            printf(";");
        }

        #sessioType
        printf("VNC");

        #clientServer
        printf(";SERVER");
        printf(" ");
    }
    found=0;
}
