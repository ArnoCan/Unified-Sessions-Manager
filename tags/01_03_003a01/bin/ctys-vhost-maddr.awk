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



BEGIN          {
                  #if you don't like that, try to find an error by your own approach!
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
$4~/\/etc\/ctys.d\/[pv]m.conf/      {pm=1;cache=$1;exit;}

               {line++;perror("record="line"$0="$0);}

               {cache=$1 "[";}

#Uniqueness has to be guaranteed previously
ids==1&&$4!="" {if(mtch==1)cache=cache ",";cache=cache $4;mtch=1; }
l==1&&$3!=""   {if(mtch==1)cache=cache ",";cache=cache $3;mtch=1; }
u==1&&$5!=""   {if(mtch==1)cache=cache ",";cache=cache $5;mtch=1; }
m==1&&$6!=""   {if(mtch==1)cache=cache ",";cache=cache $6;mtch=1; }
t==1&&$7!=""   {if(mtch==1)cache=cache ",";cache=cache $7;mtch=1; }

END            {if(cache!=""&&pm==0){if(mtch!=1)cache=cache"ERROR";printf("%s]\n",cache);}else printf("%s\n",cache);}



