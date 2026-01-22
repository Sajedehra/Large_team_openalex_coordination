
# loading packages --------------------------------------------------------

library(readr)
library(data.table)
library(dplyr)
library(readxl)
library(stringr)
library(psych)
library(ggplot2)

# initial merging ------------------------------------------------------------


# loading the data

#dat1 <- fread("D:/Sajedeh/dat_field_nn_en2.csv", sep = ";", col.names = c("oa_id", "doi", "pubdate", "title", "journal", 
#                                                               "issn", "type", "language", "open_access", "authors", "orcid","oa_id_author", 
#                                                               "citation", "citation_2y", "cite_tre_year", "cite_tre_count", "ref","volume", "issue" , "page" ))

#dat2 <- fread("D:/Sajedeh/targetfile.csv", sep = ";", col.names = c("oa_id", "doi", "pubdate", "title", "journal", 
#                                                         "issn", "type", "language", "open_access", "authors", "orcid","oa_id_author", 
#                                                         "citation", "citation_2y", "cite_tre_year", "cite_tre_count", "ref","volume", "issue" , "page" ))

#dat3<- fread("D:/Sajedeh/finalHPCen.csv", sep = ",")

#dat<- rbind(dat1, dat2, dat3)

#write_rds(dat, "D:/Sajedeh/dat_raw.rds")


# Start of cleaning -------------------------------------------------------


dat<- readRDS("D:/Sajedeh/dat_raw.rds")

dat<- dat|>distinct(oa_id, .keep_all = TRUE)

n_initial<- nrow(dat)

dat<- dat|>distinct(doi, pubdate, journal, volume, issue, page, .keep_all = TRUE)
n_notduplicate<- nrow(dat)

#setting desired publication range
range(dat$pubdate, na.rm = TRUE)

dat<- dat|> filter(pubdate>="1975-01-01" & pubdate<"2024-09-15")
n_correctyear<- nrow(dat)

## removing non-psychology works / not journals
dat<- dat|> filter(type == "journal-article")
n_article<- nrow(dat)

dat<- dat|> filter(language == "en")
dat <- dat[which(!grepl("[^\x01-\x7F]+", dat$title)),]
n_english<- nrow(dat)

# removing unrelated work

#check<- sample_n(dat, 200, replace = FALSE)
#check2<- sample_n(dat_d, 200, replace = FALSE)
#check3<- sample_n(dat, 200, replace = FALSE)
#check4<- sample_n(dat, 200, replace = FALSE)
#keywordcheck<- rbind(check, check2, check3, check4)
saveRDS(keywordcheck, "keywordcheck.rds")

dat <- dat |>
  filter(!str_detect(
    str_trim(title),
    regex("^Acknowledg(e)?ment(s)?$", ignore_case = TRUE)
  ))

ack_pat   <- regex("\\bAcknowledg(e)?ment(s)?\\b", ignore_case = TRUE)
editor_pat <- regex("\\bReviewer(s)?\\b", ignore_case = TRUE)

dat <- dat |>
  filter(!(str_detect(coalesce(title, ""), ack_pat) &
             str_detect(coalesce(title, ""), editor_pat)))

dat<- dat|> filter(!str_detect(str_trim(title), regex("^Achievement(s)?$", ignore_case = TRUE))) #5264 cases until here


irrelevant_title_keywords<- c("Essay", "symposium", "table of content", "proceedings", "annual meeting", "Blockchain", "Bug", "Temporal Network", "Handbook", "Conference",
                              "control system", "Poetry", "Dance", "update on", "Machine Learning", "NUCLEAR", "PHYSICS", "portfolio", "Solar Power",
                              "Epilogue", "oppening", "Book Review", "COMMENTARY", "Reporting Guideline", "editorial", "nursing", "Publication Information",
                              "Sibling Designs", "airfoil", "Meeting and Workshops", "Correction to") 

#Correction to should also be added

