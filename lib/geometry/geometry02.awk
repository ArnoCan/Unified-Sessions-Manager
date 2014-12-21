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
    xsize=-1;
    ysize=-1;
    xoffs=-1;
    yoffs=-1;
    xscreen=-1;
    yscreen=-1;
    label=""
    line=0;
    error="";
    perror("************");
    perror("d=  " d);
    perror("0=  " $0);
}

{
    line++;
}

function splitSize(sinp){
    n=split(sinp,sparts,"x");
    if(n==2){
        #xsize+ysize
        if(sparts[1]!~/^$/)xsize=sparts[1];
        if(sparts[2]!~/^$/)ysize=sparts[2];
    }else{
        if(n==1){
            #xsize
            if(sparts[1]!~/^$/)xsize=sparts[1];
        }else{
            #oops!?
        }
    }
}


function splitXorg(inp){
    n=split(inp,parts,"+");
    if(n==3){
        #size+xoffset+yoffset
        splitSize(parts[1]);
        if(parts[2]!~/^$/)xoffs=parts[2];
        if(parts[3]!~/^$/)yoffs=parts[3];
    }else{
        if(n==2){
            #size+xoffset
            splitSize(parts[1]);
            if(parts[2]!~/^$/)xoffs=parts[2];
        }else{
            if(n==1){
                #xsize
                splitSize(parts[1]);
            }else{
                #oops!?
            }
        }
    }
    perror("----------");
    perror("xsize=" xsize);
    perror("ysize=" ysize);
    perror("xoffs=" xoffs);
    perror("yoffs=" yoffs);
    perror("----------");
}

function splitExpansion (inp){
    n=split(inp,parts," ");
    if(n>=3){
        perror("inp=" inp);
        if(parts[1]!~/^$/)label=parts[1];
        if(parts[2]!~/^$/)xscreen=parts[2];
        if(parts[3]!~/^$/)yscreen=parts[3];

        if(xoffs==-1)xoffs=xscreen;else xoffs+=xscreen;
        if(yoffs==-1)yoffs=yscreen; else yoffs+=yscreen;
    }else{
        #oops!?
    }
    perror("----------");
    perror("label= "  label);
    perror("xscreen=" xscreen);
    perror("yscreen=" yscreen);
    perror("xsize=" xsize);
    perror("ysize=" ysize);
    perror("xoffs=" xoffs);
    perror("yoffs=" yoffs);
    perror("----------");
}


#<geometry> - Xorg only
NF>=1{
    perror("1-<geometry>");
    splitXorg($1);
}


#<geometry>:<ScreenIndex>
NF==2&&$2~/^[0-9]*$/{
    perror("2a-<geometry>:<ScreenIndex>");
    cli="getScreenOffset " d " \"\" \"\" " $2 " " xorgconf;
    perror("cli=" cli);
    cli|getline x;
    perror("x=" x);
    splitExpansion(x);
}
  
#<geometry>:<ScreenSection>
NF==2&&$2~/^.*[a-zA-Z].*$/{
    perror("2b-<geometry>:<ScreenSection>");
    cli="getScreenOffset " d " \"\" \"" $2 "\" -1 " xorgconf;
    perror("cli=" cli);
    cli|getline x;
    perror("x=" x);
    if(x~/^$/){
        error="ERROR:missing value for parameters:\n";
        error=error"ERROR: ->"xorgconf"\n";
        error=error"ERROR: ->geometry:"d"  ScreenSection:"$2"\n";
#        error="ERROR:Parameters my be faulty, check matching of labels!!!\n";
        exit 1;
    }
    splitExpansion(x);
}


#<geometry>:<ScreenIndex>:<ServerLayout>
NF==3&&$2~/^[0-9]*$/{
    perror("3a-<geometry>:<ScreenIndex>:<ServerLayout>");
    cli="getScreenOffset " d " \"" $3 "\" \"\" " $2 " " xorgconf;
    perror("cli=" cli);
    cli|getline x;
    perror("x=" x);
    splitExpansion(x);
}
  

#<geometry>:<ScreenSection>:<ServerLayout>
NF==3&&$3~/^.*[a-zA-Z].*$/{
    perror("3b-<geometry>:<ScreenSection>:<ServerLayout>");
    cli="getScreenOffset " d " \"" $3 "\" \"" $2 "\" -1 " xorgconf;
    perror("cli=" cli);
    cli|getline x;
    perror("x=" x);
    if(x~/^$/){
        error="ERROR:missing value for parameters:\n";
        error=error"ERROR: ->"xorgconf"\n";
        error=error"ERROR: ->geometry:"d"  ScreenSection:"$3"  ServerLayout:"$2"\n";
        exit 1;
    }
    splitExpansion(x);
}


#       <geometry>[:[<ScreenSection>|<ScreenIndex>][:[ServerLayout]:[Workspace]]]

END{
    if(error~/^$/){
        if(xsize!=-1)printf("%d",xsize);
        if(ysize!=-1)printf("x%d",ysize);
        if(xoffs!=-1){
            printf("+%d",xoffs);
            if(yoffs!=-1)printf("+%d",yoffs);
        }
    }else{
        printf("%s",error);
    }
    printf("\n");
}
