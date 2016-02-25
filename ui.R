
library(shiny)
library(shinythemes)
library(dplyr)
library(tidyr)

raw <- read.csv("visitor-international-arrivals-to-singapore-by-country-monthly.csv")

#d <- raw %>% 
#    select(country) %>% 
#    distinct(country) %>%
#    arrange(country)
d <- sort(unique(as.character(raw$country)))

shinyUI(
    navbarPage("Singapore Visitor Arrival",
               tabPanel("Where are you from?",
                        # Sidebar for Site Visitor Information
                        sidebarLayout(
                            sidebarPanel(
                                textInput("name","Please enter your name"),
                                selectInput("country","Where are you from?", choices = c("[select your country]",d))#as.character(d$country)))
                                
                            ),
                            
                            # Main Panel for Information
                            mainPanel(
                                h1("Welcome to Singapore, ",textOutput("vname")),
                                h5(textOutput("vmessage")),
                                conditionalPanel(
                                    condition = "input.country != '[select your country]'",
                                    fluidRow(
                                        column(width=4, wellPanel(h3(textOutput("msg1")))),
                                        column(width=4, wellPanel(h3(textOutput("msg2")),h6("* data is available since 1978"))),
                                        column(width=4, wellPanel(h3(textOutput("msg3a")),h6(textOutput("msg3b"))))
                                    ),
                                    fluidRow(
                                        column(width=12,wellPanel(h3(textOutput("maptitle")),htmlOutput("map1")))
                                    ),
                                    fluidRow(
                                        column(width=12,wellPanel(h3(textOutput("plottitle")),plotOutput("plot1")))
                                    ),
                                    fluidRow(
                                        column(width=6,sliderInput("range","Years:",min = 1978,max = 2015,value = c(1978,2015))),
                                        column(width=2,
                                               checkboxInput("shpoint", "Show points", value = TRUE),
                                               checkboxInput("shline", "Show line", value = TRUE)),
                                        column(width=3,checkboxInput("shavg", "Show country average", value = FALSE))
                                    )
                                )
                            )
                        )
               ),
               tabPanel("Data",
                        fluidPage(
                            fluidRow(column(width=10,offset=1,h1("Source Data"),br())),
                            fluidRow(column(width=2,offset=1,downloadButton('dl', 'Download')),column(width=8,h5("Download a copy of this dataset in CSV"))),
                            fluidRow(column(width=10,offset=1,wellPanel(dataTableOutput("tbl"))))
                            
                        )),
               tabPanel("About",
                        fluidPage(
                            fluidRow(column(width=7,offset=3,
                                wellPanel("Dear Singapore Virtual Visitor,",br(),
                                          "Welcome! Please feel at home here. Tell us your name and where you come from (on the first tab). We'll show you the rest!",br(),br(),
                                          "*You can interactive with the chart using the slider to filter years.")),
                            fluidRow(column(width=7,offset=3,h3("Developing Data Products - Course Project"),h5("This is a submission for Coursera: Developing Data Products- Course Project (Data Science Specialization)"))),
                            fluidRow(column(width=7,offset=3,h3("Singapore Visitor Arrival"),h5("The objective of this application is to explore some trends on international tourist arrivals to Singapore throughout the past years."),
                                h5("Dataset sourced from ", a(href="https://data.gov.sg/dataset/total-visitor-international-arrivals-to-singapore","https://data.gov.sg/dataset/total-visitor-international-arrivals-to-singapore")),br(),
                                h5("While you're here, take note"),h5("- This application is limited by available data source from data.gov.sg. It does not contain a complete list of all countries in the world. If in any case, your country is not listed, feel free to browse any country of interest."),
                                h5("- The dataset have missing data for December 2015. However, for the purpose of this application, data is displayed as it is and not imputed. You might see a less accurate trend but this will not affect the objective of this project to showcase shiny."))),
                            fluidRow(column(width=7,offset=3,h3("Links"),
                                h5("Shiny App Link"),h5(a(href="http://kakilima.shinyapps.io/visitsingapore","http://kakilima.shinyapps.io/visitsingapore")),
                                h5("Alternative Shiny App Link"),h5(a(href="http://seni.shinyapps.io/visitsingapore","http://seni.shinyapps.io/visitsingapore")),
                                h5("Slidify Slides"),h5(a(href="http://kakilima.github.io/visitsingapore/","http://kakilima.github.io/visitsingapore/")),
                                h5("Github"),h5(a(href="https://github.com/kakilima/visitsingapore","https://github.com/kakilima/visitsingapore"))),br())
                            ))
       
               ),theme = "bootstrap-superhero.css")
)
