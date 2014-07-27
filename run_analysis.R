setwd("./TidyData/")

#reading files with variable names. This will be used as column headers
var_names<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//features.txt", sep=" ", skipNul=TRUE)

#reading activity dictionary -> for merging
activity_dict<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//activity_labels.txt", sep=" ", skipNul=TRUE)

#names that will be applied to final table
names<-c("Subject", "Activity", grep("mean|std", var_names$V2, value=TRUE))

###########################
# Combining to data sets
###########################
# 1. Reading test data and preprocessing

raw_data<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//test/X_test.txt", skipNul=TRUE)
#reading activity data
activities<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//test/y_test.txt", sep=" ", skipNul=TRUE)
#reading subjects
subjects<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//test/subject_test.txt", sep=" ", skipNul=TRUE)

combined<-data.frame(subjects[,1], merge(activity_dict, activities, by.x="V1", by.y="V1", all=TRUE)[,2], raw_data[,grep("mean|std", var_names$V2)])

# 2. Reading train data and preprocessing

raw_data<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//train//X_train.txt", skipNul=TRUE)
#reading activity data
activities<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//train//y_train.txt", sep=" ", skipNul=TRUE)
#reading subjects
subjects<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset//train//subject_train.txt", sep=" ", skipNul=TRUE)

# 3. Final table
combined<-rbind(combined, data.frame(subjects[,1], merge(activity_dict, activities, by.x="V1", by.y="V1", all=TRUE)[,2], raw_data[,grep("mean|std", var_names$V2)]))
names(combined)<-names


# 4. Fixing variable names. Note that variable names include capital letters due to the number and complexity of those names. This is intentionally
# left to maintain the descriptive character of variable names.
# Removal of some erroneous or unconventional substrings
names<-gsub("Freq","",names)
names<-gsub("BodyBody","Body",names)

# Changing f and t into Freq and Time
names<-gsub("^f","Freq",names)
names<-gsub("^t","Time",names)

# Moving applied function description into the beginning; removal of forbidden marks
names<-gsub("(.*)-mean\\(\\)","Mean\\1",names)
names<-gsub("(.*)-std\\(\\)","StDev\\1",names)

# Removal of remaining '-'
names<-gsub("-","",names)


