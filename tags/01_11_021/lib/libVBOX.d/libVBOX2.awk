#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


function ptrace(inp){
    if(!d){
            print inp | "cat 1>&2"
        }
}

BEGIN{
    A="";
    B="";
    ptrace("libVBOX-C/S");
}


function printRes(a){
    if(a!~/^$/)print A""a""B;
}


/'$$'/{
    next;
}

!/virtualbox/{
    next;
}

s==1&&!/VBoxHeadless/{
    next;
}

c==1&&!/VirtualBox/&&!/VBoxSDL/{
    next;
}


/-comment/{
    l=$0;
    n=gsub("^.*--comment  *","",l);
    if(n!=0){n=gsub("  *.*$","",l);}
}
/-startvm /{
    u=$0;
    n=gsub("^.*-startvm  *","",u);
    if(n!=0){n=gsub(" .*$","",u);}
}

/-s /{
    u=$0;
    n=gsub("^.*-s  *","",u);
    if(n!=0){n=gsub(" .*$","",u);}
}

u!~/^$/&&u!~/........-....-....-..../{
    l=u;
    u="";
}


{
    p0="";p="";
    for(i=1;i<8;i++){
        p0=p0" "$i
    }
    p=p0;
    exep=$8;
    ptrace("0-p="p);
    if(u!=""||l!=""){
            if(u!=""){
		    x0=u;
		    }else{
	            x0=l;
    		}
 		call="VBoxManage showvminfo --machinereadable "x0;
		ptrace("0-call="call);
		call=call"|awk -F= -v l="l" -F= -v u="u" \" function printRes(r0,r1){if(r0!~/^\\$/)print A\\\"\\\"r0\\\"\\\"B\\\";\\\"r1;} ";
#		call=call"/SATA-Controller-0-0=/&&\\$2!~/none/{a=\\$2;} ";
#		call=call"/IDE-Controller-0-0=/&&\\$2!~/none/{a=\\$2;} ";
       		call=call"/vrdpport/{b=\\$2;} ";
		call=call"/^name=/{c=\\$2;} ";
		call=call"/^macaddress1=/{d1=\\$2;}";
		call=call"/^macaddress2=/{d2=\\$2;}";
		call=call"/^macaddress3=/{d3=\\$2;}";
		call=call"/^macaddress4=/{d4=\\$2;}";
		call=call"/^macaddress5=/{d5=\\$2;}";
		call=call"/^macaddress6=/{d6=\\$2;}";
		call=call"/^macaddress7=/{d7=\\$2;}";
		call=call"/^macaddress8=/{d8=\\$2;}";
		call=call"/^hwvirtex=/&&/on/{e=\\\"HWM\\\";} ";
		call=call"/^ostype=/{ ";
		call=call"  if(\\$0~/_64/){f=\\\"x86_64\\\";} ";
		call=call"  else{f=\\\"i386\\\";}";
		call=call"} ";
		call=call"END{ ";

#		call=call"   A=a\\\";\\\"c\\\";\\\"L\\\";\\\"b\\\";\\\"; ";
#		call=call"   A=c\\\";\\\"a\\\";\\\"u\\\";\\\";";
#		call=call"   A=c\\\";\\\"a\\\";\\\"u\\\";\\\";";
		call=call"   A=a\\\";\\\"c\\\";\\\"u\\\";\\\"b\\\";\\\";";


#		call=call"   B=\\\";\\\"e\\\";\\\"f; ";
#		call=call"   B=\\\";;\\\"b\\\";;;;VBOX;;;;;;;;;\\\"e\\\";\\\"f;";
#		call=call"   B=\\\";\\\"b\\\";VBOX;\\\"e\\\";\\\"f;";
		call=call"   B=\\\";\\\"e\\\";\\\"f;";


		call=call"printRes(d1,\\\"1\\\"); printRes(d2,\\\"2\\\"); printRes(d3,\\\"3\\\"); printRes(d4,\\\"4\\\"); ";
		call=call"printRes(d5,\\\"5\\\"); printRes(d6,\\\"6\\\"); printRes(d7,\\\"7\\\"); printRes(d8,\\\"8\\\");";
		call=call"} ";
		call=call"\"";

		ptrace("1-call="call);
		x1="";    
		while(call|getline){
		    x1=$0;

#		    p=p" "x1";"exep;
		    p=p0" "x1";"exep;
		    gsub("\"","",p);
		    ptrace("1-p="p);
		    ptrace("1-p0="p0);
		    printf("%s\n",p);
		}
		close(call);
	}
	ptrace("2-call="call);
	l="";
	u="";
}




#            call=call"|awk -F= -v L="u" \"/IDE-Controller-0-0=/{a=\\$2;} /vrdpport/{b=\\$2;} /^name=/{c=\\$2;} /^macaddress1=/{d=\\$2;} /^hwvirtex=/{e=\\$2;} /^ostype=/{if(\\$0~/_64/){f=\\\"x86_64\\\"}else{f=\\\"i386\\\"}} END{print a\\\";\\\"c\\\";\\\"L\\\";\\\"b\\\";\\\"d\\\";\\\"e\\\";\\\"f}\"";



