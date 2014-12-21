########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a13
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

function addIfDat() {
    if(getif==2||s=="WITHMAC"||s=="ALL"){
        if(curmac!~/^$/){
            if(f=="CONFIG"){
                iflst=iflst" "curmac"="curip"%"curmask"%"curname;
            }else{
                iflst=iflst" "curmac"="curip;
            }
        }
    }
    curmac="";
    curip="";
    curmask="";
    curname="";
    getif=0;    
}

BEGIN{
    getif=0;
    iflst="";
    ptrace("netGetIFlst");
    ptrace("scope =<"s">");
    ptrace("format=<"f">");
}

{ptrace("display:"$0);}

/Link encap:Ethernet/||/Proto.*:Ethernet/{
    #test for now, IF without IP, mainly for protocol analysers, and WoL-Only-IFs
    if(getif!=0){
        addIfDat();
    }

    #not a bridged if of Xen
    if($NF!="FE:FF:FF:FF:FF:FF"){ 
        getif=1;
        curmac=$NF
        curname=$1;
        ptrace("Set:"$1);
    }else{        
        ptrace("Ignored:"$1);
    }
    next;
}

/Link encap:[^E]/||/Proto[ck]o[l]+:[^E]/{
    #avoid local, and for now any except Ethernet
    getif=0;
    ptrace("Ignored:"$1);
    next;
}

/inet /{
    if(getif==1){
        getif=2;
        gsub("[^:]*:","",$2);
        curip=$2;
        ptrace("Fetch:"curip);
        if(s=="WITHIP"&&curip~/^$/){
            ptrace("Ignored:"$2);
            getif=0;            
        }        
        gsub("[^:]*:","",$3);
        curbcst=$3;
        ptrace("Fetch:"curbcst);
        if(s=="WITHIP"&&curbcst~/^$/){
            ptrace("Ignored:"$3);
        }        
        gsub("[^:]*:","",$4);
        curmask=$4;
        ptrace("Fetch:"curmask);
        if(s=="WITHIP"&&curmask~/^$/){
            ptrace("Ignored:"$4);
        }        
    }
    next;
}

getif==2{
    addIfDat();
}

END{
    print iflst;
}
