# UX Survey Report

A user experience survey was developed and applied to students using the assessment system in the 2018-19 school year. A total of 423 students were surveyed from statistics classes throughout the school year. 

## Treatment vs. Control Groups

In order to evaluate the system features, students were assigned to either a treatment or a control group. The treatment group had access to all system features: final score for each assessment, scaffolding (step-by-step solutions), assessment reports with answer keys, and attribute reports with "Novice", "Intermediary", and "Expert" assigned to each skill. The control group only had access to their scores on the assessments.

## The UX Survey

Among a number of surveys, a User Experience was developed and assigned to each student asking about their satisfaction with the system navigation, usability, and reliability, and their perception of the content relevance and motivation for learning. All items were given on a 5-point scale from "Strongly Disagree" to "Strongly Agree". A summary of the items is given below:

| Domain | \# | Item |
|----|----------------------------------------------------------------------------|---|
|*System Usability* |  1  | "I feel confident using the   system."                                     |
| | 2  | "I feel confident navigating through the assignments."                     |
| | 3  | "I feel confident interpreting reports."                                   |
|  | 4  | "I am satisfied with using the system as an assisted learning   tool."     |
| | 5  |  "I am satisfied with the   post-assignments reports from the system."     |
|| 6  | "I am satisfied with the process of taking assignments on the   system."   |
|| 12 |            "It is helpful to   see the answer key after the assignment."   |
|| 13 |            "I am satisfied   with the speed of the system."                |
|| 14 |            "I frequently run   into technical problems in the system (R)." |
| | 16 |            "I find the system   easy to use."                              |
| *Learning*|   7  |            "I am satisfied   with scaffolding solutions."                  |
| | 8  |            "The assignments   are very relevant to our curriculum."        |
|| 9  |            "The FAQ is   useful."                                          |
|| 10 |            "The scaffolding   solutions are useful."                       |
|| 11 |            "The attribute   reports are useful."                           |
|| 15 |            "I am satisfied   with the design of the system."               |
|| 17 |            "I believe the   system promotes learning."                     |
|| 18 |            "I believe the   system improves testing performance."          |
|| 19 |            "I believe the   system promotes learning motivation."          |

## Q1: Is there a difference user satisfaction

At the end of the school year the students took the AP statistics exam, and their scores were reported. Students were considered to "Pass" they scored 4 or 5, and to "Fail" otherwise. We first evaluate how students in the treatment group compared in their satisfaction using of the system by AP exam score.

Using the `likert` package and a centered layout, we can plot response frequencies per category
<img src="figures/userx_survey_treat_updated.png" width="800">


