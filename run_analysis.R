## Title: Getting and Cleaning Data Course Project
## FileName: run_analysis.R

## Work directory contains a directory "UCI HAR Dataset" with "test" and "train" folders
## and other necessary files

## Load Features.txt to get the columnn mapping
f<-read.table("UCI HAR Dataset/features.txt")

## Load Activity mapping
act_lab<-read.table("UCI HAR Dataset/activity_labels.txt")
## Add Column names to activity reference table
names(act_lab)<-c("code","activity")

## loaddata function reads three file, adds column names and binds it into
## one data frame
loaddata<-function(subject,data,activity){
        ## Load Subjects from Training folder
        sub<-read.table(subject)
        ## Add "subject" header
        names(sub)<-c("subject")
                
        ## Load activity  Data
        dat<-read.table(data)
        ## Add column names from features
        names(dat)<-f[,2]
                
        ## Load Activity identfier
        act<-read.table(activity)
        ## Add the column name for activity code
        names(act)<-c("code")
        
        ## Column bind subjec, activity and training data
        dataWI<-cbind(sub,act,dat)
}

##Load training data
train<-loaddata("UCI HAR Dataset/train/subject_train.txt","UCI HAR Dataset/train/X_train.txt","UCI HAR Dataset/train/y_train.txt")

##load test data
test<-loaddata("UCI HAR Dataset/test/subject_test.txt","UCI HAR Dataset/test/X_test.txt","UCI HAR Dataset/test/y_test.txt")

## 1.Merges the training and the test sets to create one data set.
## Combine test and training data
dt<-rbind(train,test)

## 3.Uses descriptive activity names to name the activities in the data set
## Add meaning full activity names based on the activity code
dt<-merge(dt,act_lab,by.x="code",by.y="code")


##get the list of all the columns that are either mean or standard deviation (std)
mean_cols<- grep("mean",names(dt))
std_cols<-grep("std",names(dt))

## final column list subject, activity, mean and std
fcols<-c(c(2,564),mean_cols,std_cols)

## 2.Extracts only the measurements on the mean and standard deviation for each measurement.
## 4.Appropriately labels the data set with descriptive variable names
## filter down to needed columns
dtStdMean<-dt[,fcols]

## clean up column names to remove "-" and "()"
tmpnames<-names(dtStdMean)[3:81]
tmpnames<-gsub("-","_",tmpnames)
tmpnames<-gsub("\\()","",tmpnames)

## set the cleaned up column names
names(dtStdMean)[3:81]<-tmpnames

## Use the summaryBy function from the "doBy" library 
library("doBy")

## 5.From the data set in step 4, creates a second, independent tidy data set with the average of each 
##variable for each activity and each subject.
## create tidy data to show means of all activity columns by subject and activity
tidy_data_MeanBySubjectActivity<-summaryBy(list(c(names(dtStdMean)[3:81]),c("subject","activity")),data=dtStdMean,FUN=c(mean))

## Save Tidy data to a text file without row names
write.table(tidy_data_MeanBySubjectActivity,"tidy_data.txt",row.names=FALSE)


