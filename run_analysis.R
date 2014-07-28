# The purpose of this script is to extract the data available at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# and to create two tidy data sets containing:
# 1 - variables with applied mean and standard deviation on the original data source and broken down by Subject and Activities
# 2 - mean values of data set above broken down by Subject and Activities.
# This script will save the created data sets in the "./TidyData" directory.
# Please make sure that you have unzipped the source data into your working directory!
# More information on source data sets can be obtained at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

# Object that contains list of all relevant files

#For some reasons '_' were changed to '-' marks in directory names

files<-c(
  features="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//features.txt",
  activity_labels="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//activity_labels.txt",
  x_test="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//test/X_test.txt",
  y_test="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//test/y_test.txt",
  subject_test="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//test/subject_test.txt",
  x_train="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//train//X_train.txt",
  y_train="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//train//y_train.txt",
  subject_train="getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset//train//subject_train.txt"
)

# Stopping if any file is missing
if(any(!file.exists(files))){
  stop("There are missing files or working directory is improper")
}
  
# Creating otuput directory
tidy_data_directory="./TidyData"
if(!file.exists(tidy_data_directory)){
  dir.create(tidy_data_directory)
}

require(plyr)

# Reading files with variable names. This will be used as column headers
var_names<-read.table(files[['features']], sep=" ", skipNul=TRUE)

# Reading activity dictionary. This will be merged later on.
activity_dict<-read.table(files[['activity_labels']], sep=" ", skipNul=TRUE)
# Transformation on activity values are done in order to maintain tidy data characteristics.
activity_dict[,2]<-gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", activity_dict[,2], perl=TRUE)
activity_dict[,2]<-gsub("(\\w*)_(\\w)(\\w*)", "\\1\\U\\2\\L\\3", activity_dict[,2], perl=TRUE)

# Names that will be applied to final table. Please note that variables like *meanFreq* have not been included intentionally.
names<-c("Subject", "Activity", grep("mean\\(\\)|std\\(\\)", var_names$V2, value=TRUE))

# Reading test data and preprocessing
raw_data<-read.table(files[['x_test']], skipNul=TRUE)
activities<-read.table(files[['y_test']], sep=" ", skipNul=TRUE)
subjects<-read.table(files[['subject_test']], sep=" ", skipNul=TRUE)

# The combined data frame will be the first data set
combined<-data.frame(subjects[,1], join(activities, activity_dict, by="V1")[,2], raw_data[,grep("mean\\(\\)|std\\(\\)", var_names$V2)])

# Reading train data and preprocessing
raw_data<-read.table(files[['x_train']], skipNul=TRUE)
activities<-read.table(files[['y_train']], sep=" ", skipNul=TRUE)
subjects<-read.table(files[['subject_train']], sep=" ", skipNul=TRUE)

# Combining two data sets
combined<-rbind(combined, data.frame(subjects[,1], join(activities, activity_dict, by="V1")[,2], raw_data[,grep("mean\\(\\)|std\\(\\)", var_names$V2)]))

#Remove rows with any missing values
if (any(is.na(combined))){
    combined<-combined[complete.cases(combined),]
}

# Fixing variable names. Note that variable names include capital letters due to the number and complexity of those names. This is intentionally
# left to maintain the descriptive character of variable names.
names<-gsub("BodyBody","Body",names)
names<-gsub("^f","Freq",names)
names<-gsub("^t","Time",names)
# Moving applied function description into the beginning; removal of forbidden marks
names<-gsub("(.*)-mean\\(\\)","Mean\\1",names)
names<-gsub("(.*)-std\\(\\)","StDev\\1",names)
names<-gsub("-","",names)

#Apply names to tidy table
names(combined)<-names

# Saving first data set
write.table(x=combined, file=paste(tidy_data_directory,"/tidy_first.txt", sep=""), sep=" ", quote=FALSE, row.names=FALSE)

#Generating second table - aggregating and ordering by Subject and Activity
final<-aggregate(combined[names[-c(1:2)]], by=combined[c("Subject","Activity")], FUN=mean)
final<-final[order(final$Subject, final$Activity),]
row.names(final)<-seq(1:nrow(final))

# Saving second data set
write.table(x=final, file=paste(tidy_data_directory, "/tidy_second.txt", sep=""), sep=" ", quote=FALSE, row.names=FALSE)

# Removal of unused data sets to free memory
remove(var_names, activity_dict, raw_data, activities, subjects, names, files, tidy_data_directory)