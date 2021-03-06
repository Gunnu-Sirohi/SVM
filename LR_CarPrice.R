## Set working directory to file location
## load libraries
library(MASS)
library(car)
library(dplyr)
library(ggplot2)
library(reshape2)


## Load data
carprice<-read.csv("CarPrice_Assignment.csv",stringsAsFactors = FALSE)
View(carprice)
str(carprice)

summary(carprice)


############################---------- DATA CLEANING ----------########################################

##-----------clean "Carname" column data-----------------

carprice$CarCompany<-sub("\\s.*","",carprice$CarName)

carprice$CarName<- NULL

distinct(carprice,carprice$CarCompany)

carprice$CarCompany<-sub("maxda","mazda",carprice$CarCompany)
carprice$CarCompany<-sub("porcshce","porsche",carprice$CarCompany)
carprice$CarCompany<-sub("toyouta","toyota",carprice$CarCompany)
carprice$CarCompany<-sub("vokswagen","volkswagen",carprice$CarCompany)
carprice$CarCompany<-sub("vw","volkswagen",carprice$CarCompany)

carprice$CarCompany<-tolower(carprice$CarCompany)

#distinct(carprice,carprice$CarCompany)

str(carprice)

##---------------------De duplicate rows-------

carprice<-unique(carprice) 
# no duplicate rows

##---------------------Check for Missing value-------

No_of_NA<-sum(is.na(carprice)) 
No_of_NA
# no missing values


###############################----------DATA PREPRATION--------############################################

##---------------------Outlier treatment------------------------
quantile(carprice$price,seq(0,1,0.01))
carprice$wheelbase[which(carprice$wheelbase > 36809.60)]<-36809.60

quantile(carprice$symboling,seq(0,1,0.01))


quantile(carprice$wheelbase,seq(0,1,0.01))
carprice$wheelbase[which(carprice$wheelbase > 115.544)]<-115.544


quantile(carprice$carlength,seq(0,1,0.01))
carprice$carlength[which(carprice$carlength > 202.480)]<-202.480
carprice$carlength[which(carprice$carlength < 155.900)]<-155.900

quantile(carprice$carwidth,seq(0,1,0.01))

quantile(carprice$carheight ,seq(0,1,0.01))


quantile(carprice$enginesize,seq(0,1,0.01))
carprice$enginesize[which(carprice$enginesize > 209.00)]<-209.00

quantile(carprice$boreratio,seq(0,1,0.01))

quantile(carprice$stroke,seq(0,1,0.01))
#carprice$stroke[which(carprice$stroke > 3.9000)]<-3.9000
carprice$stroke[which(carprice$stroke < 2.6400)]<-2.6400

quantile(carprice$compressionratio,seq(0,1,0.01))
carprice$compressionratio[which(carprice$compressionratio > 10.9400)]<-10.9400

quantile(carprice$horsepower,seq(0,1,0.01))
carprice$stroke[which(carprice$stroke > 207.00)]<-207.00

quantile(carprice$peakrpm,seq(0,1,0.01))

quantile(carprice$citympg,seq(0,1,0.01))

quantile(carprice$highwaympg,seq(0,1,0.01))
carprice$highwaympg[which(carprice$highwaympg > 49.88)]<-49.88


##########################-----EXPLORATORY DATA ANALYSIS PART - 1----------#####################################

FuelType<-ggplot(data.frame(carprice), aes(x=fueltype)) + geom_bar() # fuel type = "Gas" is 5 times fuel type = "Disel"
#FuelType
Aspiration<-ggplot(data.frame(carprice), aes(x=aspiration))+ geom_bar() # std aspiration most common
#Aspiration
Doornumber<-ggplot(data.frame(carprice), aes(x=doornumber))+ geom_bar()
#Doornumber
Enginelocation<-ggplot(data.frame(carprice), aes(x=enginelocation))+ geom_bar() # Engine location rear is rare
#Enginelocation
Carbody<-ggplot(data.frame(carprice), aes(x=carbody))+ geom_bar() #sedan and hatchback more popular carbody
#Carbody
hist(carprice$symboling)
Drivewheel<-ggplot(data.frame(carprice), aes(x=drivewheel))+ geom_bar() # most cars have FWD drivewheel
#Drivewheel
Enginetype<-ggplot(data.frame(carprice), aes(x=enginetype))+ geom_bar() # Ohc engine type most common
#Enginetype
Cylindernumber<-ggplot(data.frame(carprice), aes(x=cylindernumber))+ geom_bar() # four cylinders most common
#Cylindernumber
Fuelsystem<-ggplot(data.frame(carprice), aes(x=fuelsystem))+ geom_bar() # mpfi and 2bbl are most common fuel systems
#Fuelsystem
CarCompany<-ggplot(data.frame(carprice), aes(x=CarCompany)) + geom_bar()
#CarCompany
## toyota,nissan,mazda,hona,mitsubhishi are the brands which are most occuring in this data set



