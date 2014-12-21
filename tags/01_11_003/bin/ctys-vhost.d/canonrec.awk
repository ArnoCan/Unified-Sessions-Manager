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
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################
########################################################################
#
#     Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################
#
#In: 
# host:label:id:uuid:mac:vncdisp:cport:sport:vncbase:TCP:sessionType:dist:distrel:os:osrel:verno:serno:category
# 1    2     3  4    5   6       7     8     9       10  11          12   13      14 15    16    17    18
#
#Out:
# host:sessionType:label:id:uuid:mac:tcp:disp:cport:sport:baseport:dist:distrel:os:osrel:verno:serno:category
# 1    2           3     4  5    6   7   8    9     10    11       12   13      14 15    16    17    18
#
########################################################################


function perror(inp){
 if(!d){
   print line ":" inp | "cat 1>&2"
 }
}
function fetchTcpDns(td,mx){
 perror("fetchTcpDns td="td" mx="mx);
 res="";
 if(mx~/^$/){
   perror("missing TcpDns input");
   return;        
 }
 chk=match(mx,"[0-9][^.]*[.][0-9][^.]*[.][0-9][^.]*[.][0-9]*");
 perror("chk:"chk);
 if(td=="d"){
  perror("request=DNS");
 }else{
  if(td=="t"){
   perror("request=TCP");
  }else{
   perror("unknown request="td);
   return;
  }
 }
 if(chk==1&&td=="t"){return mx;}
 if(chk==0&&td=="d"){return mx;}
 else{
  call="x=`host "mx" 2>/dev/null`;[ $? -eq 0 ]&&echo ${x##* }";
  call|getline res;
  close(call); 
  perror("call="call);
  return res;
 }
}
function fetchMacMap(td,mx){
 perror("fetchMacMap td="td" mx="mx);
 res="";
 if(mx~/^$/){
  perror("missing TcpDns input");
  return;
 }
 call=callp"ctys-vhost.sh -C macmaponly -s ";
 if(d>0){
  call=call "-d "d" ";
 }
 if(td=="d"){
  perror("request=DNS");
  call=call "-o d ";
 }else{
  if(td=="t"){
   perror("request=TCP");
   call=call "-o t ";
  }else{
   perror("unknown request="td);
   return;        
  }
 }
 call=call mx ";";
 perror("call="call);
 call|getline res;
 close(call); 
 return res;
}
BEGIN{mx=0;
 perror("Start record with AWK:vhost-canonize.awk");
 perror("arch     ="arch);
 perror("callp    ="callp);
 perror("cat      ="cat);
 perror("cols     ="cols);
 perror("cp       ="cp);
 perror("cstr     ="cstr);
 perror("ctysrel  ="ctysrel);
 perror("d        ="d);
 perror("dist     ="dist);
 perror("distrel  ="distrel);
 perror("dns      ="dns);
 perror("dsp      ="dsp);
 perror("execloc  ="execloc);
 perror("gateway  ="gateway);
 perror("h        ="h);
 perror("hwcap    ="hwcap);
 perror("hwreq    ="hwreq);
 perror("hyrel    ="hyrel);
 perror("i        ="i);
 perror("ifname   ="ifname);
 perror("ip       ="ip);
 perror("l        ="l);
 perror("mac      ="mac);
 perror("mapdb    ="mapdb);
 perror("netmask ="netmask);
 perror("relay   ="relay);
 perror("reloccap="reloccap);
 perror("os       ="os);
 perror("osrel    ="osrel);
 perror("pform    ="pform);
 perror("scap     ="scap);
 perror("ser      ="ser);
 perror("sp       ="sp);
 perror("sreq     ="sreq);
 perror("sshport  ="sshport);
 perror("netname  ="netname);
 perror("t        ="t);
 perror("tcp      ="tcp);
 perror("title    ="title);
 perror("titleidx ="titleidx);
 perror("ustr     ="ustr);
 perror("uu       ="uu);
 perror("vb       ="vb);
 perror("vcpu     ="vcpu);
 perror("ver      ="ver);
 perror("vram     ="vram);
 perror("vstat    ="vstat);
 perror("rsrv1    ="rsrv1);
 perror("rsrv2    ="rsrv2);    
 perror("rsrv3    ="_rsrv3);
 perror("rsrv4    ="rsrv4);
 perror("rsrv5    ="rsrv5);
 perror("rsrv6    ="rsrv6);
 perror("rsrv7    ="rsrv7);
 perror("rsrv8    ="rsrv8);
 perror("rsrv9    ="rsrv9);
 perror("rsrv10   ="rsrv10);
 perror("rsrv11   ="rsrv11);
 perror("rsrv12   ="rsrv12);
 perror("rsrv13   ="rsrv13);
 perror("rsrv14   ="rsrv14);
 perror("rsrv15   ="rsrv15);
 line=0;
}
{line++;perror("RECORD="$0);}


