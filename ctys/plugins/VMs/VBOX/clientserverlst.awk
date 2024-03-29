########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011alpha
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
    
    ptrace("mode"mode);
    if(mode==0){ ptrace("Start record with AWK:VBOX:CLIENTLST");}
    else{ ptrace("Start record with AWK:VBOX:SERVERLST");}

    ptrace("_c1=\"" _c1 "\"");
    ptrace("_c2=\"" _c2 "\"");
    ptrace("_c3=\"" _c3 "\"");
}

{
    line++;
    ptrace("input=<"$0">");
}

{
    curEntry="";
    colnum=split($8,colsA,";");

    ptrace("LABEL="colsA[2]);
    curEntry=colsA[2]";";
    curEntry=curEntry""colsA[1]";";

    #uuid
    if(colsA[3]!~/^$/){
        curEntry=curEntry""colsA[3]";";
        ptrace("UUID="colsA[3]);
    }else{
        curEntry=curEntry";";               
    }

    #mac
    if(colsA[5]!~/^$/){
        ptrace("MAC-raw="colsA[5]);
        z=gsub(":",":",colsA[5]);
        if(z==0){
            new=substr(colsA[5],1,2);
            new=new":"substr(colsA[5],3,2);
            new=new":"substr(colsA[5],5,2);
            new=new":"substr(colsA[5],7,2);
            new=new":"substr(colsA[5],9,2);
            new=new":"substr(colsA[5],11,2);
            curEntry=curEntry""new";";
            ptrace("MAC-ethernetX.address="new);
        }else{
            curEntry=curEntry""colsA[5]";";
            ptrace("MAC="colsA[5]);            
        }
    }else{
        curEntry=curEntry";";               
    }

    #display    
    curEntry=curEntry";";               

    #cport - proprietary and VNC -> could vary for each!!!
    if(colsA[4]!~/^$/){
        curEntry=curEntry""colsA[4]";";
        ptrace("CPORT="colsA[4]);
    }else{
        curEntry=curEntry";";               
    }

    #sport;pid;uid;
    curEntry=curEntry";"$2";"$1";";
    ptrace("pid="$2);
    ptrace("uid="$1);
    if($1!~/^$/){
        call="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"" " 2>/dev/null";
        ptrace(call);
        x1="";    
        call|getline x1;
        close(call);
        curEntry=curEntry""x1";";
        ptrace("gid="x1);

    }else{
        curEntry=curEntry";";
    }

    curEntry=curEntry"VBOX;";

    if(mode==0){curEntry=curEntry"CLIENT;";}
    else{curEntry=curEntry"SERVER;";}
    
    j=$0;
    jm=gsub("^.* -j *","",j);
    if(jm!=0){
        gsub(" .*$","",j);
        curEntry=curEntry""j";";
        ptrace("jobid="j);        
    }else{
        ptrace("jobid=");
        curEntry=curEntry";";
    }

    #hwvirtex
    if(colsA[6]!~/^$/){
        curEntry=curEntry""colsA[6]";";
        ptrace("hwvirtex="colsA[6]);
    }else{
        curEntry=curEntry";";               
    }

    #exepath
    if(colsA[8]!~/^$/){
        curEntry=curEntry""colsA[9]";";
        ptrace("exepath="colsA[9]);
        ptrace("curEntry="curEntry);
    }else{
        curEntry=curEntry";";               
    }

    #arch
    if(colsA[7]!~/^$/){
        curEntry=curEntry""colsA[7]";";
        ptrace("exepath="colsA[7]);
    }else{
        curEntry=curEntry";";               
    }

    #ifnumber
    if(colsA[9]!~/^$/){
        curEntry=curEntry""colsA[8];
        ptrace("ifnumber="colsA[8]);
#     }else{
#         curEntry=curEntry";";               
    }

    ptrace("output=<"curEntry">")
    printf("%s ", curEntry);
    found=0;
}


############################################################################
############################################################################
############################################################################
############################################################################

