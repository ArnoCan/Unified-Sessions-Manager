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

function perror(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}

BEGIN{
    line=0;
    perror("Start record with AWK:CLIENTLST");
    perror("_c1=\"" _c1 "\"");
    perror("_c2=\"" _c2 "\"");
    perror("machine="machine);
}

{
    line++;
}

{
    curEntry="";
    #
    #reminder:4tst
    # cll="echo " $0 "|sed -n \"s/^.*\\\/\\\([^/]*\\\)\\\.vmx.*/\\\1/;p\"";;
    # cll|getline x;
    #

    #fetch label, if given from CLI of running process
    if($9~/^$/){
        call=_c1 " "  $8 " 2>/dev/null";
        call|getline x;
        close(call);        
    }else{
        x=$9;
    }
    if(x~/^$/&&machine==0){
        #Was not the best solution!!!
        #   at least use fname as ID 
        #   x1= gensub(".vmx$","","g",$NF);x2=match(x1,"[^/]*$");
        #   x=substr(x1,x2);
        #=>CHANGED for transparency and easy post-processing
        x="NO-VMX-PERMISSION";
    }
    perror("LABEL="x" for "$8);

    curEntry=curEntry x ";";
    if(f==1){
        curEntry=curEntry $8;
    }else{
        x1= gensub(".vmx$","","g",$8);x2=match(x1,"[^/]*$");
        x3=substr(x1,x2);
        curEntry=curEntry ".../" x3;
    }

    #UUID
    curEntry=curEntry ";";
    if(_c2!~/^$/){
        call=_c2 " "  $8 " 2>/dev/null";
        call|getline u;
        close(call);        
        if(u~/^$/&&machine==0){
            u="NO-VMX-PERMISSION";            
        }
        curEntry=curEntry u;               
    }
        
    if(machine==0){
        curEntry=curEntry ";NO-MAC";
    }
    else{
        curEntry=curEntry ";"; 
    }

    #cport - proprietary and VNC -> could vary for each!!!
    cu="";
    call="getClientTPVMW " x " " $8;
    call|getline cu;
    perror("clientTP="cu);
    close(call);        
    if(cu~/^$/){
        if(machine==0){
            curEntry=curEntry ";NO-DISP";
            curEntry=curEntry ";NO-VMX-PERMISSION";            
        }
        else{
            curEntry=curEntry ";;"; 
        }
    }else{
        #even though redundant keep it for now seperate, Xen at least could change.
        curEntry=curEntry ";" cu ";" cu;
    }

    if(machine==0){
        curEntry=curEntry ";NO-SPORT";
    }
    else{
        curEntry=curEntry ";"; 
    }

    curEntry=curEntry ";" $2 ";" $1;
    {
        call="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"" " 2>/dev/null";
        call|getline x1;
        close(call);        
        curEntry=curEntry ";" x1;
    }
    curEntry=curEntry ";VMW";
    if(machine==0)curEntry=curEntry "-" s;
    curEntry=curEntry ";CLIENT ";
    printf("%s", curEntry);
    found=0;
}

