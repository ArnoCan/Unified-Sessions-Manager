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
    ptrace("Start record with AWK:tab_gen");
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
    valline="<record index='"line"'>\n";
    for(i=1;i<=NF;i++){
        if(i>1)valline=valline"\n";
        recnum=split($i,myRecA,",");
        valline=valline""indent0"<"myRecA[1]" index="myRecA[2]">";
        for(n=3;n<=recnum;n++){f3=myRecA[n];}
        valline=valline""f3;
        valline=valline"</"myRecA[1]">";
    }
    valline=valline"\n</record>\n";
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
        indent0="   ";
        indent1="      ";
        remain=0;
        valline="<record index='"line"'>\n";
        for(i=1;i<=colnum;i++){
            if(i>1)valline=valline"\n";
            ptrace("formstrg="formstrg);



            ptrace("fieldsA["i"]="fieldsA[i]);
            ptrace("$fieldsA["i"]="$fieldsA[i]);
            ptrace("widthsA["i"]="widthsA[i]);

            recnum=split($fieldsA[i],myRecA,",");

            valline=valline""indent0"<";
            if(titlesA[i]!=""){
                valline=valline""titlesA[i];
            }else{
                valline=valline""myRecA[1];
            }
            valline=valline" index="myRecA[2]">";

            for(n=3;n<=recnum;n++){f3=myRecA[n];}
            if(widthsA[i]==0){               
                valline=valline""f3;
            }
            else{
                myOut="";

                formstrg="%-"widthsA[i]"s";
                l=0;
                ptrace("widthsA["i"]="widthsA[i]);

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
            if(titlesA[i]!=""){
                valline=valline"</"titlesA[i]">";
            }else{
                valline=valline"</"myRecA[1]">";
            }
        }
        valline=valline"\n</record>\n";
        print valline;
        loopcnt++;
    }    
}

