
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
    if(dbg<=d){
        print line ":" inp | "cat 1>&2"
    }
}  

BEGIN{
    layoutSections=0
    inLayoutSection=0
    matchedSection=0
    matchedScreen=0
    mySecNr=-1
    mySecName="NoName"
    myScreenName="NoName"
    line=0
    myLineScreen=0
    myLineSection=0

    perror("dbg=   " dbg);
    perror("d=     " d);
    perror("sect=  " sect);
    perror("nr=    " nr);
    perror("alias= " alias);
}

{
    line++;
}
  
/EndSection/{
    inLayoutSection=0;
}

/ServerLayout/  { 
    layoutSections=layoutSections+1
    inLayoutSection=1
}
  
matchedSection==0&&inLayoutSection==1&&sect~/^$/{
    perror("matchedSection DEFAULT");
    matchedSection=1;
    mySecNr=layoutSections;
    mySecName="DEFAULT";
    myLineSection=line
}

matchedSection==0&&inLayoutSection==1{
    if(index($2,sect)&&length($2)==length(sect)){
        perror("matchedSection" sect);
        matchedSection=1;
        mySecNr=layoutSections;
        mySecName=$2;
        myLineSection=line
    }
}
  
inLayoutSection==1&&matchedSection==1&&matchedScreen==0{
    if(alias!~/^$/&&index($3,alias)&&length($3)==length(alias)||nr==$2){
        printf("%s %d %d", $3, $4, $5);
        matchedScreen=1;
        myLineScreen=line;
        myScreenName=alias;
    }
}
  
END{
    if(dbg!=0){
        if(matchedSection==0){  
            perror("No section found:"); 
        }else{
            if(matchedScreen==0){  
                perror("No screen found in section:"); 
            }
        }
        perror(sprintf(" mySectionIdx=%d mySectionName=%s totalSections=%d Section(%d)",
                       mySecNr,mySecName,layoutSections,myLineSection));
        if(matchedScreen==1){
            perror(sprintf(" Screen(%d)",myLineScreen));
        }
    }
    print
    if(matchedScreen==0){exit 1;}  
}
