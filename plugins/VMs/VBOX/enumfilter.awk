
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_006alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

BEGIN                                    {mx=0;}
$0~/#@#MAGICID-IGNORE/                   {exit 2;}
$0~/#@#MAGICID-NOENUM/                   {exit 3;}
$0~/#@#MAGICID-VBOX/                     {exit 0;}


