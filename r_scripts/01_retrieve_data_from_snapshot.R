

# Libraries ---------------------------------------------------------------


library(jsonlite)
library(tibble)
library(future)
library(future.apply)
library(readr)
library(vroom)
library(here)


# Functions ---------------------------------------------------------------


# Define the function to parse JSON files in chunks 
process_file_in_chunks <- function(file_path, chunk_size = 1000) {
  temp_final <- list()
  con <- file(file_path, open = "r")
  on.exit(close(con))
  
  repeat {
    lines <- readLines(con, n = chunk_size, warn = FALSE)
    if (length(lines) == 0) break
    
    for (l in seq_along(lines)) {
      tryCatch({
        j_list <- fromJSON(lines[l])
        # psychology and decision science as first or second field name
        is_psychology <- (
          any(sapply(j_list[["topics"]][["field"]][["display_name"]][[1]],
                     function(name) grepl("Decision Sciences", name, ignore.case = TRUE))) |
            any(sapply(j_list[["topics"]][["field"]][["display_name"]][[1]],
                       function(name) grepl("Psychology", name, ignore.case = TRUE)))|
            any(sapply(j_list[["topics"]][["field"]][["display_name"]][[2]],
                       function(name) grepl("Decision Sciences", name, ignore.case = TRUE))) |
            any(sapply(j_list[["topics"]][["field"]][["display_name"]][[2]],
                       function(name) grepl("Psychology", name, ignore.case = TRUE))))
        if(is_psychology){
          # Add a new row to temp_final for each matching result, handling missing fields
          row_data <- list( 
            oa_id = if (!is.null(j_list[["id"]])) as.character(j_list[["id"]]) else NA_character_,
            doi = if (!is.null(j_list[["doi"]])) as.character(j_list[["doi"]]) else NA_character_,
            pubdate = if (!is.null(j_list[["publication_date"]])) as.character(j_list[["publication_date"]]) else NA_character_,
            title = if (!is.null(j_list[["display_name"]])) as.character(j_list[["display_name"]]) else NA_character_,
            journal = if (!is.null(j_list[["primary_location"]][["source"]][["display_name"]])) as.character(j_list[["primary_location"]][["source"]][["display_name"]]) else NA_character_,
            issn = if (!is.null(j_list[["primary_location"]][["source"]][["issn_l"]])) as.character(j_list[["primary_location"]][["source"]][["issn_l"]]) else NA_character_,
            type = if (!is.null(j_list[["type_crossref"]])) as.character(j_list[["type_crossref"]]) else NA_character_,
            language = if (!is.null(j_list[["language"]])) as.character(j_list[["language"]]) else NA_character_,
            open_access = if (!is.null(j_list[["open_access"]][["oa_status"]])) as.character(j_list[["open_access"]][["oa_status"]]) else NA_character_,
            authors = if (!is.null(j_list[["authorships"]][["author"]][["display_name"]])) as.character( paste(j_list[["authorships"]][["author"]][["display_name"]], collapse = ", ")) else NA_character_,
            oa_id_author = if (!is.null(j_list[["authorships"]][["author"]][["id"]])) as.character(paste(j_list[["authorships"]][["author"]][["id"]], collapse = ", ") )else NA_character_,
            orcid = if (!is.null(j_list[["authorships"]][["author"]][["orcid"]])) as.character(paste(j_list[["authorships"]][["author"]][["orcid"]], collapse = ", ") )else NA_character_,
            citation = if (!is.null(j_list[["cited_by_count"]])) as.integer(j_list[["cited_by_count"]]) else NA_integer_,
            citation_2y = if (!is.null(j_list[["summary_stats"]][["2yr_cited_by_count"]])) as.integer(j_list[["summary_stats"]][["2yr_cited_by_count"]]) else NA_integer_,
            cite_tre_year = if (!is.null(j_list[["counts_by_year"]])) as.character(paste(j_list[["counts_by_year"]][["year"]], collapse = ", ")) else NA_character_,
            cite_tre_count =if (!is.null(j_list[["counts_by_year"]])) as.character(paste(j_list[["counts_by_year"]][["cited_by_count"]], collapse = ", ")) else NA_character_,
            volume = if (!is.null(j_list[["biblio"]][["volume"]])) as.integer(j_list[["biblio"]][["volume"]]) else NA_integer_,
            issue = if (!is.null(j_list[["biblio"]][["issue"]])) as.integer(j_list[["biblio"]][["issue"]]) else NA_integer_,
            page = if (!is.null(j_list[["biblio"]][["first_page"]])) as.integer(j_list[["biblio"]][["first_page"]]) else NA_integer_,
            ref = if (!is.null(j_list[["referenced_works"]])) as.character(paste(j_list[["referenced_works"]], collapse = ", ") )else NA_character_
          )
          temp_final[[length(temp_final) + 1]] <- row_data
        }
        
      }, error = function(e) {
        cat("Error:", conditionMessage(e), "\n", file = "errors.log", append = TRUE)
      })
    }
    gc()
  }
  return(temp_final)  
  
}


# set parallel analysis ---------------------------------------------------


plan(multisession, workers = availableCores())



# iteration ---------------------------------------------------------------


## create an empty tibble to store the desired info
final <- tibble(oa_id = character(), doi = character(), pubdate = character(), title = character(), journal = character(),
                issn = character(), type = character(), language = character(),
                open_access = character(), authors = character(), orcid = character(),oa_id_author = character(), 
                citation = integer(), citation_2y = integer(), cite_tre_year = character(), cite_tre_count = character(), ref = character(),volume = integer(), issue = integer(), page = integer())

empt_final <- final



dat_file <- here("data","works")

dat_file2<- list.files(dat_file, recursive = TRUE, full.names = TRUE)


#iterating over the data in all files and folders

for (j in 1:length(dat_file2)) {
  file_paths <- dat_file2[j]
  print(file_paths)
  results_list <- future_lapply(file_paths, process_file_in_chunks)
  if (length(results_list[[1]])>0){
    for (l in 1:length(results_list[[1]])) {
      final <<- add_row(final, as_tibble(results_list[[1]][[l]]))
    }
  }
  remove(results_list)
  write_delim(final, file = here("data", "raw_data_OpenAlex.csv"), delim = ";", append = TRUE)
  final <- empt_final
}


