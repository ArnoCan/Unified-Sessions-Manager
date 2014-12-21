########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a10
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


#
#  Does a simple clipping, but considers "words" to be the break-start.
#
#  Reads stream from stdin.
#
#PARAMETERS:
#  size:   size of line-entry, includes indent, default=80
#  indent: indent, any line "1+", default=0
#
BEGIN{
    nrec=0;
}
{
    nrec=1;
}
{
    l=length($0);
    out=$0;
    if(l>size){
            if(nrec==1){
		    indent0=0;
		    x=match(out,"^  *[^ ]");
		    if(x>0){
			    offset=RLENGTH-1;
			}
			else{
			    offset=0;
			}
			indent1=indent+offset;
			size0=size-indent1;
			nrec=0;
		}

		while(l>size){
                    #new endpoint
		    out1=substr(out,1,size+1);
		    l1=match(out1,"[^ ]  *[^ ]*$");
		    if(l1==0){
			    l1=size;
			}
			printf("%"indent0"s%s\n","",substr(out,1,l1));
			out=substr(out,l1+1);

                        #strip leading spaces
			l1=match(out,"^ *[^ ]");

			out=substr(out,RLENGTH);
			l=length(out);
			indent0=indent1+3;
			size=size0;
		}
		printf("%"indent0"s%s\n","",out);
	}
	else{
            print out;
	}
}

