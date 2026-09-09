library(readxl)
library(irr)
library(here)


to_binary <- function(x) {
  ifelse(is.na(x), 0, 1)
}

codes <- c(
  "Symbolic",
  "No clear reason",
  "Part of bigger consortium",
  "Financial",
  "Epistemic",
  "Logistic",
  "Temporal"
)


coder1<- read_xlsx(here("qualitative analysis", "check_SR.xlsx"))
coder2<- read_xlsx(here("qualitative analysis", "check_KV.xlsx"))
coder3<- read_xlsx(here("qualitative analysis", "check_DL.xlsx"))

coder1_a<- coder1[1:50,]
coder1_b<- coder1[52:101,]


qual_result_2<- data.frame()

for (code in codes) {
  bin_coder1<- to_binary(coder1_a[code])
  bin_coder2<- to_binary(coder2[code])
  
  agreement<-mean(bin_coder1 == bin_coder2)*100
  
  
  qual_result_2 <- rbind(
    qual_result_2,
    data.frame(
      Code = code,
      N = length(bin_coder1),
      Percent_Agreement = agreement
    )
  )
}



qual_result_3<- data.frame()

for (code in codes) {
  coder1<- to_binary(coder1_b[code])
  coder2<- to_binary(coder3[code])
  
  agreement<-mean(coder1 == coder2)*100
  
  
  qual_result_3 <- rbind(
    qual_result_3,
    data.frame(
      Code = code,
      N = length(coder1),
      Percent_Agreement = round(agreement, 1)
    )
  )
}


saveRDS(qual_result_2, here("data", "intercoder_initial.rds"))
saveRDS(qual_result_3, here("data", "intercoder_final.rds"))

