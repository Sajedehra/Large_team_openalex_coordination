

library(readxl)
maxqda<- read_xlsx("max_data.xlsx", col_names = c("code", "Reasons", "Frequesncy"))
maxqda<- maxqda|>select(-c(code))
maxqda <- maxqda[-1, ]
maxqda$Reasons[1]<- "Total"
maxqda$Reasons[7]<- "Commentary, Position,Opinion,\n and Perspective Literature"
maxqda$Reasons[13]<- "Multi-Center and Multi-Region Studies"
maxqda$Reasons[9]<- "Developing and Validating Scales"
maxqda$Frequesncy<-as.numeric(maxqda$Frequesncy)
saveRDS(maxqda, "maxqda.rds")


library(ggplot2)

maxqda|> slice(-1)|>
  ggplot(aes(x = Reasons, y=Frequesncy, fill = Reasons))+
  geom_col()+
  theme_classic()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))+
  scale_fill_manual(values = c("#023743FF","#72874EFF","#476F84FF","#A4BED5FF","#A40000FF",
                                "#453947FF","#774762FF","#BA6E1DFF","#D6BB3BFF","#755028FF",
                                "#205F4BFF","#913914FF","#585854FF","#F0A430FF","#007E2FFF"), guide = "none")





