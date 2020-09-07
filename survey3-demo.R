#######################################
### Script to select data from UX
### survey and generate figures to
### visualize results.
###
### by Dani Reboucas
#######################################

## Load libraries
library(boxr)
library(tidyverse)
library(ggplot2)
library(likert)

#######################################
### 1. Select item responses and
### demographics for comparison between
### groups.
###   - Biological sex
###   - Grade
###   - School
###   - Teacher
###   - Treatment condition
###   - AP exam score
###   - etc.
###
### a) Load data from Team's Box
### b) Select item responses and
### demographics variables
### c) Dichotomize AP scores into
###   PASS or FAIL
#######################################

## Data file stored in Team's Box
## Use boxr package to retrieve data
box_auth()
bs <- box_search("pilot4 merged",
                 type = "file")
survey <- box_read(bs)
survey %>%
  select(id,
         biological_sex_c,
         grade_c,
         school,
         teacher,
         treatment1,
         race_identity_c,
         expected_education_c,
         free_reduced_lunch_c,
         contains("t3_A"),
         AP_Score,
         Dropped_Class1,
         Class_Grade_Final,
         AP_Exam_Not_Take1) -> dat

## add variable for PASS/FAIL of AP exam
dat %>%
  mutate(ap_exam = ifelse(AP_Score < 4,
                          "Fail",
                          "Pass")) %>%
  select(id,
         contains("t3_A"),
         treatment1,
         ap_exam,
         biological_sex_c,
         free_reduced_lunch_c) -> userx

## exclude free response questions
userx %>%
  select(!contains("text")) -> userx

## rename treatment variable
userx %>%
  rename(condition = treatment1) ->
  userx

## select treatment group data only
userx %>%
  filter(condition == 1) -> userx_treat

## select item responses only
userx_treat %>%
  select(starts_with("t3_")) -> items



#######################################
### 2. Data Cleaning.
###   a) Identify responses with
###   variance equal to 0.
###   b) Remove flagged responses.
###   c) Recode numeric to categorical
###   values.
#######################################

## flag items with variance == 0
sds <- apply(items, 1, sd)
ind_flag0 <- which(sds == 0)
userx_treat %>%
  filter(condition == 1) %>%
  select(starts_with("t3_")) %>%
  filter(!row_number() %in% ind_flag0)-> items

## calculate total sum ----
## this total sum should be reviewed to include
## reverse-coded item 14
total <- rowSums(items)

## how much missing data?
mis <- apply(items, 1, function(x){
  sum(is.na(x))
})
table(mis)

## remove missing data
ind_mis <- which(mis == 19)
## 16.66% missing
items %>%
  filter(!row_number() %in% ind_mis) -> items

