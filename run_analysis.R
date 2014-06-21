## This script reads in data from the Human Activity Recognition
## database that was built from the recordings of 30 subjects 
## peforming acitivities of daily living while carrying a waist-
## mounted smartphone. The data can be found at the University of
## California Irvine Machine Learning Repository website.
## The script reads in the raw data and then processes it into
## the desired format, as required by the Coursera Course Project
## for the online course Getting and Cleaning Data

## First the data files are read into separate data frames

testData <- read.table("UCI HAR Dataset/test/X_test.txt")
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt")
testActivity <- read.table("UCI HAR Dataset/test/y_test.txt")
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")
trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainActivity <- read.table("UCI HAR Dataset/train/y_train.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
featuresLabels <- read.table("UCI HAR Dataset/features.txt")

## rename the column names for the appropriate data frames

names(testData) <- featuresLabels[[2]]
names(testSubject) <- "subjectid"
names(testActivity) <- "activityid"
names(trainData) <- featuresLabels[[2]]
names(trainSubject) <- "subjectid"
names(trainActivity) <- "activityid"
names(activityLabels) <- c("activityid", "activity")

## combine the different data frames into one 'bigdata' set that
## includes the raw data from the test group and the train group

trainGroup <- cbind(trainSubject, trainActivity, trainData)
testGroup <- cbind(testSubject, testActivity, testData)
bigdata <- rbind(trainGroup, testGroup)

## subset the 'bigdata' by only including the measurements that
## reference "mean" or "Mean" or "std" in their column names, 
## as well as the subjectid and activityid columns and then
## merge the newly subsetted data with the activityLabels data
## using the default common 'activityid' column name

newcolumns <- grep("[Mm]ean|std", names(bigdata))
smallerdata <- bigdata[c(1:2, newcolumns)]
smallerdata <- merge(smallerdata, activityLabels, all = FALSE)

## edit variable names in 'smallerdata' to make them easier to
## work with by removing and substituting ( ) - , characters 

names(smallerdata) <- gsub("-", "_", names(smallerdata))
names(smallerdata) <- gsub(",", ".", names(smallerdata))
names(smallerdata) <- gsub("\\(", "", names(smallerdata))
names(smallerdata) <- gsub("\\)", "", names(smallerdata))

## convert the subjectid column into a factor variable and then
## summarize the data by listing only the means of each measurement
## by subjectid and activity and then write the data to a file

library(reshape2)
finaldata <- data.frame(subjectid = rep(1:30, each = 6), activity = activityLabels$activity)
smallerdata$subjectid <- factor(smallerdata$subjectid)
for (i in 3:(length(names(smallerdata))-1)) {
	newcalcs <- tapply(smallerdata[[i]], smallerdata[,c("subjectid", "activity")], mean)
	newdata <- melt(newcalcs, id = "subjectid", measure.vars = colnames(newcalcs))
	names(newdata)[names(newdata) == "value"] <- names(smallerdata)[i]
	finaldata <- merge(finaldata, newdata, all = FALSE)	
}
finaldata <- finaldata[order(finaldata$subjectid),]
write.table(finaldata, file = "tidy_data_project.txt", row.names = FALSE)









