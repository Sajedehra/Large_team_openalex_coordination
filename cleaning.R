
# loading packages --------------------------------------------------------

library(readr)
library(data.table)
library(dplyr)
library(readxl)
library(stringr)
library(rcrossref)
library(openalexR)
library(tictoc)
library(psych)
library(ggplot2)
library(stringr)
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
                              "Sibling Designs", "airfoil", "Meeting and Workshops") #9621 cases for the first 4



pattern <- paste(irrelevant_title_keywords, collapse = "|")

dat <- dat |>
  filter(!str_detect(title, regex(pattern, ignore_case = TRUE))) # 85252 cases until here (NAs are also removed)

#check<- sample_n(dat, 200, replace = FALSE)
#check2<- sample_n(dat_d, 200, replace = FALSE)
#check3<- sample_n(dat, 200, replace = FALSE)
#check4<- sample_n(dat, 200, replace = FALSE)

irrelevant_journal_keywords<- c("History", "software", "Eos", "Acoustics", "Surgery", "Tourism", "chemistry", "Robotics", "Physical",
                                "Entrepreneurial Business", "ACM SIGCSE Bulletin", "computer science", "Environmental", "Pharmacology",
                                "Metaphilosophy", "Signal Processing", "Electronic", "Nutrition", "Canadian Studies", "Style",
                                "Fashion", "Entomology", "Ethnology", "Engineering", "Gas", "Critical Care", "Anthropolog", "art",
                                "Energy Conversion", "Safety Progress", "Mathematic", "Machine Learning", "Revista eureka",
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
                                "Obstetrics", "Intelligent Systems", "Transportation Research", "Urology", "dialectica") 



pattern2 <- paste(irrelevant_journal_keywords, collapse = "|")

dat <- dat |>
  filter(!str_detect(journal, regex(pattern2, ignore_case = TRUE))) # 652811 cases removed


irrelevant_issn<- c("1073-1911", "0022-0418", "1356-5028", "1440-7833", "0894-069X", "0013-7545", "1940-9052", "1063-5157", "0042-8469", "1327-9556", "1660-9336",
                    "0127-9696", "1470-5427")
pattern3 <- paste(irrelevant_issn, collapse = "|")
dat <- dat |>
  filter(is.na(issn) | !str_detect(issn, regex(pattern3, ignore_case = TRUE))) # 3189 cases removed





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

extr_authors<-dat  |> 
  filter(!is.na(n_author)) |> 
  slice_max(n_author, n = 10)

extr_citations<- dat |> 
  filter(!is.na(citation)) |> 
  slice_max(citation, n = 10)

# defining groups ---------------------------------------------------------

# grouping based on number of authors (3 different versions)


max<- dat_d |> 
  filter(!is.na(citation)) |> 
  slice_max(citation, n = 10)

bigger_g<- dat_d|> filter(n_author>= 200)
phys<- dat_d|> filter(str_detect(journal, regex("Medicine", ignore_case = TRUE)))

max(dat_d$n_author, na.rm = TRUE)

nrow(filter(bigger_g, n_author >= 250))
nrow(filter(bigger_g, n_author <= 250 & n_author>=211))


breaks_a <- c(0, 1, 2, 3, 4, 5, seq(10, 200, by = 5), 250, Inf)
labels_1to5 <- as.character(1:5)
labels_5plus <- paste(seq(6, 196, by = 5), seq(10, 200, by = 5), sep = "–")
labels_tail <- c("201–250", "251+")
labels_a <- c(labels_1to5, labels_5plus, labels_tail)

breaks_b <- c(0, 1, 2, 3, 4, 5, seq(15, 195, by = 10), 250, Inf)
labels_10s <- paste(seq(6, 190, by = 10), seq(15, 200, by = 10), sep = "–")
labels_tail_10 <- c("196–250", "251+")
labels_b <- c(labels_1to5, labels_10s, labels_tail_10)


breaks_c <- c(0, 1, 2, 3, 4, 5, seq(20, 200, by = 15), 250, Inf)
labels_15s <- paste(seq(6, 186, by = 15), seq(20, 200, by = 15), sep = "–")
labels_c <- c(labels_1to5, labels_15s, labels_tail)

# Apply cut
dat_d <- dat_d |>
  mutate(author_group_five = cut(n_author, breaks = breaks_a, labels = labels_a, right = TRUE, include.lowest = TRUE),
         author_group_ten = cut(n_author, breaks = breaks_b, labels = labels_b, right = TRUE, include.lowest = TRUE),
         author_group_fifteen = cut(n_author, breaks = breaks_c, labels = labels_c, right = TRUE, include.lowest = TRUE))







#saving the clean data
saveRDS(dat, file="D:/Sajedeh/Psydat_cleaned.rds")


# taking the subset of the data and save it

#samdat <- slice_sample(.data = dat, n = 1000000, weight_by = )

#samdat<- sample_n(dat, 1000000)
#saveRDS(samdat, file="data/samdatc.rds")

dat<- readRDS("D:/Sajedeh/Psydat_cleaned.rds")

try<- oa_fetch(identifier = "W4234470470",
         entity = "works",
         options = tibble(select = c("display_name"))
         )

dat<- dat|> mutate(oa_identifier = sub(".*/", "", oa_id))
tic()
for (i in 1:nrow(dat)) {
  res<- oa_fetch(identifier = dat$oa_identifier[i],
                          entity = "works",
                          options = tibble(select = c("display_name")))
  if(!is.null(res) && nrow(res) > 0){
    dat$title[i]<- res$display_name
  }
  else{ dat$title[i]<- NA_character_ }
}
toc()