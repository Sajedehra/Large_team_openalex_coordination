library(RVAideMemoire)
library(here)


dat<- readRDS(here("data","consolidate_data_openalex.rds"))
dat_sjr<- readRDS(here("data","consolidate_journal_data.rds"))



ci1<- spearman.ci(dat$n_author, dat$citation)
ci2<- spearman.ci(dat$n_author, dat$citation_2y)
ci3<- spearman.ci(dat$n_author, dat$corr_citation)
ci4<- spearman.ci(dat_sjr$n_author, dat_sjr$SJR)


ci_full<- data.frame("variable" = c("citation", "citation_2y", "corr_citation", "SJR"),
                     "ci.l"= c(ci1[["conf.int"]][[1]], ci2[["conf.int"]][[1]], ci3[["conf.int"]][[1]], ci4[["conf.int"]][[1]]),
                     "ci.u"=c(ci1[["conf.int"]][[2]], ci2[["conf.int"]][[2]], ci3[["conf.int"]][[2]], ci4[["conf.int"]][[2]]))

saveRDS(ci_full, here("data","all_CI_openalex.rds"))
