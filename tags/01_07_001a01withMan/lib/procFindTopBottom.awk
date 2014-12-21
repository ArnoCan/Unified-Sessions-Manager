########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a04
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


#
#REMARK:
#  YES, quick and (maybe not so)dirty!
#
#  BUT, works on any supported platform, almost.
#
#  Needs some rework when having some time to spend.
#  Current version supports "ctys" processes only, imported subcalls are
#  not handled quite well, but anyhow, works sufficiently well, until now.
#
#  -> FIRST: Sometimes additional temporary processes are detected.
#            For now eliminated by "robust" post-processing.
#
#

#
#
#CALL:l
#
#  awk -v d=0 -v call=ctys -v bottomlabel='X11' -v toplabel='XEN' -f ...
#
#EXAMPLE:
#
#  ps -ef|grep -v grep|grep -v awk|grep -v ps|awk -v d=0 -v call=ctys -v bottomlabel='X11' -v toplabel='XEN' -f ...
#

function perror(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}
   
BEGIN{
    perror("AWK:procFindTopBottom");
    perror("call="call);
    gsub("%","|",call);
    perror("call="call);
    
    perror("toplabel="toplabel);
    gsub("%","|",toplabel);
    perror("toplabel="toplabel);

    perror("bottomlabel="bottomlabel);
    gsub("%","|",bottomlabel);
    perror("bottomlabel="bottomlabel);


    perror("exclusive="exclusive);
    if(exclusive!=""){
        gsub("%","|",exclusive);
        perror("exclusive="exclusive);

        perror("include-cleared="include);
        include="";
    }else{
        perror("include="include);
        gsub("%","|",include);
        perror("include="include);

    }
    perror("exclude="exclude);
    gsub("%","|",exclude);
    perror("exclude="exclude);
    
    idx=1;
    subsys[1]="";
    pid[1]="";
    ppid[1]="";
    topnodes[1]="";
    bottomnodes[1]="";
    hasbottomnodes[1]="";
    hastopnodes[1]="";

    excludematch=0;
    excludebranch[1]="";

    includematch=0;
    includebranch[1]="";

    outidx=1;    
    outlst[1]="";
    outlstsrc[1]="";
    outlstkeep[1]="";

    recursioncounter=0;
    line=0;    
}

#topmost in present list
function resolveTop(){
    perror("\n--------------------------");
    perror("resolveTop");
    perror("recursioncounter="recursioncounter);
    perror("--------------------------");

    #find top nodes store idx, replace ppid of trial
    for(i0=1;i0<idx;i0++){
        trial=topnodes[i0];
        perror("trial("i0")="trial);
        for(i1=1;i1<idx;i1++){
            if(ppid[trial]==pid[i1]){
                topnodes[i0]=i1;
                continue;
            }
        }
    }
    if(recursioncounter<idx){
        if(!d){
            for(i=1;i<idx;i++){
                perror("result-top("i")="topnodes[i]" "subsys[i]" "pid[i]" "ppid[i]);
            }
        }
        recursioncounter++;       
        resolveTop();        
    }
}

#bottom layer in present list
function resolveBottom(){
    perror("\n--------------------------");
    perror("resolveBottom");
    perror("recursioncounter="recursioncounter);
    perror("--------------------------");
        
    #find bottom nodes: store idx
    for(i0=1;i0<idx;i0++){
        trial=bottomnodes[i0];
        perror("trial("i0")="trial);
        if(trial!=0){            
            for(i1=1;i1<idx;i1++){
                if(ppid[i1]==pid[trial]){
                    bottomnodes[i0]=i1;
                    hasbottomnodes[i0]=1;
                    hastopnodes[i1]=1;
                    continue;
                }
            }
        }        
    }
    if(recursioncounter<idx){
        if(!d){
            for(i=1;i<idx;i++){
                perror("result-bottom("i")="bottomnodes[i]" "subsys[i]" "pid[i]" "ppid[i]);
            }
        }
        recursioncounter++;       
        resolveBottom();        
    }
}