#####################---------convert factors with 2 levels to numerical variables------########################

carprice$fueltype<-as.factor(carprice$fueltype)
levels(carprice$fueltype)<-c(1,0)
carprice$fueltype<- as.numeric(levels(carprice$fueltype))[carprice$fueltype]

carprice$aspiration<-as.factor(carprice$aspiration)
levels(carprice$aspiration)<-c(1,0)
carprice$aspiration<- as.numeric(levels(carprice$aspiration))[carprice$aspiration]

carprice$doornumber<-as.factor(carprice$doornumber)
levels(carprice$doornumber)<-c(1,0)
carprice$doornumber<- as.numeric(levels(carprice$doornumber))[carprice$doornumber]


carprice$enginelocation<-as.factor(carprice$enginelocation)
levels(carprice$enginelocation)<-c(1,0)
carprice$enginelocation<- as.numeric(levels(carprice$enginelocation))[carprice$enginelocation]



################################---------Create DUMMY Variables----------#######################################

##---------------carbody---------------------

dummy_carbody <- data.frame(model.matrix( ~carbody, data = carprice))
#View(dummy_carbody)
dummy_carbody <- dummy_carbody[,-1]

carprice_1 <- cbind(carprice[,-6], dummy_carbody)

##---------------symboling---------------------

carprice_1$symboling<-as.factor(carprice_1$symboling)
dummy_symboling <- data.frame(model.matrix( ~symboling, data = carprice_1))
#View(dummy_symboling)
dummy_symboling <- dummy_symboling[,-1]

carprice_1 <- cbind(carprice_1[,-2], dummy_symboling)

##---------------drivewheel---------------------

dummy_drivewheel <- data.frame(model.matrix( ~drivewheel, data = carprice_1))
#View(dummy_drivewheel)
dummy_drivewheel <- dummy_drivewheel[,-1]

carprice_1 <- cbind(carprice_1[,-5], dummy_drivewheel)

##---------------enginetype---------------------

dummy_enginetype <- data.frame(model.matrix( ~enginetype, data = carprice_1))
#View(dummy_enginetype)
dummy_enginetype <- dummy_enginetype[,-1]

carprice_1 <- cbind(carprice_1[,-11], dummy_enginetype)

##---------------cylindernumber---------------------

dummy_cylindernumber <- data.frame(model.matrix( ~cylindernumber, data = carprice_1))
#View(dummy_cylindernumber)
dummy_cylindernumber <- dummy_cylindernumber[,-1]

carprice_1 <- cbind(carprice_1[,-11], dummy_cylindernumber)

##---------------fuelsystem---------------------

dummy_fuelsystem <- data.frame(model.matrix( ~fuelsystem, data = carprice_1))
#View(dummy_fuelsystem)
dummy_fuelsystem <- dummy_fuelsystem[,-1]

carprice_1 <- cbind(carprice_1[,-12], dummy_fuelsystem)


###############################---------------DERIVED METRICS------###################################################

ggplot(data.frame(carprice), aes(x=CarCompany)) + geom_bar()

# based on the frequency seen in above graph , dividing car brands into four categories.

##------------------- Creating levels of popularity -------------------------
carprice$CarCompany[carprice$CarCompany %in% c("toyota","nissan","mazda")] <- "Highly Popular"
carprice$CarCompany[carprice$CarCompany %in% c("honda","mitsubishi","volkswagen","subaru","volvo","peugeot")] <- "Popular"
carprice$CarCompany[carprice$CarCompany %in% c("dodge","bmw","buick","audi","plymouth","saab")] <- "Not-so Popular"
carprice$CarCompany[carprice$CarCompany %in% c("porsche","isuzu","jaguar","alfa-romero","chevrolet","renault","mercury")] <- "Least Popular"

carprice$CarCompany <- as.factor(carprice$CarCompany)

dummy_Popularity<-data.frame(model.matrix(~CarCompany,data=carprice))
dummy_Popularity<-dummy_Popularity[,-1]

