fix_package()
{
	echo	"Fixing package	->	$1"
	echo	"old version	->	$2"
	echo	"new version	->	$3"
	echo	"old hash	->	$4"
	echo	"new hash	->	$5"

	root=$(pwd -P)

	filename_mk=$root/buildroot/package/$1/$1.mk
	filename_hash=$root/buildroot/package/$1/$1.hash

	# Replace pacage version and hash value
	sed -i "s/$2/$3/g" "$filename_mk"
	sed -i "s/$2/$3/g" "$filename_hash"
	sed -i "s/$4/$5/g" "$filename_hash"

	# Remove all patch files
	rm -rf $root/buildroot/package/$1/*.patch

}

echo "Preferably run the script from a empty directory for the first time"

# TODO:Setup the environment

# Download the latest Buildroot tree
git 	clone 	https://git.busybox.net/buildroot 				-b 	2017.08.x

# Download Boundary Devices external layer
git 	clone 	https://github.com/boundarydevices/buildroot-external-boundary 	-b 	2017.08.x


# e2fsprogs
fix_package	e2fsprogs	'1.43.4'	'1.45.6'	\
	'54b3f21123a531a6a536b9cdcc21344b0122a72790dbe4dacc98e64db25e4a24'	\
	'ffa7ae6954395abdc50d0f8605d8be84736465afc53b8938ef473fcf7ff44256'

# flex
fix_package	flex		'2.6.4'		'2.5.39'	\
	'e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995'	\
	'71dd1b58158c935027104c830c019e48c73250708af5def45ea256c789318948'

# Fixing xlocale.h file not found error.
ln 	-s 	/usr/include/locale.h /usr/include/xlocale.h

# Config defconfig
make	BR2_EXTERNAL=$PWD/buildroot-external-boundary/	\
	-C buildroot/ 	\
  	O=$PWD/output	\
	nitrogen6x_qt5_gst1_defconfig

# Build the code
cd	output;
make 	-j4

# TODO: Add the check if the build is successful
echo 	"Rootfs is ready ! Please verify manually if there is any error in the build"

echo	"Flash the build in the SD card using the following command:"
echo	"~/output$ ls -l images/sdcard.img"
echo	"~/output$ sudo dd if=images/sdcard.img of=/dev/sdX bs=1M"