pattern <- paste(irrelevant_title_keywords, collapse = "|")

dat <- dat |>
  filter(!str_detect(title, regex(pattern, ignore_case = TRUE))) # 85252 cases until here (NAs are also removed) {with added correction one day later, 868 cases are added}



irrelevant_journal_keywords<- c("History", "software", "Eos", "Acoustics", "Surgery", "Tourism", "chemistry", "Robotics", "Physical",
                                "Entrepreneurial Business", "ACM SIGCSE Bulletin", "computer science", "Environmental", "Pharmacology",
                                "Metaphilosophy", "Signal Processing", "Electronic", "Nutrition", "Canadian Studies", "Style",
                                "Fashion", "Entomology", "Ethnology", "Engineering", "Gas", "Critical Care", "Anthropolog", "art",
                                "Energy Conversion", "Safety Progress", "Mathematic", "Machine Learning", "Revista eureka", "BMJ",
                                "IT services", "Deleted Journal", "Philosophy", "auto world", "National Academy of Sciences", "Choice Reviews Online",
                                "Hotline", "Economic", "Nursing", "Mobilities", "Conference", "Maska", "Utility Computing", "Green Computing",
                                "theatre", "IEEE", "Pediatrics", "Information Technology", "Tissue", "Ergonomics", "Industry Applications",
                                "Agrosearch", "Discourse", "Cybernetics", "Accounting" ,"Infection", "The Monist", "A I I E Transactions",
                                "Molecular", "Sports", "nonmunji", "Linguistica e filologia", "Music", "DergiPark", "Acta Medica", "Trade",
                                "Synthesiology", "Aerospace", "musik", "Marketing", "Human Rights", "Dialysis", "Kairaranga", "Disaster", "Fuzzy",
                                "Legal", "NUCLEAR", "Operations Research", "BMC", "English", "Literacy", "Information Science", "Trafficking",
                                "Planner", "Experimental Biology", "Airports", "NASSP", "Medical Ethics", "Complexity", "Medical Herald", "Social Work",
                                "Optical", "Movement Science", "soft Computing", "law Journal", "Fire", "Shock", "Vinnytsia", "Linguistica", "biochem",
                                "Applied Probability", "Physics", "plant Science", "Parks", "Nephrology", "techtrends", "Dental", "Fuel", "criminology",
                                "Training", "Verbal", "Internal Medicine", "St Tikhons University Review", "Petroleum", "CORAK", "Teachers College", 
                                "Agricultur", "Lawyer", "Orthopt", "information systems", "Finance Review", "Air transport", "Orthopaedic", "Medicine & Biology",
                                "Obstetrics", "Intelligent Systems", "Transportation Research", "Urology", "dialectica", "JWST Proposal. Cycle 1", "Immunology") 

# there are unrealated articles in bmj, but also PRISMA is there
# "Immunology" and "JWST Proposal. Cycle 1" should be added to the list

pattern2 <- paste(irrelevant_journal_keywords, collapse = "|")

dat <- dat |>
  filter(!str_detect(journal, regex(pattern2, ignore_case = TRUE))) # 652811 cases removed


irrelevant_issn<- c("1073-1911", "0022-0418", "1356-5028", "1440-7833", "0894-069X", "0013-7545", "1940-9052", "1063-5157", "0042-8469", "1327-9556", "1660-9336",
                    "0127-9696", "1470-5427")
pattern3 <- paste(irrelevant_issn, collapse = "|")
dat <- dat |>
  filter(is.na(issn) | !str_detect(issn, regex(pattern3, ignore_case = TRUE))) # 3189 cases removed (with added keywords next day extra 733 removed)


n_irrelevant <- nrow(dat)


#calculating number of authors
dat$n_author<- str_count(dat$oa_id_author, ",")+1

# calculating the time difference from publication
download_date <- as.Date("2024-09-14")

