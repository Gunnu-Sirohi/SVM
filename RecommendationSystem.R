#----------------Set working directory to file path--------------------------------

#---------------- Load Library ----------------------------------------#

install.packages("skimr")
library(skimr)
library(dplyr)
library(recommenderlab)

#------------------ Data Load --------------------------------------------#

beer_data<-read.csv("beer_data.csv", stringsAsFactors = FALSE)

#----------------- Data understanding ------------------------------------#
str(beer_data)
#475984 records
#  beerid : int
#  profilename : char
# review_overall : number


# reorder the columns : required order : profilename , beerid , review_overall

beer_data<-beer_data[,c(2,1,3)]


# convert beerid to factor

beer_data$beer_beerid<-as.factor(beer_data$beer_beerid)

skim(beer_data)

#_______________________________________________________________________________________
# review_profilename : no null values , 100 empty strings
#                      22498 unique reviewer

# No of empty reviewer profiles names
sum(beer_data$review_profilename=='') # 100

# remove records with empty reviewer name

beer_data<-beer_data[beer_data$review_profilename!='',]

# No of unique reviewers 
length(unique(beer_data$review_profilename)) # 22498

#________________________________________________________________________________________
# beer_id : no null values , 40308 unique beers

length(unique(beer_data$beer_beerid)) #40308

#________________________________________________________________________________________
# review_overall : no null values ,  min - 0 , max - 5 , unique rating - 10

length(unique(beer_data$review_overall))


#--------------------------- Data Prepration ----------------------------#

#___________________________________________________________________________________
# no of reviews with 0 rating
filter(beer_data ,review_overall==0) # 6 reviews with rating = 0

# remove reviews with 0 rating

beer_data<-filter(beer_data ,review_overall!=0) # no records with 0 rating

#__________________________________________________________________________________
# check duplicate reviews for a beer id by same reviewer

head(beer_data %>% count(review_profilename,beer_beerid , sort = TRUE ))

#check for few user and beer id with duplicate reviews
beer_data[beer_data$review_profilename %in% c('akorsak','Arbitrator')& beer_data$beer_beerid %in% c('1013','7971'),]

# select max and distinct reviews 
result <- beer_data %>% 
       group_by(review_profilename,beer_beerid) %>%
       filter(review_overall == max(review_overall)) %>%
       distinct(review_profilename,beer_beerid,review_overall)

# check if above code gave the right subset of data with max and distinct reviews
result[result$review_profilename %in% c('akorsak','Arbitrator') & result$beer_beerid %in% c('1013','7971'),]

#__________________________________________________________________________________
# remove duplicate reviews for a beer id by same reviewer

beer_data <- beer_data %>% 
  group_by(review_profilename,beer_beerid) %>%
  filter(review_overall == max(review_overall)) %>%
  distinct(review_profilename,beer_beerid,review_overall)

#test
beer_data[beer_data$review_profilename %in% c('akorsak','Arbitrator')& beer_data$beer_beerid %in% c('1013','7971'),]

#check if new beer_data has all distinct reviews
head(beer_data %>% count(review_profilename,beer_beerid , sort = TRUE ))

#___________________________________________________________________________________
# no of reviews per beer and optimal value of N

# count how many times a beer id occurs in the df which will give the count of reviews per beer  
review_per_beer<-beer_data %>% group_by(beer_beerid) %>% count(beer_beerid , sort = TRUE)

View(review_per_beer)

# beer id 2093 has been reviewed maximum times ie 977

# check the distribution of number of reviews per beer

quantile(review_per_beer$n, probs=seq(0,1,0.1))

# 0%  10%  20%  30%  40%  50%  60%  70%  80%  90% 100% 
# 1    1    1    1    1    2    2    4    7   21  977  

#  90% of the beers have been reviewed  at least 21 times
# hence  we will keep only those beers which have been reviewed at least 21 times


#___________________________________________________________________________________
# filter beer_data with beers reviewed at least 21 times

Atleast_20<-beer_data %>% group_by(beer_beerid) %>% count(beer_beerid , sort = TRUE) %>% filter(n > 20)

length(unique(Atleast_20$beer_beerid)) #4103

beer_data<-beer_data[beer_data$beer_beerid %in% Atleast_20$beer_beerid ,]

length(unique(beer_data$beer_beerid)) #4103



#___________________________________________________________________________________
# no of reviews per user and optimal value of N

# count number of times a user occur in the df which will give the count of reviews given by that user
review_per_user<-beer_data %>% group_by(review_profilename) %>% count(review_profilename , sort = TRUE)

View(review_per_reviewer)
# northyorksammy has given maximum reviews i.e 1842

# check the spread of number of reviews per user
quantile(review_per_user$n, probs=seq(0,1,0.1))
# 0%  10%  20%  30%  40%  50%  60%  70%  80%  90% 100% 
# 1    1    1    1    2    3    4    8   16   43  821 

#  80% of the user have given reviewes less than 16 times
# hence  we will keep only those users which have  reviewed atleast 16 times


#___________________________________________________________________________________
# filter beer_data with users who have reviewed beer more than 3 times

Morethan_3<-beer_data %>% group_by(review_profilename) %>% count(review_profilename , sort = TRUE) %>% filter(n > 15)

length(unique(Morethan_3$review_profilename)) #4239

beer_data<-beer_data[beer_data$review_profilename %in% Morethan_3$review_profilename ,]

