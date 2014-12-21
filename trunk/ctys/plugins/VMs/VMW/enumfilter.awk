########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
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

BEGIN                                    {mx=0;}
$0~/#@#MAGICID-IGNORE/                   {mx=0;exit 2;}
$0~/#@#MAGICID-NOENUM/                   {mx=0;exit 3;}
$0~/#@#MAGICID-VMW/                      {mx+=99;}

$1~/^#!\/usr\/bin\/vmware/               {mx=100;exit;}
$0~/^#/                                  {next;}

$1~/^ *displayName *$/                   {mx=3;}
$1~/^ *uuid.action *$/                   {mx=3;}
$1~/^ *ethernet0.addressType *$/         {mx=2;}
$1~/^ *guestOS *$/                       {mx++;}
$1~/^ *uuid.bios *$/                     {mx++;}
$1~/^ *nvram *$/                         {mx++;}
$1~/^ *config.version *$/                {mx=2;}

END                                {if(mx>matchMin)exit 0;else exit 1;}

