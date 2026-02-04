
# Libraries ---------------------------------------------------------------

library(openalexR)
library(dplyr)
library(purrr)
library(tibble)
library(readr)
library(here)


# opening data ------------------------------------------------------------

dat<- readRDS(here("data","first_cleaned_data_openalex.rds"))


# OpenAlex Info -----------------------------------------------------------

mail<- "EMAIL ADDRESS"
apiKey<- "API KEY FOR OPENALEX"

# Selecting papers --------------------------------------------------------

set.seed(1377)

quali_papers<- dat|>filter(n_author>= 20)|> slice_sample(n = 1000)


safe_fetch <- possibly(
  function(id) oa_fetch(identifier = id, abstract = TRUE, mailto = mail, api_key = apiKey),
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

quali_abstracts_with_abstract<-quali_abstracts|> filter(!is.na(abstract))
quali_abstracts_without_abstract<-quali_abstracts|> filter(is.na(abstract))


# Saving ------------------------------------------------------------------

write_csv(quali_abstracts_with_abstract, here("data","qualitative_materials","quali_abstracts_with_abstract.csv"))
write_csv(quali_abstracts_without_abstract, here("data","qualitative_materials","quali_abstracts_without_abstract.csv"))

