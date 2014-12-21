#!/bin/sh
#
# prepare kernel and ramdisk for suse installs
# see http://www.suse.de/~kraxel/xen/suse-guest.html
#
####################################################################################

# create work dir
WORK="${TMPDIR-/tmp}/${0##*/}-$$"
mkdir "$WORK" || exit 1
trap 'echo "### cleanup ..."; rm -rf "$WORK"' EXIT

####################################################################################
# helper functions

function do_extract() {
	local rpm="$1"
	local rpmarch="$2"

	if test ! -f "$rpm"; then
		echo "rpm doesn't exist: $rpm"
		exit 1
	fi
	echo "### unpack $rpm ..."
	mkdir -p $WORK/${rpmarch}
	rpm2cpio "$rpm" | (cd $WORK/${rpmarch}; \
		cpio --extract --make-dir --quiet --unconditional)
}

####################################################################################
# go!

cd $(dirname $0)
kernels=$(echo $(pwd)/kernel-*.rpm)

for kernel in $kernels; do
	# get name
	flavor=${kernel##*/kernel-}
	flavor=${flavor%%-*}
	release=$(rpm -q --queryformat="%{VERSION}-%{RELEASE}" -p "$kernel")
	rpmarch=$(rpm -q --queryformat="%{ARCH}" -p "$kernel")
	fprefix="inst.${flavor}-${release}-${rpmarch}"
	initrd=$(echo $(pwd)/install-initrd*.${rpmarch}.rpm)
	# kernel
	do_extract "$kernel" "${rpmarch}"
	cp $WORK/${rpmarch}/boot/*linu*-${release}-${flavor} ${fprefix}-kernel
	# initrd
	test -f $WORK/${rpmarch}/usr/sbin/mkinstallinitrd ||\
		do_extract "$initrd" "${rpmarch}"
	echo "### create $flavor install ramdisk ..."
	$WORK/${rpmarch}/usr/sbin/mkinstallinitrd		\
	  --libdir=$WORK/${rpmarch}/usr/lib/install-initrd	\
	  --kernel-rpm=$kernel ${fprefix}-ramdisk
	# list files
	ls -l ${fprefix}-*
done
echo "### all done"

