Microsoft R for Data Science Workshop
======================================

Welcome to the Microsoft R for Data Science Course Repository. You can find the latest materials from the workshop here, and links for course materials from prior iterations of the course ca be found in the [version pane](https://github.com/akzaidi/R-cadence/releases). While this course is intended for data scientists and analysts interested in the Microsoft R programming stack (i.e., Microsoft employees in the Algorithms and Data Science group), other programmers might find the material useful as well.

## Current Links

+ [Collab Edit](http://collabedit.com/2xutq)
+ [Survey Link](https://www.surveymonkey.co.uk/r/3WPD6M3)
+ [Signup Sheet, please fill out before class!](https://microsoft.sharepoint.com/teams/ADS_education/_layouts/15/WopiFrame.aspx?sourcedoc=%7b6D621161-3AB7-41D5-9C23-1B2C6940EF0C%7d&file=ParticipantBackground-London08-29-16.xlsx&action=default)
    * I'll use the signup sheet to email you, so add your email address if you want to be contacted with updates
+ Download Data as a zip file, and extract to directory
    * [data link](https://alizaidi.blob.core.windows.net/training/data.zip)
+ Download data for dplyrXdf tutorial:
    * download.file("https://alizaidi.blob.core.windows.net/training/yellow_tripdata_2015.xdf", destfile = "yellow_tripdata_2015.xdf")


## Course Syllabus

Please refer to the [course syllabus](https://github.com/akzaidi/R-cadence/wiki/Syllabus) for the full syllabus. The goal of this course is to cover the following modules, although some of the latter modules might be repalced for a hackathon/office hours.

+ Topics:
    * R Fundamentals
    * Data Manipulation with `dplyr`
    * Data Manipulation with `dplyrXdf`
    * Modeling and Scoring with Microsoft R
    * Parallel Computing with the `RevoScaleR` package
    * Deploying Models with the `AzureML` package
    * RxSpark and R APIs for Spark

## DSVMs

We will use DSVMs (Data Science Virtual Machines) from the Azure marketplace to run the course materials. For the Spark training, we will use Spark HDInsight Premium clusters, also from Azure. If you are interested in running these materials in a different environment, see the course [wiki](https://github.com/akzaidi/R-cadence/wiki) for instructions. 

+ JupyterHub:
	* https://londonrtrain.northeurope.cloudapp.azure.com:8000/hub/login
	* https://londontwo.northeurope.cloudapp.azure.com:8000/hub/login
+ RStudio Server:
	* http://londonrtrain.northeurope.cloudapp.azure.com:8787/
	* http://londontwo.northeurope.cloudapp.azure.com:8787/

# Logistics

+ Need >=MRS 8.0.3
+ an R IDE

# Course Repository

We are still in the process of transitioning our course materials from our Revolution Repository to the Azure repository and Cortana gallery. Currently, you can find the following two courses on the Cortana Gallery:

* [MRS for SAS Users](https://github.com/Azure/Cortana-Intelligence-Gallery-Content/blob/master/Tutorials/MRS-for-SAS-Users/MRS%20for%20SAS%20Users.md)
* [R for SAS Users](https://github.com/Azure/Cortana-Intelligence-Gallery-Content/blob/master/Tutorials/R-for-SAS-Users/R%20for%20SAS%20Users.md)
