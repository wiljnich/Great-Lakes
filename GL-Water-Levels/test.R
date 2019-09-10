library(plyr)
library(reshape2)

# Read in lake level data from GLERL site
clair <- read.csv('clair1918.csv')
#read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/clair1918.csv', skip=2)
clair$Lake <- 'Lake St. Clair'
miHuron  <- read.csv('miHuron1918.csv')
#read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/miHuron1918.csv', skip=2)
miHuron$Lake <- 'Lake Michigan-Huron'
erie  <- read.csv('erie1918.csv')
#read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/erie1918.csv', skip=2)
erie$Lake <- 'Lake Erie'
superior <- read.csv('superior1918.csv')
#read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/superior1918.csv', skip=2)
superior$Lake <- 'Lake Superior'
ontario  <- read.csv('ontario1918.csv')
#read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/ontario1918.csv', skip=2)
ontario$Lake <- 'Lake Ontario'

lakes <- Reduce(rbind, c(clair, miHuron, erie, superior, ontario))
lakes <- melt(data = lakes, id.vars = c("Year", "Lake"), measure.vars = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'))
print(lakes[1,])