# function ptrace(inp){
#     if(!d){
#         print line ":" inp | "cat 1>&2"
#     }
# }

# BEGIN{
#     line=0;
#     ptrace("Start record with AWK:VBOX:CLIENTLST");
#     ptrace("_c1=\"" _c1 "\"");
#     ptrace("_c2=\"" _c2 "\"");
# }

# {
#     line++;
# }

# {
#     ptrace("input=\"" $0 "\"");

#     curEntry="";
#     colnum=split($8,colsA,";");

#     ptrace("LABEL="colsA[2]);
#     curEntry=colsA[2]";";
#     curEntry=curEntry""colsA[1]";";

#     #uuid
#     if(colsA[3]!~/^$/){
#         curEntry=curEntry""colsA[3]";";
#         ptrace("UUID="colsA[3]);
#     }else{
#         curEntry=curEntry";";               
#     }

#     #mac
#     if(colsA[5]!~/^$/){
#         ptrace("MAC-raw="colsA[5]);
#         z=gsub(":",":",colsA[5]);
#         if(z==0){
#             new=substr(colsA[5],1,2);
#             new=new":"substr(colsA[5],3,2);
#             new=new":"substr(colsA[5],5,2);
#             new=new":"substr(colsA[5],7,2);
#             new=new":"substr(colsA[5],9,2);
#             new=new":"substr(colsA[5],11,2);
#             curEntry=curEntry""new";";
#             ptrace("MAC-ethernetX.address="new);
#         }else{
#             curEntry=curEntry""colsA[5]";";
#             ptrace("MAC="colsA[5]);            
#         }
#     }else{
#         curEntry=curEntry";";               
#     }

#     #display    
#     curEntry=curEntry";";               

#     #cport - proprietary and VNC -> could vary for each!!!
#     if(colsA[4]!~/^$/){
#         curEntry=curEntry""colsA[4]";";
#         ptrace("CPORT="colsA[4]);
#     }else{
#         curEntry=curEntry";";               
#     }

#     #sport;pid;uid;
#     curEntry=curEntry";"$2";"$1";";
#     ptrace("pid="$2);
#     ptrace("uid="$1);
#     if($1!~/^$/){
#         call="id " $1 "|sed -n \"s/.*gid=[0-9]*(\\([^)]*\\)).*/\\1/p\"" " 2>/dev/null";
#         ptrace(call);
#         x1="";    
#         call|getline x1;
#         close(call);
#         curEntry=curEntry""x1";";
#         ptrace("gid="x1);
#     }else{
#         curEntry=curEntry";";
#     }

#     curEntry=curEntry"VBOX;";
#     curEntry=curEntry"CLIENT;";
#     j=$0;
#     jm=gsub("^.* -j *","",j);
#     if(jm!=0){
#         gsub(" .*$","",j);
#         curEntry=curEntry""j";";
#         ptrace("jobid="j);        
#     }else{
#         ptrace("jobid=");
#         curEntry=curEntry";";
#     }

#     #hwvirtex
#     if(colsA[6]!~/^$/){
#         curEntry=curEntry""colsA[6]";";
#         ptrace("hwvirtex="colsA[6]);
#     }else{
#         curEntry=curEntry";";               
#     }

#     #exepath
#     if(colsA[8]!~/^$/){
#         curEntry=curEntry""colsA[8]";";
#         ptrace("exepath="colsA[8]);
#     }else{
#         curEntry=curEntry";";               
#     }

#     #arch
#     if(colsA[7]!~/^$/){
#         curEntry=curEntry""colsA[7]";";
#         ptrace("exepath="colsA[7]);
#     }else{
#         curEntry=curEntry";";               
#     }

#     #ifnumber
#     if(colsA[9]!~/^$/){
#         curEntry=curEntry""colsA[9];
#         ptrace("ifnumber="colsA[9]);
# #     }else{
# #         curEntry=curEntry";";               
#     }

#     ptrace("output=<"curEntry">")
#     printf("%s ", curEntry);
#     found=0;
# }

