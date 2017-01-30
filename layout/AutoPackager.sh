#!/bin/bash

DEBROOT=$1
AUTONAME=$2
IP_ADDRESS=$3

if [[ $DEBROOT == "" ]]; then
	read -e -p "Please set your package path : " DEBROOT
fi

if [[ $AUTONAME == "" ]]; then
	echo "Filename format"
	echo "1. author_package_version.deb"
	echo "2. package_version.deb"
	echo "3. package.deb"
	echo "4. None (Directory name)"
	read -p "" AUTONAME
fi

if [[ $IP_Address == "" ]]; then
	IP_ADDRESS=127.0.0.1
fi

cd $DEBROOT/DEBIAN
echo $DEBROOT/DEBIAN

find ./ -iname ".DS_Store" -exec rm {}  \;
find ./ -iname "Thumbs.db" -exec rm {}  \;

if [[ $AUTONAME != "4" ]]; then
	AUTHOR=$(grep Package: control | sed -e 's/Package://'  -e 's/ //' | awk -F "." '{ print $2}')
	PACKAGE=$(grep Package: control | sed -e 's/Package://'  -e 's/ //' | awk -F "." '{ print $3}')
	VERSION=$(grep Version: control | sed -e 's/Version://' -e 's/ //')
fi

cd ../../

export DEBNAME

case "$AUTONAME" in
	1 ) DEBNAME=$AUTHOR\_$PACKAGE\_$VERSION.deb
		;;
	2 ) DEBNAME=$PACKAGE\_$VERSION.deb
		;;
	3 ) DEBNAME=$PACKAGE.deb
		;;
	* ) DEBNAME=$DEBROOT.deb
		;;
esac

rsync -e "ssh -p 2222" -r -z $DEBROOT/* root@$IP_ADDRESS:/User/DEB/$DEBROOT
ssh root@$IP_ADDRESS -p 2222 packager /User/DEB/$DEBROOT lzma $AUTONAME y
rsync -e "ssh -p 2222" -z root@$IP_ADDRESS:/User/DEB/$DEBNAME ./