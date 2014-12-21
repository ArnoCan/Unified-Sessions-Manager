#
#PROJECT:Unified Sessions Manager
#AUTHOR: Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#LICENCE:GPL3
#VERSION:01_02_007a03
#
function perror(inp){
      if(d>0){
#          print line ":" inp | "cat 1>&2"
          errout(line ":" inp);
      }
}

function perrorProgress(){
      if(interact==1){
#          printf(".") | "cat 1>&2"
          errout(".");
          
      }
}

function errout(inp){
    print inp | "cat 1>&2"
}

function output(inp){
    perror(inp);
    print inp
}


function accessCheck(){
    perror("accessCheck:rt="rt":rs="rs);
    ret="";

    if(rt!=0){
        perror("0-rs="rs);        
        if(rs==1){
            perror("ping PM="$1);          
            call="ping -c 1 "$1" 2>&1 >/dev/null;echo $?";
            call|getline ret;
            close(call); 
            perror("call="call);        
        }
        if(rs==2){
            perror("ping VM="$8);          
            call="ping -c 1 "$8" 2>&1 >/dev/null;echo $?";
            call|getline ret;
            close(call); 
            perror("call="call);        
        }
        perror("1-rt="rt":ret="ret);

        if(ret==0&&rs==1){
            if(rt==2){
                perror("ssh PM="$1);           
                call=$1" echo 2>/dev/null;echo $?";
                if(user!=""){
                    call="ssh "user"@"call;
                }
                else{
                    call="ssh "$1 call;
                }
                perror("call="call);
                call|getline ret;
                close(call); 
            }
        }
        if(ret==0&&rs==2){
            if(rt==2){
                perror("ssh VM="$8);
                call=$8" echo 2>/dev/null;echo $?";
                if(user!=""){
                    call="ssh "user"@"call;
                }
                else{
                    call="ssh "call;
                }
                perror("call="call);
                call|getline ret;
                close(call); 
            }
        }
        perror("2-rt="rt":ret="ret);

        #check for active
        if(ret!=0){
            return;
        }
        output($2"@"$1"#@#"cache);
    }else{
        output(cache);
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

    call=callp"/ctys-vhost ${CTRL_VERBOSE:+ -d $CTRL_VERBOSE} -C macmaponly ";
    if(d!=""){
        call=call "-d "d" ";
    }
    if(w==""){
        call=call "-W ";
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



BEGIN                   {
                          #if you don't like that, I2 - so you may try to find an error by your own approach!
                          cacheLast="";
                          line=0;
                          perror("Begin presel");
                          perror("d="d);
                          perror("w="w);
                          perror("mach="mach);
                          perror("interact="interact);
                          perror("s="s);
                          perror("t="t);
                          perror("dns="dns);
                          perror("m="m);
                          perror("idd="idd);
                          perror("ids="ids);
                          perror("u="u);
                          perror("p="p);
                          perror("mt="mt);
                          perror("o="o);
                          perror("l="l);
                          perror("first="first);
                          perror("all="all);
                          perror("last="last);
                          perror("rt="rt);
                          perror("rs="rs);
                          perror("user="user);
                          perror("mmap="mmap);
                          perror("callp="callp);
                        }

                        {
                          mx=0;td=0;cache="";line++;perror("record="line"$0="$0);
                          perrorProgress();
                        }

#dump for general postprocessing
$0~s&&mach==1           {                          cache=$0;        mx=1; perror("cache[0]="cache); }

#requested attributes
p==1&&$0~s&&mach!=1     {                          cache=cache $1;  mx=1; perror("cache[1]="cache); }
mt==1&&$0~s&&mach!=1    {if(mx==1)cache=cache ";"; cache=cache $2;  mx=1; perror("cache[3]="cache); }
l==1&&$0~s&&mach!=1     {if(mx==1)cache=cache ";"; cache=cache $3;  mx=1; perror("cache[4]="cache); }
ids==1&&$0~s&&mach!=1   {if(mx==1)cache=cache ";"; cache=cache $4;  mx=1; perror("cache[2]="cache); }
u==1&&$0~s&&mach!=1     {if(mx==1)cache=cache ";"; cache=cache $5;  mx=1; perror("cache[5]="cache); }
m==1&&$0~s&&mach!=1     {if(mx==1)cache=cache ";"; cache=cache $6;  mx=1; perror("cache[6]="cache); }

t==1&&$0~s&&mach!=1     {
                            if(mx==1)cache=cache ";"; 

                            if(cacheX==""){
                                cacheX=$7;
                            }
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
                            cache=cache " " cacheX;
                            mx=1; 
                            perror("cache[7]="cache); 
                        }

dns==1&&$0~s&&mach!=1   {
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
                            cache=cache " " cacheX;
                            mx=1; 
                            perror("cache[8]="cache); 
                        }

o==1&&$0~s&&mach!=1     {if(mx==1)cache=cache ";"; cache=cache $12; mx=1; perror("cache[9]="cache); }


first==1&&mx==1         {accessCheck();exit;}
all==1&&mx==1           {accessCheck();}

last==1&&mx==1          {cacheLast=cache;}

END                     {if(cacheLast!=""){output(cacheLast);}if(interact==1){printf("\n") | "cat 1>&2";}}


