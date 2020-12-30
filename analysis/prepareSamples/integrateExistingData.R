# the purpose of this script is to identify how many journals included in our sample are already included in TOP-d
# this is note in the sample data files. The code then extracts and saves the relevant data from TOP-d

library(tidyverse)
library(here)
library(stringdist)

randomSample <- read_csv(here('data','primary','prepareSamples','randomSample.csv'))
highImpactSample <- read_csv(here('data','primary','prepareSamples','highImpactSample.csv'))
top <- read_csv(here('data','primary','prepareSamples','top-factor.csv'))

# one problem we need to overcome is that the journal names used in the top database do not follow the same formatting standards as in the WOS database
# one change we can make to improve standardisation is to make the journal names in the top database uppercase (as they are in the samples)
top <- top %>%
  mutate(Journal = toupper(Journal))

# Now we will use approximate string matching to see if journal names in the sample are a close match to ones in the TOP database
# Specifically, we will compute the Standard Levenshtein distance (SLD)

sampleJournals <- tibble(journals = c(randomSample$Journal, highImpactSample$Journal), # get list of all journals in samples
                         matchInTOP = NA)

# this code will loop through all of the journals in the sample. For each journal, it will compute the SLD against all journal names in
# TOP-d. It will then select any journal names in TOP-d that had an SLD < = 5, display them at the command line, and ask the user to 
# confirm if there is a match or not

# NB - the code below requires MANUAL INPUT so it is commented out. Instead we load the csv file that orginally result from this manually input process

# MANUAL INPUT STARTS
# for(thisJournal in sampleJournals$journals){
#   print(paste('Sample journal is:',thisJournal))
#   SLDs <- tibble(journals = top$Journal,SLD = stringdist(thisJournal,top$Journal)) # compute SLD for this sample journal against all journals in the top database
#   possibleMatches <- SLDs %>% filter(SLD <= 5)
#   if(nrow(possibleMatches) == 0){
#     print('No matches with SLD <= 5')
#     sampleJournals <- sampleJournals %>%
#       mutate(matchInTOP = ifelse(journals == thisJournal, F, matchInTOP))
#   }else{
#     print('Possible matches with SLD <= 5:')
#     print(possibleMatches$journals)
#     userMatch <- readline(prompt="ENTER MATCHING NAME:") 
#     sampleJournals <- sampleJournals %>%
#       mutate(matchInTOP = ifelse(journals == thisJournal, userMatch, matchInTOP))
#   }
# }
# 
# sampleJournalsInTop <- sampleJournals %>% 
#   filter(matchInTOP %notin% c("F", "FALSE"))
# 
# write_csv(sampleJournalsInTop,here('data','primary','prepareSamples','sampleJournalsInTop.csv'))

sampleJournalsInTop <- read_csv(here('data','primary','prepareSamples','sampleJournalsInTop.csv'))

# MANUAL INPUT ENDS

# identify in sample dataframes whether journals have already been coded
randomSample <- randomSample %>%
  mutate(inTOP = ifelse(Journal %in% sampleJournalsInTop$journals, T, F))
highImpactSample <- highImpactSample %>%
  mutate(inTOP = ifelse(Journal %in% sampleJournalsInTop$journals, T, F))

# save files
write_csv(randomSample,here('data','primary','prepareSamples','randomSample.csv'))
write_csv(highImpactSample,here('data','primary','prepareSamples','highImpactSample.csv'))

# where sample journals have already been coded, extract the data from TOP-d
top %>% 
  filter(Journal %in% sampleJournalsInTop$matchInTOP) %>%
  write_csv(here('data','primary','topData.csv'))

