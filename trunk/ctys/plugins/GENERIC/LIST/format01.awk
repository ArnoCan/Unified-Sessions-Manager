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

#List-Input-Format:
#==================
#
#   format: host:label:id:uuid:mac:disp:cport:sport:pid:uid:gid:sessionType:clientServer
#            1    2     3   4   5   6     7     8    9   10  11      12         13       
#
#   awk -F':' -v h=$_H -v l=$_L -v i=$_I -v p=$_P -v u=$_U -v g=$_G -v t=$_T -v uu=$_UU -v cs=$_S 
#             -v mac=$_MAC -v dsp=$_DSP -v cp=$_CP -v sp=$_SP 

BEGIN{mx=0;
    if(title==1){
        if(h==1)  {                       mx=1; printf("ContainingMachine"); }
        if(t==1)  { if(mx==1)printf(";"); mx=1; printf("SessionType");       }
        if(l==1)  { if(mx==1)printf(";"); mx=1; printf("Label");             }
        if(i==1)  { if(mx==1)printf(";"); mx=1; printf("ID");                }
        if(uu==1) { if(mx==1)printf(";"); mx=1; printf("UUID");              }
        if(mac==1){ if(mx==1)printf(";"); mx=1; printf("MAC");               }
        if(dsp==1){ if(mx==1)printf(";"); mx=1; printf("DISPLAY");           }
        if(cp==1) { if(mx==1)printf(";"); mx=1; printf("ClientAccessPort");  }
        if(sp==1) { if(mx==1)printf(";"); mx=1; printf("ServerAccessPort");  }
        if(p==1)  { if(mx==1)printf(";"); mx=1; printf("PID");               }
        if(u==1)  { if(mx==1)printf(";"); mx=1; printf("UID");               }
        if(g==1)  { if(mx==1)printf(";"); mx=1; printf("GUID");              }
        if(cs==1) { if(mx==1)printf(";"); mx=1; printf("C/S-Type");          }
        printf("\n");
    }    
}

{
    if(h==1)  {                       mx=1; printf("%s", $1); }
    if(t==1)  { if(mx==1)printf(";"); mx=1; printf("%s", $12);}
    if(l==1)  { if(mx==1)printf(";"); mx=1; printf("%s", $2); }
    if(i==1)  { if(mx==1)printf(";"); mx=1; printf("%s", $3); }
    if(uu==1) { if(mx==1)printf(";"); mx=1; printf("%s", $4); }
    if(mac==1){ if(mx==1)printf(";"); mx=1; printf("%s", $5); }
    if(dsp==1){ if(mx==1)printf(";"); mx=1; printf("%s", $6); }
    if(cp==1) { if(mx==1)printf(";"); mx=1; printf("%s", $7); }
    if(sp==1) { if(mx==1)printf(";"); mx=1; printf("%s", $8); }
    if(p==1)  { if(mx==1)printf(";"); mx=1; printf("%s", $9); }
    if(u==1)  { if(mx==1)printf(";"); mx=1; printf("%s", $10);}
    if(g==1)  { if(mx==1)printf(";"); mx=1; printf("%s", $11);}
    if(cs==1) { if(mx==1)printf(";"); mx=1; printf("%s", $13);}
    printf("\n");
}


#
#List-Output-Format:
#===================
#
#  0 - h:    host
#  1 - t:    type
#  2 - l:    label
#  3 - i:    id
#  4 - uu:   uuid
#  5 - mac:  mac
#  6 - dsp:  display
#  7 - cp:   client access port
#  8 - sp:   server access port
#  9 - p:    pid
# 10 - u:    uid
# 11 - g:    gid
# 12 - cs:   client|server
#