length(unique(beer_data$review_profilename)) #4239

#___________________________________________________________________________________
# realratingMatrix
beer_data <- as.data.frame(beer_data)
beer_matrix <- as(beer_data, "realRatingMatrix")

class(beer_matrix)
#[1] "realRatingMatrix"
#attr(,"package")
#[1] "recommenderl



#-------------------------------- Data Exploration --------------------------------------

#____________________________________________________________________________________
# similar the first ten users are with each other

similar_users <- similarity(beer_matrix[1:10, ],
                            method = "cosine",
                            which = "users")
#Similarity matrix
as.matrix(similar_users)

#Visualise similarity matrix
image(as.matrix(similar_users), main = "User similarity")

#____________________________________________________________________________________
# simlarity between first 10 beers

similar_items <- similarity(beer_matrix[,1:10 ],
                            method = "cosine",
                            which = "items")
as.matrix(similar_items)

image(as.matrix(similar_items), main = "Item similarity")

#___________________________________________________________________________________
#Unique value of rating

unique(getRatings(beer_matrix))
# 4.0 4.5 5.0 3.0 3.5 1.0 2.5 1.5 2.0

#-------------------  Visualise the rating values

library(ggplot2)
qplot(getRatings(beer_matrix), binwidth = 1, 
      main = "Histogram of ratings", xlab = "Rating")

#___________________________________________________________________________________
#The average beer ratings

head(colMeans(beer_matrix))
# 5        6        7        8        9       10 
# 3.529703 3.699519 3.290419 3.500000 3.333333 3.868020



qplot(colMeans(beer_matrix), binwidth = 1, 
      main = "Histogram of ratings", xlab = "Rating")

# Average rating per beer
Beer_Ratings<-colMeans(beer_matrix)
View(Beer_Ratings)

#Overall : Average rating 

mean(Beer_Ratings)
# 3.7

#___________________________________________________________________________________
#The average user ratings

head(rowMeans(beer_matrix))
# 0110x011  05Harley 100floods      1099  1759Girl   1Adam12 
# 4.303030  4.132353  4.067568  3.794118  3.660000  3.750000


qplot(rowMeans(beer_matrix), binwidth = 1, 
      main = "Histogram of ratings", xlab = "Rating")

# Average rating per user
User_Ratings<-rowMeans(beer_matrix)
View(User_Ratings)

#Overall :Average Rating

mean(User_Ratings)
#3.8

#___________________________________________________________________________________
#The average number of ratings given to the beers

qplot(colCounts(beer_matrix), binwidth = 10, 
      main = "beers rated on average", 
      xlab = "# of users", 
      ylab = "# of beers rated")


#Most beer have been rated less number of times
#Very few beer have been rated more

Beer_rating_count<-colCounts(beer_matrix)
View(Beer_rating_count)

mean(Beer_rating_count)

#average number of ratings given to the beers : 74

#___________________________________________________________________________________
#The average number of ratings given by the users

qplot(rowCounts(beer_matrix), binwidth = 10, 
      main = "beers rated on average", 
      xlab = "# of users", 
      ylab = "# of beers rated")

#Most users rate have rated less number of beers
#Very few users have rated more beers


User_rating_count<-rowCounts(beer_matrix)
View(User_rating_count)

mean(User_rating_count)
#average number of ratings by users : 72



#-------------------------------- Recommendation Models ----------------------------------------

#______________________________________________________________________________________________
#Divide data into test


# Split
scheme_split <- evaluationScheme(beer_matrix, method = "split", train = .9,
                           k = 1, given = 2, goodRating = 4)


scheme_split

scheme_cross <- evaluationScheme(beer_matrix, method = "cross-validation", train = .9,
                                 k = 5, given = 2, goodRating = 4)

scheme_cross


#_______________________________________________________________________________________________
#IBCF and UBCF models

algorithms <- list(
  "user-based CF" = list(name="UBCF", param=list(normalize = "Z-score",
                                                 method="Cosine",
                                                 nn=30, minRating=3)),
  "item-based CF" = list(name="IBCF", param=list(normalize = "Z-score"
  ))
)


#_______________________________________________________________________________________________
#Evaluate

# Split
result_split <- evaluate(scheme_split, algorithms, n=c(1, 3, 5, 10, 15, 20))


# Cross
result_cross <- evaluate(scheme_cross, algorithms, n=c(1, 3, 5, 10, 15, 20))


#_______________________________________________________________________________________________
#ROC curve

#Split
plot(result_split, annotate = 1:4, legend="topleft")


#cross
plot(result_cross, annotate = 1:4, legend="topleft")


#________________________________________________________________________________________________
# Final Model 

#ROC curve shows USer Based model is better than Item based


#--------------------------- Top 5 Beer Recommendation -----------------------------------------

recommendation <- Recommender(beer_matrix, method = "UBCF")


#top 5 beers  recommended to the users "cokes", "genog" & "giblet"

# cokes
cokes <- predict(recommendation, beer_matrix['cokes'], n=5)
as(cokes, "list")
# 7971,571,582,599,1346

# genog
genog <- predict(recommendation, beer_matrix['genog'], n=5)
as(genog, "list")
# 34420,11757,19960,148,1093 


#giblet
giblet <- predict(recommendation, beer_matrix['giblet'], n=5)
as(giblet, "list")
# 731,2671,459,141,14916
