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
 if(!d){print line ":" inp | "cat 1>&2"}
}
BEGIN{
 line=0;
 pm=0;                  
 perror("Begin maddr");
 perror("t="t);
 perror("m="m);
 perror("ids="ids);
 perror("u="u);
 perror("p="p);
 perror("l="l);
}

#PM:temporary hard-coded 1-level for 1.step of basic proof-of-concept for now, will be reworked soon.
#Has to be generic for any level/layer of "stack-entry" of course.
$4~/\/etc\/ctys.d\/[pv]m.conf/{pm=1;cache=$1;exit;}

{line++;perror("record="line"$0="$0);}
{cache=$1"[";}

#Uniqueness has to be guaranteed previously
ids==1&&$4!=""{if(mtch==1)cache=cache ",";cache=cache $4;mtch=1;}
l==1&&$3!=""{if(mtch==1)cache=cache ",";cache=cache $3;mtch=1;}
u==1&&$5!=""{if(mtch==1)cache=cache ",";cache=cache $5;mtch=1;}
m==1&&$6!=""{if(mtch==1)cache=cache ",";cache=cache $6;mtch=1;}
t==1&&$7!=""{if(mtch==1)cache=cache ",";cache=cache $7;mtch=1;}

END{if(cache!=""&&pm==0){if(mtch!=1)cache=cache"ERROR";printf("%s]\n",cache);}else printf("%s\n",cache);}



