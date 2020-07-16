# ref: https://www.nxp.com/docs/en/user-guide/IMXLXYOCTOUG.pdf
# machine options -  •  imx6qpsabreauto•  imx6qpsabresd•  imx6ulevk•  imx6ull14x14evk•  imx6ull9x9evk•  imx6dlsabreauto•  imx6dlsabresd•  imx6qsabreauto•  imx6qsabresd•  imx6slevk•  imx6solosabreauto•  imx6solosabresd•  imx6sxsabresd
echo 	"Make sure all the packages required for Yocto build is installed."
echo 	"TODO: Script can be extended to install any package that is needed but installed yet."
# sudo apt-get update
# sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
#     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
#     xz-utils debianutils iputils-ping libsdl1.2-dev xterm

echo 	"This scipt is expected to run from a empty folder (for the first time) or a folder where the script was run previously."
echo 	"TODO: Add check and remove this comment."

root=$(pwd -P)

# One time only setup 
setup()
{
if [ -d ~/bin/repo ] 
then
    	echo "Setup is already available" 
else
	echo "Setup - starting." 
	mkdir ~/bin 
	curl https://storage.googleapis.com/git-repo-downloads/repo  > ~/bin/repo
	chmod a+x ~/bin/repo
	echo "Setup - Done." 
fi
export PATH=~/bin:$PATH 
}

# Sync Code from repository
code_sync()
{
	mkdir imx-yocto-bsp
	cd imx-yocto-bsp
	repo init -u https://source.codeaurora.org/external/imx/imx-manifest  -b imx-linux-rocko -m imx-4.9.88-2.0.0_ga.xml
	repo sync 
}

# Modify local.conf - platform specific.
#cat 	>> 	${root}/build/conf/local.conf <<EOF

###################################################
###
### Configuration added by script
###
###################################################
#MENDER_ARTIFACT_NAME	= 	"release-1"
#INHERIT 		+= 	"mender-full"
#MACHINE 		= 	"raspberrypi3"
#RPI_USE_U_BOOT 		= 	"1"
#MENDER_PARTITION_ALIGNMENT_KB 	= 	"4096"
#MENDER_BOOT_PART_SIZE_MB 	= 	"40"
#IMAGE_INSTALL_append 		= 	"kernel-image kernel-devicetree"
#IMAGE_FSTYPES_remove 		+= 	"rpi-sdimg"
# Build for Hosted Mender
# To get your tenant token, log in to https://hosted.mender.io,
# click your email at the top right and then "My organization".
# Remember to remove the meta-mender-demo layer (if you have added it).
# We recommend Mender 1.4.0 and Yocto Project's rocko or later for Hosted Mender.
#
# MENDER_SERVER_URL 			= 	"https://hosted.mender.io"
# MENDER_TENANT_TOKEN 			= 	"<YOUR-HOSTED-MENDER-TENANT-TOKEN>"
#DISTRO_FEATURES_append 			= 	"systemd"
#VIRTUAL-RUNTIME_init_manager 		= 	"systemd"
#DISTRO_FEATURES_BACKFILL_CONSIDERED 	= 	"sysvinit"
#VIRTUAL-RUNTIME_initscripts 		= 	""
#IMAGE_FSTYPES 				= 	"ext4"
#EOF


build()
{
	DISTRO=fsl-imx-wayland MACHINE=imx6slevk source fsl-setup-release.sh -b Build
	bitbake fsl-image-qt5-validation-imx
}

setup
code_sync
build

# Flash the binary in SD card.
#echo	"file to copy to SD card:"
#echo 	${root}/build/tmp/deploy/images/raspberrypi3/core-image-full-cmdline-raspberrypi3.sdimg

#echo	"File to copy to SD card for mender build"
#echo    ${root}/build/tmp/deploy/images/raspberrypi3/core-image-full-cmdline-raspberrypi3.mender
#echo 	"Flash using this command"
#echo 	"sudo dd if=build-basic/tmp/deploy/images/raspberrypi3/core-image-full-cmdline-raspberrypi3.sdimg of=/dev/mmcblk0 bs=4M"