carprice_1<-cbind(carprice_1[,-20],dummy_Popularity)

str(carprice_1)

##----------------------- Remove car id column -----------------------------

## as card id column is a unique identifier of rows it has no business impact , hence removing it

carprice_1$car_ID<- NULL


#################################------- EXPLORATORY DATA ANALYSIS PART -2 --------#################################

##--------------------- Comparision with price-----------------------------------

hist(carprice_1$price)                           # most cars under 20000 

plot(carprice_1$fueltype,carprice_1$price)     # Fuel type show no clear impact on price
plot(carprice$carlength,carprice$price)        # increase in length has marginal increase in price with few exceptions
plot(carprice$carwidth,carprice$price)         # increase in width shows increase in price 
plot(carprice$carheight,carprice$price)        # Hieght shows no impact on price
plot(carprice$wheelbase,carprice$price)        # wheel base do not show no clear impact on Price
plot(carprice$curbweight,carprice$price)       # increase in bweight shows increase in price
plot(carprice$enginesize,carprice$price)       # increase in engine size shows increase in price
plot(carprice$boreratio,carprice$price)        # boreratio shows no clear impact
plot(carprice$stroke,carprice$price)           # stroke has np impact on price
plot(carprice$compressionratio,carprice$price) # compressionratio has no clear impact on price
plot(carprice$horsepower,carprice$price)       # price increases with increase in horse power
plot(carprice$peakrpm,carprice$price)          # peakrpm shows no clear impact on price
plot(carprice$citympg,carprice$price)          # as city mpg increase , price decreases
plot(carprice$highwaympg,carprice$price)       # as highway mpg increase , price decrease


str(carprice_1)
View(carprice_1)

#################################-------Check Corelation -----------------#######################################

Corelation<-round(cor(carprice_1),digits = 2)
melted_cormat <- melt(Corelation)

#DF contaoning high postivie corelation data
Positive_cor<-melted_cormat[Corelation > .60 & Corelation < 1.00,]
#View(Positive_cor)
#check which variable is most positively co related
High_Poscor_Var<-table(Positive_cor$Var1)
#View(High_Poscor_Var) 

#curbweight,enginesize,carwidth,horsepower,curbweight are positive corelated with multiple variables

#DF contaoning high negative corelation data
Negative_cor<-melted_cormat[Corelation < -.60 & Corelation > -1.00,]
#View(Negative_cor)
#check which variable is most negatively co related
High_Negcor_Var<-table(Negative_cor$Var1)
#View(High_Negcor_Var)

#cylindernumberfour,citympg,highwaympg are negatively corelated with multiple variables

##################################------separate training and testing data-------#################################


set.seed(100)
trainindices= sample(1:nrow(carprice_1), 0.7*nrow(carprice_1))
train = carprice_1[trainindices,]
test = carprice_1[-trainindices,]


###################################---Variable selection : Backward & StepAIC------############################

###################################------------ Model_1 -----------------#######################################

model_1 <-lm(price~.,data=train)
summary(model_1)
#Adjusted R-squared:  0.9375 

###################################------------ StepAIC -----------------#######################################

step <- stepAIC(model_1, direction="both")

step

###################################------------ Model_2 -----------------#######################################

model_2<-lm(formula = price ~ fueltype + aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1 + drivewheelrwd + 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix + fuelsystem2bbl + fuelsystemmfi + fuelsystemmpfi + 
              fuelsystemspdi + CarCompanyLeast.Popular + CarCompanyNot.so.Popular, 
            data = train)

summary(model_2)
#Adjusted R-squared:  0.9436

VIF2<-sort(vif(model_2))
View(VIF2)


#drivewheelrwd has high VIF 3.095923 and high p value  0.10676  , hence remove this column in next model

###############################--------------Model_3--------------------#########################################

model_3<-lm(formula = price ~ fueltype + aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1+ 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix + fuelsystem2bbl + fuelsystemmfi + fuelsystemmpfi + 
              fuelsystemspdi + CarCompanyLeast.Popular + CarCompanyNot.so.Popular, 
            data = train)

summary(model_3)

#Adjusted R squar : 0.9428

VIF3<-sort(vif(model_3))
#View(VIF3)



## fuelsystem2bbl has high p value  0.096913 , hence remove this column in next model

###############################--------------Model_4--------------------#########################################

