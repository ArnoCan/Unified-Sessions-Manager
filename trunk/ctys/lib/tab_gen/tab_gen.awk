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


function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:tab_gen");
    colnum=split(cols,colsA,"%");

    formstrg="";
    titlesA[1]="";
    widthsA[1]="";
    fieldsA[1]="";

    cutPolicyA[1]="";
    cutBufA[1]="";

    for(i=1;i<=colnum;i++){
        if(colsA[i]!~/^$/){
            recnum=split(colsA[i],record,"_");
            fieldsA[i]=record[1];
            if(record[2]!="")titlesA[i]=record[2];
            else titlesA[i]=record[1];

            if(record[3]!=0)widthsA[i]=record[3];
            else widthsA[i]=10;
            cutPolicyA[i]=record[4];
        }
    }
}

{
    line++;
}

#Input-format: generic
# record=<field>[:<record>]

titleidx!=0{
    x="---------------------------------------------------------------------------------------------------";
    tabline="";
    titlestrg="";    
    idxstrg="";    
    for(i=1;i<=colnum;i++){
        formstrg="%-"widthsA[i]"s";
        if(i<colnum)formstrg=formstrg"|";
        titlestrg=titlestrg""sprintf(formstrg,substr(titlesA[i],1,widthsA[i]));
        idxstrg=idxstrg""sprintf(formstrg,substr(i"("fieldsA[i]")",1,widthsA[i]));

        tabline=tabline""substr(x,1,widthsA[i]);
        if(i<colnum)tabline=tabline"+";
    }
    print titlestrg;
    print idxstrg;
    print tabline;
    next;
}

title==1{
    x="---------------------------------------------------------------------------------------------------";
    tabline="";
    titlestrg="";    
    for(i=1;i<=colnum;i++){
        formstrg="%-"widthsA[i]"s";
        if(i<colnum)formstrg=formstrg"|";
        titlestrg=titlestrg""sprintf(formstrg,substr(titlesA[i],1,widthsA[i]));

        tabline=tabline""substr(x,1,widthsA[i]);
        if(i<colnum)tabline=tabline"+";
    }
    print titlestrg;
    print tabline;
    next;
}


{
    ptrace("colnum="colnum);
    ptrace("$0="$0);
    
    remain=1;
    loopcnt=0;
    loopmax=50;
    
    while(remain==1){
        if(loopcnt>loopmax){
            print line ":Loop-Counter=="loopmax" overflow!!!" | "cat 1>&2"
            exit 1;
        }
        
        valline="";
        remain=0;
        for(i=1;i<=colnum;i++){
            formstrg="%-"widthsA[i]"s";
            ptrace("formstrg="formstrg);
            ptrace("fieldsA["i"]="fieldsA[i]);
            ptrace("$fieldsA["i"]="$fieldsA[i]);
            ptrace("widthsA["i"]="widthsA[i]);

            if(i<colnum)formstrg=formstrg"|";
            l=0;

            if(cutPolicyA[i]=="L"){
                l=length($fieldsA[i])-widthsA[i]+1;
                ptrace("length="l);
            }
            ptrace("widthsA["i"]="widthsA[i]);
    
            valline=valline""sprintf(formstrg,substr($fieldsA[i],l,widthsA[i]));

            if(cutPolicyA[i]=="B"){
                l=length($fieldsA[i]);
                if(l>widthsA[i]){
                    $fieldsA[i]=substr($fieldsA[i],widthsA[i]+1);
                    remain=1;
                }
                else{
                    $fieldsA[i]="";
                }
            }else{
                    $fieldsA[i]="";
            }
        }
        print valline;
        loopcnt++;
    }    
}