## rename levels
items <- lapply(items, function(x){
    factor(x, levels=c(1:5), labels=c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"))
})
items <- as.data.frame(items)


#######################################
### 3. Plot results for treatment
### group.
###
### Use 'likert' package with central
### layout. Visualize each item
### frequency per category.
### Save figure as .png file.
#######################################
## Prepare data for visualization
item_names <- c("01. I feel confident using the system.", ## confidence
           "02. I feel confident navigating through the assignments.",
           "03. I feel confident interpreting reports.",
           "04. I am satisfied with using the system as an assisted learning tool.", # satisfaction
           "05. I am satisfied with the post-assignments reports from the system.",
           "06. I am satisfied with the process of taking assignments on the system.",
           "07. I am satisfied with scaffolding solutions.",
           "08. The assignments are very relevant to our curriculum.", # relevance
           "09. The FAQ is useful.", # helpfulness
           "10. The scaffolding solutions are useful.",  # helpfulness
           "11. The attribute reports are useful.",  # helpfulness
           "12. It is helpful to see the answer key after the assignment.",
           "13. I am satisfied with the speed of the system.",
           "14. I frequently run into technical problems in the system (R).",
           "15. I am satisfied with the design of the system.",
           "16. I find the system easy to use.",
           "17. I believe the system promotes learning.",
           "18. I believe the system improves testing performance.",
           "19. I believe the system promotes learning motivation.")

names(items) <- item_names

tt <- likert(items = items)
title <- "Treatment group: 'How you feel about the AP-CAT system'"
png("figures/userx_survey_treat_updated.png",
    height=700, width=1200, res=120)
plot(tt, centered=T, pt.cex=2) +
  ggtitle(title)
dev.off()



#######################################
### 4. Plot results based on approximate
### factor structure (see
### script in factor-structure.R)
###
#######################################

## Treatment group
userx_treat %>%
  filter(condition == 1) %>%
  filter(!row_number() %in% ind_flag0) %>%
  select(ap_exam) %>% unlist() %>%
  factor() -> groups

## 1. Is there a difference in satisfaction between pass and fail groups?
## answer: probably (p-value=.02)
pf <- data.frame(groups, total)
t.test(pf$total[pf$groups == "Pass"],
       pf$total[pf$groups == "Fail"])

## userx_treat %>%
##   filter(condition == 1) %>%
##   filter(free_reduced_lunch_c != "Not applicable at my school") %>%
##   select(free_reduced_lunch_c) %>% unlist() %>%
##   factor() -> groups

## userx_treat %>%
##   filter(condition == 1) %>%
##   select(biological_sex_c) %>% unlist() %>%
##   factor() -> groups

items_f1 <- items[,1:3]
items_f1 %>%
  bind_cols(condition = groups) -> items_f1

items_f2 <- items[,4:7]
items_f2 %>%
  bind_cols(condition = groups) -> items_f2

items_f3 <- items[,8:10]
items_f3 %>%
  bind_cols(condition = groups) -> items_f3

items_f4 <- items[,11:14]
items_f4 %>%
  bind_cols(condition = groups) -> items_f4

items_f5 <- items[,15:17]
items_f5 %>%
  bind_cols(condition = groups) -> items_f5

items_f6 <- items[,18:19]
items_f6 %>%
  bind_cols(condition = groups) -> items_f6


tt <- likert(items=items_f1[,-4],
             grouping = items_f1[,4])
## prop <- likert(summary = tt$results)
title <- "Navigation"
png("userx_pf_navigation.png", height=700, width=1000, res=120)
plot(tt, centered=F, pt.cex=2) + ggtitle(title)
dev.off()

tt <- likert(items=items_f2[,-5],
             grouping = items_f2[,5])
## prop <- likert(summary = tt$results)
title <- "Usefulness"
png("userx_pf_usefulness.png", height=700, width=1000, res=120)
plot(tt, centered=T, pt.cex=2) + ggtitle(title)
## dev.off()

tt <- likert(items=items_f3[,-4],
             grouping = items_f3[,4])
## prop <- likert(summary = tt$results)
title <- "Learning"
png("userx_pf_learning.png", height=700, width=1000, res=120)
plot(tt, centered=T, pt.cex=2) + ggtitle(title)
dev.off()

tt <- likert(items=items_f4[,-5],
             grouping = items_f4[,5])
## prop <- likert(summary = tt$results)
title <- "Usability"
png("userx_pf_usability.png", height=700, width=1000, res=120)
plot(tt, centered=T, pt.cex=2) + ggtitle(title)
dev.off()


tt <- likert(items=items_f5[,-4],
             grouping = items_f5[,4])
## prop <- likert(summary = tt$results)
title <- "Satisfaction"
png("userx_pf_satisfaction.png", height=700, width=1000, res=120)
plot(tt, centered=T, pt.cex=2) + ggtitle(title)
dev.off()


tt <- likert(items=items_f6[,-3],
             grouping = items_f6[,3])
## prop <- likert(summary = tt$results)
title <- "Relevance"
png("userx_pf_relevance.png", height=700, width=1000, res=120)
plot(tt, centered=T, pt.cex=2) + ggtitle(title)
dev.off()




## create plot for control group
## reorder the data according to the order that appears in "Prop"
##control <- control[,as.character(prop$results$Item)]
tt_control <- likert(control)
##prop <- likert(summary = tt$results)
##str(prop)

## add control group stats
## means <- summary(prop)[,-c(2:4)]
## colnames(means)[2:3] <- c("mean.C", "sd.C")
## means.sd %>% left_join(means, by='Item') -> means.sd

## 
## arrange(prop.c, by=prop$Item)

## save image
title <- "Control group: 'How you feel about the AP-CAT system'"
png("userx_survey_control_updated.png", height=700, width=1200, res=120)
plot(tt_control, centered=F, pt.cex=2) + ggtitle(title)
dev.off()

## save descriptive stats
write.csv(means.sd, "descript_userx.csv", row.names=F)

#write.csv(data.frame(Item=means.sd[,1], round(means.sd[,2:5],2)), "descriptives_userx.csv", row.names=F)


## now recode
treat %>%
    data.frame(stringsAsFactors = F) %>%
    mutate(vars(starts_with("satisfaction")), funs("rc" = factor(., levels = c(1="Strongly Disagree", 2="Disagree", 3="Neutral", 4="Agree", 5="Strongly Agree"))))
    


treat %>% mutate_at(vars(starts_with("satisfaction")),
                    funs("rc" = recode(.,"Strongly disagree" = 1,
                                       "Disagree" = 2,
                                       "Neutral" = 3,
                                       "Agree" = 4,
                                       "Strongly Agree" = 5))) %>%
    select(ends_with("rc")) -> treat.rc

treat.rc %>% mutate_at(vars(starts_with("satisfaction")),
                    funs("rc" = factor(., levels = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"))))

    -> treat.rc

head(treat.rc)

control %>% mutate_at(vars(starts_with("satisfaction")),
                      funs("rc" = recode(.,"Strongly disagree" = 1,
                                         "Disagree" = 2,
                                         "Neutral" = 3,
                                         "Agree" = 4,
                                         "Strongly Agree" = 5))) %>% select(ends_with("rc")) -> control.rc

head(control.rc)
