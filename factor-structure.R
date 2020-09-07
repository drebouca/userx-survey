setwd("~/Documents/Research/survey-rt/data/")

## load response time and survey data
dat <- read.csv("t2_bfi_process_data_clean.csv",
                row.names = "X")


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
