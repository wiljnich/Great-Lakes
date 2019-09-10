library(shiny)
library(shinythemes)
library(plyr)
library(dplyr)
library(tools)
library(stringr)
library(zoo)
library(reshape2)
library(ggplot2)
library(ggthemes)

# Read in lake level data from GLERL site
#clair <- read.csv('clair1918.csv')
clair <- read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/clair1918.csv', skip=2)
clair$Lake <- 'Lake St. Clair'
#miHuron  <- read.csv('miHuron1918.csv')
miHuron  <- read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/miHuron1918.csv', skip=2)
miHuron$Lake <- 'Lake Michigan-Huron'
#erie <- read.csv('erie1918.csv')
erie <- read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/erie1918.csv', skip=2)
erie$Lake <- 'Lake Erie'
#superior <- read.csv('superior1918.csv')
superior <- read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/superior1918.csv', skip=2)
superior$Lake <- 'Lake Superior'
#ontario  <- read.csv('ontario1918.csv')
ontario  <- read.csv('https://www.glerl.noaa.gov/data/dashboard/data/levels/1918_PRES/ontario1918.csv', skip=2)
ontario$Lake <- 'Lake Ontario'

cbPalette <- c("#0072B2", "#009E73", "#999999", "#E69F00", "#56B4E9", "#F0E442", "#D55E00", "#CC79A7")

lakes <- data.frame(bind_rows(clair, miHuron, erie, superior, ontario))
lakes <- melt(data = lakes, id.vars = c("year", 'Lake'), measure.vars = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'))
lakes$variable <- str_to_title(lakes$variable)
lakes$variable <- match(lakes$variable,month.abb)
lakes$Date <- as.yearmon(paste(lakes$year, lakes$variable), "%Y %m")
lakes <- lakes[-c(1, 3)]
lakes$Date <- as.Date(lakes$Date)


server <- function(input, output, session) {
  updateSelectizeInput(session, 'lake_drop', choices = c('Lake Erie', 'Lake Michigan-Huron', 'Lake Ontario', 'Lake St. Clair', 'Lake Superior'), server = TRUE,selected=c('Lake Erie'))

  output$Chart <- renderPlot({
    
    lakes2 <- select(filter(lakes, Lake %in% input$lake_drop), c(Lake, Date, value))
    lakes2 <- select(filter(lakes2, Date >= min(input$dates)), c(Lake, Date, value))
    lakes2 <- select(filter(lakes2, Date <= max(input$dates)), c(Lake, Date, value))

    x_string <- lakes2$Date
    y_string <- lakes2$value
    
    ggplot(lakes2, aes_string(x=x_string, y=y_string)) +
      scale_color_manual(values=cbPalette) +
      geom_line(aes(color=Lake), size=.5) +
      labs(caption = '\nData courtesy of NOAA and the Great Lakes Environmental Research Laboratory \n Data is preliminary and not for use in formal research. \n This project does not represent the views of NOAA and the GLERL.') + 
      theme_calc() +
      facet_wrap(~Lake, scales = ifelse(input$constant==FALSE, 'free_y', 'fixed')) +
      geom_smooth(method = "lm", se=FALSE, color='black') +
      labs(x='Year', y='Water Level (m)') +
      theme(strip.text.x = element_text(size = 14, face='bold')) +
      theme(legend.title = element_text(color="#2D3E4E", face='bold', size=18)) +
      theme(legend.text = element_text(color="#2D3E4E", size=15)) +
      theme(legend.key.size = unit(4, "line")) +
      theme(plot.title = element_text(color="#2D3E4E", size=28, hjust=0)) +
      theme(axis.title = element_text(color="#2D3E4E", size=18)) +
      theme(axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0))) +
      theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0))) +
      theme(axis.text.x = element_text(color="#2D3E4E", size = 14), 
            axis.text.y = element_text(color="#2D3E4E", size = 14))
  },height = 700, width = 900)
  
  output$hover_info <- renderText({
    if(!is.null(input$plot_hover)){
      hover=input$plot_hover
      paste(hover$panelvar[1], 'Water Level:', round(hover$y[1], 2), "meters")
    }
  })

}