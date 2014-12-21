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


function perror(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}

BEGIN{
    ripCord=1000;
    curind=1;
    buf1="";
    ind=a;

    line=0;
    perror("Start record with AWK:splitArgsWithOpts");
    perror("D=     "D);
    perror("d=     "d);
    perror("ind=   "ind);
}
{
    line++;
}
{
    buf1=$0;
    perror("buf1-raw  =<"buf1">");
    #canonize somewhat...
    gsub(" *[\"]* *[(] *","(",buf1);
    gsub(" *[)] *[\"]* *",")",buf1);
    perror("buf1-canon=<"buf1">");

    while(buf1&&ripCord&&curind<=ind){
        perror("buf1-canon("ind")=<"buf1">");
        ripCord--;
       perror("ripCord="ripCord);

        if((p=match(buf1,"^[^(]* ")==1) || (p=match(buf1,"^[^(]*$")==1)){

            perror("no argopts");
            #no argopts

            p=match(buf1,"^[^ ]*");
            if(curind==ind){
                out=substr(buf1,RSTART,RLENGTH);
                gsub(" *","",out);
                perror("out("ind")="out);
                print out;
            }
            buf1=substr(buf1,RLENGTH+1);
            if((p=match(buf1,"^ *"))==1){
                buf1=substr(buf1,RLENGTH+1);
            }
            curind++;
        }
        else{
            perror("argopts");
            #argopts
            if((p=match(buf1,"^[^\\(]*\\("))==1){
                perror("ind="ind" curind="curind);
                if((p=match(buf1,"^[^\\)]*\\)"))==1){
                    if(curind==ind){
                        out=substr(buf1,RSTART,RLENGTH);
                        perror("out("ind")="out);
                        print out;
                    }
                    buf1=substr(buf1,RLENGTH+1);
                    if((p=match(buf1,"^  *"))==1){
                        buf1=substr(buf1,RLENGTH+1);
                    }
                }
                curind++;
            }
        }
    }
}
