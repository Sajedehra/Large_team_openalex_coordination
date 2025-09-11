
big_authors <- dat |> filter(n_author>=20)|>
  select(title, oa_id_author) %>%
  separate_rows(oa_id_author, sep = ",\\s*") %>%
  filter(oa_id_author != "") %>%
  rename(authors = oa_id_author)

big_authors_count<- nrow(big_authors)
big_authors <- big_authors|>distinct(authors)
big_authors_unique_count<- nrow(big_authors)


dat_small <- dat|>filter(n_author<20)
dat_big<- dat|>filter(n_author>=20)


library(dplyr)
library(stringr)
# library(purrr) if you use the map() version below

author_performance <- tibble(
  author_id = character(),
  small_project = list(),
  big_project   = list()
)

for (i in 1:nrow(big_authors)) {  # probably meant seq_along(...) or 1:nrow(...)
  author <- pull(big_authors, 1)[i]
  
  small_projects <- dat_small |>
    filter(str_detect(oa_id_author, author)) |>
    select(title, pubdate, n_author, citation, citation_2y, corr_citation)
  
  big_projects <- dat_big |>
    filter(str_detect(oa_id_author, author)) |>
    select(title, pubdate, n_author, citation, citation_2y, corr_citation)
  
  author_performance <- bind_rows(
    author_performance,
    tibble(
      author_id     = author,
      small_project = list(small_projects),
      big_project   = list(big_projects)
    )
  )
}


