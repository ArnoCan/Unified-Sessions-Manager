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

#    output format: "host:label:id:uuid:pid:uid:gid:sessionType:clientServer:JobID"
#                     +    +     +  +    +   +   +       +          +        +

function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

BEGIN{
    line=0;
    ptrace("Start record with AWK:DIGGER-SERVERLST");
}

{
    line++;
    ptrace("input=<"$0">");
}


{
    reslst="";    
    found=0;
    #label
    if($5){
        reslst=$5;
        found=1;  
    }
                     
    if(found!=0){
        #id==lpot-rport
        reslst=reslst";"$4"-"$6;

        #uuid+mac
        reslst=reslst";;";

        #disp
        reslst=reslst";";

        #cport
        reslst=reslst";"$4;

        #sport
        reslst=reslst";"$6;

        #pid+uid+gid
#        reslst=reslst";"$10";"$8";"$9;
        reslst=reslst";"$1";"$8";"$9;

        #sessionType+clientServer
        reslst=reslst";SSH("$2");TUNNEL";

        #tcp
        reslst=reslst";";

        #jobid
        gsub("-",":",$12)
        reslst=reslst";"$12;

        printf("%s ",reslst);
        ptrace("output=<"reslst">");
    }
    found=0;
}