dat$timediff <- as.integer(download_date - as.Date(dat$pubdate))
dat$timediff[dat$timediff == 0] <- 1




# missing data ------------------------------------------------------------


#checking the missing info

n_miss_author<- sum(is.na(dat$n_author))
n_miss_issn <- sum(is.na(dat$issn))

n_miss_both<- nrow(dat|>filter(if_all(c(n_author, issn), is.na)))

n_missing_ref <- sum(dat$ref == "")


# checking the most extremes ----------------------------------------------
dat$citation<- as.numeric(dat$citation)
dat$citation_2y<- as.numeric(dat$citation_2y)

extr_authors<-dat  |> 
  filter(!is.na(n_author)) |> 
  slice_max(n_author, n = 10) # the most extreme is not related to psychology (https://doi.org/10.1001/jama.2023.8823), so it is manually removed
#dat <- dat[-which(dat$doi == "https://doi.org/10.1001/jama.2023.8823"), ]
extr_citations<- dat |> 
  filter(!is.na(citation)) |> 
  slice_max(citation, n = 10)

# defining groups ---------------------------------------------------------

# grouping based on number of authors (3 different versions)

range(dat$n_author, na.rm = TRUE)
bigger_g<- dat|> filter(n_author>= 100) # only 75 papers are more than 100 authors


breaks_a <- c(0, 1, 2, 3, 4, 5, seq(10, 100, by = 5), Inf)
labels_1to5 <- as.character(1:5)
labels_5plus <- paste(seq(6, 96, by = 5), seq(10, 100, by = 5), sep = "–")
labels_tail <- c("101+")
labels_a <- c(labels_1to5, labels_5plus, labels_tail)

breaks_b <- c(0, 1, 2, 3, 4, 5, seq(15, 95, by = 10), Inf)
labels_10s <- paste(seq(6, 90, by = 10), seq(15, 100, by = 10), sep = "–")
labels_tail_10 <- c("96+")
labels_b <- c(labels_1to5, labels_10s, labels_tail_10)


breaks_c <- c(0, 1, 2, 3, 4, 5, seq(20, 100, by = 15), Inf)
labels_15s <- paste(seq(6, 86, by = 15), seq(20, 100, by = 15), sep = "–")
labels_c <- c(labels_1to5, labels_15s, labels_tail)


dat <- dat |>
  mutate(author_group_five = cut(n_author, breaks = breaks_a, labels = labels_a, right = TRUE, include.lowest = TRUE),
         author_group_ten = cut(n_author, breaks = breaks_b, labels = labels_b, right = TRUE, include.lowest = TRUE),
         author_group_fifteen = cut(n_author, breaks = breaks_c, labels = labels_c, right = TRUE, include.lowest = TRUE))




n_info <- data.frame(initial = n_notduplicate,
                     Corr_range = n_correctyear,
                     article = n_article,
                     noeng = n_english,
                     relevant = n_irrelevant,
                     miss_author = n_miss_author,
                     miss_issn = n_miss_issn,
                     missing_ref= n_missing_ref)


#saving the clean data
saveRDS(dat, file="dat_cleaned.rds")
saveRDS(dat, file="openalexdata_cleaned.rds")
saveRDS(n_info, file= "n_info.rds")


