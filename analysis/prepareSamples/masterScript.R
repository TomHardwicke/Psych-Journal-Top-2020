# This master script prepares the study samples

library(tidyverse)
library(here)

# This script loads the master list of journals included in the Web of Science Social Sciences Citation Index and saves a list of only the psychology journals
# The script also compiles all of the separate journal by impact factor files (one for each subfield) into one file
source(here('analysis','prepareSamples','organizePreStudyFiles.R'))

# This script obtains a random sample of 40 psychology journals from amongst all psychology journals indexed by Web of Science (WOS)
source(here('analysis','prepareSamples','randomSample.R'))

# This script obtains a sample of the top-5 journals according to 2019 Journal Impact Factor in each of ten sub-fields of psychology
source(here('analysis','prepareSamples','highImpactSample.R'))

# This script identifies how many journals included in our sample are already included in TOP-d
# This is noted in the sample data files. The code then extracts and saves the relevant data from TOP-d
source(here('analysis','prepareSamples','integrateExistingData.R'))

# This script assigns coders to the journals that have not yet been included in TOP-d
source(here('analysis','prepareSamples','assignJournalsToCoders.R'))
