library(openalexR)
library(dplyr)
library(purrr)
library(readr)
library(tidyr)
library(stringr)
library(here)

options(openalexR.mailto = "s.rasti@tue.nl")


# Extract OpenAlex author IDs from one row of an oa_fetch() result
get_author_ids <- function(work_row) {
  a <- work_row$authorships[[1]]
  if (is.null(a) || nrow(a) == 0) return(character(0))
  a<- unique(a$id)
  a<-a|> str_remove("^https?://(dx\\.)?openalex\\.org/")
  return(a)
}


# Safe wrapper: retries once and returns NULL on failure instead
# of stopping the whole script
safe_oa_fetch <- function(...) {
  tryCatch(oa_fetch(...), error = function(e) {
    message("  fetch failed, retrying once: ", conditionMessage(e))
    Sys.sleep(2)
    tryCatch(oa_fetch(...), error = function(e2) {
      message("  retry failed: ", conditionMessage(e2))
      NULL
    })
  })
}


forward_self_citations <- function(dat) {
  
  results_list <- vector("list", nrow(dat))
  
  for (i in seq_len(nrow(dat))) {
    
    message(
      "Processing paper ", i, " / ", nrow(dat),
      ": ", dat$doi[i]
    )
    
    # -----------------------------
    # Clean focal paper OpenAlex ID
    # -----------------------------
    oa_id_paper <- dat$oa_id[i] |>
      str_remove("^https?://(dx\\.)?openalex\\.org/") |>
      str_trim()
    
    # -----------------------------
    # Clean focal author IDs
    # -----------------------------
    author_oa_id <- dat$oa_id_author[i] |>
      str_remove_all("[\\[\\]\"']") |>
      str_split(",\\s*") |>
      unlist() |>
      str_remove("^https?://(dx\\.)?openalex\\.org/") |>
      str_trim()
    
    author_oa_id <- unique(
      author_oa_id[
        !is.na(author_oa_id) &
          author_oa_id != ""
      ]
    )
    
    # -----------------------------
    # Find papers citing focal paper
    # -----------------------------
    citing_works <- safe_oa_fetch(
      entity = "works",
      cites = oa_id_paper,
      verbose = FALSE
    )
    
    # -----------------------------
    # No citing papers
    # -----------------------------
    if (is.null(citing_works) || nrow(citing_works) == 0) {
      
      results_list[[i]] <- tibble(
        oa_id = oa_id_paper,
        doi = dat$doi[i],
        n_authors = dat$n_author[i],
        our_citation = dat$citation[i],
        n_citations_new = 0L,
        n_self_citations_new = 0L
      )
      
      next
    }
    
    # -----------------------------
    # Determine self-citations
    # -----------------------------
    self_flags <- map_lgl(
      seq_len(nrow(citing_works)),
      function(j) {
        
        citing_authors <- get_author_ids(
          citing_works[j, ]
        )
        
        length(
          intersect(citing_authors, author_oa_id)
        ) > 0
      }
    )
    
    # -----------------------------
    # Identify citing papers published up to 2024
    # -----------------------------
    is_2024 <- citing_works$publication_date <= "2024-09-15"
    
    # Protect against missing publication years
    is_2024[is.na(is_2024)] <- FALSE
    
    # -----------------------------
    # Current citation metrics
    # -----------------------------
    n_citations_new <- nrow(citing_works)
    
    n_self_citations_new <- sum(
      self_flags,
      na.rm = TRUE
    )
    
    pct_self_forward_new <-
      100 * n_self_citations_new / n_citations_new
    
    # -----------------------------
    # Citation metrics up to 2024
    # -----------------------------
    n_citations_2024 <- sum(is_2024)
    
    n_self_citations_2024 <- sum(
      self_flags[is_2024],
      na.rm = TRUE
    )
    
    pct_self_forward_2024 <-
      ifelse(
        n_citations_2024 > 0,
        100 * n_self_citations_2024 / n_citations_2024,
        NA_real_
      )
    
    # -----------------------------
    # Store result
    # -----------------------------
    results_list[[i]] <- tibble(
      oa_id = oa_id_paper,
      doi = dat$doi[i],
      n_authors = dat$n_author[i],
      our_citation = dat$citation[i],
      
      n_citations_new = n_citations_new,
      n_self_citations_new = n_self_citations_new,
      pct_self_forward_new = pct_self_forward_new,
      
      n_citations_2024 = n_citations_2024,
      n_self_citations_2024 = n_self_citations_2024,
      pct_self_forward_2024 = pct_self_forward_2024
    )
    Sys.sleep(0.2)
  }
  
  bind_rows(results_list)
}



# Less than 20 authors ----------------------------------------------------


set.seed(1370)
dat2<- dat|>filter(n_author<20)|>slice_sample(n=500)

batch_1<-dat2[1:100,]
results1<- forward_self_citations(batch_1) 

batch_2<-dat2[101:200,]
results2<- forward_self_citations(batch_2)

batch_3<-dat2[201:300,]
results3<- forward_self_citations(batch_3)

batch_4<-dat2[301:400,]
results4<- forward_self_citations(batch_4)

batch_5<-dat2[401:500,]
results5<- forward_self_citations(batch_5)


self_citation_less20<- rbind(results1, results2, results3, results3, results5)
self_citation_less20<-self_citation_less20|>mutate(across(n_self_citations_new, ~ replace_na(.x, 0)))|>
  mutate(non_self_citation = n_citations_new - n_self_citations_new)

saveRDS(self_citation_less20, here("data", "self_citation_less20.rds"))


# More than 20 authors ----------------------------------------------------

set.seed(1370)

dat1<- dat|>filter(n_author>=20)|>slice_sample(n=500)

batch_1<-dat1[1:100,]
results1<- forward_self_citations(batch_1) 

batch_2<-dat1[101:200,]
results2<- forward_self_citations(batch_2)

batch_3<-dat1[201:300,]
results3<- forward_self_citations(batch_3)

batch_4<-dat1[301:400,]
results4<- forward_self_citations(batch_4)

batch_5<-dat1[401:500,]
results5<- forward_self_citations(batch_5)


self_citation_more20<- rbind(results1, results2, results3, results3, results5)

self_citation_more20<-self_citation_more20|>mutate(across(n_self_citations_new, ~ replace_na(.x, 0)))|>
  mutate(non_self_citation = n_citations_new - n_self_citations_new)

saveRDS(self_citation_more20, here("data", "self_citation_more20.rds"))


# comparisons -------------------------------------------------------------


wilcox.test(self_citation_more20$n_citations_new, self_citation_less20$n_citations_new, alternative = "greater", conf.int = TRUE)


self_citation_less20<- self_citation_less20|> mutate(corr_self_citation_new = n_self_citations_new/n_authors)

self_citation_more20<- self_citation_more20|> mutate(corr_self_citation_new = n_self_citations_new/n_authors)

wilcox.test(self_citation_more20$corr_self_citation_new, self_citation_less20$corr_self_citation_new, alternative = "greater", conf.int = TRUE)
