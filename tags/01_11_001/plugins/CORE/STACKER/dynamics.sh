#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_07_001b02
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


#FUNCBEG###############################################################
#NAME:
#  stackerCheckDynamics
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#
# THE FIRST VERSION, thus priority is on success only!!!
#
#
# Performs some basic checks for consistency of actual required and provided
# resource capabilities.
#
# The following is checked within this version:
#
# 1. Pre-Running entities, and if so, consistency of their runtime-location
#    with current VMSTACK under request.
#    Uitilizes global: JOB_EXECCALLS[].
#
# 2. VMs runtime-location for the not-yet-started stack parts, including their 
#    appropriate session type applicability.
#    This requires the cacheDB to be available and properly populated on the 
#    caller's site.
#    Uitilizes global: JOB_EXECCALLS[].
#
#
#
# This works within the final SUB-TASK, where the split of the valid targets
# has to and is already processed. Thus even though not the "earliest" runtime 
# point, it is for now the "least-development-cost" approach to be prefered.
#
#EXAMPLE:
#
#PARAMETERS:
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerCheckDynamics () {
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-ENTRY:\$@=${@}"

    #several helper attributes
    declare -a STACK_IDX;
    declare -a STACK_STATE;
    declare -a STACK_SES;
    declare -a STACK_ACT;

    #address of VM-GuestOS
    declare -a STACK_MACHINE_RAW;
    declare -a STACK_MACHINE;
    declare -a STACK_MACHINEDNS;

    #addres of current container
    declare -a STACK_EXECTARGET_RAW;
    declare -a STACK_EXECTARGET;
    declare -a STACK_EXECTARGETDNS;

    #cacheDB MACHINE entry of VM, process with getField
    declare -a STACK_VMDATA;


    #
    #collect required data for setup and verification of the VMSTACK
    #ignores helper sessions such as CONSOLEs, so only VMs+PMs should
    #be contained.
    #
    function collectStackData () {
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-ENTRY"
	local siz=${#JOB_EXECCALLS[@]}
	local x=0;
        local x1=0;
	for((x=0;x<${siz};x++));do
            #fetch basic task data
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"

	    local _schk=`getSessionType ${JOB_EXECSERVER[$x]}`
	    case ${_schk} in
		X11|CLI|VNC)continue;;
	    esac
	    STACK_IDX[$x1]=${x}
	    STACK_SES[$x1]=${_schk}
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_SES[$x1]=${STACK_SES[$x1]}"
	    
	    STACK_ACT[$x1]=`getAction ${JOB_EXECSERVER[$x]}`
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_ACT[$x1]=${STACK_ACT[$x1]}"


            #################
            #
            #execution target
	    case ${_schk} in
		PM)
                    #################
                    #
                    #first trial for PM mainly, which might contain TCP/IP and/or MAC anyhow, thus
                    #utilizes macmap only, requiring DHCP uniqueness.
                    #
                    #fetch basic interconnection peers
                    #
		    STACK_MACHINE[$x1]=`cacheGetMachineAddressFromCall TCP NONE ${JOB_EXECSERVER[$x]}`
		    if [ -n "${STACK_MACHINE[$x1]}" ];then
			STACK_MACHINE_RAW[$x1]="${STACK_MACHINE[$x1]}"
			STACK_MACHINE[$x1]=`${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -i ${STACK_MACHINE[$x1]}`
		    fi
		    if [ -z "${STACK_MACHINE[$x1]}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: Missing data of basic PM=\"${STACK_MACHINE[$x1]}\""
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: The VMSTACK requires in current version the cacheDB"
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: to be properly initialized for all participating"
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: entities."
			gotoHell ${ABORT}
		    fi
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_MACHINE_RAW[$x1]=${STACK_MACHINE_RAW[$x1]}"
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_MACHINE[$x1]    =${STACK_MACHINE[$x1]}"
		    STACK_EXECTARGET[$x1]=${STACK_MACHINE[$x1]}
		    ;;
		*)
		    local _call=${JOB_EXECCALLS[$x]}
		    STACK_EXECTARGET[$x1]=${_call#*@}
		    ;;
	    esac
	    if [ -n "${STACK_EXECTARGET[$x1]}" ];then
		STACK_EXECTARGET_RAW[$x1]=${STACK_EXECTARGET[$x1]}
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique "
		STACK_EXECTARGET[$x1]=`${_VHOST} -o TCP ";PM;" ${STACK_EXECTARGET[$x1]} E:28:1`
		STACK_EXECTARGETDNS[$x1]=`${_VHOST} -o netname ";PM;" ${STACK_EXECTARGET[$x1]} E:28:1`
	    fi
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_EXECTARGET_RAW[$x1]=${STACK_EXECTARGET_RAW[$x1]}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_EXECTARGET[$x1]    =${STACK_EXECTARGET[$x1]}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_EXECTARGETDNS[$x1] =${STACK_EXECTARGETDNS[$x1]}"

            #################
            #
            #Second trial when still missing, requires for distributed caches frequently the <exec-target>
            #for extended mapping on non-tcp-only data, should be available now.
            #
            #fetch basic interconnection peers

            #first trial:PM/VM
	    if [ -z "${STACK_MACHINE[$x1]}" ];then
		STACK_MACHINE[$x1]=`cacheGetMachineAddressFromCall VHOST FROMCALL ${JOB_EXECSERVER[$x]}`
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique "
		STACK_MACHINE[$x1]=`${_VHOST} -o TCP ";PM;" ${STACK_MACHINE[$x1]} E:28:1`
		STACK_MACHINE[$x1]=${STACK_MACHINE[$x1]// /}

		if [ -n "${STACK_MACHINE[$x1]}" ];then
		    STACK_MACHINE_RAW[$x1]="${STACK_MACHINE[$x1]}"
		fi
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_MACHINE_RAW[$x1]=${STACK_MACHINE_RAW[$x1]}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_MACHINE[$x1]    =${STACK_MACHINE[$x1]}"

	    fi


            #fetch entry from cacheDB to mem-cache
            #execution target
	    case ${_schk} in
		PM)
                    #tmp workaround
		    STACK_VMDATA[$x1]=`cacheGetMachineAddressFromCall VHOST FROMCALL ${JOB_EXECSERVER[$x]}`;

		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_VMDATA[$x1]=${JOB_EXECSERVER[$x]}"
		    if [ -z "${STACK_VMDATA[$x1]}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing data of basic PM=${STACK_EXECTARGET[$x1]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Called:\"cacheGetMachineAddressFromCall VHOST ${JOB_EXECSERVER[$x]}\""
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Check with: no \"-s\" and \"-M all\""

			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 0. Check your <machine-address>, has to match"
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:    the WoL-target."
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 1. Call:\"ctys-genmconf.sh -x PM ${JOB_EXECSERVER[$x]}\""
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 2. Call:\"ctys-vdbgen.sh ...\""
			gotoHell ${ABORT}
		    fi

		    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique"
		    STACK_VMDATA[$x1]=`${_VHOST} -o MACHINE ";PM;" ${STACK_VMDATA[$x1]} E:28:1`
		    if [ -z "${STACK_VMDATA[$x1]}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing data from cacheDB for basic PM=${STACK_EXECTARGET[$x1]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Called:\"${_VHOST} -o MACHINE ${STACK_VMDATA[$x1]}\""
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Check with:no \"-s\" and \"-M all\""

			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 0. Check your <machine-address>, has to match"
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:    the WoL-target."
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 1. Call:\"ctys-genmconf.sh -x PM ${STACK_EXECTARGET[$x1]}\""
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 2. Call:\"ctys-vdbgen.sh ...\""
			gotoHell ${ABORT}
		    fi
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_VMDATA[$x1]=${STACK_VMDATA[$x1]}"
		    STACK_PMDATA[$x1]="${STACK_VMDATA[$x1]}"
		    ;;
		*)
                    #tmp workaround
		    STACK_VMDATA[$x1]=`cacheGetMachineAddressFromCall VHOST FROMCALL ${JOB_EXECSERVER[$x]}`
		    STACK_VMDATA[$x1]="${STACK_VMDATA[$x1]} ${STACK_EXECTARGET_RAW[$x1]}"
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_VMDATA[$x1]=${STACK_VMDATA[$x1]}"
		    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique"
		    STACK_VMDATA[$x1]=`${_VHOST} -o MACHINE ${STACK_VMDATA[$x1]}`
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_VMDATA[$x1]=${STACK_VMDATA[$x1]}"
		    if [ -z "${STACK_VMDATA[$x1]}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing data of hypervisor basic PM/VM=${STACK_MACHINE[$x1]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 1. Check configuration file."
			printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 2. Call: \"ctys-vdbgen.sh ...\""
			gotoHell ${ABORT}
		    fi

		    STACK_PMDATA[$x1]=${STACK_MACHINE_RAW[$x1]}
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_PMDATA[$x1]=${STACK_PMDATA[$x1]}"
		    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique"

		    STACK_PMDATA[$x1]=`${_VHOST} -o MACHINE -M first "${STACK_PMDATA[$x1]}" ";PM;" ";VM;" `

		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_PMDATA[$x1]=${STACK_PMDATA[$x1]}"

		    if [ -z "${STACK_PMDATA[$x1]}" ];then
			ABORT=1;
			local _index=0;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Missing data of basic PM/VM=${STACK_MACHINE[$x1]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "in cacheDB(${DBPATHLST})."
			printERR $LINENO $BASH_SOURCE ${ABORT} "  $((_index++)). Check with \"ctys-vhost.sh...\""

			case "${STACK_SES[$x1]}" in 
			    QEMU)
				printERR $LINENO $BASH_SOURCE ${ABORT} "  $((_index++)). Check VDE with \"ctys-steupVDE ...\""
				;;
			    *)
				;;
			esac

			printERR $LINENO $BASH_SOURCE ${ABORT} "  $((_index++)). Start VM \"ctys -t ${STACK_SES[$x1]} -a create=t:${STACK_MACHINE[$x1]}...\""
			printERR $LINENO $BASH_SOURCE ${ABORT} "  $((_index++)). Call: \"ctys-genmconf.sh -x VM ${STACK_MACHINE[$x1]}\""
			printERR $LINENO $BASH_SOURCE ${ABORT} "  $((_index++)). Call: \"ctys-vdbgen.sh ...\""
			gotoHell ${ABORT}
		    fi
		    ;;
	    esac

	    let x1++;
	done
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-OK"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME-OK"
    }



    #
    #the stacking of hosts, the location on one and the same location
    function verifyCreateOnly () {
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-ENTRY"
	local siz=${#STACK_SES[@]}
	local x=0;
	for((x=0;x<${siz};x++));do
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACK_ACT[$x]=${STACK_ACT[$x]}"
	    if [ "${STACK_ACT[$x]}" != CREATE ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Current VMSTACK supports CREATE only"
		printERR $LINENO $BASH_SOURCE ${ABORT} "$x:"
		printERR $LINENO $BASH_SOURCE ${ABORT} "  ${STACK_ACT[$x]}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "  ${STACK_SES[$x]}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "  ${STACK_MACHINE[$x]}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "  ${STACK_EXECTARGET[$x]}"
		gotoHell ${ABORT}
	    fi
	done
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-OK"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME-OK"
	return
    }


    #
    #the stacking of hosts, the allocation on one and the same location
    function verifyStacking () {
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-ENTRY"
	local siz=${#STACK_SES[@]}
	local x=0;
	for((x=0;x<${siz};x++));do
	    case ${STACK_SES[$x]} in
		PM)#assume PM only for x=0
		    if [ $x -ne 0 ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Current VMSTACK supports PM for layer-0 only"
			printERR $LINENO $BASH_SOURCE ${ABORT} "layer=$x"
			gotoHell ${ABORT}
		    fi
		    if [ -n "${STACK_MACHINE[$x]}" ];then
			ping -c 1 -w 1 ${STACK_MACHINE[$x]} 2>&1 >/dev/null
			STACK_SES[$x]=$?
			continue;
		    fi
		    ;;

		XEN|VMW|QEMU)
		    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique -o PM "
		    local PM0=`${_VHOST} -o PM "${STACK_MACHINE[$((x-1))]}"`
		    local PM1=`${_VHOST} -o PM "${STACK_EXECTARGET[$((x))]}"`
		    if [ "${PM0}" != "${PM1}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The provided addresses seem to be inconsistent"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  layer=$x"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  PM0[$((x-1))]            = ${PM0}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_MACHINE[$((x-1))]  = ${STACK_MACHINE[$((x-1))]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  PM1[$((x))]              = ${PM1}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_EXECTARGET[$((x))] = ${STACK_EXECTARGET[$((x))]}"
			gotoHell ${ABORT}
		    fi
		    ;;

		X11|CLI|VNC)#keep it seperate for now
		    if [ "${STACK_MACHINE[$((x-1))]}" != "${STACK_EXECTARGET[$((x))]}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The provided addresses seem to be inconsistent"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  layer=$x"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_MACHINE[$((x-1))]  = ${STACK_MACHINE[$((x-1))]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_EXECTARGET[$((x))] = ${STACK_EXECTARGET[$((x))]}"
			gotoHell ${ABORT}
		    fi
		    ;;
	    esac
	done
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-OK"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME-OK"
	return
    }


    #
    #For now just do the basics:
    #- appropriate hypervisor-type, version still checked dynamically
    function verifyStackCapability () {
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-ENTRY"
	local siz=${#STACK_SES[@]}
	local x=0;
	for((x=0;x<${siz};x++));do
	    case ${STACK_SES[$x]} in
		PM)
		    ;;

		XEN|VMW|QEMU)
		    local _myses="${STACK_SES[$x]}";
		    local _mybase="${STACK_PMDATA[$((x-1))]}"

		    if [ "${_mybase//$_myses/}" == "${_mybase}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The provided addresses does not match STACKREQ<==>STACCAP"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  layer=$x"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_MACHINE[$x]        = ${STACK_MACHINE[$x]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_SES[$x]            = ${STACK_SES[$x]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_PMDATA[$((x-1))]   = ${STACK_PMDATA[$((x-1))]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_VMDATA[$((x-1))]   = ${STACK_VMDATA[$((x-1))]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_MACHINE[$((x-1))]  = ${STACK_MACHINE[$((x-1))]}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_EXECTARGET[$((x))] = ${STACK_EXECTARGET[$((x))]}"
			gotoHell ${ABORT}
		    fi
		    ;;


		X11|CLI|VNC)
		    ;;
	    esac
	done
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-OK"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME-OK"
	return
    }



    #
    #For now just do the basics:
    #- appropriate CPU/ARCH
    #
    #PAE for now ignored, anyhow might be available in most relevant cases.
    #HVM for now ignored, started with PVM only.
    function verifyHardwareCapabilityStatic () {
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-ENTRY"

	local siz=${#STACK_SES[@]}
	local x=0;
	for((x=0;x<${siz};x++));do
	    case ${STACK_SES[$x]} in
		PM)
		    ;;

		XEN|VMW|QEMU)
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "STACK_PMDATA[$((x-1))]   = ${STACK_PMDATA[$((x-1))]}"
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "STACK_VMDATA[$x]   = ${STACK_VMDATA[$x]}"
		    local _reqvarch=`echo "${STACK_VMDATA[$x]}"|awk -F';' '{printf("%s",$38);}'`;
		    local _reqvcpu=`echo "${STACK_VMDATA[$x]}"|awk -F';' '{printf("%s",$41);}'`;
		    local _reqvram=`echo "${STACK_VMDATA[$x]}"|awk -F';' '{printf("%s",$40);}'`;
		    _reqvram="${_reqvram%M}";

                    #ARCH
		    local _availvarch=`echo "${STACK_PMDATA[$((x-1))]}"|awk -F';' '{printf("%s",$38);}'`;

                    #CPU
		    local _availvcpu=`echo "${STACK_PMDATA[$((x-1))]}"|awk -F';' '{printf("%s",$41);}'`;
		    local _availvmaxcpu="${_availvcpu##*/}";
		    _availvcpu="${_availvcpu%/*}";

                    #RAM
		    local _availvram=`echo "${STACK_PMDATA[$((x-1))]}"|awk -F';' '{printf("%s",$40);}'`;
		    local _availvmaxram=${_availvram##*/};
		    _availvram=${_availvram%%/*};
		    _availvram=${_availvram%M};
		    _availvmaxram=${_availvmaxram%M};
		    _availvmaxram=${_availvmaxram:-$_availvram};

                    

		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "STACK_SES[$x]           = ${STACK_SES[$x]}"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_reqvcpu      =$_reqvcpu"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_availvcpu    =$_availvcpu"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_availvmaxcpu =$_availvmaxcpu"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_reqvram      =$_reqvram"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_availvram    =$_availvram"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_availvmaxram =$_availvmaxram"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_reqvarch     =$_reqvarch"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_availvarch   =$_availvarch"

		    if((_reqvcpu>_availvcpu));then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "  The provided number of #CPUs is not sufficient"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    layer      =$x"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    _reqvcpu   =$_reqvcpu(${STACK_MACHINE[$x]})"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    _availvcpu =$_availvcpu(${STACK_EXECTARGET[$x]})"
			gotoHell ${ABORT}
		    fi

		    if((_reqvram>_availvram));then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "  The provided amount of RAM is not sufficient"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    layer      =$x"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    _reqvram   =$_reqvram(${STACK_MACHINE[$x]})"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    _availvram =$_availvram(${STACK_EXECTARGET[$x]})"
			gotoHell ${ABORT}
		    fi

		    local _archMatch=0;
		    case "${_reqvarch}" in
			i86pc|i386)
                            #first assumption for finishing a version, but see PVM!!!
			    case "${_availvarch}" in
				i86pc)  _archMatch=1;;
				i386)  _archMatch=1;;
				x86_64)_archMatch=1;;
				amd64) _archMatch=1;;
			    esac
			    ;;
			x86_64)
			    case "${_availvarch}" in
				x86_64)_archMatch=1;;
				amd64) _archMatch=1;;
			    esac
			    ;;
			amd64)
			    case "${_availvarch}" in
				x86_64)_archMatch=1;;
				amd64) _archMatch=1;;
			    esac
			    ;;
			*)
			    if [ -z "${_reqvarch// /}" -o -z "${_availvarch// /}" ];then
				_archMatch=1;
				printINFO 1 $LINENO $BASH_SOURCE 0 "  One ARCH only given, assume compatibility"
				printINFO 1 $LINENO $BASH_SOURCE 0 "    layer=$x"
				printINFO 1 $LINENO $BASH_SOURCE 0 "    _reqvarch   =${_reqvarch}(${STACK_MACHINE[$x]})"
				printINFO 1 $LINENO $BASH_SOURCE 0 "    _availvarch =${_availvarch}(${STACK_EXECTARGET[$x]})"
			    else
				if [ "${_reqvarch}" == "${_availvarch}" ];then
				    _archMatch=1;
				fi
			    fi
			    ;;
		    esac

		    if((_archMatch!=1));then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "  The provided ARCH does not match the required"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    layer       =$x"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    _reqvarch   =$_reqvarch(${STACK_MACHINE[$x]})"
			printERR $LINENO $BASH_SOURCE ${ABORT} "    _availvarch =$_availvarch(${STACK_EXECTARGET[$x]})"
			gotoHell ${ABORT}
		    fi
		    ;;


		X11|CLI|VNC)
		    ;;
	    esac
	done
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-OK"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME-OK"
	return
    }


    #
    #For now just do the basics:
    #- just complete starts are supported for now, this can be an additional
    #  substack ontop of an existing, but no implicit re-usage is supported.
    #- The only and one execption s the PM.
    #
    function verifyStackLocation () {
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-ENTRY"
	local siz=${#STACK_SES[@]}
	local ret=0;
	local x=0;

	STACKER_STARTIDX=0;

	for((x=0;x<${siz};x++));do
	    case ${STACK_SES[$x]} in
		PM)
		    ping -c 1 -w 1 ${STACK_MACHINE[$x]} 2>&1 >/dev/null
		    ret=$?
		    if [ $ret -eq 0 ];then
			STACKER_STARTIDX=${STACK_IDX[$x]};
		    fi
		    ;;

		XEN|VMW|QEMU)
		    ping -c 1 -w 1 ${STACK_MACHINE[$x]} 2>&1 >/dev/null
		    ret=$?
		    if [ $ret -eq 0 ];then
			case ${C_STACKREUSE} in
			    0)  #force initial
				ABORT=1;
				local _tcpX0=`${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -i -n "${STACK_MACHINE_RAW[$x]};"`
				local _tcpX1=`${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -i -n "${STACK_EXECTARGET[$x]};"`
				printERR $LINENO $BASH_SOURCE ${ABORT} "REUSE of stack is disabled, but parts are active."
				printERR $LINENO $BASH_SOURCE ${ABORT} "Check VMSTACK options and \"-k\" option"
				printERR $LINENO $BASH_SOURCE ${ABORT} "The following entry is already running:"
 				printERR $LINENO $BASH_SOURCE ${ABORT} "  layer=$x"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_SES[$x]=${STACK_SES[$x]}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_MACHINE_RAW[$x]=${STACK_MACHINE_RAW[$x]}(${_tcpX0})"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_EXECTARGET[$x]=${STACK_EXECTARGET[$x]}(${_tcpX1})"
				gotoHell ${ABORT}
				;;

			    1)  #check bottom
				local _pnam=`cacheGetMachineAddressFromCall PNAME FROMCALL ${JOB_EXECSERVER[$((x-1))]}`
				if [ -n "$_pnam" ];then
				    local _x="${MYLIBEXECPATH}/ctys.sh -t ${STACK_SES[$x]} -a ISACTIVE=${_pnam} ${STACK_EXECTARGET[$x]}"
				    if [ "${_x#*=}" == 1 ];then
					ABORT=2;
					local _tcpX0=`${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -i -n "${STACK_MACHINE_RAW[$x]};"`
					local _tcpX1=`${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -i -n "${STACK_EXECTARGET[$x]};"`
					printERR $LINENO $BASH_SOURCE ${ABORT} "The requested VMSTACK is already partially active,"
					printERR $LINENO $BASH_SOURCE ${ABORT} "but not in accordance to the requested location."
					printERR $LINENO $BASH_SOURCE ${ABORT} "The following entry is already running:"
 					printERR $LINENO $BASH_SOURCE ${ABORT} "  layer=$x"
					printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_SES[$x]=${STACK_SES[$x]}"
					printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_MACHINE_RAW[$x]=${STACK_MACHINE_RAW[$x]}(${_tcpX0})"
					printERR $LINENO $BASH_SOURCE ${ABORT} "But not on:"
					printERR $LINENO $BASH_SOURCE ${ABORT} "  STACK_EXECTARGET[$x]=${STACK_EXECTARGET[$x]}(${_tcpX1})"
					gotoHell ${ABORT}
				    fi
				    STACKER_STARTIDX=${STACK_IDX[$x]};
				else
				    ABORT=2;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "STACK REUSE resuires correct setup of cacheDB."
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Refer to \"ctys-vdbgen.sh\" for further information."
				    printERR $LINENO $BASH_SOURCE ${ABORT} "The following cannot be resolved:"
 				    printERR $LINENO $BASH_SOURCE ${ABORT} "  layer=$x"
				    printERR $LINENO $BASH_SOURCE ${ABORT} "  JOB_EXECSERVER[$((x-1))]=${JOB_EXECSERVER[$((x-1))]}"
				    gotoHell ${ABORT}
				fi
				;;

			    2)  #reuse topmost, if present, do not care about bottom consistency
				STACKER_STARTIDX=${STACK_IDX[$x]};
				;;

			esac
		    fi

		    ;;

		X11|CLI|VNC)
		    ;;
	    esac
	done
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-OK"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME-OK"
	return
    }





    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-FETCH-DATA"
    collectStackData

    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-VERIFY-STACKER"
    verifyCreateOnly
    verifyStacking

    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-VERIFY-STACKCONTENT"
    verifyStackCapability
    verifyHardwareCapabilityStatic

    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-VERIFY-STACKRUNTIME"
    verifyStackLocation

    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME-OK"
    printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME-OK"
    return
}

