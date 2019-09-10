library(shiny)
library(shinythemes)
library(plyr)
library(dplyr)
library(tools)
library(stringr)
library(zoo)
library(reshape2)
library(ggplot2)

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

lakes <- data.frame(bind_rows(clair, miHuron, erie, superior, ontario))
lakes <- melt(data = lakes, id.vars = c("year", 'Lake'), measure.vars = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'))
lakes$variable <- str_to_title(lakes$variable)
lakes$variable <- match(lakes$variable,month.abb)
lakes$Date <- as.yearmon(paste(lakes$year, lakes$variable), "%Y %m")
lakes <- lakes[-c(1, 3)]
lakes$Date <- as.Date(lakes$Date)

shinyUI(fluidPage(theme = shinytheme("darkly"),
            fluidRow(column(4, img(src='glerl.png', style='width:275px')),
                     column(8, titlePanel('Great Lakes Monthly Average Water Levels: 1918-Present'))),
            
    sidebarLayout(
    sidebarPanel(
      helpText("Use the inputs below to model changes in water levels over time."),
      selectizeInput('lake_drop', label=h4("Select Lakes"), 
                     choices = c('Lake Erie', 'Lake Michigan-Huron', 'Lake Ontario', 'Lake St. Clair', 'Lake Superior'), 
                     options = list(maxItems = 5, placeholder = 'Select lakes')
      ),
      dateRangeInput("dates",label=h4("Time Period"),
                     start = min(lakes$Date),
                     end   = max(lakes$Date),
                     format = 'mm/yyyy',
                     startview='month'),
      checkboxInput("constant", "Hold water level axis constant", FALSE),
      textOutput("hover_info")
    ),
    
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("Chart", hover = hoverOpts(id ="plot_hover"))
    )
  )
))