model_4<-lm(formula = price ~ fueltype + aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1+ 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix  + fuelsystemmfi + fuelsystemmpfi + 
              fuelsystemspdi + CarCompanyLeast.Popular + CarCompanyNot.so.Popular, 
            data = train)

summary(model_4)

#Adjusted R squar : 0.9401

VIF4<-sort(vif(model_4))
#View(VIF4)

## fuelsystemmpfi has high VIF 2.368873 and high p value  0.241953 , hence remove this column in next model

###############################--------------Model_5--------------------#########################################

model_5<-lm(formula = price ~ fueltype + aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1+ 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix  + fuelsystemmfi  + 
              fuelsystemspdi + CarCompanyLeast.Popular + CarCompanyNot.so.Popular, 
            data = train)


summary(model_5)

#Adjusted R squar : 0.9399

VIF5<-sort(vif(model_5))
#View(VIF5)

## CarCompanyLeast.Popular has high p value  0.180610  , hence remove this column in next model
###############################--------------Model_6--------------------#########################################

model_6<-lm(formula = price ~ fueltype + aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1+ 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix  + fuelsystemmfi  + 
              fuelsystemspdi + CarCompanyNot.so.Popular, 
            data = train)

summary(model_6)

#Adjusted R squar : 0.9395 

VIF6<-sort(vif(model_6))
#View(VIF6)

## fueltype  has  high p value  0.378462  , hence remove this column in next model
###############################--------------Model_7--------------------#########################################

model_7<-lm(formula = price ~  aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1+ 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix  + fuelsystemmfi  + 
              fuelsystemspdi + CarCompanyNot.so.Popular, 
            data = train)

summary(model_7)

#Adjusted R squar : 0.9396 

VIF7<-sort(vif(model_7))
#View(VIF7)

## fuelsystemmfi has  p value  0.155066 , hence remove this column in next model
###############################--------------Model_8--------------------#########################################

model_8<-lm(formula = price ~  aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1+ 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix   + 
              fuelsystemspdi + CarCompanyNot.so.Popular, 
            data = train)

summary(model_8)

#Adjusted R squar : 0.9391

VIF8<-sort(vif(model_8))
#View(VIF8)

## fuelsystemspdi     p value 0.179109  , hence remove this column in next model
###############################--------------Model_9--------------------#########################################

model_9<-lm(formula = price ~  aspiration + enginelocation + 
              wheelbase + carwidth + curbweight + carbodyhardtop + carbodyhatchback + 
              carbodysedan + carbodywagon + symboling.1+ 
              enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
              cylindernumbersix + CarCompanyNot.so.Popular, 
            data = train)


summary(model_9)

#Adjusted R squar : 0.9387

VIF9<-sort(vif(model_9))
#View(VIF9)



##carwidth  has high VIF value 6.604592 and  high p value 0.006802 , hence remove this column in next model
###############################--------------Model_10--------------------#########################################

model_10<-lm(formula = price ~  aspiration + enginelocation + 
               wheelbase  + curbweight + carbodyhardtop + carbodyhatchback + 
               carbodysedan + carbodywagon + symboling.1+ 
               enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
               cylindernumbersix + CarCompanyNot.so.Popular, 
             data = train)


summary(model_10)

#Adjusted R squar : 0.9355

VIF10<-sort(vif(model_10))
#View(VIF10)

##aspiration   p value 0.018357 , hence remove this column in next model
###############################--------------Model_11--------------------#########################################

model_11<-lm(formula = price ~   enginelocation + 
               wheelbase  + curbweight + carbodyhardtop + carbodyhatchback + 
               carbodysedan + carbodywagon + symboling.1+ 
               enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
               cylindernumbersix + CarCompanyNot.so.Popular, 
             data = train)


summary(model_11)

#Adjusted R squar : 0.9332 

VIF11<-sort(vif(model_11))
#View(VIF11)

##carbodyhardtop  high p value 0.008625  , hence remove this column in next model
###############################--------------Model_12--------------------#########################################

model_12<-lm(formula = price ~   enginelocation + 
               wheelbase  + curbweight  + carbodyhatchback + 
               carbodysedan + carbodywagon + symboling.1+ 
               enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
               cylindernumbersix + CarCompanyNot.so.Popular, 
             data = train)

summary(model_12)

#Adjusted R squar : 0.93 

VIF12<-sort(vif(model_12))
#View(VIF12)

##carbodysedan   p value 0.202607  , hence remove this column in next model
###############################--------------Model_13--------------------#########################################

