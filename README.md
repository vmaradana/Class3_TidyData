---
title: "Readme describes the various files in this folder and run_anlaysis.R that describes the steps for data cleansing"
output: html_document
---

**Readme.md** : Describes the purpose of each file

**run_analysis.R** : This file contains the scipt with the list of steps to cleanup and create tidy_data.txt. Code assumes Working directory contains a directory "UCI HAR Dataset" with "test" and "train" folders and other files from source archive

**CodeBook.md** : Describes the steps and variables for each of the r steps performed to get to the final result

**tidy_data.txt** : Final output

##Analysis Steps
**Step 1**: Load features.txt (column mapping) into a vairiabl 'f'

```{r}
f<-read.table("UCI HAR Dataset/features.txt")
```

**Step 2**: Load Activity mapping and set the column names so that they can be referenced further below

```{r}
act_lab<-read.table("UCI HAR Dataset/activity_labels.txt")
names(act_lab)<-c("code","activity")
```

**Step 3**: created a loaddata function that reads three files, adds column names and binds it into one data frame. To be used with train and test data

```{r}
loaddata<-function(subject,data,activity)
        {
                sub<-read.table(subject)
                names(sub)<-c("subject")
                dat<-read.table(data)
                names(dat)<-f[,2]
                act<-read.table(activity)
                names(act)<-c("code")
                dataWI<-cbind(sub,act,dat)
        }     
```

**Step 4**: Load Train and Test data use the load data function from above 

```{r}
train<-loaddata("UCI HAR Dataset/train/subject_train.txt","UCI HAR Dataset/train/X_train.txt","UCI HAR Dataset/train/y_train.txt")
test<-loaddata("UCI HAR Dataset/test/subject_test.txt","UCI HAR Dataset/test/X_test.txt","UCI HAR Dataset/test/y_test.txt")
```

**Step 5**: Merges the training and the test sets to create one data set.

```{r}
dt<-rbind(train,test)
```

**Step 6**: Add meaning full activity names based on the activity code

```{r}
dt<-merge(dt,act_lab,by.x="code",by.y="code")
```

**Step 7**: Build a list of all the columns that are either mean or standard deviation (std) using grep. Also add the subject and activity columns

```{r}
tmpnames<-gsub("\\()","",tmpnames)
std_cols<-grep("std",names(dt))
fcols<-c(c(2,564),mean_cols,std_cols)
```


**Step 8**: Extracts into dtStdMeans only the measurements on the mean and standard deviation for each measurement from dt.

```{r}
dtStdMean<-dt[,fcols]
```

**Step 9**: clean up column names to remove "-" and "()"

```{r}
tmpnames<-names(dtStdMean)[3:68]
tmpnames<-gsub("-","_",tmpnames)
tmpnames<-gsub("\\()","",tmpnames)
## set the cleaned up column names
names(dtStdMean)[3:68]<-tmpnames
```

**Step 10**: Use the summaryBy function from the "doBy" library on  dtStdMean to create independent tidy data set with the average of each variable for each activity and each subject.

```{r}
library("doBy")
tidy_data_MeanBySubjectActivity<-summaryBy(list(c(names(dtStdMean)[3:68]),c("subject","activity")),data=dtStdMean,FUN=c(mean))
```

**Step 11**: Save tidy data to a file

```{r}
write.table(tidy_data_MeanBySubjectActivity,"tidy_data.txt",row.names=FALSE)
```
