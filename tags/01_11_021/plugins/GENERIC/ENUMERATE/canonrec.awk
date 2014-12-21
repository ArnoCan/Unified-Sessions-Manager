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


function pinfo(inp){
      if(info){
          print "INFO:" line ":" info ":" inp | "cat 1>&2"
      }
}
function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}
function perror(inp){
    print line ":ERROR:" inp | "cat 1>&2"
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


#Enumerate-Input-Format:
# host:label:id:uuid:mac:vncdisp:cport:sport:vncbase:TCP:sessionType:dist:distrel:os:osrel:verno:serno:category
# 1    2     3  4    5   6       7     8     9       10  11          12   13      14 15    16    17    18
#
#Enumerate-Output-Format:
# host:sessionType:label:id:uuid:mac:tcp:disp:cport:sport:baseport:dist:distrel:os:osrel:verno:serno:category
# 1    2           3     4  5    6   7   8    9     10    11       12   13      14 15    16    17    18
BEGIN{mx=0;
#    d=0;
    
    ptrace("ENUMERATE:canon:Start record with AWK");
    ptrace("title      ="title);
    ptrace("titleidx   ="titleidx);

    ptrace("mstat      ="mstat);
    ptrace("enumnf     ="enumnf);

    ptrace("h          ="h);
    ptrace("vb         ="vb);
    ptrace("ip         ="ip);
    ptrace("defcon     ="defcon);
    ptrace("defhosts   ="defhosts);
    ptrace("dist       ="dist);
    ptrace("distrel    ="distrel);
    ptrace("os         ="os);
    ptrace("osrel      ="osrel);
    ptrace("ver        ="ver);
    ptrace("ser        ="ser);
    ptrace("cat        ="cat);
    ptrace("mapdb      ="mapdb);
    ptrace("l          ="l);
    ptrace("i          ="i);
    ptrace("tcp        ="tcp);
    ptrace("dns        ="dns);
    ptrace("t          ="t);
    ptrace("uu         ="uu);
    ptrace("mac        ="mac);
    ptrace("dsp        ="dsp);
    ptrace("cp         ="cp);
    ptrace("sp         ="cp);
    ptrace("d          ="d);
    ptrace("callp      ="callp);
    ptrace("cols       ="cols);
    ptrace("vmstate    ="vmstate);
    ptrace("hyperrel   ="hyperrel);
    ptrace("stackcap   ="stackcap);
    ptrace("stackreq   ="stackreq);
    ptrace("arch       ="arch);
    ptrace("platform   ="platform);
    ptrace("vram       ="vram);
    ptrace("vcpu       ="vcpu);
    ptrace("contextstrg="contextstrg);
    ptrace("userstr    ="userstr);
    ptrace("sshport    ="sshport);    
    ptrace("netname    ="netname);    
    ptrace("hwcap      ="hwcap);
    ptrace("hwreq      ="hwreq);
    ptrace("execloc    ="execloc);
    ptrace("reloccap   ="reloccap);
    ptrace("sshport    ="sshport);
    ptrace("ifname     ="ifname);
    ptrace("ctysrel    ="ctysrel);
    ptrace("netmask    ="netmask);
    ptrace("gateway    ="gateway);
    ptrace("relay      ="relay);

    ptrace("uid        ="uid);
    ptrace("gid        ="gid);

    ptrace("exep       ="exep);
    ptrace("acc        ="acc);
    ptrace("hrx        ="hrx);

    line=0;
}
{
    line++;
#    ptrace("RECORD="$0);
}


$0~/^$/||!($19~mstat){
    ptrace("DROPPED="$19" "$4);
    pinfo("DROPPED:VMSTATE="$19":"$0);
    exit;
}

{
    #check for internal conversion-errors
    if(NF!=enumnf){
        perror("Internal plugins-interface:PLUGIN-RECORD-SIZE="NF" != ENUMERATE-REQUIERED-NF="enumnf);
        perror("DROPPED-RECORD=<"$0">");
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
                ptrace("fetchTcpDns)="$1);
            }
            else{
                if(tcp>1){ 
                    tcpaddr=fetchTcpDns("t",$1);
                    ptrace("fetchTcpDns="$1); 
                }
                else tcpaddr=$1;
            }
        }
        if($1!~/^$/){
            outbuf=outbuf"ContainingMachine,1,"tcpaddr;
        }
        
        else tcpaddr=$1;
    }

    if(t>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SessionType,2,"$11;    }
    if(l>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Label,3,"$2;  }
    if(i>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ID,4,"$3;   }
    if(uu>0) { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UUID,5,"$4;  }
    if(mac>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"MAC,6,"$5;  }

    tcpaddr="";
    if(dns>1){
        if($9~/^$/&&$5!~/^$/){
            tcpaddr=fetchMacMap("d",$5);
            ptrace("fetchMacMap="tcpaddr); 
        }
        else{
            tcpaddr=fetchTcpDns("d",$10);
            ptrace("fetchTcpDns="$10); 
        }                
    }
    else{
        if(tcp>1){ 
            if($10~/^$/&&$5!~/^$/){
                tcpaddr=fetchMacMap("t",$5);
                ptrace("fetchMacMap="tcpaddr); 
            }
            else{
                tcpaddr=fetchTcpDns("t",$10);
                ptrace("fetchTcpDns="$10); 
            }                
        }
        else{            
            tcpaddr=$10;
        }
    }
    if(tcp>0||dns>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"TCP,7,"tcpaddr;  }
    if(dsp>0){  if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"DISPLAY,8,"$6;   }
    if(cp>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ClientAccessPort,9,"$7;  }
    if(sport>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ServerAccessPort,10,";$8;  }
    if(vb>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VNCbasePort,11,"$9; }
    if(dist>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distro,12,"$12; }
    if(distrel>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distrorel,13,"$13; }
    if(os>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OS,14,"$14; }
    if(osrel>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OSREL,15,"$15; }
    if(ver>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VersNo,16,"$16; }
    if(ser>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SerialNo,17,"$17; }
    if(cat>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Category,18,"$18; }
    if(vmstate>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VMstate,19,"$19; }
    if(hyperrel>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"hyperrel,20,"$20; }
    if(stackcap>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackCap,21,"$21; }
    if(stackreq>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackReq,22,"$22; }
    if(hwcap>0){   if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWCAP,23,"$23; }
    if(hwreq>0)      {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWREQ,24,"$24; }
    if(execloc>0)    {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ExecLocation,25,"$25; }
    if(reloccap>0)   {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"RelocationCapacity,26,"$26; }
    if(sshport>0)    {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SSHport,27,"$27; }
    if(netname>0)    {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Netname,28,"$28; }
    if(hrx>0)        {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Hyperrelrun,29,"$29; }
    if(acc>0)        {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Accellerator,30,"$30; }
    if(exep>0)       {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Execpath,31,";$31; }
    if(reserv>0)     {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"rsrv,32,"$32; }
    if(ifname>0)     {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"IFname,33,"$33; }
    if(ctysrel>0)    {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"CTYSRelease,34,"$34; }
    if(netmask>0)    {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"netmask,35,"$35; }
    if(gateway>0)    {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"gateway,36,"$36; }
    if(relay>0)      {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"relay,37,"$37; }
    if(arch>0)       {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Arch,38,"$38; }
    if(platform>0)   {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Platform,39,"$39; }
    if(vram>0)       {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VRAM,40,"$40; }
    if(vcpu>0)       {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VCPU,41,"$41; }
    if(contextstrg>0){    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ContextStg,42,"$42; }
    if(userstr>0)    {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UserStrg,43,"$43; }
    if(uid>0)        {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UserID,44,"$44; }
    if(gid>0)        {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"GroupID,45,"$45; }
    if(defhosts>0)   {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"DefHOSTs,46,"$46; }
    if(defcon>0)     {    if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"DefCONSOLE,47,"$47; }

    ptrace("output="outbuf);
    printf("%s\n",outbuf);
}