$0~/^$/{exit;}
{
 outbuf="";
 mx=0;
 if(h>0){
  mx=1; 
  if($1!~/^$/){
    tcpaddr="";
    if(dns>1){tcpaddr=fetchTcpDns("d",$1);perror("fetchTcpDns)="$1);}
    else{
      if(tcp>1){tcpaddr=fetchTcpDns("t",$1);perror("fetchTcpDns="$1);}
      else tcpaddr=$1;
    }
  }
  if($1!~/^$/)outbuf=outbuf"ContainingMachine,1,"tcpaddr;
  else tcpaddr=$1;
 }

 if(t>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"SessionType,2,"$2;}
 if(l>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"Label,3,"$3;}
 if(i>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"ID,4,"$4;}
 if(uu>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"UUID,5,"$5;}
 if(mac>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"MAC,6,"$6;}

 tcpaddr="";
 if(dns>1){
   if($7~/^$/&&$6!~/^$/){tcpaddr=fetchMacMap("d",$6);perror("fetchMacMap="tcpaddr);}
   else{tcpaddr=fetchTcpDns("d",$7);perror("fetchTcpDns="$7);}                
 }
 else{
   if(tcp>1){ 
     if($7~/^$/&&$6!~/^$/){tcpaddr=fetchMacMap("t",$6);perror("fetchMacMap="tcpaddr);}
     else{tcpaddr=fetchTcpDns("t",$7);perror("fetchTcpDns="$7);}                
   }else{tcpaddr=$7;}
 }
 if(tcp>0||dns>0){
   if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"TCP,7,"tcpaddr;
 }

 if(dsp>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"DISPLAY,8,"$8;}
 if(cp>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"ClientAccessPort,9,"$9;}
 if(sp>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"ServerAccessPort,10,"$10;}
 if(vb>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"VNCbasePort,11,"$11;}
 if(dist>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"Distro,12,"$12;}
 if(distrel>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"Distrorel,13,"$13;}
 if(os>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"OS,14,"$14;}
 if(osrel>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"OSREL,15,"$15;}
 if(ver>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"VersNo,16,"$16;}
 if(ser>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"SerialNo,17,"$17;}
 if(cat>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"Category,18,"$18;}
 if(vstat>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"VMstate,19,"$19;}
 if(hyrel>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"HypervisorRelease,20,"$20;}
 if(scap>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"StackCapability,21,"$21;}
 if(sreq>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"StackRequirement,22,"$22;}
 if(hwcap>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"HWcapability,23,"$23;}
 if(hwreq>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"HWrequirement,24,"$24;}
 if(execloc>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"ExecLocation,25,"$25;}
 if(reloccap>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"RelocationCapability,26,"$26;}
 if(sshport>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"SSHport,27,"$27;}
 if(netname>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"netname,28,"$28;}
 if(rsrv7>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"rsrv,29,"$29;}
 if(rsrv8>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"rsrv,30,"$30;}
 if(rsrv9>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"rsrv,31,"$31;}
 if(rsrv10>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"rsrv,32,"$32;}
 if(ifname>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"ifname,33,"$33;}
 if(ctysrel>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"CTYSrelease,34,"$34;}
 if(netmask>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"netmask,35,"$35;}
 if(gateway>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"gateway,36,"$36;}
 if(relay>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"relay,37,"$37;}

 if(arch>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"Arch,38,"$38;}
 if(pform>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"Platform,39,"$39;}
 if(vram>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"VRAM,40,"$40;}
 if(vcpu>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"VCPU,41,"$41;}
 if(cstr>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"ContextStg,42,"$42;}
 if(ustr>0){if(mx==1)outbuf=outbuf";";mx=1;outbuf=outbuf"UserStrg,43,"$43;}

 perror("output="outbuf);
 printf("%s\n",outbuf);
}
