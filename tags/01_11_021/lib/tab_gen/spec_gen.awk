########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


function ptrace(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:spec_gen");
    colnum=split(cols,colsA,"%");

    if(colnum>0){
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
                titlesA[i]=record[2];
                widthsA[i]=record[3];
                cutPolicyA[i]=record[4];
            }
        }
    }
}

{
    line++;
}

colnum==0{
    ptrace("colnum="colnum);
    ptrace("$0="$0);
    
    indent0="   ";
    indent1="       ";
    valline="record("line"):={\n";
    for(i=1;i<=NF;i++){
        if(i>1)valline=valline"\n";
        valline=valline""indent0""sprintf("%03d: ",i);
        myOut="";
        recnum=split($i,myRecA,",");
        valline=valline""sprintf("%3d: ",myRecA[2]);
        valline=valline""sprintf("%25s: ",myOut=myRecA[1]);

        for(n=3;n<=recnum;n++){
            f3=myRecA[n];
        }
        formstrg="%s";
        valline=valline""sprintf(formstrg,f3);
    }
    valline=valline"\n}";
    print valline;
}

colnum>0{
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
        indent="    ";
        remain=0;
        valline="record("line"):={\n";
        for(i=1;i<=colnum;i++){
            if(i>1)valline=valline"\n";
            ptrace("formstrg="formstrg);
            ptrace("fieldsA["i"]="fieldsA[i]);
            ptrace("$fieldsA["i"]="$fieldsA[i]);
            ptrace("widthsA["i"]="widthsA[i]);

            valline=valline""indent""sprintf("%03d: ",i);
            myOut="";
            recnum=split($fieldsA[i],myRecA,",");

            valline=valline""indent""sprintf("%3d: ",myRecA[2]);

            if(titlesA[i]!=""){
                myOut=titlesA[i];
            }else{
                myOut=myRecA[1];
            }
            valline=valline""sprintf("%25s: ",myOut);

            for(n=3;n<=recnum;n++){
                f3=myRecA[n];
            }
                
            ptrace("widthsA["i"]="widthsA[i]);
            if(widthsA[i]==0){               
                formstrg="%s";
                valline=valline""sprintf(formstrg,f3);
            }
            else{
                l=0;
                formstrg="%-"widthsA[i]"s";
                if(cutPolicyA[i]=="L"){
                    l=length(f3)-widthsA[i]+1;
                    ptrace("length="l);
                }
                valline=valline""sprintf(formstrg,substr(f3,l,widthsA[i]));
                if(cutPolicyA[i]=="B"){
                    l=length(f3);
                    if(l>widthsA[i]){
                        f3=substr(f3,widthsA[i]+1);
                    }
                }
            }
        }
        valline=valline"\n}";
        print valline;
        loopcnt++;
    }    
}

