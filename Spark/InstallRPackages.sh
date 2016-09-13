#!/usr/bin/env bash

#usage - ./InstallRPackages <package1> <package2> <package3> ...
#example - ./InstallRPackages bitops stringr arules

echo "Sample action script to install R packages..."

if [ -f /usr/bin/R ]
then

	#
	# Example of R package that requires system dependencies
	#

	# echo "Install system dependencies required by rJava..."
	# apt-get -y -f install libpcre3 libpcre3-dev
	# apt-get -y -f install zlib1g-dev

	# echo "Configure R for use with Java..."
	# R CMD javareconf

	#loop through the parameters (i.e. packages to install)
	for i in "$@"; do
		if [ -z $name ]
		then
			name=\'$i\'
		else
			name=$name,\'$i\'
		fi
	done

	echo "Install packages..."
	R --no-save -q -e "install.packages(c($name))"

else
	echo "R not installed"
	exit 1
fi

echo "Finished"