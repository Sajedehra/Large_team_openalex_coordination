# Repository

This repository is dedicated to the paper title "The Benefits and Motivations Behind Large-Team Coordination in Psychology". It contains materials and codes used in this study, as well as the
manuscript (not peer-reviewed) and the supplementary materials. You can freely access the data to reproduce the manuscript at *link*.


# Project structure
```
Large_team_openalex_coordination/
|
├── Manuscript.pdf       # Preprint of the study
├── Manuscript.qmd       # Quarto document to fully reproduce the manuscript
├── Supplementary.pdf    # Supplementary materials
├── Supplementary.qmd    # Quarto document to fully reproduce the supplementary materials
├── apa.csl              # csl file for making references apa style
├── references.bib       # Bib file contianing the references used in the manuscript
|
├── additional information/ 
│   ├── Steps to take for creating raw data.md      # Instructions to prepare the snapshot for the analysis
│   └── note.md                                     # Open Lab notebook
|
├── data/                                                          # this is an empty folder but you can download the content of this forlder (besides the snapshot) at XX
│   ├── works/                                                     # Where snapshot should go
│   ├── qualitative_materials/                                     # folder containing the random sample of papers picked for qualitative analysis
│       ├── quali_papers_with_abstract.csv   
│       └── quali_papers_without_abstract.csv  
│   ├── all_CI_openalex.RDS                                        # Confidence intervals for the correlations
│   ├── author_smallvsbig_performance_citation_metrics_15.rds      # Dataset for comparing the performance in citations of large-team vs small-team publications of authors (large team >= 15)
│   ├── author_smallvsbig_performance_citation_metrics_20.rds      # Dataset for comparing the performance in citations of large-team vs small-team publications of authors (large team >= 20)
│   ├── author_smallvsbig_performance_citation_metrics_25.rds      # Dataset for comparing the performance in citations of large-team vs small-team publications of authors (large team >= 25)
│   ├── author_smallvsbig_performance_journal_ranking_15.rds       # Dataset for comparing the performance in journal ranking of large-team vs small-team publications of authors (large team >= 15)
|   ├── author_smallvsbig_performance_journal_ranking_20.rds       # Dataset for comparing the performance in journal ranking of large-team vs small-team publications of authors (large team >= 20)
|   ├── author_smallvsbig_performance_journal_ranking_25.rds       # Dataset for comparing the performance in journal ranking of large-team vs small-team publications of authors (large team >= 25)
|   ├── consolidate_data_openalex.rds                              # Final dataset for citation metrics
|   ├── consolidate_journal_data.rds                               # Final dataset for journal ranking
|   ├── dunn_fif.rds                                               # result of Dunn test for total citation and group size of 15
|   ├── dunn_fif2.rds                                              # result of Dunn test for second-year citation and group size of 15
|   ├── dunn_five.rds                                              # result of Dunn test for total citation and group size of 5
|   ├── dunn_five2.rds                                             # result of Dunn test for second-year citation and group size of 5
|   ├── dunn_ten.rds                                               # result of Dunn test for total citation and group size of 10
|   ├── dunn_ten2.rds                                              # result of Dunn test for second-year citation and group size of 10
|   ├── first_cleaned_data_openalex.rds                            # Dataset after first round of cleaning
|   ├── MAXQDA openalex-interdep - Code System.xlsx                # Raw results of qualititive analysis
|   ├── qualitative_descriptive.rds                                # Cleaned results of qualitative analysis
|   ├── raw_data_OpenAlex.csv                                      # Raw data that was retrieved from the snapshot
|   └── scimagojr 2024.csv                                         # SJR journal ranking
|
├── r_scripts/️
│   ├── 01_retrieve_data_from_snapshot.R                           # Generating the raw data from the snapshot
|   ├── 02_data_cleaning.R                                         # Cleaning of the raw data
|   ├── 03_pairwise_comparison.Rmd                                 # pairwise comparison (Dunn test) for total citation and second-year citation across all group sizes
|   ├── 04_retrieve_papers_qualitative.R                           # Randomly sampling papers for qualitative analysis
|   ├── 05_total_citation.Rmd                                      # All analyses and figures regarding the total citation
|   ├── 06_second_year_citation.Rmd                                # All analyses and figures regarding the second-year citation
|   ├── 07_date_correcterd_citation.Rmd                            # All analyses and figures regarding the date-corrected citation
|   ├── 08_journal_ranking.Rmd                                     # All analyses and figures regarding Jounal ranking
|   ├── 09_ConfidenceInterval.R                                    # Calculating confidence intervals for the correlations using bootstrapping
|   ├── 10_author_performance_big_vs_small_team.Rmd                # Creating datasets for comparing performance of large-team vs small-team publications of authors across all group sizes and measures
│   └── 11_qualitative_cleaning.R                                  # Cleaning the qualitative coding and generating Figure 2
|
└──  qualitative analysis/️
   └── openalex-interdep.mqda   # MAXQDA project for qualitative coding


```