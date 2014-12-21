########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
#
########################################################################
#
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


function perror(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

BEGIN{
    line=0;
    perror("Start record with AWK:tab_tcp");
    colnum=split(cols,colsA,"%");

    h="TCP-container";   if(colnum>0&&colsA[1]!~/^$/)hX=colsA[1];else hX=18;
    gu="TCP-guest";      if(colnum>1&&colsA[2]!~/^$/)guX=colsA[2];else guX=17;

    if(i>1){l="id";}else{l="label";}if(colnum>2&&colsA[3]!~/^$/)lX=colsA[3];else lX=17;
    
    t="stype";           if(colnum>3&&colsA[4]!~/^$/)tX=colsA[4];else tX=9;
    a="accel";           if(colnum>4&&colsA[5]!~/^$/)aX=colsA[5];else aX=5;
    c="c";               if(colnum>5&&colsA[6]!~/^$/)cX=colsA[6];else cX=1;
    u="user";            if(colnum>6&&colsA[7]!~/^$/)uX=colsA[7]; else uX=10;
    gr="group";          if(colnum>7&&colsA[8]!~/^$/)grX=colsA[8];else grX=10;
    formstrg="%-"hX"s|%-"guX"s|%-"lX"s|%-"tX"s|%-"aX"s|%"cX"s|%-"uX"s|%-"grX"s\n";    
}

{
    line++;
}

#Input-format: 
# host:sessionType:label:id:uuid:mac:tcp:disp:cport:sport:pid:uid:gid:clientServer
# 0    1           2     3  4    5   6   7    8     9     10  11  12  13


title==1{
    printf(formstrg,substr(h,1,hX),substr(gu,1,guX),substr(l,1,lX),substr(t,1,tX),substr(a,1,aX),substr(c,1,cX),substr(u,1,uX),substr(gr,1,grX));
    x="---------------------------------------------------------------------------------------------------";
    tabline="";
    tabline=tabline""substr(x,1,hX)"+";
    tabline=tabline""substr(x,1,guX)"+";
    tabline=tabline""substr(x,1,lX)"+";
    tabline=tabline""substr(x,1,tX)"+";
    tabline=tabline""substr(x,1,aX)"+";
    tabline=tabline""substr(x,1,cX)"+";
    tabline=tabline""substr(x,1,uX)"+";
    tabline=tabline""substr(x,1,grX);
    printf("%s\n",tabline);
    next;
}


{
    if($1!~/^$/)h=substr($1,1,hX);else h="-";

    if(tcp>1||dns>1){
        if($7!~/^$/)gu=substr($7,1,guX);
        else
            if(mac==1&&$6!~/^$/)gu=substr($6,1,guX);
            else gu="-";
    }else{
        if(mac>1){
            if($6!~/^$/)gu=substr($6,1,guX);else gu="-";
        }
            else gu="-";
    }

    if(i>1){
        if($4!~/^$/){
            LlX=length($4)-lX+1;
            l=substr($4,LlX,lX);
        }
        else l="-";
    }
    else{    
        if($3!~/^$/)l=substr($3,1,lX);else l="-";
    }
    
    if($2!~/^$/)t=substr($2,1,tX);else t="-";
    if($21!~/^$/)a=substr($21,1,aX);else a="-";

    if($14~/SERVER/)c="S";
    else if($14~/CLIENT/)c="C";
    else if($14~/TUNNEL/)c="T";
    else c="?";

    if($12!~/^$/)u=substr($12,1,uX);else u="-";
    if($13!~/^$/)gr=substr($13,1,grX);else gr="-";
    
    printf(formstrg,h,gu,l,t,a,c,u,gr);
}


#
#List-Output-Format: tab01
#===================
#
#  host             |guest            |label               |type    |accel  |C|user      |group     
#  -----------------+-----------------+--------------------+--------+-------+----------+----------
#  17               |17               |20                  |8       |7      |1|10        |10        
#
#  
#  host            containing host
#  guest           running host()
#  label           user defined label
#  type            type of machine
#  accel           available accelerator on machine
#  client|server   communications peer type
#  uid             user name
#  gid             group name

#################
#  id
#  uuid
#  mac
#  display
#  client access port
#  server access port
#  pid
#

