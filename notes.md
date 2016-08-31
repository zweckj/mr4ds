+ System library access on VS, IDEs in general
+ azureML, good data science methods
+ course portal internally
+ saveRDS
+ remove reverse assignment operator examples
+ share best standards for code practices
+ add courses to prereqs:
	* https://www.edx.org/course/introduction-r-data-science-microsoft-dat204x-1
	* https://www.edx.org/course/programming-r-data-science-microsoft-dat209x-1
+ Linux DSVM setup
	* ssh into server
	* download rstudio server
		- wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-rhel-0.99.1294-x86_64.rpm
		- sudo yum install ./rstudio-server-rhel-0.99.1294-x86_64.rpm
		- open the 8787 port on azure inbound security rules
			+ properties
			+ network interfaces
			+ security group
			+ network security group
			+ inbound security rules
	* add users
		- chmod 755 ./create-users.sh
		- ./create-users.sh
