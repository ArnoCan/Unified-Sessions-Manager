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


function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

function fetchTcpDns(td,mx){
    ptrace("fetchTcpDns td="td" mx="mx);
    res="";

    if(mx~/^$/){
        ptrace("missing TcpDns input");
        return;        
    }
    
    chk=match(mx,"[0-9][^.]*[.][0-9][^.]*[.][0-9][^.]*[.][0-9]*");
    ptrace("chk:"chk);
    if(td=="d"){
        ptrace("request=DNS");
    }
    else{
        if(td=="t"){
            ptrace("request=TCP");
        }
        else{
            ptrace("unknown request="td);
            return;
        }
    }

    if(chk==1&&td=="t"){
        return mx;
    }
    
 
    if(chk==0&&td=="d"){
        return mx;
    }
    else{
        call="x=`host "mx" 2>/dev/null`;[ $? -eq 0 ]&&echo ${x##* }";
        call|getline res;
        close(call); 
        ptrace("call="call);
        return res;
    }
}

function fetchMacMap(td,mx){
    ptrace("fetchMacMap td="td" mx="mx);
    res="";

    if(mx~/^$/){
        ptrace("missing TcpDns input");
        return;
    }

    call=callp"ctys-vhost.sh -C macmaponly -s ";
    if(dargs!=""){
        call=call" "dargs" ";
    }
   

    if(td=="d"){
        ptrace("request=DNS");
        call=call "-o d ";
    }
    else{
        if(td=="t"){
            ptrace("request=TCP");
            call=call "-o t ";
        }
        else{
            ptrace("unknown request="td);
            return;        
        }
    }
    call=call mx ";";
    ptrace("call="call);
    call|getline res;
    close(call); 

    return res;
}



#List-Input-Format:
#==================
#
#Input-format: 
# host:label:id:uuid:mac:disp:cport:sport:pid:uid:gid:sessionType:clientServer:TCP:JobID:res0:res1:res2:res3:hrx:acc:arch
# 1    2     3  4    5   6    7     8     9   10  11  12          13           14  15    16   17   18   19   20  21  22
#
#
#List-Output-Format:
#===================
#Output-format: 
# host:sessionType:label:id:uuid:mac:tcp:disp:cport:sport:pid:uid:gid:clientServer:JobID:ifn:res1:cstrg:exep:hrx:acc:arch
# 1    2           3     4  5    6   7   8    9     10    11  12  13  14           15    16  17   18    19   20  21  22
#
#
BEGIN{mx=0;
    ptrace("LIST:canon:Start record with AWK");
    ptrace("listnf="listnf);
    ptrace("jid   ="jid);
    ptrace("d     ="d);
    ptrace("h     ="h);
    ptrace("t     ="t);
    ptrace("l     ="l);
    ptrace("i     ="i);
    ptrace("uu    ="uu);
    ptrace("mac   ="mac);
    ptrace("tcp   ="tcp);
    ptrace("dns   ="dns);
    ptrace("dsp   ="dsp);
    ptrace("cp    ="cp);
    ptrace("sp    ="sp);
    ptrace("p     ="p);
    ptrace("u     ="u);
    ptrace("g     ="g);
    ptrace("cs    ="cs);
    ptrace("res1  ="res1);
    ptrace("cstrg ="cstrg);
    ptrace("exep  ="exep);
    ptrace("hrx   ="hrx);
    ptrace("acc   ="acc);
    ptrace("arch  ="arch);
    ptrace("ifn   ="ifn);

    line=0;
}
{
    line++;
    ptrace("input=<"outbuf">"); 
}
{
  ptrace("RECORD="$0);
}

titleidx==2{
    outbuf="";
    printf("%s\n",outbuf);
    exit;        
}


$0~/^$/{
    exit;
}

{
    #check for internal conversion-errors
    if(NF!=listnf){
        ptrace("Internal plugins-interface:PLUGIN-RECORD-SIZE="NF" != LIST-REQUIRED-NF="listnf);
        ptrace("DROPPED-RECORD=<"$0">");
        next;
    }


    outbuf="";
    mx=0;
    
    if(h>0)  {
        mx=1; 
        if($1!~/^$/){
            tcpaddr="";
            if(dns>1){
                tcpaddr=fetchTcpDns("d",$1);
                ptrace("fetchTcpDns-d0=<"tcpaddr">");
            }
            else{
                if(tcp>1){ 
                    tcpaddr=fetchTcpDns("t",$1);
                    ptrace("fetchTcpDns-t0=<"tcpaddr">"); 
                }
                else tcpaddr=$1;
            }
        }
        if($1!~/^$/) outbuf=outbuf"ContainingMachine,1,"tcpaddr;
    }

    if(t>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SessionType,2,"$12; }
    if(l>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Label,3,"$2; }
    if(i>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ID,4,"$3; }
    if(uu>0) { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UUID,5,"$4; }
    if(mac>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"MAC,6,"$5;  }

    tcpaddr="";
    if(dns>1){
        if($14~/^$/&&$5!~/^$/){
            tcpaddr=fetchMacMap("d",$5);
            ptrace("fetchMacMap-d1=<"tcpaddr">"); 
        }
        else{
            tcpaddr=fetchTcpDns("d",$14);
            ptrace("fetchTcpDns-d1=<"tcpaddr">"); 
        }                
    }
    else{
        if(tcp>1){ 
            if($14~/^$/&&$5!~/^$/){
                tcpaddr=fetchMacMap("t",$5);
                ptrace("fetchMacMap-2=<"tcpaddr">"); 
            }
            else{
                tcpaddr=fetchTcpDns("t",$14);
                ptrace("fetchTcpDns-2=<"tcpaddr">"); 
            }                
        }
        else{            
            tcpaddr=$14;
        }
    }

    if(tcp>0||dns>0){
        if(tcpaddr~/^$/){
            if($14!~/^$/){
                tcpaddr=$14;
            }
        }
        if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"TCP,7,"tcpaddr;
    }

    if(dsp>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"DISPLAY,8,"$6; }
    if(cp>0){  if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ClientAccessPort,9,"$7; }
    if(sp>0){  if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ServerAccessPort,10,"$8; }
    if(p>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"PID,11,"$11; }
    if(u>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UID,12,"$12; }
    if(g>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"GUID,13,"$13; }
    if(cs>0){  if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"C/S-Type,14,"$14; }
    if(jid>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"JobID,15,"$15;   }
    if(ifn>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"IFNAME,16,"$16;  }
    if(res1>0){if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"RESERVED1,17,"$17;  }
    if(cstrg>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"CONTEXTSTRG,18,"$18; }
    if(exep>0){  if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"EXECPATH,19,"$19; }
    if(hrx>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HYPERRELRUN,20,"$20; }
    if(acc>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ACCELLERATOR,21,"$21; }
    if(arch>0){  if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ARCH,22,"$22; }

    ptrace("output=<"outbuf">"); 
    printf("%s\n",outbuf);
}


