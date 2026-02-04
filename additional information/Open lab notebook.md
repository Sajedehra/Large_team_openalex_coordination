---
title: Open lab notebook
---

This open notebook was created on September 11, 2025 before the qualitative analysis for the study and includes information on the changes from then on wards. 

Decisions made before creation of the open notebook (before Sep 11):

- We prepare the codes for analysis on citation, citation second year, and time corrected citation (i.e., correlation, pairwise rank comparison, descriptive, percentiles)
- We prepare the codes for analysis on journals ranking (i.e., correlation, pairwise rank comparison, descriptive, percentiles)
- early version of citation network 

Meeting Sep 11:

- we decided on the points of introduction
- we decided to look into the individual contributions of big team author papers.
- We have to make a decision what counts as prestige, as we may look into it.
- we decided the missing authors should be removed.

Meeting Sep 25:

- we decided we do not have a reasonable comparison point at this stage for network analysis, so we will drop it from the analysis.

Sep 29:

- I just found out there are more non-articles in the data through reading the randomly selected papers for qualitative part of the project. I will add "Day-by Day" to the keywords for cleaning the data, and ask supervisors for what to do with the cases (there are some non-psychology in the data as well). I also found an oral presentation that is classified as article: https://openalex.org/works/W2150114669

Sep 30:

- there is a collection of papers (paper series) that has been included as one big paper in OpenAlex: https://openalex.org/W4312679429

Oct 8:

- today I found another keyword "correction": https://openalex.org/W2979929196
- Last week on Thursday we decided to finish the qualitative part to include 500 and then remove all the unrelated paper I found during this checks and rerun all the analyses.

Oct 21:

I found that there are some characters that missed my regex cleaning with keywords. With the help of chat GPT, I made a code to ensure those metacharachters are not missing. and I will run previous keywords again.

Nov 27:

Since yesterday, I iterated over the codes and decided on some arbitrary criteria:
- studies with above 1000 participants are big data collection (for quantitative studies). If they used the word nationally represented, without any mention of the final number also categorised as this. For qualitative studies, I set the threshold at 100 interviewees. 
- if a study worked on some mental disorders and had added an additional criteria (e.g., both diagnosed depression and having suicide background) were coded as specific population.
- if they were interview studies and there was an indication that it was possible to be done online, I did not code for multi-center. But I did count it for quantitative online surveys because I assumed they had to translate (unless it happened in the same country).


Nov 28: 

I realised I left some papers without codes, as there was no access to their abstract (n=4). I remove them and coded 4 other papers.

Dec 8:

Last week at our meeting (on Dec 5th) we decided to rearrange the coding of the qualitative that matches the division of interdependency in our previous paper.

If a papers is using specific tool (e.g., FMRI or intensive studies like genome studies) or specific population, it will be classified as financial + logistic.

all multi-centers have logistic component and count as financial if they have big sample sizes. All longitudinal, cohorts, and eligible RCTs (with multiple time-point data collection) also have a temporal component. if RCT also involves delivering a treatment or therapy they are epistemic as well. the remaining RCTS are coded as logistic.

Dec 12:

Today I realised one of the abstracts was wrong: https://openalex.org/W2991079055

Jan 16:

We decided to go over the papers without clear interdependencies and check if they have CREDIT statement.

Jan 27:

We check the "standard studies" with Daniel and decided that putting cut of for big-team data collection was not a good idea.
We also realised that I have made a mistake in some of them and instead of why they did this big team collaboration, I coded them as standard because I believed they could have done it in smaller teams.
We also found a paper https://openalex.org/W1995163329, that in meta data it has 45 authors but in reality there are only 8. I will remove this paper and coded another one for this section.

Feb 2:

On Jan 30, I sent 54 of the qualitative studies to Daniel to code to check the compatibility with my coding. I checked the codes and for 24 studies we agree on the codes, for 21 studies we have disagreement on adding/removing one interdependency in a group of interdependencies. The later and the remaining 9 papers will be discussed on Thursday.