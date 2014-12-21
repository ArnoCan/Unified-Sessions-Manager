#
#PROJECT:Unified Sessions Manager
#AUTHOR: Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#LICENCE:GPL3
#VERSION:01_02_007a03
#

function perror(inp){
    if(!d){
            print line ":" inp | "cat 1>&2"
        }
}

BEGIN{
    line=0;
    perror("RESOLVE_ENUM");
}

{outs="";line++;matched=0;}

#MAC <-> TCP/IP
$7~/^$/&&p!~/^$/{
    perror("===>MATCH-MAC");
    call="awk -F\";\" -v mx=\""$6"\" \"mx!~/^\\$/&&\\$2~mx{print \\$3;}\" "p;
    u="";
    ipaddr="";
    
    perror("call="call);
    call|getline u;
    close(call);
    ipaddr=u;
    matched=1;
}

{
    if(matched==1){
        perror("out-map="$0);
        cb="";
        for(i=1;i<7;i++){
            cb=cb""$i";";
        }
        if(ipaddr!=""){
	    perror("out[7]=\""$7"\"->"ipaddr);
            cb=cb""ipaddr";";
        }else{
            cb=cb""$7";";
	}
	for(i=8;i<=NF;i++){
            if(i!=NF){
                cb=cb""$i";";
            }
            else{
                cb=cb""$i;
            }
	}
	print cb;
    }else{
#4tst   perror("out-non-map="$0);
	print;
    }
    matched=0;
}
