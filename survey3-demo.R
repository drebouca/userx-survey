library(tidyverse)
library(car)


## example case
set.seed(1)
n=100
fdaff_likert <- data.frame(
    country=factor(sample(1:3, n, replace=T), labels=c("US","Mexico","Canada")),
    item1=factor(sample(1:5,n, replace=T), labels=c("Very Poor","Poor","Neither","Good","Very Good")),
    item2=factor(sample(1:5,n, replace=T), labels=c("Very Poor","Poor","Neither","Good","Very Good")),
    item3=factor(sample(1:5,n, replace=T), labels=c("Very Poor","Poor","Neither","Good","Very Good"))
)
names(fdaff_likert) <- c("Country",
                         "1. I read only if I have to",
                         "2. Reading is one of my favorite hobbies",
                         "3. I find it hard to finish books")

fdaff_likert3 <- likert(items=fdaff_likert[,2:4], grouping=fdaff_likert[,1])
plot(fdaff_likert3)












## box_auth
## usethis::edit_r_environ()
## 4j0660orfjkkwg9aqh6cp84h92asmcim
## cguGlXDMM3jgRdaI4FzHFHLc5UFAaOIO
library(boxr)
library(tidyverse)
box_auth()
bs <- box_search("pilot4 merged", type = "file")

## load dataset (first on the list)
survey <- box_read(bs)

## select variables of interest
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

## add variable for PASS/FAIL of the AP exam
dat %>%
  mutate(ap_exam = ifelse(AP_Score < 4, "Fail", "Pass")) %>%
  select(id,
         contains("t3_A"),
         treatment1,
         ap_exam,
         biological_sex_c,
         free_reduced_lunch_c) -> userx

## exclude free response questions
userx %>%
  select(!contains("text")) -> userx

## select only treatment group
userx %>%
  filter(treatment1 == 1) -> userx_treat

## select item responses only
colnames(userx_treat)
userx_treat %>%
  select(starts_with("t3_")) -> items



##userx %>%
##  na.omit() -> userx

## rename to make it easier
userx %>%
  rename(condition = treatment1) -> userx_treat

## responses only from treatment group
## userx_treat %>%
##   filter(condition == 1) %>%
##   filter(free_reduced_lunch_c != "Not applicable at my school") %>%
##   select(starts_with("t3_")) -> items

userx_treat %>%
  filter(condition == 1) %>%
  select(starts_with("t3_")) -> items

library(careless)
sds <- apply(items, 1, sd)
ind_flag0 <- which(sds == 0)
items[ind_flag0,]

userx_treat %>%
  filter(condition == 1) %>%
  select(starts_with("t3_")) %>%
  filter(!row_number() %in% ind_flag0)-> items

## calculate total sum
total <- rowSums(items)



## ## what is the factor structure of the data?
## library(lavaan)
## library(psych)

## fit2 <- fa(treat, 2, rotate = "promax")
## fit2

## fit3 <- fa(treat, 3, rotate = "promax")
## fit3

## fit4 <- fa(treat, 4, rotate = "promax")
## fit4

## fit5 <- fa(treat, 5, rotate = "promax")
## fit5

## fit6 <- fa(treat, 6, rotate = "promax")
## fit6

## 6-factor structure helps with visualization
## results between groups


## ## organize levels of factors
## treat <- lapply(treat, function(x){
##     factor(x, levels=c(1:5), labels=c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"))
## })
## treat <- as.data.frame(treat)
## head(treat)

## control <- lapply(control, function(x){
##     factor(x, levels=c(1:5), labels=c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"))
## })
## control <- as.data.frame(control)

items <- lapply(items, function(x){
    factor(x, levels=c(1:5), labels=c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"))
})
items <- as.data.frame(items)
## create plots
#summary(prop)
## there are basically 2 factors, or 6 subfactors
facts2 <- c(rep("f2", 6),
           rep("f1", 5),
           rep("f2", 3),
           "f1", "f2",
           rep("f1", 3))
length(facts2)

facts6 <- c(rep("f1", 3),
            rep("f5", 3),
            "f2", "f6",
            rep("f2", 3),
            rep("f4", 3),
            "f3","f4",
            "f6",
           rep("f3", 2))
length(facts6)

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

facts_og <- colnames(items)
reorder <- data.frame(facts_og, facts2, facts6, item_names)
reorder %>%
  arrange(facts6) -> reorder6

items <- items[,reorder6$facts_og]

names(items) <- as.character(reorder6$item_names)

## create plot for treatment group
library(ggplot2)
library(likert)
## groups <- userx_treat$condition
## groups <- factor(groups, levels=c(1,0),
##                  labels = c("Treatment", "Control"))

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


## overall for treatment group
tt <- likert(items = items)
title <- "Treatment group: 'How you feel about the AP-CAT system'"
png("userx_survey_treat_updated.png", height=700, width=1200, res=120)
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
