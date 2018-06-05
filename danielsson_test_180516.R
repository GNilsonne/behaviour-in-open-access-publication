# Hypotes 1: Finansiärers policies för öppen tillgång gör att fler artiklar från projekt som fått bidrag publiceras med öppen tillgång
# Hypotes 2: Finansiärers policies för öppen tillgång gör att artiklar utan öppen tillgång inte rapporteras till anslag från resp. finansiär

# Read data
id <- "1GHf6Lb8Bq7FAf8TPkE1XVtdiL6jQBXgI" # google file ID
data <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))

# Identify funders
funder_VR <- c("Swedish Research Council", "Vetenskapsrådet", "Vetenskapsradet", "Swedish Science Council", "VR$", "VR ")
funder_forte <- c("FORTE", "Swedish research council for health, working life and welfare", "FAS", "Forskningsrådet för arbetsliv och socialvetenskap", "Swedish fund for working life")
funder_formas <- c("FORMAS", "Swedish Research Council for Environment, Agricultural Sciences and Spatial Planning")
funder_RJ <- c("Riksbankens Jubileumsfond", "RJ", "Bank of Sweden Tercentenary Foundation", "Swedish Tercentary Fund")

data$funder_VR <- FALSE
data$funder_VR[grep(paste(funder_VR, collapse="|"), data$FU, ignore.case = T)] <- TRUE
data$funder_forte <- FALSE
data$funder_forte[grep(paste(funder_forte, collapse="|"), data$FU, ignore.case = T)] <- TRUE
data$funder_formas <- FALSE
data$funder_formas[grep(paste(funder_formas, collapse="|"), data$FU, ignore.case = T)] <- TRUE
data$funder_RJ <- FALSE
data$funder_RJ[grep(paste(funder_RJ, collapse="|"), data$FU, ignore.case = T)] <- TRUE

data$funder_any <- data$funder_VR | data$funder_forte | data$funder_formas | data$funder_RJ

#remaining_funders <- as.character(data$FU[!data$funder_any])

# Rename
levels(data$OA)[levels(data$OA)==""] <- "closed"
levels(data$OA)[levels(data$OA)=="green_accepted"] <- "g_a"
levels(data$OA)[levels(data$OA)=="green_published"] <- "g_p"

# Explore
plot(OA ~ funder_any, data, cex = 0.5)


# Try oadoi
install.packages("roadoi")
library(roadoi)

dois <- as.character(data$DI)

oadoi_out <- roadoi::oadoi_fetch(dois = dois[11:20], email = "gustav.nilsonne@ki.se")

library(purrr)
test <- purrr::map(dois[1:10], 
                     .f = purrr::safely(function(x) roadoi::oadoi_fetch(x, email ="gustav.nilsonne@ki.se")))
test2 <- purrr::map_df(test, "result")


library(dplyr)
oadoi_out %>%
  filter(is_oa == TRUE) %>%
  tidyr::unnest(best_oa_location) %>% 
  group_by(evidence) %>%
  summarise(Articles = n()) %>%
  arrange(desc(Articles)) %>%
  knitr::kable()

test2 %>%
  filter(is_oa == TRUE) %>%
  tidyr::unnest(best_oa_location) %>% 
  group_by(evidence) %>%
  summarise(Articles = n()) %>%
  arrange(desc(Articles)) %>%
  knitr::kable()

test_merge <- merge(data, test2, by.x = "DI", by.y = "doi", all = F)
test_merge_reduced <- test_merge[, c("OA", "is_oa", "best_oa_location")]
