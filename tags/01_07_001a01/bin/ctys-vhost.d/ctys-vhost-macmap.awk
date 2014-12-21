#
#PROJECT:Unified Sessions Manager
#AUTHOR: Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#LICENCE:GPL3
#VERSION:01_02_007a03
#
function perror(inp){
    if(!d){errout(line ":" inp);}
}
function perrorProgress(){
    if(interact!=0){errout(".");}
}

function errout(inp){
    print inp | "cat 1>&2"
}

function output(inp){
    perror(inp);print inp;
}

function accessCheck(){
    perror("accessCheck:rt="rt":rs="rs);
    ret="";
    if(rt!=0){
        perror("0-rs="rs);        
        if(rs==1){
            perror("ping PM="$1);          
            call="ping -c 1 -w 1 "$1" 2>&1 >/dev/null;echo $?";
            call|getline ret;
            close(call); 
            perror("call="call);        
        }
        if(rs==2){
            perror("ping VM="$7);          
            call="ping -c 1 -w 1 "$7" 2>&1 >/dev/null;echo $?";
            call|getline ret;
            close(call); 
            perror("call="call);        
        }
        perror("1-rt="rt":ret="ret);
        if(ret==0&&rs==1){
            if(rt==2){
                perror("ssh PM="$1);           
                call=$1" echo 2>/dev/null;echo $?";
                if(user!=""){call="ssh "user"@"call;}
                else{call="ssh "$1 call;}
                perror("call="call);
                call|getline ret;
                close(call); 
            }
        }
        if(ret==0&&rs==2){
            if(rt==2){
                perror("ssh VM="$7);
                call=$7" echo 2>/dev/null;echo $?";
                if(user!=""){call="ssh "user"@"call;}
                else{call="ssh "call;}
                perror("call="call);
                call|getline ret;
                close(call); 
            }
        }
        perror("2-rt="rt":ret="ret);
        if(ret!=0){return;}
#        output($2"@"$1"@"$7"#@#"cache);
        output(line"@"$2"@"$1"@"$7"#@#"cache);
    }else{
        if(rt==3){
#            output($2"@"$1"@"$7"#@#"cache);
            output(line"@"$2"@"$1"@"$7"#@#"cache);
        }else{
            output(cache);
        }
    }
}

BEGIN{
    cacheLast="";
    line=0;
    perror("Begin macmap");
    perror("mach="mach);
    perror("d="d);
    perror("w="w);
    perror("t="t);
    perror("m="m);
    perror("dns="dns);
    perror("rt="rt);
    perror("rs="rs);
    perror("first="first);
    perror("all="all);
    perror("last="last);
}
{mx=0;td=0;cache="";line++;perror("record="line" $0="$0);}
m==1&&$0~s&&mach!=1{if(mx==1)cache=cache";";cache=cache $2;mx=1;}
t==1&&$0~s&&mach!=1{if(mx==1)cache=cache";";cache=cache $3;mx=1;}
dns==1&&$0~s&&mach!=1{if(mx==1)cache=cache";";cache=cache $1;mx=1;}
first==1&&mx==1{accessCheck();exit;}
all==1&&mx==1{accessCheck();}
last==1&&mx==1{cacheLast=cache;}
END{if(cacheLast!="")printf("%s\n",cacheLast);}

