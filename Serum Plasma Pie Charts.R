###This R code is to plot the biospecimen processing collection data as requested from Madhuri on Sep. 28, 2022
###the working datafolder in box : All Files/CONNECT_DCEG ONLY/Biospecimen_DCEG ONLY/Biospecimen Metrics/BSI Reports
###the reference code and plots are from Madhuri's SAS code:Biospecimen Pie Charts
###the additional requirements is by email sent from Mahuri on the color adjustment for the freezer time and processing time 
###Author: Jing Wu 09/30/2022
rm(list = ls())
library(bigrquery) ###to download data from GCP
library(data.table) ###to write or read and data management 
library(boxr) ###read or write data from/to box
library(tidyverse) ###for data management
library(dplyr) ###data management
library(reshape)  ###to work on transition from long to wide or wide to long data
library(listr) ###to work on a list of vector, files or..
library(sqldf) ##sql
library(lubridate) ###date time
library(ggplot2) ###plots
library(ggpubr) ###for the publications of plots
library(RColorBrewer) ###visions color http://www.sthda.com/english/wiki/colors-in-r
library(gridExtra)
library(stringr) ###to work on patterns, charaters
library(plyr)
library(rmarkdown) ###for the output tables into other files: pdf, rtf, etc.
library(sas7bdat) ###input data
library(finalfit) #https://cran.r-project.org/web/packages/finalfit/vignettes/export.html t
library(expss) ###to add labels
library(epiDisplay) ##recommended applied here crosstable, tab1
library(summarytools) ##recommended
library(gmodels) ##recommended

#Pulling data from box
box_auth(client_id = "627lww8un9twnoa8f9rjvldf7kb56q1m",
         client_secret = "gSKdYKLd65aQpZGrq9x4QVUNnn5C8qqm") 
box_setwd(dir_id = 170816197126) 

bptl <- box_read(file_id=1030254413292)

#Creating Receipt to Frozen Time Variable
#Every time you create a variable, you have to do data name (bpt1)$VarName
#If you don't include the $ then it is a vector w/ numbers
###time
# ReceiptToFrozenTm = Date_Frozen - Date_Received
#as.PoSIXct is a format for a datetime var using lubridate
bptl$Rpt2FreezenTm <- difftime(as.POSIXct(ymd_hms(bptl$`Date Frozen`)), as.POSIXct(ymd_hms(bptl$`Date Received`)),units="secs")
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# -40500    9900   11580   17064   14280  212520    2888 

# NeedleToFreezerTm = Date_Frozen - Date_Drawn
bptl$Needle2FreezenTm <- difftime(as.POSIXct(ymd_hms(bptl$`Date Frozen`)), as.POSIXct(ymd_hms(bptl$`Date Drawn`)),units="secs")
# > summary(as.numeric(bptl$Needle2FreezenTm))
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#   35880   93960  101640  118579  111420  438120    2888 
bptl$Needle2FreezenHrs <- difftime(as.POSIXct(ymd_hms(bptl$`Date Frozen`)), as.POSIXct(ymd_hms(bptl$`Date Drawn`)),units="hours")
# > summary(as.numeric(bptl$Needle2FreezenHrs))
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#   9.967  26.100  28.233  32.939  30.950 121.700    2888 

bptl$NeedleToFreezerCatM <- ifelse(bptl$Needle2FreezenHrs >= 96, 7,
                                   ifelse(72 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 96, 6,
                                          ifelse(48 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 72, 5,
                                                 ifelse(36 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 48, 4,
                                                        ifelse(30 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 36, 3,
                                                               ifelse(24 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 30, 2,
                                                                      ifelse(0 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs <24, 1,NA)))))))
#To view columns in dataset do: colnames(bptl)

#table function to view var 
table(bptl$NeedleToFreezerCatM)

