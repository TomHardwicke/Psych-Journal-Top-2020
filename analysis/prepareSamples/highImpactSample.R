# This script obtains a sample of the top-5 journals according to 2019 Journal Impact Factor in each of ten sub-fields of psychology

library(tidyverse)
library(here)
`%notin%` <- Negate(`%in%`)

journals_by_IF <- read_csv(here('data','primary','prepareSamples','journals_by_IF.csv')) # load list of journals ranked by impact factor

# filter out journals identified as non-empirical during manual screening
# update Jan 4, 2021 - the journal *Psychological Science in the Public Interest* was originally included in the high impact sample but identified during data extraction as a review only journal. Therefore we are excluding it now and replacing it with the next available rank.
journals_by_IF <- journals_by_IF %>%
  filter(`Full Journal Title` %notin% 
           c("TRENDS IN COGNITIVE SCIENCES",
             "Advances in Experimental Social Psychology",
             "Behavior Research Methods",
             "Current Opinion in Behavioral Sciences",
             "PSYCHOLOGICAL BULLETIN", 
             "Annual Review of Psychology", 
             "PSYCHOLOGICAL INQUIRY", 
             "PSYCHOLOGICAL REVIEW", 
             "Annual Review of Clinical Psychology",
             "CLINICAL PSYCHOLOGY REVIEW",
             "CLINICAL PSYCHOLOGY-SCIENCE AND PRACTICE", 
             "NEUROPSYCHOLOGY REVIEW", 
             "Child Development Perspectives", 
             "ZEITSCHRIFT FUR PSYCHOSOMATISCHE MEDIZIN UND PSYCHOTHERAPIE",
             "International Review of Sport and Exercise Psychology",
             "Annual Review of Organizational Psychology and Organizational Behavior", 
             "ORGANIZATIONAL RESEARCH METHODS",
             "Behavior Research Methods",
             "JOURNAL OF EDUCATIONAL AND BEHAVIORAL STATISTICS",
             "PSYCHOMETRIKA",
             "EDUCATIONAL AND PSYCHOLOGICAL MEASUREMENT",
             "Methodology-European Journal of Research Methods for the Behavioral and Social Sciences",
             "JOURNAL OF CLASSIFICATION", 
             "EDUCATIONAL PSYCHOLOGY REVIEW", 
             "EDUCATIONAL PSYCHOLOGIST", 
             "BEHAVIORAL AND BRAIN SCIENCES",
             "PERSONALITY AND SOCIAL PSYCHOLOGY REVIEW",
             "Social Issues and Policy Review",
             "Advances in Experimental Social Psychology",
             "European Review of Social Psychology",
             "Psychological Science in the Public Interest"))

journals_by_IF <- journals_by_IF %>% 
  mutate(`Full Journal Title` = toupper(`Full Journal Title`)) # capitalize journal titles as this is the standard in WOS-psych-d

# remove any journals that are included in the random sample
random_sample <- read_csv(here('data','primary','prepareSamples','randomSample.csv')) # load random sample

# removals required if we consider top 5 ranks only
journals_by_IF %>% group_by(field) %>% # for each field
  slice(1:5) %>% # select top 5 rows
  ungroup() %>%
  filter(`Full Journal Title` %in% random_sample$`Journal`) %>% 
  nrow()

# perform removals
journals_by_IF <- journals_by_IF %>%
  filter(`Full Journal Title` %notin% random_sample$`Journal`)

# check for journals appearing in multiple subfields
duplicateJournals <- journals_by_IF %>% 
  group_by(field) %>% # for each field
  slice(1:5) %>% # select top 5 rows
  ungroup() %>%
  count(`Full Journal Title`) %>% # count journal name usage
  filter(n > 1) # show any journals appearing more than once

duplicateJournals

# check the ranks for these journals
journals_by_IF %>% 
  filter(`Full Journal Title` %in% c(duplicateJournals$`Full Journal Title`))

# for CHILD DEVELOPMENT, the rank is higher in educational, so it needs to be replaced in developmental
# for PSYCHONOMIC BULLETIN & REVIEW, the rank is higher in mathematical, so it needs to be replaced in experimental

journals_by_IF <- journals_by_IF %>%
  filter(case_when(
    `Full Journal Title` == "CHILD DEVELOPMENT" & field == "developmental" ~ FALSE,
    `Full Journal Title` == "PSYCHONOMIC BULLETIN & REVIEW" & field == "experimental" ~ FALSE,
    TRUE ~ TRUE))

# check again for journals appearing in multiple subfields
duplicateJournals <- journals_by_IF %>% 
  group_by(field) %>% # for each field
  slice(1:5) %>% # select top 5 rows
  ungroup() %>%
  count(`Full Journal Title`) %>% # count journal name usage
  filter(n > 1) # show any journals appearing more than once

duplicateJournals

# check the ranks for these journals
journals_by_IF %>% 
  filter(`Full Journal Title` %in% c(duplicateJournals$`Full Journal Title`))

# for PSYCHOPHYSIOLOGY, the rank is higher in biological, so it needs to be replaced in experimental

journals_by_IF <- journals_by_IF %>%
  filter(case_when(
    `Full Journal Title` == "PSYCHOPHYSIOLOGY" & field == "experimental" ~ FALSE,
    TRUE ~ TRUE))

# check again for journals appearing in multiple subfields
duplicateJournals <- journals_by_IF %>% 
  group_by(field) %>% # for each field
  slice(1:5) %>% # select top 5 rows
  ungroup() %>%
  count(`Full Journal Title`) %>% # count journal name usage
  filter(n > 1) # show any journals appearing more than once

# check again for journals appearing in multiple subfields
duplicateJournals

# there are now no duplicates

# select top 5 journals in each subfield
highImpactSample <- journals_by_IF %>% 
  group_by(field) %>% # for each field
  slice(1:5) # select top 5 rows

# load the journal websites that were identified during screening and combine them with the journal list
websites <- read_csv(here('data','primary','prepareSamples','highImpactSampleWebsites.csv')) %>%
  filter(empirical == T) %>% 
  select(`Full Journal Title`,website) %>%
  distinct(`Full Journal Title`, .keep_all = T) %>%
  mutate(`Full Journal Title` = toupper(`Full Journal Title`))

highImpactSample <- left_join(highImpactSample,websites, by = 'Full Journal Title') 

# add bibliographic information from the WOS database
wos <- read_csv(here('data','primary','prepareSamples','wos-core_SSCI.csv')) %>% # load list of all WOS journals
  rename(`Full Journal Title` = `Journal title`)

highImpactSample <- left_join(highImpactSample,wos,by='Full Journal Title')

# apply formatting changes to standardize with the highImpactSample
highImpactSample <- highImpactSample %>%
  select(everything(),
         'Journal' = `Full Journal Title`,
         -`Publisher address`,
         )

write_csv(highImpactSample,here('data','primary','prepareSamples','highImpactSample.csv')) # save file
