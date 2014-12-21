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
#
#
# For own extensions:
# The call will be performed with "-F'='" for field seperator.
# Thus the FIELD $1 contains the left side of the value assignment 
# with additional whitespaces.
#
# The given semantics of decision is of course based on my own convention,
# gwhich could change.
#
# So, for your own modifications, just add or remove lines with keywords you 
# define as mandatory for a Xen-Configuration file, sufficient for deciding 
# it is a config-file.
#
# For now all has to be lowercase.
#
# The preset value of matchMin defines the count of mandatory matches within
# each file, in order to be sufficient for deciding it to be a Xen-Configuration.
#
#

BEGIN                            {mx=0;}
$0~/#@#MAGICID-IGNORE/           {mx=0;exit 2;}
$0~/#@#MAGICID-NOENUM/           {mx=0;exit 3;}
$0~/#@#MAGICID-XEN/              {mx+=99;}
$0~/^#/                          {next;}



$1~/^ *name *$/                  {mx++;}
$1~/^ *vif *$/                   {mx++;}
$1~/^ *disk *$/                  {mx++;}
$1~/^ *memory *$/                {mx++;}
$1~/^ *bootloader *$/            {mx++;}
$1~/^ *uuid *$/                  {mx++;}
$1~/^ *vcpus *$/                 {mx++;}

END                              {if(mx>matchMin)exit 0;else exit 1;}

