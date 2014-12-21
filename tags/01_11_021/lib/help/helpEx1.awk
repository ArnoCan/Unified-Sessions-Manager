########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
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
    insection=0;
    maxlead=0;
    perror("dbg=   " dbg);
    perror("d=     " d);
}

insection==1&&($0!~/^ *$/&&maxlead>=match($0,"[^ ]")||$0~prefix){
    insection=0;
    perror("finish section");
}
$1~"^"_a{
    perror(sprintf("match=<%d>\n",match($0,"[^ ]")));
    perror(sprintf("0=<%s>\n",$0));
    perror(sprintf("1=<%s>\n",$1));
    perror(sprintf("_a=<%s>\n",_a));
#    prefix=gensub(_a".*$","","g");
    prefix=$0;
    gsub(_a".*$","",prefix);

    #be aware: expecting spaces only, particularly intermixed leading
    #white-space could confuse
    maxlead=length(prefix);

    perror(sprintf("maxlead=%d\n",maxlead));
    perror(sprintf("prefix0=<%s>\n",prefix));
    prefix="^" prefix "[^ =].*$";
    perror(sprintf("prefix=<%s>\n",prefix));
    insection=1;
}
insection==1{
    print $0
}
