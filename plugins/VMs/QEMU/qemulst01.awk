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
    perror("Start record with AWK:SERVERLST");
    perror("_c1=\"" _c1 "\"");
    perror("_c2=\"" _c2 "\"");
    perror("machine="machine);
}

{
    line++;
}

$8!~/^$/&&$8~/vdeq/{
    curEntry="";

    x1=$NF;
    gsub("/[^/]*$","",x1);
    x2=match(x1,"[^/]*$");
    x3=substr(x1,x2);
    ctys=x1"/"x3".ctys";
    perror("config="ctys);

    call=_c1 " "  ctys " 2>/dev/null";
    call|getline x;
    close(call);
    if(x~/^$/&&machine==0){
        x="NO-CONF-PERMISSION";        
    }

    perror("LABEL="x3" for "ctys);
    curEntry=curEntry x3 ";";
    if(f==1){
        curEntry=curEntry ctys;
    }else{
        x1=ctys;
        gsub(".*$","",x1);
        x2=match(x1,"[^/]*$");
        x3=substr(x1,x2);
        curEntry=curEntry ".../" x3;
    }
    curEntry=curEntry ";";
    if(_c2!~/^$/){
        call=_c2 " " ctys " 2>/dev/null";
        call|getline u;
        close(call);
        if(u~/^$/&&machine==0){
            u="NO-VMX-PERMISSION";            
        }
        curEntry=curEntry u;               
        perror("UUID="u);
    }

    y1=$0;
    gsub("^.*macaddr=","",y1);
    p2=match(y1,"[0-9a-fA-F].:..:..:[0-9a-fA-F][0-9a-fA-F]:..:.[0-9a-fA-F]");
    y3=substr(y1,RSTART,RLENGTH);
    perror("MAC="y3);

    if(machine==0&&x~/^$/){
        curEntry=curEntry ";NO-MAC";
    }
    else{
        curEntry=curEntry ";"y3;
    }

    x2=match(x1," -vnc *");
    if(RSTART!=0){
        x=substr(x2,RSTART+RLENGTH);
        x2=match(x," [^ ]*");
        x3=substr(x2,RSTART,RLENGTH);        
    }
    perror("DISPLAY="x3);
    if(machine==0){
        if(x3~/^$/){            
            curEntry=curEntry ";NO-DISP";
        }
        else{
            curEntry=curEntry ";" x3;            
        }
        curEntry=curEntry ";NO-VMX-PERMISSION";            
    }
    else{
        curEntry=curEntry ";;";            
    }

    if(machine==0){
        curEntry=curEntry ";NO-SPORT";
    }
    else{
        curEntry=curEntry ";"; 
    }
            
    curEntry=curEntry ";" $2 ";" $1;
    perror("pid="$2);
    perror("uid="$1);
    {
        call="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"" " 2>/dev/null";
        perror(call);
        call|getline x1;
        close(call);
        curEntry=curEntry ";" x1;
        perror("guid="x1);
    }
    curEntry=curEntry ";QEMU";

    sys=$9;
    gsub("qemu","",sys);
    if(sys!~/^$/&&sys!=$9){
        gsub("^-system-","",sys);
        curEntry=curEntry "-" sys ;
    }
    
    curEntry=curEntry ";SERVER ";
    printf("%s", curEntry);
    found=0;
}
