# this study organizes various pre-study files

library(tidyverse)
library(here)

# this code loads the master list of journals included in the Web of Science Social Sciences Citation Index and saves a list of only the psychology journals

wos_journals <- read_csv(here('data','primary','prepareSamples','wos-core_SSCI.csv')) # load list of all WOS journals

wos_psych <- wos_journals %>% 
  filter(str_detect(`Web of Science Categories`, 'Psychology')) # filter to obtain only WOS journals classified as psychology

write_csv(wos_psych,here('data','primary','prepareSamples','wos-psych-d.csv')) # save file


# this code compiles all of the separate journal by impact factor files (one for each subfield) into one file

# load in journals for each subject area ranked by impact factor (top 10)
journals_by_IF <- rbind(
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_experimental.csv'), skip = 1) %>%
    mutate(field = 'experimental'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_multidisciplinary.csv'), skip = 1) %>%
    mutate(field = 'multidisciplinary'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_clinical.csv'), skip = 1) %>%
    mutate(field = 'clinical'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_developmental.csv'), skip = 1) %>%
    mutate(field = 'developmental'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_social.csv'), skip = 1) %>%
    mutate(field = 'social'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_psychoanalysis.csv'), skip = 1) %>%
    mutate(field = 'psychoanalysis'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_applied.csv'), skip = 1) %>%
    mutate(field = 'applied'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_mathematical.csv'), skip = 1) %>%
    mutate(field = 'mathematical'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_educational.csv'), skip = 1) %>%
    mutate(field = 'educational'),
  read_csv(here('data','primary','prepareSamples','journals_by_IF','journals_by_IF_psychology_biological.csv'), skip = 1) %>%
    mutate(field = 'biological')
)

# remove some notes that are included in the data files
journals_by_IF %>% filter(!str_detect(Rank,'Copyright.'),
                          !str_detect(Rank,'By exporting.'))

write_csv(journals_by_IF, here('data','primary','prepareSamples','journals_by_IF.csv'))