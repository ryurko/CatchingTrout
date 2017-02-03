# Packages:
library(dplyr)
library(baseballr)
library(pitchRx)
library(RSQLite)

# Set up the PITCHf/x database:
setwd("~/Documents/BaseballResearch/CatchingTrout/data")
#my_db <- src_sqlite("pitchRx.sqlite3", create = TRUE)
#scrape(start = "2016-04-03", end = "2016-10-02", connect = my_db$con)

#files <- c("inning/inning_hit.xml", "miniscoreboard.xml", "players.xml")
#scrape(start = "2016-04-03", end = "2016-10-02", suffix = files, connect = my_db$con)

# Open the database connection:
db <- src_sqlite('pitchRx.sqlite3')

# atbats table:

atbats <- tbl(db,'atbat')

# pitches table:

pitches <- tbl(db,'pitch')

# Join together and filter down to just the regular season using the
# fact it was between April 3 and October 2:

db_2016 <- inner_join(pitches, atbats, by = c('num', 'gameday_link')) %>% filter(date >= "2016_04_03" & date <= "2016_10_02")

# Now the only columns needed from this dataset are batter and b_height:

batters_2016 <- db_2016 %>% select(batter,batter_name,b_height) %>% distinct() %>%
  filter(!is.na(batter_name)) %>% collect(n=Inf)

# Check that the number of unique batter ids is the number of rows (no batter with
# multiple heights):

nrow(batters_2016) == length(unique(batters_2016$batter))
# TRUE

# Need to remove the following batter ids (Pedro Strop, Chad Hinshaw, pitchers anyway
# that crashes the scrape function and a missing ID):

batters_2016 <- batters_2016 %>% filter(batter != 467008 & batter != 664058 & 
                                        batter != 660168 & batter != 643364 &
                                        batter != 607430)

# Now for each batter in the batters_2016 dataframe,
# need to call scrape_statcast_savant_batter() and 
# then merge the dataframes together

# Use lapply with the scraping function to get
# the pitchfx and statcast dataframes for each batter:

pfx_statcast_list <- lapply(batters_2016$batter,
                            function(x) scrape_statcast_savant_batter(start_date = "2016-04-03",
                                                                      end_date = "2016-10-02",
                                                                      batterid=x))


# There was an error:
error_2016 <- db_2016 %>% select(batter,batter_name) %>% filter(batter == 607430) %>% 
  distinct () %>% collect(n=Inf)