#bottom layer in present list
function checkChilds(cidx){
    startpid=pid[cidx];
    curpid=pid[cidx];
    found=0;
    
    perror("start pid["cidx"]="startpid"  bottomlabel="bottomlabel);

    #find successors

    #maxrounds - for grandchilds
    for(i0=1;i0<idx;i0++){

        #maxtrials - for childs
        for(i1=1;i1<idx;i1++){
            if(curpid==ppid[i1]){
                perror("successor of ppid["i1"]="curpid"  pid["i1"]="pid[i1]);
                curpid=pid[i1];
                if(include!=""&&includebranch[i1]==0){
                    continue;
                }
                if(excludebranch[i]==1){
                    continue;
                }
                if(subsys[i1]==bottomlabel){
                    perror("match:subsys["i1"]="subsys[i1]"=="bottomlabel);
                    found=i1;
                }
                break;
            }
        }
        if(i1==idx){
            break;
        }
    }
    if(found==0){
        perror("start pid["cidx"]="startpid" => checkChilds=0");
        return 0;
    }
    perror("start pid["cidx"]="startpid" => checkChilds="found);
    return found;
}


{
    line++;
    perror("current-record=<"$0">");
}

include!=""&&$0~include{
    includematch=1;
    excludematch=0;
    perror("include("line")");
}
include!=""&&$0!~include{
    includematch=0;
    excludematch=0;
    perror("non-include("line")");
}

exclusive!=""&&$0~exclusive{
    perror("exclusive("line")");
    includematch=2;
    excludematch=0;
}

exclusive!=""&&$0!~exclusive{
    perror("non-exclusive("line")");
    includematch=0;
    excludematch=1;
}

exclude!=""{
    x=$0;
    n=gsub(exclude,"",x);
    perror("n="n);
    perror("x="x);
    if(n!=0){        
        excludematch=1;
        includematch=0;
        perror("exclude("line")");
    }else{
        excludematch=0;
        if(includematch!=1)includematch=1;
        perror("non-exclude("line")");
    }
}


(($0~call)&&toplabel!~/^$/&&$0~toplabel){
    subsys[idx]=toplabel;
    pid[idx]=$2;
    ppid[idx]=$3;
    excludebranch[idx]=excludematch;
    includebranch[idx]=includematch;
    perror("match-top("idx"-"excludebranch[idx]"-"includebranch[idx]"):"toplabel":"$2":"$3);
    perror($0);   
    idx++;
}

toplabel==bottomlabel{
    next;
}

(($0~call)&&bottomlabel!~/^$/&&$0~bottomlabel){
    subsys[idx]=bottomlabel;
    pid[idx]=$2;
    ppid[idx]=$3;
    excludebranch[idx]=excludematch;
    includebranch[idx]=includematch;
    perror("match-bot("idx"-"excludebranch[idx]"-"includebranch[idx]"):"bottomlabel":"$2":"$3);

    perror($0);
    
    idx++;
}

includematch==1||(($0~call)&&$0!~bottomlabel&&$0!~toplabel){
    if($3==1){next;}
    if(includematch==1){subsys[idx]=include;}
    else{subsys[idx]="INTERMEDIATE";}
    pid[idx]=$2;
    ppid[idx]=$3;
    excludebranch[idx]=excludematch;
    includebranch[idx]=includematch;
    perror("match-int("idx"-"excludebranch[idx]"-"includebranch[idx]"):INTERMEDIATE:"$2":"$3);
    perror($0);   
    idx++;
}



