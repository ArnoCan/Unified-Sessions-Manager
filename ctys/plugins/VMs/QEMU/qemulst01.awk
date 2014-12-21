########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
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

function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

BEGIN{
    line=0;
    ptrace("QEMU:Start record with AWK:QEMU:SERVERLST");
    ptrace("d="d);
    ptrace("mycallpath="mycallpath);
    ptrace("cdargs="cdargs);
    ptrace("myProc="myProc);
    ptrace("d="d);
    ptrace("s="s);
    ptrace("f="f);
    ptrace("vncbase="vncbase);
    ptrace("exclude="exclude);
    ptrace("_c1=\"" _c1 "\"");
    ptrace("_c2=\"" _c2 "\"");
}

{
    line++;
    ptrace("input=<"$0">");
    
}

$8!~/^$/&&$8~myProc{
    curEntry="";

    x1=$NF;
    gsub("/[^/]*$","",x1);
    x2=match(x1,"[^/]*$");
    x3=substr(x1,x2);

    ctys=x1"/"x3".conf";
    ctys1=x1"/"x3".ctys";
    ptrace("config0="ctys);
    ptrace("config1="ctys1);


    x3=$0;
    gsub("^.*-name *","",x3);
    gsub(" .*$","",x3);
    
    ptrace("LABEL="x3" for "ctys);
    curEntry=curEntry""x3";";
    curEntry=curEntry""ctys";";

    #uuid
    call=_c2 " " ctys " 2>/dev/null";
    call|getline u;
    close(call);
    if(u~/^$/){
        call=_c2 " " ctys1 " 2>/dev/null";
        call|getline u;
        close(call);
    }
    curEntry=curEntry""u";";
    ptrace("UUID="u);
    

    y1=$0;
    gsub("^.*macaddr=","",y1);
    p2=match(y1,"[0-9a-fA-F].:..:..:[0-9a-fA-F][0-9a-fA-F]:..:.[0-9a-fA-F]");
    y3=substr(y1,RSTART,RLENGTH);
    ptrace("MAC="y3);
    curEntry=curEntry""y3";";

    x2=match($0," -vnc *");
    ptrace("x2="x2);
    x3="";
    if(x2!=0){
        x=substr($0,RSTART+RLENGTH);
        x2=match(x,":[0-9]*");
        x3=substr(x,RSTART+1,RLENGTH-1);
    }

    ptrace("DISPLAY=<"x3">");
    if(x3~/^$/){            
        curEntry=curEntry";";
    }
    else{
        curEntry=curEntry""x3";";            
    }

    #cport
    if(x3!=""&&vncbase!=""){
        curEntry=curEntry""x3+vncbase";";
    }else{
        curEntry=curEntry";";
    }
    

    #sport
    {
        x1=$0;
        gsub("^.*mon:unix:","",x1);
        gsub(",server,nowait.*$","",x1);

        curEntry=curEntry""x1";";
        ptrace("masterPid="x1);
    }

    curEntry=curEntry""$2";";
    ptrace("pid="$2);
    curEntry=curEntry""$1";";
    ptrace("uid="$1);
    {
        call="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"" " 2>/dev/null";
        ptrace(call);
        call|getline x1;
        close(call);
        curEntry=curEntry""x1";";
        ptrace("guid="x1);
    }

    curEntry=curEntry"QEMU";
    sys=$9;
    gsub("qemu","",sys);
    if(sys!~/^$/&&sys!=$9){
        gsub("^-system-","",sys);
        curEntry=curEntry"-"sys ;
    }
    curEntry=curEntry ";SERVER;";

    #tcp
    call=_c3 " " ctys " 2>/dev/null";
    call|getline u;
    close(call);
    if(u~/^$/){
        call=_c3 " " ctys1 " 2>/dev/null";
        call|getline u;
        close(call);
    }
    curEntry=curEntry""u";";
    ptrace("TCP="u);

    #job
    j=$0;
    jm=gsub("^.* -j *","",j);
    if(jm!=0){
        gsub(" .*$","",j);
        curEntry=curEntry""j;
    }

    printf("%s ", curEntry);
    ptrace("output=<"curEntry">")
    found=0;
}
