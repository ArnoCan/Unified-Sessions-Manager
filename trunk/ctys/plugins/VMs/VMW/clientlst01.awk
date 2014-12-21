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
    perror("Start record with AWK:CLIENTLST-SERVER+WS");
}

{
    line++;
}

$8~/.*\/bin\/vmware$/{
    curEntry=""
    #<UNIX process parameters>
    for(i=1;i<=7;i++){curEntry=curEntry " " $i;perror("i("i")="$i);}

    #<vmx-filepath>
    curEntry=curEntry " " $NF;
    perror("vmx-filepath="$NF);
    #<label>
    pos=match($0, "displayName=");
    if(pos!=0){
        n=substr($0,RSTART+RLENGTH);
        x=gensub(" -[[:alnum:]]* .*$", "", "g", n);
        curEntry=curEntry " " x;
        perror("displayName="x);
    }

    #<uuid> is enclosed in "" and in original format
    pos=match($0, "uuid.bios=\"");
    if(pos!=0){
        n=substr($0,RSTART+RLENGTH-1);
        #extract arg
        x=gensub(" -[[:alnum:]]* .*$", "", "g", n);
        #normalize uuid
        x=gensub("[ -]", "", "g", x);
        curEntry=curEntry " " x;
        perror("uuid.bios="x);
    }

#     curEntry=curEntry " NO-MAC";
#     curEntry=curEntry " NO-DISP";
#     curEntry=curEntry " NO-CPORT";
#     curEntry=curEntry " NO-SPORT";


    printf("%s\n",curEntry);
}
