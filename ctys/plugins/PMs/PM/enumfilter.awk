########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
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

BEGIN                  {mx=0;}
$1~/^#@#MAGICID-PM */  {mx+=99;}
$1~/#@#LABEL */        {mx++;}
$1~/#@#UUID */         {mx++;}
$1~/#@#MAC */          {mx++;}
$1~/#@#IP */           {mx++;}
$1~/#@#DIST */       {mx++;}
END                    {if(mx>matchMin)exit 0;else exit 1;}
