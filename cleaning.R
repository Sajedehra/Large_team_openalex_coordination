
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


dat<- readRDS("D:/Sajedeh/dat_enjournal.rds")

dat<- dat|>distinct(oa_id, .keep_all = TRUE)
#dat <- dat[!duplicated(dat)]
n_initial<- nrow(dat)

dat<- dat|>distinct(doi, pubdate, journal, volume, issue, page, .keep_all = TRUE)
n_notduplicate<- nrow(dat)

#dat<- dat|> sum(!is.na(issn))
#length(unique(dat$issn))
#journal_check<- dat |> distinct(issn, journal, IF.x)
#write.csv(journal_check, "D:/Sajedeh/journal_check.csv")
## removing journals that are clearly unrelated to psychology
#unique_psy_jour<- read_csv("C:/Users/labcontrol/Downloads/psychology_core_and_general_journals.csv")
#unique_psy_jour <- unique_psy_jour |> select(-IF.x)
#PNAS<- c("0027-8424", "PNAS (paper)")
#unique_psy_jour <-rbind(PNAS, unique_psy_jour)
#dat_d<- dat_1 |>filter(issn %in% unique_psy_jour$issn)
#sum(dat_d$journal=="Science", na.rm = TRUE)


## removing non-psychology works / not journals

dat<- dat|> filter(language == "en")|> filter(type == "journal-article")
n_enjournal<- nrow(dat)

non_psych_keywords <- c(
  "cancer", "oncology", "immunology", "biotechnology", "cell", "genetics",
  "molecular", "materials", "energy", "physics", "chemistry", "biomedical",
  "cardiology", "nephrology", "gastroenterology", "pathology", "plant",
  "engineering", "metabolism", "diabetes", "neurology", "urology", "hematology",
  "endocrinology", "photonics", "optics", "thoracic", "seismology", "climate",
  "sustainability", "fluid", "robotics", "composites", "environment",
  "bioproducts", "computing", "electronics", "pattern analysis", "earth",
   "microbiology", "virology", "biochemistry", 
   "respiratory", "solar", "bioethics", "bioresources", "ceramics",
  "ophthalmology", "rheumatic", "infection", "infection", "neuro-oncology",
  "nucleic acids", "retinal", "thoracic", "failure", "liver", "nanotech",
  "chem", "drug", "development", "surveillance", "medicine",
  "advanced materials", "host", "metabolism", "tissue", "vascular", "transduction", 
   "surgery", "Instrumentation", "Anaesthesia",
  "diabet", "Autophagy", "Physical", "particle", "BMC", "APS", "Biological Rhythms", 
  "Epidemiology", "lancet", "JAMA", "Ecology", "arXiv", "MIT", "PMC", "Repository",
  "chest", "Archives", "Reproduction", "Change Biology", "BMJ", "pharmacological",
  "film studies", "#", "table of Content", "Symposium", "acknowledgement to",
  "acknowledgement of"
)



pattern <- paste(non_psych_keywords, collapse = "|")

dat <- dat |>
  filter(!str_detect(title, regex(pattern, ignore_case = TRUE)))


dat <- dat |>
  filter(!str_detect(
    str_trim(title),
    regex("^Acknowledg(e)?ment(s)?$", ignore_case = TRUE)
  ))

n_article_psychology<- nrow(dat)

# removing other types of entries but journal articles
dat_d <- dat_d[(dat_d$type == "journal-article"),]
n_journal<- nrow(dat)



#removing unwanted years
range(dat$pubdate)

dat_d<- dat_d|> filter(pubdate>="1900-01-01" & pubdate<"2025-01-01")
range(dat$pubdate)

#calculating number of authors
dat_d$n_author<- str_count(dat_d$oa_id_author, ",")+1

# calculating the time difference from publication
download_date <- as.Date("2024-09-14")

dat_d$timediff <- as.integer(download_date - as.Date(dat_d$pubdate))
dat_d$timediff[dat_d$timediff == 0] <- 1

dat$issuedate <- format(as.Date(dat$pubdate), "%Y-%m") #sometimes pubdate appears as such in crossref



# missing data ------------------------------------------------------------


#checking the missing info

n_miss_author<- sum(is.na(dat2$n_author))
n_miss_issn <- sum(is.na(dat$issn))

n_miss_both<- nrow(dat|>filter(if_all(c(n_author, issn), is.na)))

n_missing_ref <- sum(dat$ref == "")

#plotting the missing data


par(mfrow = c(2,2))

#dat|> mutate(pubyear = format(pubdate, "%Y"))|> group_by(pubyear)|>summarise(miss_author = sum(is.na(dat$n_author)))|>
#  ggplot(aes(x = pubyear, y = miss_author))+
#  geom_point()

missing_years<- dat|>mutate(pubyear = format(pubdate, "%Y"))|> group_by(pubyear)|> summarise(sum(is.na(n_author)))

ggplot(aes(x = as.integer(pubyear), y = `sum(is.na(n_author))`), data= missing_years)+
  geom_line(color = "blue")+
  geom_point(color = "red")



missing_ref <- dat|>mutate(pubyear = format(pubdate, "%Y"))|> group_by(pubyear)|> summarise(miss_ref = sum(ref == ""))

ggplot(aes(x = as.integer(pubyear), y = miss_ref), data= missing_ref)+
  geom_line(color = "blue")+
  geom_point(color = "red")
missing_issn <- dat|>mutate(pubyear = format(pubdate, "%Y"))|> group_by(pubyear)|> summarise(miss_issn = sum(is.na(issn)))


#trying to replace missing authors

tic()
for (i in 128:138) {
  if(is.na(dat$n_author[i])){
      info<- oa_fetch(identifier = paste(sub("https://openalex.org/", "", dat$oa_id[i])))
      title<- info$title
      cr_info<- cr_works(query=title)
      for (j in 1:length(cr_info[["data"]][["author"]])) {
        if(cr_info[["data"]][["issued"]][[j]] == dat$issuedate[i] || cr_info[["data"]][["issued"]][[j]] == dat$pubdate[i]){
          dat$n_author[i] = length(cr_info[["data"]][["author"]][[j]][["family"]])
        }else
          dat$n_author[i] <- "unknown"
      }
    }
  }

toc()

# trying to replace missing issn




# defining groups ---------------------------------------------------------

# grouping based on number of authors (3 different versions)
max<- dat_d  |> 
  filter(!is.na(n_author)) |> 
  slice_max(n_author, n = 30)

mean(max$n_author[1:10])

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