#Creating new blood dataset bptl_bld where the variable Material Type only has 2 categories- plasma and serum
bptl_bld <-bptl[which(bptl$`Material Type` %in% c("PLASMA","SERUM")),]
#Creating needle_freezen_bld dataset. This is from tidyverse library
#%>% to indicate that we are performing a function to the bpt1_bld dataset- in this case a groupby function
needle_freezen_bld <- bptl_bld %>%
  #group_by is like proc freq, creates freq table. We are creating a frequency table of material type, separating by NeedleToFreezerCatM categories
  group_by(`Material Type`,NeedleToFreezerCatM) %>%
  #including package name dplyr in front of the function  we are using which is the summarize function
  dplyr::summarize(count=n())

#Using CrossTable function to create a list of tables in table1. Creating table of Time categories by Material type plasma and serum
#We don't want total percentage, row percentage, or chisq to show up. We only want column percentage
#Below function is creating a list of tables within table1. This is a list of tables as vectors. 
table1 <- CrossTable(bptl_bld$NeedleToFreezerCatM,bptl_bld$`Material Type`, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)

#Creating table pct. As data frame is a function to create a table out of the above list of tables. 
#We want 2 tables- one is a percentage table and 1 is a freq table. 
#Use cbind which is column bind to bind together column percentage list with frequency list
pct <- as.data.frame(cbind(table1$prop.col,table1$t))
#Create new variable Tm_fnum in order to see rows numbered 1-7 to correspond to the colors
pct$Tm_fnum <- rownames(pct)
#Creating Tmcat vector to label the categories
Tmcat <- c("<24 Hours","24 to < 30 Hours","30 to < 36 Hours", "36 to < 48 Hours","48 to < 72 Hours", "72 to < 96 Hours","greater than 96 Hours")

#Creating Tmcat variable
pct$Tmcat <- ifelse(pct$Tm_fnum==1,"<24 Hours",ifelse(pct$Tm_fnum==2,"24 to < 30 Hours",ifelse(pct$Tm_fnum==3,"30 to < 36 Hours", 
                                                                                               ifelse(pct$Tm_fnum==4,"36 to < 48 Hours",ifelse(pct$Tm_fnum==5,"48 to < 72 Hours", ifelse(pct$Tm_fnum==6,"72 to < 96 Hours","greater than 96 Hours"))))))
#To see what column names look like
colnames(pct)
#Creating serum sub table tb_serumF by extracting columns 2, 4, 5, 6 from table pct
tb_serumF <- pct[,c(2,4,5,6)]
names(tb_serumF) <- c("serum_pct","serum_N","Needle_to_Freezer_num","Needle_to_Freezer_Time")

#Creating new character variable to allow n and % to be in the same cell
#paste0 function does not allow for deliminator; paste function allows for deliminator
#round to keep to a certain decimal point. 2 indicates 2 decimal places, % to have percent sign show up
tb_serumF$Percent <- paste0(round(100*tb_serumF$serum_pct,2),"%")
#arrange function as an order function. Order by Descending time category 1-7
tb_serumF <- tb_serumF %>% arrange(desc(Needle_to_Freezer_num)) 
#Creating new variable text_y for labels. 
#cumsum function is for column sum. This is for the position of the % labels to be in the middle
tb_serumF$text_y <- cumsum(tb_serumF$serum_pct) - tb_serumF$serum_pct/2

#Creating plasmaF table by concatenating columns 1, 3, 5, 6 from pct table
tb_plasmaF <- pct[,c(1,3,5,6)]
#labeling columns 1, 3, 5, 6
names(tb_plasmaF) <- c("plasma_pct","plasma_N","Needle_to_Freezer_num","Needle_to_Freezer_Time")

#same as before calculating % for placement of % labels
tb_plasmaF$Percent <- paste0(round(100*tb_plasmaF$plasma_pct,2),"%")
tb_plasmaF <- tb_plasmaF %>% arrange(desc(Needle_to_Freezer_num)) 
tb_plasmaF$text_y <- cumsum(tb_plasmaF$plasma_pct) - tb_plasmaF$plasma_pct/2

