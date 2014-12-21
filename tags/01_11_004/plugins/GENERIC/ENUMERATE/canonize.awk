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

    ptrace("exep       ="exep);
    ptrace("acc        ="acc);
    ptrace("hrx        ="hrx);

    line=0;
}
{
    line++;
#    ptrace("RECORD="$0);
}
titleidx==1{
    outbuf="";
    if(h>0)       {                            mx=1; outbuf=outbuf"ContainingMachine(1)"; }
    if(t>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SessionType(2)";       }
    if(l>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Label(3)";             }
    if(i>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ID(4)";                }
    if(uu>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UUID(5)";              }
    if(mac>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"MAC(6)";               }
    if(tcp>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"TCP(7)";               }
    if(dsp>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"DISPLAY(8)";           }
    if(cp>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ClientAccessPort(9)";  }
    if(sport>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ServerAccessPort(10)"; }
    if(vb>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VNCbasePort(11)";      }
    if(dist>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distro(12)";           }
    if(distrel>0) { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distrorel(13)";        }
    if(os>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OS(14)";               }
    if(osrel>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OSREL(15)";            }
    if(ver>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VersNo(16)";           }
    if(ser>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SerialNo(17)";         }
    if(cat>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Category(18)";         }

    if(vmstate>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VMstate(19)";       }
    if(hyperrel>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"hyperrel(20)";      }
    if(stackcap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackCap(21)";      }
    if(stackreq>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackReq(22)";      }
    if(hwcap>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWCAP(23)";   }
    if(hwreq>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWREQ(24)";   }
    if(execloc>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ExecLocation(25)";   }
    if(reloccap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"RelocationCapacity(26)";   }
    if(sshport>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SSHport(27)";   }
    if(netname>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Netname(28)";   }
    if(hrx>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Hyperrelrun(29)";   }
    if(acc>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Accellerator(30)";   }
    if(exep>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Exepath(31)";   }
    if(reserv10>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"rsrv(32)";   }
    if(ifname>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"IFname(33)";   }
    if(ctysrel>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"CTYSRelease(34)";   }
    if(netmask>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"netmask(35)";   }
    if(gateway>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"gateway(36)";   }
    if(relay>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"relay(37)";   }
    if(arch>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Arch(38)";          }
    if(platform>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Platform(39)";      }
    if(vram>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VRAM(40)";          }
    if(vcpu>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VCPU(41)";          }
    if(contextstrg>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ContextStg(42)";    }
    if(userstr>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UserStrg(43)";      }

    printf("%s\n",outbuf);
    exit;        
}

titleidx==2{
    outbuf="";
    if(h>0)       {                            mx=1; outbuf=outbuf"ContainingMachine(A-1)"; }
    if(t>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SessionType(B-2)";       }
    if(l>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Label(C-3)";             }
    if(i>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ID(D-4)";                }
    if(uu>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UUID(E-5)";              }
    if(mac>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"MAC(F-6)";               }
    if(tcp>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"TCP(G-7)";               }
    if(dsp>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"DISPLAY(H-8)";           }
    if(cp>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ClientAccessPort(I-9)";  }
    if(sport>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ServerAccessPort(J-10)"; }
    if(vb>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VNCbasePort(K-11)";      }
    if(dist>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distro(L-12)";           }
    if(distrel>0) { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distrorel(M-13)";        }
    if(os>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OS(N-14)";               }
    if(osrel>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OSREL(O-15)";            }
    if(ver>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VersNo(P-16)";           }
    if(ser>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SerialNo(Q-17)";         }
    if(cat>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Category(R-18)";         }

    if(vmstate>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VMstate(S-19)";       }
    if(hyperrel>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"hyperrel(T-20)";      }
    if(stackcap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackCap(U-21)";      }
    if(stackreq>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackReq(V-22)";      }
    if(hwcap>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWCAP(W-23)";   }
    if(hwreq>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWREQ(X-24)";   }
    if(execloc>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ExecLocation(Y-25)";   }
    if(reloccap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"RelocationCapacity(Z-26)";   }
    if(sshport>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SSHport(AA-27)";   }
    if(netname>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Netname(AB-28)";   }
    if(hrx>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Hyperrelrun(AC-29)";   }
    if(acc>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Accellerator(AD-30)";   }
    if(exep>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Exepath(AE-31)";   }
    if(reserv10>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"rsrv(AF-32)";   }
    if(ifname>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"IFname(AG-33)";   }
    if(ctysrel>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"CTYSRelease(AH-34)";   }
    if(netmask>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"netmask(AI-35)";   }
    if(gateway>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"gateway(AJ-36)";   }
    if(relay>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"relay(AK-37)";   }
    if(arch>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Arch(AL-38)";          }
    if(platform>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Platform(AM-39)";      }
    if(vram>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VRAM(AN-40)";          }
    if(vcpu>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VCPU(AO-41)";          }
    if(contextstrg>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ContextStg(AP-42)";    }
    if(userstr>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UserStrg(AQ-43)";      }

    printf("%s\n",outbuf);
    exit;        
}


title==1{
    outbuf="";
    if(h>0)       {                            mx=1; outbuf=outbuf"ContainingMachine"; }
    if(t>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SessionType";       }
    if(l>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Label";             }
    if(i>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ID";                }
    if(uu>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UUID";              }
    if(mac>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"MAC";               }
    if(tcp>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"TCP";               }
    if(dsp>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"DISPLAY";           }
    if(cp>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ClientAccessPort";  }
    if(sport>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ServerAccessPort";  }
    if(vb>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VNCbasePort";       }
    if(dist>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distro";            }
    if(distrel>0) { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Distrorel";         }
    if(os>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OS";                }
    if(osrel>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"OSrel";             }
    if(ver>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VersNo";            }
    if(ser>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SerialNo";          }
    if(cat>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Category";          }

    if(vmstate>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VMstate";       }
    if(hyperrel>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"hyperrel";      }
    if(stackcap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackCap";      }
    if(stackreq>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"StackReq";      }
    if(hwcap>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWCAP";   }
    if(hwreq>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"HWREQ";   }
    if(execloc>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ExecLocation";   }
    if(reloccap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"RelocationCapacity";   }
    if(sshport>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"SSHport";   }
    if(netname>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"netname";   }
    if(hrx>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"hyperrelrun";   }
    if(acc>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"accellerator";   }
    if(exep>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"exepath";   }
    if(reserv10>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"rsrv";   }
    if(ifname>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"IFname";   }
    if(ctysrel>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"CTYSRelease";   }
    if(netmask>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"netmask";   }
    if(gateway>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"gateway";   }
    if(relay>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"relay";   }
    if(arch>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Arch";          }
    if(platform>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"Platform";      }
    if(vram>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VRAM";          }
    if(vcpu>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"VCPU";          }
    if(contextstrg>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"ContextStg";    }
    if(userstr>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf"UserStrg";      }

    printf("%s\n",outbuf);
    exit;        
}

$0~/^$/||!($19~mstat){
    ptrace("DROPPED="$19" "$4);
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
        if($1!~/^$/) outbuf=outbuf tcpaddr;
        else tcpaddr=$1;
    }
    if(t>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $11;}
    if(l>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $2; }
    if(i>0)  { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $3; }
    if(uu>0) { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $4; }
    if(mac>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $5; }

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
    if(tcp>0||dns>0){
        if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf tcpaddr;
    }

    if(dsp>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $6; }
    if(cp>0)         { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $7; }
    if(sport>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $8; }
    if(vb>0)         { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $9; }


    if(dist>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $12;}
    if(distrel>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $13;}
    if(os>0)         { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $14;}
    if(osrel>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $15;}
    if(ver>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $16;}
    if(ser>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $17;}
    if(cat>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $18;}

    if(vmstate>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $19;}
    if(hyperrel>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $20;}
    if(stackcap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $21;}
    if(stackreq>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $22;}

    if(hwcap>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $23;}
    if(hwreq>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $24;}
    if(execloc>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $25;}
    if(reloccap>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $26;}
    if(sshport>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $27;}
    if(netname>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $28;}
    if(hrx>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $29;}
    if(acc>0)        { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $30;}
    if(exep>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $31;}
    if(reserv10>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $32;}
    if(ifname>0)     { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $33;}
    if(ctysrel>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $34;}
    if(netmask>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $35;}
    if(gateway>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $36;}
    if(relay>0)      { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $37;}
    if(arch>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $38;}
    if(platform>0)   { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $39;}
    if(vram>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $40;}
    if(vcpu>0)       { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $41;}
    if(contextstrg>0){ if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $42;}
    if(userstr>0)    { if(mx==1)outbuf=outbuf";"; mx=1; outbuf=outbuf $43;}

    ptrace("output="outbuf);
    printf("%s\n",outbuf);
}


