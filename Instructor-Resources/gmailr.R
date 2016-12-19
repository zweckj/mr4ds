install.packages('gmailr', repos = 'https://mran.revolutionanalytics.com/snapshot/2016-05-01')
library(gmailr)
use_secret_file("gmailr-mr4ds.json")

# find key here
# https://console.developers.google.com/apis/credentials?project=gmailr-mr4ds

# test --------------------------------------------------------------------


test_email <- mime(
  To = "alikaz.zaidi@gmail.com",
  From = "learn.mr4ds@gmail.com",
  Subject = "this is just a gmailr test",
  body = "Can you hear me now?")

send_message(test_email)

## verify that the email arrives succesfully!



# create usernames --------------------------------------------------------

library(data.table)
library(dplyr)
library(stringr)

comics <- fread("https://raw.githubusercontent.com/fivethirtyeight/data/master/comic-characters/marvel-wikia-data.csv")
comics <- comics %>% tbl_df

heros <- comics %>% 
  arrange(desc(APPEARANCES)) %>% select(name) %>% 
  mutate(first = str_locate(pattern = "[(]", name)[, "start"], 
         cool_name = tolower(str_replace(substr(name, 1, first - 2), " |-", ""))) %>% 
  filter(nchar(cool_name) < 10, !str_detect(cool_name, " "))

credentials <- heros %>% select(cool_name) %>% mutate(password = paste0(cool_name, "123!"))

credentials %>% slice(1:50) %>% write.csv(file = "credentials.csv", row.names = F, quote = FALSE)

logins <- credentials %>% slice(1:50)


# credentials -------------------------------------------------------------

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))
library(readr)

my_dat <- read_csv("munchen_2016_12_attendees.csv")

subject <- "Login Credentials for Microsoft R Workshop"
email_sender <- 'Ali Zaidi <learn.mr4ds@gmail.com>'
optional_bcc <- 'Ali Zaidi <alizaidi@microsoft.com>'
body <- "Hi, %s.

Your username for the workshop is %s, and your password is %s.


Thanks for participating in this workshop!

Ali Zaidi
"


names(my_dat) <- str_replace_all(names(my_dat), " ", ".")

edat <- bind_cols(my_dat, slice(logins, 1:nrow(my_dat))) %>% 
  mutate(
    To = sprintf('%s <%s>', First.Name, Email),
    Bcc = optional_bcc,
    From = email_sender,
    Subject = subject,
    body = sprintf(body, First.Name, cool_name, password)) %>%
  select(To, Bcc, From, Subject, body)
edat
write_csv(edat[, ], "composed-emails.csv")

emails <- edat %>%
  pmap(mime)


safe_send_message <- safely(send_message)
sent_mail <- emails %>%
  map(safe_send_message)

saveRDS(sent_mail,
        paste(gsub("\\s+", "_", subject), "sent-emails.rds", sep = "_"))

errors <- sent_mail %>%
  transpose() %>%
  .$error %>%
  map_lgl(Negate(is.null))
sent_mail[errors]