# cleanings after manual coding ---------------------------------------------------------
n_dat<- nrow(dat)
new_keyword<- c("correction", "Book Notes", "Day-by Day", "Respiratory", "Cover-Chewing", "daytime napping", 
                "immune protection", "CSCL System", "Poster Session", "colonial legacy", "Cardiopulmonary",
                "blood disorders", "DMD patients", "Upper Limb", "About the Contributors", "acousto-mechanical", "grid computing",
                "ventilation", "cyberinfrastructure", "PRO-TECT", "geospatial", "interprofessional medication", "Phenotypic",
                "artery bypass", "Madagascar", "metabolomics", "aesthetic surg", "endometrial", "tertiary care", "deflagration", 
                "Temparature", "Temperature", "nano-material", "Diffusion", "Infection", "transportation", "tuberculosis",
                "Photographic", "Vitreoretinopathy", "hybrid mixtures", "Prophylactic", "Abstracts", "lightcurves", "ape decline",
                "fibrosis", "AQUA", "primate extinction", "particle", "ISOCAM", "diabetes", "Stopwatch", "genetics gap",
                "Blood Collection", "muscular dystrophy", "Symbolic universes", "Decarboxylase", "ERA Registry", "molecular",
                "Flow System", "antioxidant", "autopsy", "Natural gas", "OpenModelica", "geological", "Nanotube", "ape extinction",
                "Arthritis", "Cardiovascular", "genomic epidemiology", "Stem Cell", "atrophy", "debris disk", "bioinformatics",
                "Antibodies", "aortic", "Telepresence", "narcolepsy", "Traumatic Brain Injury", "Hypoferremia", "Stroke", "oncology",
                "Galaxy", "Metabolit", "harmonization", "versatility", "ivory", "Ecology", "motor disorder", "Cardiac pacing", "Edible Insects",
                "entomology", "gas gauge", "endangered species", "hepatitis", "Sydenham Chorea", "Pollinator", "dialysis", "Biomarkers", "acousto-mechanical"
                )

case_sensitive<- c( "HIV","COPD", "serum", "BMI", "IPCC")

journal<- c("pac", "oncology", "APS")

ids<- "https://openalex.org/W4382936650
https://openalex.org/W4200564330
https://openalex.org/W4286762924
https://openalex.org/W3097713271
https://openalex.org/W1992360116
https://openalex.org/W4312679429
https://openalex.org/W3215287579
https://openalex.org/W3043317701
https://openalex.org/W1967120130
https://openalex.org/W3203418161
https://openalex.org/W4282915658
https://openalex.org/W4391495193
https://openalex.org/W2542228716
https://openalex.org/W3196418672
https://openalex.org/W2026532911
https://openalex.org/W4400112743
https://openalex.org/W1514933037
https://openalex.org/W2055798093
https://openalex.org/W2285173204
https://openalex.org/W4220867049
https://openalex.org/W3159009895
https://openalex.org/W2325257031
https://openalex.org/W2795224003
https://openalex.org/W3205560381
https://openalex.org/W2274190439
https://openalex.org/W2943251031
https://openalex.org/W4388728636
https://openalex.org/W2985950284
https://openalex.org/W2591445343"

ids_vec <- strsplit(ids, "\n")[[1]]

escape_regex <- function(x) str_replace_all(x, "([\\^$.|?*+()\\[\\]{}])", "\\\\\\1")
space_to_class <- function(x) str_replace_all(x, "\\p{Zs}+", "\\\\s+")  # any Unicode space

make_pattern <- function(keys) {
  keys |>
    escape_regex() |>
    space_to_class() |>
    (\(v) paste0("\\b", v, "\\b"))() |>
    paste(collapse = "|")
}



n_pattern_title <- make_pattern(new_keyword)
dat <- dat |>
  filter(!str_detect(title, regex(n_pattern_title, ignore_case = TRUE))) #28115 removed


#reruuning previous one
pattern2 <- make_pattern(irrelevant_journal_keywords)

dat <- dat |>
  filter(!str_detect(journal, regex(pattern2, ignore_case = TRUE))) # 1 additional removed


n_pattern_case <- paste(case_sensitive, collapse = "|")
dat <- dat |>
  filter(!str_detect(title, regex(n_pattern_case, ignore_case = FALSE))) #4266


n_pattern_journal <- paste(journal, collapse = "|")
dat <- dat |>
  filter(!str_detect(journal, regex(n_pattern_journal, ignore_case = TRUE))) #7788


dat <- dat |>
  filter(!oa_id %in% ids_vec) #22

saveRDS(dat, "final_clean_dat.rds")