model_13<-lm(formula = price ~   enginelocation + 
               wheelbase  + curbweight  + carbodyhatchback+ carbodywagon + symboling.1+ 
               enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
               cylindernumbersix + CarCompanyNot.so.Popular, 
             data = train)

summary(model_13)

#Adjusted R squar : 0.9297 

VIF13<-sort(vif(model_13))
#View(VIF13)

##carbodyhatchback high p value 0.131142  , hence remove this column in next model
###############################--------------Model_14--------------------#########################################

model_14<-lm(formula = price ~   enginelocation + 
               wheelbase  + curbweight  +  carbodywagon + symboling.1+ 
               enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
               cylindernumbersix + CarCompanyNot.so.Popular, 
             data = train)

summary(model_14)

#Adjusted R squar : 0.929

VIF14<-sort(vif(model_14))
#View(VIF14)

##symboling.1 has p value 0.023014  , hence remove this column in next model
###############################--------------Model_15--------------------#########################################

model_15<-lm(formula = price ~   enginelocation + 
               wheelbase  + curbweight  +  carbodywagon + 
               enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + 
               cylindernumbersix + CarCompanyNot.so.Popular, 
             data = train)

summary(model_15)

#Adjusted R squar : 0.9266

VIF15<-sort(vif(model_15))
#View(VIF15)

##cylindernumbersix has p value 1.84e-13   , hence remove this column in next model
###############################--------------Model_16--------------------#########################################

model_16<-lm(formula = price ~   enginelocation + 
               wheelbase + curbweight  + carbodywagon +  
               enginetypel + enginetyperotor + cylindernumberfive + cylindernumberfour + CarCompanyNot.so.Popular, 
             data = train)


summary(model_16)

#Adjusted R squar : 0.8901

VIF16<-sort(vif(model_16))
#View(VIF16)

## enginetyperotor   p value 0.101972 a, hence remove this column in next model
###############################--------------Model_17--------------------#########################################

model_17<-lm(formula = price ~   enginelocation + 
               wheelbase + curbweight  + carbodywagon +  
               enginetypel  + cylindernumberfive + cylindernumberfour + CarCompanyNot.so.Popular, 
             data = train)

summary(model_17)

#Adjusted R squar : 0.8887  

VIF17<-sort(vif(model_17))
#View(VIF17)

## wheelbase has p value : 0.010737
###############################--------------Model_18--------------------#########################################

model_18<-lm(formula = price ~   enginelocation  + curbweight  + carbodywagon +  
               enginetypel  + cylindernumberfive + cylindernumberfour + CarCompanyNot.so.Popular, 
             data = train)

summary(model_18)

#Adjusted R squar : 0.884

VIF18<-sort(vif(model_18))
#View(VIF18)

#enginetypel p value : 0.014090
###############################--------------Model_19--------------------#########################################

model_19<-lm(formula = price ~   enginelocation  + curbweight  + carbodywagon + cylindernumberfive + cylindernumberfour + CarCompanyNot.so.Popular, 
             data = train)


summary(model_19)

#Adjusted R squar : 0.8796 

VIF19<-sort(vif(model_19))
#View(VIF19)

#cylindernumberfive p value  0.009140
###############################--------------Model_20--------------------#########################################

model_20<-lm(formula = price ~   enginelocation  + curbweight  + carbodywagon + cylindernumberfour + CarCompanyNot.so.Popular, 
             data = train)

summary(model_20)

#Adjusted R squar : 0.8743

VIF20<-sort(vif(model_20))
View(VIF20)




## At this point all variables are significant and all have low VIF , hence lets test the model

############################------Test the final model-----------------##################################

Predict_1<-predict(model_20,test[,-18])

Predict_cor<-cor(test$price,Predict_1)

R_Squared<-round(Predict_cor^2,digits = 3)
R_Squared

##  PREDICTED R^2 (0.791) and  MODEL R^2(0.8743) 
##  Five significant Independent varialbes as below and their co efficients
## enginelocation           -1.668e+04  
## curbweight                1.081e+01  
## carbodywagon             -3.038e+03  
## cylindernumberfour       -3.562e+03  
## CarCompanyNot.so.Popular  2.554e+03
## intercept                 4.575e+03

## Carcomapny not so pouplar are brand names "dodge","bmw","buick","audi","plymouth","saab" . Each brand's count lies between 9 to 6 in given data.

## Enginelocation , carbody , cylinder number have negative impact on price
## curbweight , brand names have positive impact on price

