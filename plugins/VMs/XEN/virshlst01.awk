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

function perror(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

function getAttrVal(inp){
    perror("getAttrVal="inp);
    #format: <... ATTR='VAL' .../>
    a=$0
    perror("a="a);
    xs=sprintf(".* %s='",inp);
    perror("xs="xs);
    gsub(xs,"",a);
    gsub("'.*","",a);
    gsub(" ","",a);
    perror("res="a);
    return a;
}


function getVal(inp){
    perror("getVal="inp);
    #format: <NODE>VAL</NODE>
    a=$0
    gsub("<"inp">","",a);
    gsub("</"inp">","",a);
    gsub(" ","",a);
    perror("res="a);
    return a;
}


BEGIN{
    label="";
    id="";
    uuid="";
    mac="";
    disp="";
    cport="";
    sport="";
    pid="";
    sessType="";
    cstype="SERVER";
    line="";
    perror("Start record with AWK:XEN-SERVERLST-virsh");

    if(ugid=="")ugid=";"
}

{
    line++;
}


/<name>/{
    label=getVal("name");
    next;    
}


/<domain type=/{
    sessType="XEN";
    pid=getAttrVal("id");
    next;    
}

/<source file=/{
    #use it for ctys:
    id=getAttrVal("file");
    gsub("/[^/]*$","",id);
    conffile=id;
    perror("id="id);
    gsub("^.*/","",conffile);
    perror("conffile="conffile);
    id=id"/"conffile".conf"
    perror("id="id);
    next;    
}

/<graphics type=/{
#    graphType=getAttrVal("type");
    cport=getAttrVal("port");
    disp=cport-voffset;
    next;    
}


/<uuid>/{
    uuid=getVal("uuid");
    next;    
}


/<mac address=/{
    mac=getAttrVal("address");
    next;    
}


END{
    if(pid==0){ugid="root;root";}
    res=label";"id";"uuid";"mac";"disp";"cport";"sport";"pid";"ugid";"sessType";"cstype";;";    
    perror("res="res);
    print res;    
}