# pct <- as.data.frame(table1$prop.col)
# 
# colnames(pct) <- c("NeedleToFreezerCatM","Material Type","percentage")
# pct <- pct %>% mutate(Tmcat=case_when(NeedleToFreezerCatM ==1 ~ "<24 Hours",
#                                       NeedleToFreezerCatM ==2 ~ "24 to < 30 Hours",
#                                       NeedleToFreezerCatM ==3 ~ "30 to < 36 Hours",
#                                       NeedleToFreezerCatM ==4 ~ "36 to < 48 Hours",
#                                       NeedleToFreezerCatM ==5 ~ "48 to < 72 Hours Hours",
#                                       NeedleToFreezerCatM ==6 ~ "72 to < 96 Hours Hours",
#                                       NeedleToFreezerCatM ==7 ~ "             > 96 Hours",
#                                       is.na(NeedleToFreezerCatM) ~ "", ),
#                       percent=paste0(round(100*percentage,2),"%"))

#Selecting colors. Brewer is the library. Creating mycolors vector. 7 means selecting 7 colors from RdYlGn series- see website
mycolors <- brewer.pal(7,"RdYlGn")
mycolors <- c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026")
#Use barplot to see colors selected. Reset margins to get rid of error that margins are too large
par(mar=c(2.1, 2.1, 2.1, 2.1), mgp=c(3, 1, 0), las=0)
barplot(c(1:7),col=mycolors)
#names function is allowing Needle_to_Freezer_time var to correspond to colors above in same order
names(mycolors) <- levels(tb_serumF$Needle_to_Freezer_Time)
#showing you color name for 7th color
mycolors[7]
#my_color <- setNames(mycolors, nam)

library(ggrepel)

outputpathname <- "C:/Users/natarajanm2/Desktop/"

