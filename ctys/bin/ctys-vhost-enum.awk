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
    call="awk -F\";\" -v mx=\""$6"\" \"\\$2~mx{print \\$3;}\" "p
    perror("call="call);
    call|getline u;
    close(call);
    ipaddr=u;
    matched=1;
}

{
    if(matched==1){
        perror("out="$0);
        for(i=1;i<7;i++){
            printf("%s;",$i);
        }

        if(ipaddr!=""){
	    perror("out[7]="$7"->"ipaddr);
	    printf("%s;",ipaddr);
        }else{
	    printf("%s;",$7);
	}

	for(i=8;i<=NF;i++){
            printf("%s;",$i);
	}

	printf("\n");
    }else{
	print;
    }
    matched=0;
}
