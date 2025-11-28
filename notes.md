---
title: notes
---

In this study the first author made the mistake of not creating an open notebook from the beginning. Based on the date of this document, it can be traced that which decisions are being taken prior to seeing the results.

What has happened until now (September 11):

- study on citation, citation second year, and time corrected citation (correlation, pairwise rank comparison, descrptives, percentiles)
- study of impact factor (correlation, pairwise rank comparison, descrptives, percentiles)
- early version of network

Meeting sep 11:

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

Since yesterday, I itterated over the codes and decided on some arbitury criteria:
- studies with above 1000 participants are big data collection (for quantitative studies). If they used the word nationally represented, withought any mention of the final number also categorised as this. For qualitative studies, I set the threashhold at 100 interviewees. 
- if a study worked on some mental disorders and had added an aditional criteria (e.g., both diagnosed dipression and having suicide background) were coded as specific population.
- if they were interview studies and there was an indication that it was possible to be done online, I did not code for multi-center. But I did count it for quantitative online surveys because I assumed they had to translate [unless they were in one country].

Nov 28: I realised I left some papers without codes, as there was no access to their abstract (n=4). I remove them and coded 4 other papers.
