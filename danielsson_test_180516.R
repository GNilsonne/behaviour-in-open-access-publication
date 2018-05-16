# Hypotes 1: Finansiärers policies för öppen tillgång gör att fler artiklar från projekt som fått bidrag publiceras med öppen tillgång
# Hypotes 2: Finansiärers policies för öppen tillgång gör att artiklar utan öppen tillgång inte rapporteras till anslag från resp. finansiär

# Read data
id <- "1GHf6Lb8Bq7FAf8TPkE1XVtdiL6jQBXgI" # google file ID
data <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))

# Identify funders
funders <- c("Swedish Research Council") # To be added: other name variants; will require manual checking
data$funder <- 0
data$funder[grep(funders, data$FU)] <- 1

# Rename
levels(data$OA)[levels(data$OA)==""] <- "closed"
levels(data$OA)[levels(data$OA)=="green_accepted"] <- "g_a"
levels(data$OA)[levels(data$OA)=="green_published"] <- "g_p"

# Explore
plot(OA ~ funder, data, cex = 0.5)
