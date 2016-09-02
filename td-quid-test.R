
# import data from Azure DW -----------------------------------------------


library(RODBC) 
dbhandle <- odbcDriverConnect('Driver={ODBC Driver 13 for SQL Server};
                              Server=tcp:msquidsqlserver.database.windows.net,1433;
                              Database=msquiddatawarehouse;Uid=<username>@msquidsqlserver;
                              Pwd={<PW>};Encrypt=yes;
                              TrustServerCertificate=no;
                              Connection Timeout=30;')
info_schema <- sqlQuery(dbhandle, 
                        'select * from information_schema.tables')
daily_mr <- sqlQuery(dbhandle, 
                     'select * from MSDS_TD_DAILY_MR')

library(dplyr)
library(lubridate)

daily_mr <- tbl_df(daily_mr)
daily_mr <- daily_mr %>% filter(!is.na(COM_COUNT))

daily_mr <- daily_mr %>% arrange(EQP_NUM, COM_DATE)

daily_mr <- daily_mr %>% 
  filter(!is.na(COM_COUNT)) %>% 
  group_by(EQP_NUM, COM_DATE) %>% 
  tally


grouped_mr <- daily_mr %>% 
  group_by(EQP_NUM) %>% 
  mutate(last_date = lag(COM_DATE),
         last_obs = COM_DATE - last_date,
         bad_obs = ifelse(!is.na(last_obs) &
                            last_obs > 1,
                          "broken",
                          "okay"))


broken_sensors <- grouped_mr %>% 
  filter(!is.na(last_obs), as.numeric(last_obs) != 1)


grouped_mr %>% filter(last_obs > 13)

grouped_mr %>% filter(bad_obs == "broken") %>% 
  group_by(EQP_NUM) %>% tally()



model_data <- read.csv("model14.csv")

