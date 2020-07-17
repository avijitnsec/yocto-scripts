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
	sudo apt-get install repo
}


# Sync Code from repository
code_sync()
{
	mkdir imx-yocto-bsp
	cd imx-yocto-bsp
	repo init -u http://github.com/boundarydevices/boundary-bsp-platform -b zeus
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
	#MACHINE=nitrogen6x DISTRO=boundary-wayland source setup-environment build-test
	MACHINE=nitrogen6x DISTRO=fslc-x11 source setup-environment boundary-eval-image
	bitbake boundary-image-multimedia-full
}

instructions()
{
	echo "The image file will deploy to tmp/deploy/images/{MACHINE}/boundary-image-multimedia-full-{MACHINE}.wic.gz"
	echo "The image is a SD card image that can be restored using zcat and dd under Linux."
	echo "zcat *boundary-image*.wic.gz | sudo dd of=/dev/sdX bs=1M"
}


setup
code_sync
build
instructions

