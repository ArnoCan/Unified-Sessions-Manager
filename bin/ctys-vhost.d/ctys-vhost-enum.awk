#
#PROJECT:Unified Sessions Manager
#AUTHOR: Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#LICENCE:GPL3
#VERSION:01_02_007a03
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
