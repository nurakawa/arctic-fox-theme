mob <- read.csv("https://raw.githubusercontent.com/ActiveConclusion/COVID19_mobility/master/summary_reports/summary_report_countries.csv")

europe <- c('Austria', 'Belgium', 'Bulgaria', 'Croatia',
            'Czechia', 'Denmark', 'Estonia', 'Finland',
            'France', 'Germany', 'Greece', 'Hungary',
            'Ireland', 'Italy', 'Latvia', 'Lithuania',
            'Luxembourg', 'Malta', 'Netherlands', 'Norway',
            'Poland', 'Portugal', 'Romania', 'Slovakia',
            'Slovenia', 'Spain', 'Sweden', 'Switzerland', 'United Kingdom') 
  
mob <- mob[mob$country %in% europe,]

# replace NA with 0 for now
mob[is.na(mob)] = 0


names(mob) <-  c("country",  "date",  "retail and recreation" ,
                 "grocery and pharmacy", "parks", "transit stations",
                 "workplaces", "residential", "driving" , "transit", "walking")  

write.csv(mob,
          '/home/nkawa/nurakawa.github.io/assets/mobility-data.csv',
          row.names = F,
          fileEncoding = 'UTF-8',
          quote = F)
