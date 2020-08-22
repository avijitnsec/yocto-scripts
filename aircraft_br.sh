# Contains the list of supported OS and check if the current
# environment is in the list.

# Configuration
TODO: Configuration and logic should be in differnt files. 
br="buildroot_aircraft"
br_ext="buildroot-aircraft-external"
op="output"

br_branch="master"
br_ext_branch="master"

server="https://github.com/avijitnsec"

br_link="$server/$br"
br_ext_link="$server/$br_ext"

br_config="nitrogen6x_qt5_gst1_wifi_defconfig"

isOSSupported()
{
	os_v_supported[0]	= 	"Ubuntu 18.04.4"
	os_supported_flag 	= 	false
	for i in 0
	do
		if [[ $(lsb_release -ds) != "Ubuntu 18.04.4" ]];
		then
			os_supported_flag = true
			break
		fi
	done
}

# Check if the OS is supported
checkOSSupport()
{
	if [ isOSSupported ];
	then
		echo '\e[32mCompatible OS version\e[0m'
	else
		echo '\e[31mIncompatible version.. Recomended version is Ubuntu 18.04\e[0m'
	fi
}

setUpEnvironment()
{
	# TODO:Setup the environment

	# Download the latest Buildroot tree
	git	clone	$br_link	-b	$br_branch
	
	# Download Boundary Devices external layer
	git	clone	$br_ext_link	-b	$br_ext_branch

	# Fixing xlocale.h file not found error.
	#ln 	-s 	/usr/include/locale.h /usr/include/xlocale.h
}

build()
{
	# Config defconfig
	make	BR2_EXTERNAL=$PWD/$br_ext/	\
		-C $br/ 	\
		O=$PWD/$op	\
		$br_config

	# Build the code
	cd	$op;
	make 	-j4
}

echo "\e[33mPreferably run the script from a empty directory for the first time\e[0m"

checkOSSupport
setUpEnvironment
build

# TODO: Add the check if the build is successful
echo 	"Rootfs is ready ! Please verify manually if there is any error in the build"

echo	"Flash the build in the SD card using the following command:"
echo	"~/output$ ls -l images/sdcard.img"
echo	"~/output$ sudo dd if=images/sdcard.img of=/dev/sdX bs=1M"

