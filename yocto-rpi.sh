echo 	"Make sure all the packages required for Yocto build is installed."
echo 	"TODO: Script can be extended to install any package that is needed but installed yet."
# sudo apt-get update
# sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
#     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
#     xz-utils debianutils iputils-ping libsdl1.2-dev xterm

echo 	"This scipt is expected to run from a empty folder (for the first time) or a folder where the script was run previously."
echo 	"TODO: Add check and remove this comment."

root=$(pwd -P)

# Source should be inside this directory
mkdir 	${root}/src

# Clone Yocto source
git clone -b rocko git://git.yoctoproject.org/poky ${root}/src/poky

# Clone layers for HW and services

# Mender is for OTA
git clone -b rocko git://github.com/mendersoftware/meta-mender ${root}/src/meta-mender

# Build automation FW
git clone -b rocko git://git.openembedded.org/meta-openembedded ${root}/src/meta-openembedded

#Platform specific. change is for differnt platform
git clone -b rocko git://git.yoctoproject.org/meta-raspberrypi ${root}/src/meta-raspberrypi

source	${root}/src/poky/oe-init-build-env 	${root}/build

# Adding layers to bblayers.conf
bitbake-layers 	add-layer 	${root}/src/meta-openembedded/meta-oe
bitbake-layers 	add-layer 	${root}/src/meta-openembedded/meta-python
bitbake-layers 	add-layer 	${root}/src/meta-openembedded/meta-multimedia
bitbake-layers 	add-layer 	${root}/src/meta-openembedded/meta-networking
# Platform specific
bitbake-layers 	add-layer 	${root}/src/meta-raspberrypi
bitbake-layers 	add-layer 	${root}/src/meta-mender/meta-mender-core
bitbake-layers 	add-layer 	${root}/src/meta-mender/meta-mender-raspberrypi


# Modify local.conf - platform specific.
cat 	>> 	${root}/build/conf/local.conf <<EOF

###################################################
###
### Configuration added by script
###
###################################################
MENDER_ARTIFACT_NAME	= 	"release-1"
INHERIT 		+= 	"mender-full"
MACHINE 		= 	"raspberrypi3"
RPI_USE_U_BOOT 		= 	"1"
MENDER_PARTITION_ALIGNMENT_KB 	= 	"4096"
MENDER_BOOT_PART_SIZE_MB 	= 	"40"
IMAGE_INSTALL_append 		= 	"kernel-image kernel-devicetree"
IMAGE_FSTYPES_remove 		+= 	"rpi-sdimg"
# Build for Hosted Mender
# To get your tenant token, log in to https://hosted.mender.io,
# click your email at the top right and then "My organization".
# Remember to remove the meta-mender-demo layer (if you have added it).
# We recommend Mender 1.4.0 and Yocto Project's rocko or later for Hosted Mender.
#
# MENDER_SERVER_URL 			= 	"https://hosted.mender.io"
# MENDER_TENANT_TOKEN 			= 	"<YOUR-HOSTED-MENDER-TENANT-TOKEN>"
DISTRO_FEATURES_append 			= 	"systemd"
VIRTUAL-RUNTIME_init_manager 		= 	"systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED 	= 	"sysvinit"
VIRTUAL-RUNTIME_initscripts 		= 	""
IMAGE_FSTYPES 				= 	"ext4"
EOF

# Run the build.Change the build type based on platoform and build flavor
echo 	"TODO: Check for fail case manually."
bitbake	core-image-full-cmdline


# Flash the binary in SD card.
echo	"file to copy to SD card:"
echo 	${root}/build/tmp/deploy/images/raspberrypi3/core-image-full-cmdline-raspberrypi3.sdimg

echo	"File to copy to SD card for mender build"
echo    ${root}/build/tmp/deploy/images/raspberrypi3/core-image-full-cmdline-raspberrypi3.mender
echo 	"Flash using this command"
echo 	"sudo dd if=build-basic/tmp/deploy/images/raspberrypi3/core-image-full-cmdline-raspberrypi3.sdimg of=/dev/mmcblk0 bs=4M"
