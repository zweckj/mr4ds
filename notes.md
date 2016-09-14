Questions, Notes and Updates
=============================

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
+ [Andrie's Blog Post](http://blog.revolutionanalytics.com/2015/12/setting-up-an-azure-resource-manager-virtual-machine-with-rstudio.html)


## Additions for next course

1. Add exercises/labs
2. Add a PowerBI sample to day 1 (this could be the lab)
3. Add a AzureML example to day 2
4. Update the AzureML webservice through R in Day 3
5. `MicrosoftRML` 


# Trip Report

On August 29 - September 2nd, I delivered Microsoft R training to the ADS team in London, an external partner, and two members of the SI team at Xbox.


## To Write

+ Survey Results
+ Highlights
+ Lowlights