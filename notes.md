## Questions

+ course portal internally
+ saveRDS instead of .Rdata objects
+ remove reverse assignment operator examples
+ share best standards for code practices
+ Update repo with instructions on getting data for MRS for SAS Users course

## Setting up a Linux DSVM with RStudio
+ Propvision a Linux DSVM on Azure
+ ssh into server
+ download rstudio server
+ wget https://s3.amazonaws.com/rstudio-dailybuilds/+studio-server-rhel-0.99.1294-x86_64.rpm
+ sudo yum install ./rstudio-server-rhel-0.99.1294-x86_64.rpm
+ open the 8787 port on azure inbound security rules
	* properties
	* network interfaces
	* security group
	* network security group
	* inbound security rules
+ add users using the script provided
+ chmod 755 ./create-users.sh
+ ./create-users.sh
* [Andrie's Blog Post](http://blog.revolutionanalytics.com/2015/12/setting-up-an-azure-resource-manager-virtual-machine-with-rstudio.html)