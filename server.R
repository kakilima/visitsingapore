
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(googleVis)

raw <- read.csv("visitor-international-arrivals-to-singapore-by-country-monthly.csv")
raw <- raw %>% 
    separate(month,c("year","month"),"-")
raw$date<-as.Date(paste(raw$year,raw$month,'01',sep="/"))
names(raw) <- c("year","month","region","country","visitors","date")

dmsg1 <- raw %>%
    select(year,country,visitors) %>% 
    filter(year==2015) %>%
    group_by(country) %>%
    summarise(visitors=sum(visitors))
dmsg2 <- raw %>%
    select(country,visitors) %>% 
    group_by(country) %>%
    summarise(visitors=sum(visitors))
dmsg3 <- raw %>%
    select(year,country,visitors) %>% 
    group_by(country,year) %>%
    summarise(visitors=sum(visitors)) %>%
    top_n(n=1)

dplot <- raw %>%
    select(year,country,visitors) %>% 
    group_by(country,year) %>%
    summarise(visitors=sum(visitors))
    dplot$year <- as.numeric(dplot$year)

shinyServer(function(input, output) {
    
    # Welcome Messages Text
    output$vname <- renderText(
        if(input$name != '') {
            input$name
        } else {   
            'Virtual Visitor'
        }
        )
    output$vmessage <- renderText(
        if(input$country == '[select your country]') {
            'Please enter your name and your country'
        } else {   
            paste("Now that I know you're from", input$country,", let's take a look at some facts about visitors from your country")
        }
    )
    
    # Fun Facts - Country Specific Messages
    output$msg1 <- renderText(
        if(input$country == '[select your country]') {
            "xxx from xxx visited Singapore in 2015"
        } else {   
            paste(format(dmsg1[dmsg1$country==input$country,2],big.mark = ","),"from",input$country,"visited Singapore in 2015")
        }
    )
    output$msg2 <- renderText(
        if(input$country == '[select your country]') {
            "Overall, xxx from xxx has stepped into Singapore"
        } else {   
            paste("Overall,",format(dmsg2[dmsg2$country==input$country,2],big.mark = ","),"from",input$country,"has stepped into Singapore")
        }
    )
    output$msg3a <- renderText(
        if(input$country == '[select your country]') {
            "Singapore recorded the highest number of visitors from xxx in xxx"
        } else {   
            paste("Singapore recorded the highest number of visitors from",input$country,"in",dmsg3[dmsg3$country==input$country,2])
        }
    )
    output$msg3b <- renderText(
        if(input$country == '[select your country]') {
            "That's a total of xxx, if you're curious"
        } else {   
            paste("That's a total of",format(dmsg3[dmsg3$country==input$country,3],big.mark = ","),"if you're curious")
        }
    )
    output$maptitle <- renderText(
        if(input$country == '[select your country]') {
            "Location of xxx and Singapore"
        } else {   
            paste("Location of",input$country," and Singapore")
        }
    )
    output$plottitle <- renderText(
        if(input$country == '[select your country]') {
            "Visitor Arrival from xxx"
        } else {   
            paste("Visitor Arrival from",input$country)
        }
    )
    
    #Plot graph
    output$plot1 <- renderPlot({
        a <- ggplot(data=dplot[{dplot$country==ifelse(input$country == '[select your country]',"Malaysia",input$country)} & dplot$year >= input$range[1] & dplot$year <= input$range[2],],
               aes(x=year, y=visitors, colour)) +
            #ggtitle(paste("Visitor Arrival from",input$country)) +
            xlab("Year")+ylab("Visitors")+
            scale_y_continuous(labels = comma)
        if(input$shavg) {a <- a + geom_hline(aes(yintercept=mean(visitors)), color="grey")}
        if(input$shline) {a <- a + geom_line(color="purple")}
        if(input$shpoint) {a <- a + geom_point()}
        plot(a)}
    )
    
    #Plot Maps
    output$map1 <- renderGvis({
        df <- data.frame(country=c(input$country,"Singapore"),description=c(input$country,"Singapore"))
        map1 <- gvisMap(df, "country", "description",
                        options=list(showTip=TRUE, mapType='normal',
                                     enableScrollWheel=TRUE))
    }
    )
    
    #Create Data Table
    output$tbl <- renderDataTable(raw)
    
    #Handle Data Download Request
    output$dl <- downloadHandler(
        filename = 'raw.csv',
        content = function(file) {
            write.csv(raw, file)
        }
    )
})
