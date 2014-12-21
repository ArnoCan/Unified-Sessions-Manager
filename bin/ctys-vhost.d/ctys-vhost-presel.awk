#
#PROJECT:Unified Sessions Manager
#AUTHOR: Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#LICENCE:GPL3
#VERSION:01_06_001a13
#

########################################################################
#
#     Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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

function perror(inp){
    if(!d){
        errout(line":"inp);
    }
}
function perrorProgress(s){
    if(s==1)mcnt++;
    if(interact!=0){
        icnt++;    
        if(icnt==1)printf("  ") | "cat 1>&2"
        if(icnt%50==0)if(s==1){printf("X%d\n  ",icnt)|"cat 1>&2";}else{printf("x%d\n  ",icnt)|"cat 1>&2";}
        else{
            if(icnt%10==0)if(s==1){printf("X")|"cat 1>&2";}else{printf("x")|"cat 1>&2";} 
            else{if(s==1){printf("!")| "cat 1>&2";}else{printf(".")| "cat 1>&2"};}
        }
    }
}
function errout(inp){
    print inp | "cat 1>&2"
}
function output(inp){
    perror(inp);
    print inp;
}
function accessCheck(){
    perror("accessCheck:rt="rt":rs="rs);
    ret="";
    if(rt==1||rt==2){
        perror("0-rs="rs);        
        if(rs==1&&$1!~/^$/){
            perror("ping PM="$1);          
            call="ping -c 1 -w 1 "$1" 2>&1 >/dev/null;echo $?";
            call|getline ret;
            close(call); 
            perror("call="call);        
        }
        if(rs==2&&$7!~/^$/){
            perror("ping VM="$7);          
            call="ping -c 1 -w 1 "$7" 2>&1 >/dev/null;echo $?";
            call|getline ret;
            close(call); 
            perror("call="call);        
        }
        perror("1-rt="rt":ret="ret);
        if(ret==0&&rs==1){
            if(rt==2&&$1!~/^$/){
                perror("ssh PM="$1);           
                call=$1" echo 2>&1 >/dev/null;echo $?";
                if(user!=""){call="ssh "user"@"call;}
                else{call="ssh "call;}
                perror("call="call);
                call|getline ret;
                close(call); 
            }
        }
        if(ret==0&&rs==2){
            if(rt==2&&$7!~/^$/){
                perror("ssh VM="$7);
                call=$7" echo 2>&1 >/dev/null;echo $?";
                if(user!=""){call="ssh "user"@"call;}
                else{call="ssh "call;}
                perror("call="call);
                call|getline ret;
                close(call); 
            }
        }
        perror("2-rt="rt":ret="ret);
        #check for active
        if(ret!=0){return;}
        output(line"@"$2"@"$1"@"$7"#@#"cache);
    }else{
        if(rt==3){
            output(line"@"$2"@"$1"@"$7"#@#"cache);
        }else{
            output(cache);
        }
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
    }
    else{
        if(td=="t"){
            perror("request=TCP");
        }
        else{
            perror("unknown request="td);
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
    call=callp"/ctys-vhost.sh ${C_DARGS} -s -C macmaponly ";
    if(dargs!=""){
        call=call""dargs" ";
    }
    if(td=="d"){
        perror("request=DNS");
        call=call "-o d ";
    }
    else{
        if(td=="t"){
            perror("request=TCP");
            call=call "-o t ";
        }
        else{
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
BEGIN{
    #if you don't like that, I2 - so you may try to find an error by your own approach!
    cacheLast="";
    line=0;
    perror("Begin preselection filter");
    perror("s          ="s);
    if(s==/^$/){
        s=".";
        perror("s  =>      ="s);
    }
    perror("complement ="complement);
    perror("all        ="all);
    perror("arch       ="arch);
    perror("callp      ="callp);
    perror("cat        ="cat);
    perror("cols       ="cols);
    perror("cp         ="cp);
    perror("cport      ="cport);
    perror("cstr       ="cstr);
    perror("ctysrel    ="ctysrel);
    perror("d          ="d);
    perror("disp       ="disp);
    perror("dist       ="dist);
    perror("distrel    ="distrel);
    perror("dns        ="dns);
    perror("dsp        ="dsp);
    perror("execloc    ="execloc);
    perror("first      ="first);
    perror("gateway    ="gateway);
    perror("h          ="h);
    perror("hwcap      ="hwcap);
    perror("hwreq      ="hwreq);
    perror("hyrel      ="hyrel);
    perror("i          ="i);
    perror("ifname     ="ifname);
    perror("l          ="l);
    perror("ids        ="ids);
    perror("interact   ="interact);
    perror("ip         ="ip);
    perror("l          ="l);
    perror("last       ="last);
    perror("m          ="m);
    perror("mac        ="mac);
    perror("mach       ="mach);
    perror("mmap       ="mmap);
    perror("mapdb      ="mapdb);
    perror("netmask    ="netmask);
    perror("o          ="o);
    perror("os         ="os);
    perror("osrel      ="osrel);
    perror("p          ="p);
    perror("pform      ="pform);
    perror("relay      ="relay);
    perror("reloccap   ="reloccap);
    perror("rs         ="rs);
    perror("rt         ="rt);
    perror("scap       ="scap);
    perror("ser        ="ser);
    perror("sp         ="sp);
    perror("sport      ="sport);
    perror("sreq       ="sreq);
    perror("sshport    ="sshport);
    perror("netname    ="netname);
    perror("st         ="st);
    perror("t          ="t);
    perror("tcp        ="tcp);
    perror("title      ="title);
    perror("titleidx   ="titleidx);
    perror("u          ="u);
    perror("user       ="user);
    perror("ustr       ="ustr);
    perror("uu         ="uu);
    perror("vb         ="vb);
    perror("vcpu       ="vcpu);
    perror("ver        ="ver);
    perror("vram       ="vram);
    perror("vstat      ="vstat);
    perror("w          ="w);

    if(interact!=0){
        icnt=0;
        mcnt=0;
        if(interact==1){
            print "QUERY:cacheDB repetitive:\""s"\"(\"-I 2\" displays intermediate steps)" | "cat 1>&2";
        }else{
            print "QUERY:cacheDB repetitive:\""s"\"" | "cat 1>&2";            
        }      
    }
    f0="";
    e0="";
    e1="";
    if(match(s,"^[fF]:")){
        gsub("^[fF]:","",s);
        f0=s;
        f1=s;
        gsub(":.*$","",f0);
        gsub("^.*:","",f1);            
    }else{
        if(match(s,"^[eE]:")){
            gsub("^[eE]:","",s);
            e0=s;
            e1=s;
            gsub(":.*$","",e0);
            gsub("^.*:","",e1);            
            if(e0~/^$/||e1~/^$/){
                errout("Missing a comparison parameter:<"s">");
                exit;
            }
        }
    }
    perror("f0=<"f0">");
    perror("f1=<"f1">");
    perror("e0=<"e0">");
    perror("e1=<"e1">");
    perror("complement=<"complement">");   
}
{
    mx=0;td=0;cache="";cacheX="";line++;perror("record="line"$0="$0);
    if(f0!=""){
        if(complement==1){if(match($f0,f1)){perrorProgress();next;}}
        else{if(!match($f0,f1)){perrorProgress();next;}}
    }else{
        if(e0!~/^$/||e1!~/^$/){
            if(complement==1){if($e0~$e1){perrorProgress();next;}}
            else{if($e0!~$e1){perrorProgress();next;}}
        }else{
            if(complement==1){if(match($0,s)){perrorProgress();next;}}
            else{if(!match($0,s)){perrorProgress();next;}}
        }
    }
    perrorProgress(1);
}
mach==1{cache=$0;mx=1;perror("cache[0]="cache);}
mach!=1{
    if(p==1){cache=cache $1;mx=1;}
    if(st==1){if(mx==1)cache=cache";";cache=cache $2;mx=1;}
    if(l==1){if(mx==1)cache=cache";";cache=cache $3;mx=1;}
    if(ids==1){if(mx==1)cache=cache";";cache=cache $4;mx=1;}
    if(u==1){if(mx==1)cache=cache";";cache=cache $5;mx=1;}
    if(m==1){if(mx==1)cache=cache";";cache=cache $6;mx=1;}
    if(t==1){
        if(mx==1)cache=cache ";"; 
        if(cacheX==""){cacheX=$7;}
        perror("cacheX=<"cacheX">"); 
        if(cacheX!~/^$/){
            cacheX=fetchTcpDns("t",cacheX);
            perror("cacheX(fetchTcpDns)="cacheX);
        }else{
            if(mmap==1){
                perror("MAC="$6); 
                cacheX=fetchMacMap("t",$6);
                perror("cacheX(fetchMacMap)="cacheX); 
            }
        }
        cache=cache " " cacheX;mx=1; 
        perror("cache[7]="cache); 
    }
    if(dns==1){
        if(mx==1)cache=cache ";";
        if(cacheX==""){
            cacheX=$7;
        }
        perror("cacheX=<"cacheX">"); 
        if(cacheX!~/^$/){
            cacheX=fetchTcpDns("d",cacheX);
            perror("cacheX(fetchTcpDns)="cacheX); 
        }else{
            if(mmap==1){
                perror("MAC="$6); 
                cacheX=fetchMacMap("d",$6);
                perror("cacheX(fetchMacMap)="cacheX); 
            }
        }
        cache=cache " " cacheX;mx=1; 
        perror("cache[8]="cache); 
    }
    if(disp==1){if(mx==1)cache=cache";";cache=cache $8;mx=1;}
    if(cport==1){if(mx==1)cache=cache";";cache=cache $9;mx=1;}
    if(sport==1){if(mx==1)cache=cache";";cache=cache $10;mx=1;}
    if(vb==1){if(mx==1)cache=cache";";cache=cache $11;mx=1;}
    if(dist==1){if(mx==1)cache=cache";";cache=cache $12;mx=1;}
    if(distrel==1){if(mx==1)cache=cache";";cache=cache $13;mx=1;}
    if(o==1){if(mx==1)cache=cache";";cache=cache $14;mx=1;}
    if(osrel==1){if(mx==1)cache=cache";";cache=cache $15;mx=1;}
    if(ver==1){if(mx==1)cache=cache";";cache=cache $16;mx=1;}
    if(ser==1){if(mx==1)cache=cache";";cache=cache $17;mx=1;}
    if(cat==1){if(mx==1)cache=cache";";cache=cache $18;mx=1;}
    if(vstat==1){if(mx==1)cache=cache";";cache=cache $19;mx=1;}
    if(hyrel==1){if(mx==1)cache=cache";";cache=cache $20;mx=1;}
    if(scap==1){if(mx==1)cache=cache";";cache=cache $21;mx=1;}
    if(sreq==1){if(mx==1)cache=cache";";cache=cache $22;mx=1;}
    if(hwcap==1){if(mx==1)cache=cache";";cache=cache $23;mx=1;}
    if(hwreq==1){if(mx==1)cache=cache";";cache=cache $24;mx=1;}
    if(execloc==1){if(mx==1)cache=cache";";cache=cache $25;mx=1;}
    if(reloccap==1){if(mx==1)cache=cache";";cache=cache $26;mx=1;}
    if(sshport==1){if(mx==1)cache=cache";";cache=cache $27;mx=1;}
    if(netname==1){if(mx==1)cache=cache";";cache=cache $28;mx=1;}
    if(rsrv7==1){if(mx==1)cache=cache";";cache=cache $29;mx=1;}
    if(rsrv8==1){if(mx==1)cache=cache";";cache=cache $30;mx=1;}
    if(rsrv9==1){if(mx==1)cache=cache";";cache=cache $31;mx=1;}
    if(rsrv10==1){if(mx==1)cache=cache";";cache=cache $32;mx=1;}
    if(ifname==1){if(mx==1)cache=cache";";cache=cache $33;mx=1;}
    if(ctysrel==1){if(mx==1)cache=cache";";cache=cache $34;mx=1;}
    if(netmask==1){if(mx==1)cache=cache";";cache=cache $35;mx=1;}
    if(gateway==1){if(mx==1)cache=cache";";cache=cache $36;mx=1;}
    if(relay==1){if(mx==1)cache=cache";";cache=cache $37;mx=1;}
    if(arch==1){if(mx==1)cache=cache";";cache=cache $38;mx=1;}
    if(pform==1){if(mx==1)cache=cache";";cache=cache $39;mx=1;}
    if(vram==1){if(mx==1)cache=cache";";cache=cache $40;mx=1;}
    if(vcpu==1){if(mx==1)cache=cache";";cache=cache $41;mx=1;}
    if(cstr==1){if(mx==1)cache=cache";";cache=cache $42;mx=1;}
    if(ustr==1){if(mx==1)cache=cache";";cache=cache $43;mx=1;}
}
first==1&&mx==1{accessCheck();exit;}
all==1&&mx==1  {accessCheck();}
last==1&&mx==1 {cacheLast=cache;}
END{
    if(cacheLast!=""){output(cacheLast);}if(interact!=0){printf("\n")|"cat 1>&2";}
    if(interact!=0){print "  match="mcnt" of total="icnt | "cat 1>&2";}
}
