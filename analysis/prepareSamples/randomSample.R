# This script obtains a random sample of 40 psychology journals from amongst all psychology journals indexed by Web of Science (WOS).

library(tidyverse)
library(here)
`%notin%` <- Negate(`%in%`)

wos_psych <- read_csv(here('data','primary','prepareSamples','wos-psych-d.csv')) # load list of all WOS psychology journals

wos_psych_eng <- wos_psych %>% 
  filter(Languages == 'English') # filter to obtain only WOS journals classified as English language

set.seed(42) # set the seed for reproducibility of random sampling
random_sample_original <- slice_sample(wos_psych_eng, n = 40) # randomly sample 40 rows

# remove any non-empirical journals identified during screening
random_sample_adjusted <- random_sample_original %>%
  filter(`Journal title` %notin% 
           c("EUROPEAN PSYCHOLOGIST",
             "JOURNAL OF CLASSIFICATION",
             "INTERNATIONAL REVIEW OF SPORT AND EXERCISE PSYCHOLOGY"))

# now we need to randomly select 3 replacement journals
# firstly remove the originally sampled journals from the wos database
wos_psych_eng_adjusted <- wos_psych_eng %>%
  filter(`Journal title` %notin% random_sample_original$`Journal title`)

# now draw three random journals from this adjusted database
set.seed(42) # set the seed for reproducibility of random sampling
random_sample_supplement <- slice_sample(wos_psych_eng_adjusted, n = 3) # randomly sample 3 rows

random_sample <- rbind(random_sample_adjusted,random_sample_supplement) # combine the 3 new journals with the adjusted random sample

# load the journal websites that were identified during screening and combine them with the journal list
websites <- read_csv(here('data','primary','prepareSamples','randomSampleWebsites.csv')) %>%
  filter(empirical == T) %>% 
  select(`Journal title`,websites = `Journal website`)

random_sample <- left_join(random_sample,websites, by = 'Journal title') 

# apply formatting changes to standardize with the highImpactSample
random_sample <- random_sample %>%
  select(everything(), 
         'Journal' = `Journal title`,
         -`Publisher address`)

write_csv(random_sample, here('data','primary','prepareSamples','randomSample.csv')) # save the list of sampled journals
