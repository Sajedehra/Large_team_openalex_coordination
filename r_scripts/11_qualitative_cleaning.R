

library(readxl)
library(dplyr)
library(tidyr)
library(eulerr)
library(here)
library(ComplexUpset)



openalex_interdep_Code <- read_excel(here("data","MAXQDA openalex-interdep - Code System.xlsx"))


openalex_interdep_Code<- openalex_interdep_Code[3:31,]

openalex_interdep_Code<- openalex_interdep_Code[,c(3,4,7)] #if without memo it should be c(3,4, 6)

openalex_interdep_Code<-openalex_interdep_Code|> rename("category" = "...3", "subcategory" = "...4"  )

df_clean <- openalex_interdep_Code |>
  mutate(category = str_trim(category)) |>   # remove leading/trailing spaces
  mutate(category = na_if(category, ""))|>
  fill(category, .direction = "down")|>
  group_by(category) |>
  summarise(Frequency = sum(Frequency, na.rm = TRUE),
            .groups = "drop")



df_sets <- df_clean |>
  mutate(
    financial = grepl("Financial", category,  ignore.case = TRUE),
    epistemic = grepl("Epistemic", category,  ignore.case = TRUE),
    logistic  = grepl("Logistic",  category,  ignore.case = TRUE),
    temporal  = grepl("Temporal",  category,  ignore.case = TRUE),
    none = !(financial | epistemic | logistic | temporal)
  )



saveRDS(df_sets, here("data", "qualitative_descriptive.rds"))


# descriptive

df_long <- df_sets |>
  select(category, Frequency,financial, logistic, epistemic, temporal, none) |>
  pivot_longer(
    cols = c(financial, logistic, epistemic, temporal, none),
    names_to = "interdependency",
    values_to = "present"
  ) |>
  filter(present) |>
  group_by(interdependency)|>
  summarise(total_cases = sum(Frequency, na.rm = TRUE), .groups = "drop")|>
  arrange(total_cases)

# making the graph

#####
#To automatically use the data to make the diagram, you can use the code below. Euler automatically pick the position in space
#to generate the diagram and I could not find how to fix the position and I prefered the other one, I used the vector version bellow.

#df_clean2<- df_clean|> mutate(category = category|> str_replace_all(" \\+ ", "&")|> str_replace_all(" Interdependency", ""))

#eul_graph<- euler(setNames(df_clean2$Frequency, df_clean2$category))

#cols <- c(
#  "#476F84",
#  "#BA6E1D",
#  "#D6BB3B",
#  "#205F4B",
#  "#913914",
#  "#768048",
#  "#F0A430"
#)


#plot(eul_graph, quantities = list(type = "counts"), fills = list(fill = cols, alpha= 0.3), edges = list(col = "black", lwd = 1.7),
#     labels = list(fontsize = 10))

#####


eul_graph<- euler(c(
  "Symbolic" = 39,
  "No clear\nreason" = 12,
  "Part of a larger\nconsortium" = 7,
  "Financial" = 37,
  "Logistic" = 63,
  "Epistemic" = 48,
  "Temporal" = 30,
  "Financial&Epistemic" = 4,
  "Financial&Temporal" = 25,
  "Financial&Logistic" = 116,
  "Logistic&Temporal" = 17,
  "Temporal&Epistemic" = 30,
  "Temporal&Epistemic&Logistic" = 10,
  "Financial&Logistic&Epistemic" = 8,
  "Financial&Temporal&Epistemic" = 6,
  "Financial&Logistic&Temporal" = 28,
  "Financial&Logistic&Temporal&Epistemic" = 7,
  "Logistic&Epistemic" = 13
))

cols <- c(
  "#476F84",
  "#BA6E1D",
  "#D6BB3B",
  "#205F4B",
  "#913914",
  "#768048",
  "#F0A430"
)


plot(eul_graph, quantities = list(type = "counts"), fills = list(fill = cols, alpha= 0.3), edges = list(col = "black", lwd = 1.7),
     labels = list(fontsize = 10))



 