#Creating pie chart serumF. Aes is key elements to go in plots. 
#geom_col is outline, geom_bar is to first create a bar plot which gets turned into a pie chart, and for the legend. 
#stat = identity means each slice is = y which is the %
serumF <- ggplot(data = tb_serumF, aes(x=" ", y=serum_pct,  fill=Needle_to_Freezer_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  #Adding colored boxes around percentages instead of just black text- using geom_label instead of geom_text
  #geom_text_repel(data=tb_serumF,aes(label=Percent , y =text_y ),nudge_x = 0.8,
  #color="black", size = 4, show.legend = F) + 
  geom_label_repel(data=tb_serumF,aes(label=Percent , y =text_y ),nudge_x = 0.8,
                   colour="white", segment.colour="black", size = 4, show.legend = F) + 
  ggtitle(label = "Needle to Freezer Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Serum") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values =c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026"))  

#Creating plasma pie chart similar to serum pie chart above
plasmaF <- ggplot(data = tb_plasmaF, aes(x=" ", y=plasma_pct,  fill=Needle_to_Freezer_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  #Adding colored box around percent instead of just black text- using geom_label instead of geom_text
  #geom_text_repel(data=tb_plasmaF,aes(label=Percent, y=text_y),nudge_x = 0.8,
  #size = 4, show.legend = F) + 
  geom_label_repel(data=tb_plasmaF,aes(label=Percent , y =text_y ),nudge_x = 0.8,
                   colour="white", segment.colour="black", size = 4, show.legend = F) +
  ggtitle(label = "Needle to Freezer Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Serum") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  #Could have done scale_fill_manual values = mycolors, but re-entering colors in the right order ensures each category will be assigned to the right color
  scale_fill_manual(values =c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026"))  

#Save graphs in 1 page 
# biospe_plot1 <- list(serumF,plasmaF)
# out1 <- paste(outputpathname,"Serum_Plasma_Cumulative_100422_color.pdf",sep="")
# png(out1,height=800,width=1200) 
# grid.arrange(grobs = biospe_plot1, ncol = 2) ## display plot
# ggsave(file = out1, arrangeGrob(grobs = biospe_plot1, ncol = 2))  
# 

###for the ReceiptToProcessedTm = "Time From Receipt of Sample to Processed
#IF ReceiptToProcessedTm = . THEN DELETE;
#ELSE IF ReceiptToProcessedTm < 0 THEN DELETE;

# 1 = "<30 minutes" 
# 2 = "30 min to 1 hour"
# 3 = "1 to 1.5 hours"
# 4 = "1.5 to 2 hours"
# 5 = "2 to 2.5 hours"
# 6 = "2.5 to 3 hours"
# 7 = "3 to 3.5 hours"
# 8 = "3.5 to 4 hours"
# 9 = "4 to 8 hours"
# 10 = "8 to 20 hours"
# 11 = "20 to 24 hours"
# 12 = "24 to 48 hours"
# 13 = "48 to 72 hours"
# 14 = "72 to 96 hours"
# 15 = "Over 96 hours"
# IF ReceiptToProcessedHrs = . THEN ReceiptToProcessedCatM = .;
# ELSE IF ReceiptToProcessedHrs < 0.5 THEN ReceiptToProcessedCatM = 1;
# ELSE IF 0.5 LE ReceiptToProcessedHrs < 1 THEN ReceiptToProcessedCatM = 2;
# ELSE IF 1 LE ReceiptToProcessedHrs < 1.5 THEN ReceiptToProcessedCatM = 3;
# ELSE IF 1.5 LE ReceiptToProcessedHrs < 2 THEN ReceiptToProcessedCatM = 4;
# ELSE IF 2 LE ReceiptToProcessedHrs < 2.5 THEN ReceiptToProcessedCatM = 5;
# ELSE IF 2.5 LE ReceiptToProcessedHrs < 3 THEN ReceiptToProcessedCatM = 6;
# ELSE IF 3 LE ReceiptToProcessedHrs < 3.5 THEN ReceiptToProcessedCatM = 7;
# ELSE IF 3.5 LE ReceiptToProcessedHrs < 4 THEN ReceiptToProcessedCatM = 8;
# ELSE IF 4 LE ReceiptToProcessedHrs < 8 THEN ReceiptToProcessedCatM = 9;
# ELSE IF 8 LE ReceiptToProcessedHrs < 20 THEN ReceiptToProcessedCatM = 10;
# ELSE IF 20 LE ReceiptToProcessedHrs < 24 THEN ReceiptToProcessedCatM = 11;
# ELSE IF 24 LE ReceiptToProcessedHrs < 48 THEN ReceiptToProcessedCatM = 12;
# ELSE IF 48 LE ReceiptToProcessedHrs < 72 THEN ReceiptToProcessedCatM = 13;
# ELSE IF 72 LE ReceiptToProcessedHrs < 96 THEN ReceiptToProcessedCatM = 14;
# ELSE IF ReceiptToProcessedHrs GE 96 THEN ReceiptToProcessedCatM = 15;
# LABEL ReceiptToProcessedCatM = "Time";

#Before was all for Needle to Freezer
#Now this is receipt to processed. Same steps as above. 
bptl$RptToProcessedHrs <-  difftime(as.POSIXct(ymd_hms(bptl$`Date Processed`)), as.POSIXct(ymd_hms(bptl$`Date Received`)),units="hours")
bptl$RptToProcessedCatM <- ifelse(bptl$RptToProcessedHrs >= 96, 15, 
                                  ifelse(72 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 96, 14,
                                         ifelse(48 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 72, 13,
                                                ifelse(24 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 48, 12,
                                                       ifelse(20 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 24, 11,
                                                              ifelse(8 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 20, 10,
                                                                     ifelse(4 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 8, 9,                                   
                                                                            ifelse(3.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 4, 8,
                                                                                   ifelse(3 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 3.5, 7,
                                                                                          ifelse(2.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 3.0, 6,
                                                                                                 ifelse(2 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 2.5, 5,
                                                                                                        ifelse(1.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 2, 4,
                                                                                                               ifelse(1 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 1.5, 3,
                                                                                                                      ifelse(0.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 1.0, 2,
                                                                                                                             ifelse(0 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs <0.5, 1,NA                                             
                                                                                                                             )))))))))))))))

table(bptl$RptToProcessedCatM)
#tapply(as.numeric(bptl$Rpt2ProcessedTm),as.character(bptl$RptToProcessedCatM),summary)
bptl_bld <-bptl[which(bptl$`Material Type` %in% c("PLASMA","SERUM")),]
table2 <- CrossTable(bptl_bld$RptToProcessedCatM,bptl_bld$`Material Type`, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)

pct2 <- as.data.frame(cbind(table2$prop.col,table2$t))
#
PrTmcat <- c("< 0.5 Hours","0.5 to < 1 Hours","1 to < 1.5 Hours", "1.5 to < 2 Hours","2 to < 2.5 Hours", "2.5 to < 3 Hours", "3 to < 3.5 Hours",
             "3.5 to < 4 Hours","4 to < 8 Hours", "8 to < 20 Hours","20 to < 24 Hours", "24 to < 48 Hours","48 to < 72 Hours", "72 to < 96 Hours","greater than 96 Hours")

pct2$PrTmcat_num <- rownames(pct2) #[1] "1"  "2"  "3"  "4"  "5"  "6"  "8"  "9"  "10" "11" "13" #rownames of the table pct is the levels of RptToProcessedCatM
pct2$PrTmcat <- PrTmcat[c(1:6,8:11,13)]

mycolors <- brewer.pal(11,"RdBu")
#mycolors <- c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026")
barplot(c(1:11),col=mycolors)
brewer.pal(n = 11, name = "RdBu")
##[1] "#67001F" "#B2182B" "#D6604D" "#F4A582" "#FDDBC7" "#F7F7F7" "#D1E5F0" "#92C5DE" "#4393C3" "#2166AC" "#053061"
#mycolors <- c("#053061", "#2166AC", "#4393C3" ,"#92C5DE", "#D1E5F0","#F7F7F7","#FDDBC7", "#F4A582","#D6604D", "#B2182B","#67001F")
mycolors <- c("#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7", "#F7F7F7", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061")

type <- c("SERUM","PLASMA")

#pct2$PrTmcat <- PrTmcat  
colnames(pct2) #[1] "PLASMA"  "SERUM"   "PLASMA"  "SERUM"   "PrTmcat"
tb_serum <- pct2[which(pct2$SERUM > 0),c(2,4,5,6)] # to replace the original one: tb_serum <- pct2[,c(2,4,5,6)]
names(tb_serum) <- c("serum_pct","serum_N","Receipt_to_Processing","Receipt_to_Processing_Time")

tb_serum$Percent <- paste0(round(100*tb_serum$serum_pct,2),"%")
tb_serum$Receipt_to_Processing_Time <- factor(tb_serum$Receipt_to_Processing_Time,
                                              levels=c("< 0.5 Hours","0.5 to < 1 Hours","1 to < 1.5 Hours","1.5 to < 2 Hours","8 to < 20 Hours","20 to < 24 Hours", "48 to < 72 Hours"))  ##to redefine the exact levels of this variable
tb_serum <- tb_serum %>% arrange(desc(as.numeric(Receipt_to_Processing)))
tb_serum$text_y <- cumsum(tb_serum$serum_pct) - tb_serum$serum_pct/2
#names(mycolors) <- fct_rev(tb_serum$Receipt_to_Processing_Time) #remove this line JW

serum1 <- ggplot(data = tb_serum, aes(x=" ", y=serum_pct,  fill=Receipt_to_Processing_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  #Adding color instead of black text to percentages- using geom_label instead of geom_text
  #geom_text_repel(data=tb_serum[which(tb_serum$serum_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=0.1,
  # size = 4, show.legend = F) + 
  geom_label_repel(data=tb_serum[which(tb_serum$serum_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=0.05,force=0.1,
                   colour="white", segment.colour="black", size = 4, show.legend = F) +
  ggtitle(label = "Receipt to Processing Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Serum") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  #scale_fill_manual(values =mycolors)
  scale_fill_manual(values = c("#053061", "#2166AC", "#4393C3", "#F4A582", "#D6604D", "#B2182B","#67001F")) ##to replace the previous line above Jing

#pct2$PrTmcat <- PrTmcat  
# colnames(pct2) #[1] "PLASMA"  "SERUM"   "PLASMA"  "SERUM"   "PrTmcat"
# tb_serum <- pct2[,c(2,4,5,6)]
# names(tb_serum) <- c("serum_pct","serum_N","Receipt_to_Processing_Time")
# 
# tb_serum$Percent <- paste0(round(100*tb_serum$serum_pct,2),"%")
# tb_serum <- tb_serum %>% arrange(desc(Receipt_to_Processing_Time)) 
# tb_serum$text_y <- cumsum(tb_serum$serum_pct) - tb_serum$serum_pct/2
# 
# serum1 <- ggplot(data = tb_serum[which(tb_serum$serum_N !=0),], aes(x=" ", y=serum_pct,  fill=Receipt_to_Processing_Time)) +
#   geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
#   coord_polar("y", start=0) + 
#   geom_label_repel(data=tb_serum[which(tb_serum$serum_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=0.1,
#                    colour="green", segment.colour="black", size = 4, show.legend = F) + 
#   ggtitle(label = "Receipt to Processing Time",
#           subtitle="Connect for Cancer Prevention Study
#                     Five Site
#                     06/13/2022-09/27/2022
#                     Material Type=Serum") + 
#   theme(panel.background = element_blank(),
#         axis.line = element_blank(),
#         axis.text = element_blank(),
#         axis.ticks = element_blank(),
#         axis.title = element_blank(),
#         plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
#         plot.subtitle = element_text(hjust = 0.5,size=12),
#         plot.caption = element_text(color = "green", face = "italic")) +
#   scale_fill_manual(values =mycolors)


tb_plasma <- pct2[,c(1,3,5,6)]
names(tb_plasma) <- c("plasma_pct","plasma_N","Receipt_to_Processing","Receipt_to_Processing_Time")

tb_plasma$Percent <- paste0(round(100*tb_plasma$plasma_pct,2),"%")
tb_plasma$Receipt_to_Processing_Time <- factor(tb_plasma$Receipt_to_Processing_Time, 
                                               levels=c("< 0.5 Hours","0.5 to < 1 Hours","1 to < 1.5 Hours", "1.5 to < 2 Hours","2 to < 2.5 Hours",
                                                        "2.5 to < 3 Hours", "3.5 to < 4 Hours","4 to < 8 Hours","8 to < 20 Hours","20 to < 24 Hours", "48 to < 72 Hours"))
tb_plasma <- tb_plasma %>% arrange(desc(as.numeric(Receipt_to_Processing)))
tb_plasma$text_y <- cumsum(tb_plasma$plasma_pct) - tb_plasma$plasma_pct/2
names(mycolors) <- fct_rev(tb_plasma$Receipt_to_Processing_Time)

plasma1 <- ggplot(data = tb_plasma, aes(x=" ", y=plasma_pct,  fill=Receipt_to_Processing_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  #Adding color instead of black text to percentages- using geom_label instead of geom_color
  #geom_text_repel(data=tb_plasma[which(tb_plasma$plasma_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=-0.1,
  #colour="black", segment.colour="black", size = 4, show.legend = F) + 
  geom_label_repel(data=tb_plasma[which(tb_plasma$plasma_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 0.8,
                   colour="white", segment.colour="black", size = 4, show.legend = F) +
  ggtitle(label = "Receipt to Processing Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Plasma") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values =mycolors)

# 
# biospe_plot2 <- list(serum1,plasma1)
# out2 <- paste(outputpathname,"Biospecimen_processing_receipt_time_forMN_10032022.pdf",sep="")
# png(out2,height=800,width=1200) 
# grid.arrange(grobs = biospe_plot2, ncol = 2) ## display plot
# ggsave(file = out2, arrangeGrob(grobs = biospe_plot2, ncol = 2))  

#Putting the 4 pie charts above together in a list
biospe_plot3 <- list(serumF,plasmaF,serum1,plasma1)
#Out3 is our output to export to pdf
out3 <- paste(outputpathname,"Serum_Plasma_Cumulative_100422_color.pdf",sep="")

#png(out3,height=800,width=1200)
#grid.arrange(grobs = biospe_plot1, ncol = 2) ## display plot
#grid.arrange(grobs = biospe_plot2, ncol = 2) ## display plot

#ggsave comes from ggplot library. MarrangeGrob arranges graphs on the page
ggsave(
  filename = out3, 
  plot = marrangeGrob(biospe_plot3, nrow=1, ncol=2), 
  width = 15, height = 9
)