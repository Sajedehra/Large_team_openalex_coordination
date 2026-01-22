set.seed(1377)

quali_papers<- dat|>filter(n_author>= 20)|> slice_sample(n = 1000)

library(openalexR)



quali_abstracts<- tibble(id = character(),
                         title = character(),
                         abstract = character())


for (i in seq_along(quali_papers)) {
  identifier<- basename(quali_papers$oa_id[i])
  
  ab<- oa_fetch(identifier = identifier, abstract = TRUE, mailto ="s.rasti@tue.nl", api_key = "9303a07273d05298a578a6de828964c8")
  if(!is.na(ab$abstract)){abstract = ab$abstract}
  else abstract = NA
  quali_abstracts<- rbind(quali_abstracts,
                          tibble(
                            id = quali_papers$oa_id[i],
                            title = quali_papers$title[i],
                            abstract = abstract
                          ))
}







library(dplyr)
library(purrr)
library(tibble)
library(readr)

safe_fetch <- possibly(
  function(id) oa_fetch(identifier = id, abstract = TRUE, mailto ="s.rasti@tue.nl", api_key = "9303a07273d05298a578a6de828964c8"),
  otherwise = NULL
)

quali_abstracts <- quali_papers %>%
  mutate(
    identifier = basename(oa_id),
    ab = map(identifier, safe_fetch),
    abstract = map_chr(ab, ~ {
      if (is.null(.x)) return(NA_character_)
      a <- .x[["abstract"]]
      if (is.null(a) || length(a) == 0 || all(is.na(a))) return(NA_character_)
      as.character(a[[1]])
    })
  ) %>%
  transmute(id = oa_id, title, abstract)

sum(!is.na(quali_abstracts$abstract))

quali_abstracts_na<-quali_abstracts|> filter(is.na(abstract))

write_csv(quali_abstracts_na, "quali_abstracts_na_add.csv")

