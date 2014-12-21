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


BEGIN{n=0;h=0;b=0;buffer[b]="";pass=0;line=0;}
{line++;}
$1~/^#FUNCBEG#/&&h==0{
    h=1;
}
h==1{
    buffer[b++]=$0;
}
n==1&&$2~fu{
    h=0;
    n=0;
    pass=1;
    printf("**************************************************************\n");
    printf("*FILE:%s(%04d)\n",fn,line);
    printf("**************************************************************\n");
    for(i=0;i<b-1;i++){
        print buffer[i];
    }
}
pass==1{
    print $0;
}
$1~/^#NAME:/{
    n=1;
}
$1~/^#FUNCEND#/{
    b=0;
    pass=0;
}