END{
    for(i=1;i<idx;i++){
        topnodes[i]=i;
        bottomnodes[i]=i;
    }

    recursioncounter=0;
    resolveTop();

    recursioncounter=0;
    resolveBottom();

    if(!d){
        perror("top("i":t-b-i-e)");
        for(i=1;i<idx;i++){
            perror("top("i":"hastopnodes[i]"-"hasbottomnodes[i]"-"includebranch[i]"-"excludebranch[i]")="topnodes[i]" "subsys[i]" "pid[i]" "ppid[i]);
        }
    }
    if(!d){
        for(i=1;i<idx;i++){
            perror("bottom("i")="bottomnodes[i]" "subsys[i]" "pid[i]" "ppid[i]);
        }
    }

    perror("-------------------------------------");
    perror("assign bottoms to tops");
    perror("-------------------------------------");
    #assign bottoms to tops
    for(i=1;i<idx;i++){
        mySuccessor=-1;
        if(excludebranch[i]==1){
            perror("outlstkeep["outidx"]=0(excludebranch["i"])");
            if(outlstkeep[outidx]!=1)outlstkeep[outidx]=0;
        }
        if(include!=""&&includebranch[i]==0){
            mySuccessor=checkChilds(i);

            perror("mySuccessor="mySuccessor);
                
            if(mySuccessor==0){
                perror("outlstkeep["outidx"]=0(includebranch["i"])");
                if(outlstkeep[outidx]!=1)outlstkeep[outidx]=0;
            }else{
                perror("outlstkeep["outidx"]=1(mySuccessor="mySuccessor")");                    
                outlstkeep[outidx]=1;
            }
        }

##########
#4test    #
##########
#             perror("###############-----------------------------------------");
#             perror("hastopnodes[topnodes["i"]]="hastopnodes[topnodes[i]]);
#             perror("hasbottomnodes["i"]="hasbottomnodes[i]);
#             perror("toplabel="toplabel);
#             perror("subsys[topnodes["i"]]="subsys[topnodes[i]]);
#             perror("bottomlabel="bottomlabel);
#             perror("subsys["i"]="subsys[i]);
#             perror("###############-----------------------------------------");
#             perror("mySuccessor="mySuccessor);
#             perror("###############-----------------------------------------");
##########
        #4test  #
##########


        if(hasbottomnodes[i]==1){
            if(mySuccessor==-1){
                mySuccessor=checkChilds(i);
            }
        }else{
            mySuccessor=0;
        }
        
        if((subsys[topnodes[i]]==toplabel&&subsys[i]==bottomlabel)&&(hastopnodes[topnodes[i]]!=1||ppid[i]==1)&&mySuccessor==0){
            outlst[outidx]=subsys[topnodes[i]]":"pid[topnodes[i]]":"subsys[i]":"pid[i];
            outlstsrc[outidx]=topnodes[i];
            perror("inserted("outidx"("i")):outlst["outidx"]("outlstsrc[outidx]"-"outlstkeep[outidx]")="outlst[outidx]);
            if(includebranch[topnodes[i]]!=0||includebranch[i]!=0){
                if(exclusive!=""){
                    if(includebranch[topnodes[i]]!=2||includebranch[i]!=2){
                        outlstkeep[outidx]=1;
                    }else{
                        outlstkeep[outidx]=0;
                    }
                }else{
                    outlstkeep[outidx]=1;
                }
            }else{
                outlstkeep[outidx]=0;
            }
            outidx++;
        }else{
            perror("dropped-label("i"):outlst["outidx"]="subsys[topnodes[i]]":"pid[topnodes[i]]":"subsys[i]":"pid[i]);
            if(outlstkeep[outidx]!=1)outlstkeep[outidx]=0;
            continue;
        }            
    }

    perror("-------------------------------------");
    for(i=1;i<outidx;i++){
        perror("task("i")<b:"excludebranch[i]"-w:"includebranch[i]">:outlst["i"]("outlstsrc[i]"-"outlstkeep[i]")="outlst[i]);
    }

    #Yes, suboptimal, anyhow, can tune later!
    #format: t1x=top-subsys:t2x=top-pid:t3x=bot-subsys:t4x=bot-pid
    #For now:assume multiple entries can only result from check-job itself.
    #Identify them by top+bottom-pid-equality.
    perror("-------------------------------------");
    perror("Check Redundancy("outidx")");
    perror("-------------------------------------");
    for(i=1;i<=outidx;i++){
        if(outlst[i]=="")continue;
        perror("Check Redundancy("i"):outlst["i"]("outlstsrc[i]")="outlst[i]);

        #top-pid         
        x=match(outlst[i],"[^:]*:");lx1=RLENGTH;
        x=match(outlst[i],"[^:]*:[^:]*:");lx2=RLENGTH;
        x=match(outlst[i],"[^:]*:[^:]*:[^:]*:");lx3=RLENGTH;

        t20=substr(outlst[i],lx1+1,lx2-1-lx1);
        perror("t20="t20);

        #bottom-pid         
        t40=substr(outlst[i],lx3+1);
        perror("t40="t40);
        perror("excludebranch["i"]="excludebranch[i]"  includebranch["i"]="includebranch[i]"  outlstkeep["i"]="outlstkeep[i]);
        if(excludebranch[i]==0||includebranch[i]!=0)outlstkeep[i]=1;

        #check remaining
        for(j=i+1;j<=outidx;j++){
            if(j==i)continue;
            if(outlst[j]=="")continue;

            x=match(outlst[j],"[^:]*:");lx1=RLENGTH;
            x=match(outlst[j],"[^:]*:[^:]*:");lx2=RLENGTH;
            x=match(outlst[j],"[^:]*:[^:]*:[^:]*:");lx3=RLENGTH;

            #top-pid
            t21=substr(outlst[j],lx1+1,lx2-1-lx1);
            perror("t21="t21);

            #bottom-pid         
            t41=substr(outlst[j],lx3+1);
            perror("t41="t41);

            if(t20==t21){
                perror("top-pid matched("i"):outlst["i"]="outlst[i]);
                if(t20==t40){
                    perror("t20==t40:sigleton matched("i"):"t20);
                    if(t21==t41){
                        perror("t21==t41:second node removed, now keep first as top("i"):outlst["i"]="outlst[i]);
                        outlst[j]="";
                        outlstkeep[j]=0;
                        if(excludebranch[i]==0){
                            outlstkeep[i]=1;
                        }
                    }else{                   
                        perror("t21!=t41:first node removed, now keep second as top("j"):outlst["j"]="outlst[j]);
                        outlst[i]="";                    
                        outlstkeep[i]=0;
                        if(excludebranch[j]==0){
                            outlstkeep[j]=1;
                        }
                    }
                }else{
                    if(t40==t41){
                        perror("t40==t41:bottom-pid matched("i"):outlst["i"]("outlstsrc[i]")="outlst[i]);
                        perror("but both are self-contained top-nodes, decide to:");
                        perror("  -> Keep  first["i"]: "outlst[i]);
                        perror("  -> Clear second["j"]:"outlst[j]);
                        outlst[j]="";
                        outlstkeep[j]=0;
                        if(excludebranch[i]==0){
                            outlstkeep[i]=1;
                        }
                    }else{
                        perror("t40!=t41:independent => keep both("i")");
                    }
                }
            }            
        }
        #first clear all actually resulting nodes to be dropped, THAN proceed
        if(outlstkeep[i]==0){
            perror("!keep("i")");
            outlst[i]="";
        }
    }
    #now check for an included sub-branch of multiple remaining branches
    for(i=1;i<outidx;i++){
        if(outlst[i]!=""&&include!=""&&outlstkeep[i]!=1){
            perror("dropped("i"):outlst["i"]("outlstsrc[i]")="outlst[i]);
            outlst[i]="";
        }
    }
    #ufff..., the resulting list
    for(i=1;i<outidx;i++){
        if(outlst[i]!=""){
            perror("remaining task("i"):outlst["i"]("outlstsrc[i]")="outlst[i]);
            print outlst[i];            
        }
    }
    #still some threads remaining, but seems to be sufficient for now
}
