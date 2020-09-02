# this script assigns coders to the journals that have not yet been included in TOP-d

library(tidyverse)
library(here)

randomSample <- read_csv(here('data','primary','prepareSamples','randomSample.csv'))
highImpactSample <- read_csv(here('data','primary','prepareSamples','highImpactSample.csv'))

# split samples up depending on whether data is already in TOP for a journal
rs_top <- randomSample %>% filter(inTOP == T) 
hi_top <- highImpactSample %>% filter(inTOP == T) 

rs_remaining <- randomSample %>% filter(inTOP != T) 
hi_remaining <- highImpactSample %>% filter(inTOP != T)

# get number remaining to be coded
rs_remaining_n <- rs_remaining %>% nrow()
hi_remaining_n <- hi_remaining %>% nrow()

# now randomly assign the journals equally between the two coders
# create vectors of coder IDs of the correct length and randomly shuffle
# and attach coders to the remaining journals
set.seed(42) # set seed for reproducibility of random procedure
rs_remaining$coder <- sample(c(rep('TEH',rs_remaining_n/2),rep('BAN',rs_remaining_n/2)))

set.seed(42) # set seed for reproducibility of random procedure
hi_remaining$coder <- sample(c(rep('TEH',hi_remaining_n/2),rep('BAN',hi_remaining_n/2)))

# attach coder id 'TOP' to journals already in TOP
rs_top$coder <- 'TOP'
hi_top$coder <- 'TOP'

# now rejoin all of the journals in the sample
randomSample <- rbind(rs_remaining,rs_top)
highImpactSample <- rbind(hi_remaining,hi_top)

# save files
write_csv(randomSample,here('data','primary','prepareSamples','randomSample.csv'))
write_csv(highImpactSample,here('data','primary','prepareSamples','highImpactSample.csv'))
