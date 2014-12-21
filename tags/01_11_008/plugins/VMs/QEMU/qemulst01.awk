########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_013
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
    ptrace("mycallpath="mycallpath);
    ptrace("cdargs="cdargs);
    ptrace("myProcLst="myProcLst);
    ptrace("d="d);
    ptrace("s="s);
    ptrace("f="f);
    ptrace("vncbase="vncbase);
    ptrace("exclude="exclude);
    ptrace("_c1=\"" _c1 "\"");
    ptrace("_c2=\"" _c2 "\"");

    m=0;
}

{
    line++;
    ptrace("input=<"$0">");    
}

{
    ptrace("input=<"$8">");
    mprg=$8
    gsub(".*/","",mprg);
    gsub("[\\]\\[<>:]","",mprg);
    ptrace("mprg=<"mprg">");
    mprg=":"mprg":"
}

myProcLst~mprg{
    ptrace("MATCH:<"$8">");
    curEntry="";

    x1=$NF;
    gsub("/[^/]*$","",x1);
    x2=match(x1,"[^/]*$");
    x3=substr(x1,x2);
    if(x1==$NF){
        x1="\\.";
    }
    #1.trial-convention:directoryname==conffilename-prefix
    ctys=x1"/"x3".ctys";
    ctys1=x1"/"x3".sh";
    ptrace("config0-1-dir="ctys);
    ptrace("config1="ctys1);

    if(ctys!~/^$/){
        call="[ -f \""ctys"\" ]&&grep MAGICID-QEMU " ctys " 2>/dev/null";
        call|getline u;
        close(call);
        if(u!~"^#@#MAGICID-QEMU"){
            ctys="";            
        }
    }



    #2.trial-convention:imagefilename-prefix==conffilename-prefix
    if(ctys==""&&$NF!=""){
        x2=$NF;
        gsub("^.*/","",x2);
        gsub("\\.[^\\.]*$","",x2);
        ctys=x1"/"x2".ctys";
        ptrace("config0-2-img="ctys);
        if(ctys!~/^$/){
            call="[ -f \""ctys"\" ]&&grep MAGICID-QEMU " ctys " 2>/dev/null";
            call|getline u;
            close(call);
            if(u!~"^#@#MAGICID-QEMU"){
                ctys="";            
            }
        }
    }
    

    x3=$0;
    m=gsub("^.*-name *","",x3);
    if(m==0){
        x3="";        
    }else{        
        gsub(" .*$","",x3);
    }

    #3.trial-convention:label==conffilename-prefix
    if(ctys==""&&x3!=""){
        u="";
        ctys=x1"/"x3".ctys";
        ptrace("config0-3-lbl="ctys);
        call="[ -f \""ctys"\" ]&&grep MAGICID-QEMU " ctys " 2>/dev/null";
        call|getline u;
        close(call);
        if(u!~"^#@#MAGICID-QEMU"){
            ctys="";            
        }
    }
    

    ptrace("LABEL=<"x3"> for <"ctys">");
    curEntry=curEntry""x3";";
    curEntry=curEntry""ctys";";

    #uuid
    u="";
    if(ctys!~/^$/){
        call=_c2 " " ctys " 2>/dev/null";
        call|getline u;
        close(call);
        if(u~/^$/){
            call=_c2 " " ctys1 " 2>/dev/null";
            call|getline u;
            close(call);
        }
    }
    curEntry=curEntry""u";";
    ptrace("UUID="u);
    

    y1=$0;
    y3="";
    m=gsub("^.*macaddr=","",y1);
    if(m!=0){
        p2=match(y1,"[0-9a-fA-F].:..:..:[0-9a-fA-F][0-9a-fA-F]:..:.[0-9a-fA-F]");
        y3=substr(y1,RSTART,RLENGTH);
    }
    ptrace("MAC="y3);
    curEntry=curEntry""y3";";

    x2=match($0," -vnc *");
    x3="";
    if(x2!=0){
        ptrace("x2="x2);
        x3="";
        if(x2!=0){
            x=substr($0,RSTART+RLENGTH);
            x2=match(x,":[0-9]*");
            x3=substr(x,RSTART+1,RLENGTH-1);
        }
    }    
    ptrace("DISPLAY=<"x3">");
    if(x3~/^$/){            
        curEntry=curEntry";";
    }
    else{
        curEntry=curEntry""x3";";            
    }

    #cport
    if(x3!=""&&x3!=""&&vncbase!=""){
        curEntry=curEntry""x3+vncbase";";
    }else{
        curEntry=curEntry";";
    }
    
    #sport
    {
        x1=$0;
        gsub("^.*mon:unix:","",x1);
        m=gsub(",server,nowait.*$","",x1);
        if(m==0){
            x1="";            
        }
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
    u="";
    if(ctys!~/^$/){
        call=_c3 " " ctys " 2>/dev/null";
        call|getline u;
        close(call);
        if(u~/^$/){
            call=_c3 " " ctys1 " 2>/dev/null";
            call|getline u;
            close(call);
        }
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

    curEntry=curEntry";"$8";";

    printf("%s ", curEntry);
    ptrace("output=<"curEntry">")
    found=0;
}
