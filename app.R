library(shiny)
library(shinyjs)
library(shinythemes)
library(stringr)
library(lubridate)
library(DT)
library(dplyr)
library(tidyverse)
library(ggwordcloud)

df <- read.csv("six_medrxiv_studies_nolists.csv", stringsAsFactors = F)

ui <- navbarPage("", id = 'menu',
                 tabPanel("Explorer", 
    #                       tags$style(HTML("
    #   #box {
    #     padding: 10px 10px 20px 10px;
    #     border: 1px solid #BFBFBF;
    #     box-shadow: 7px 7px 5px #888888;
    #   }
    # ")),
                          shinyjs::useShinyjs(),
                          fluidPage(
                              #theme = shinythemes::shinytheme("readable"), 
                              h3("How Covid-19 preprints spread on Twitter"),
                              #h5("", style = "color:#C82613"),
                              #h5("We analyzed 900 medRxiv preprints and how they propagated on Twitter. Here are six of the most popular."),
                              hr(),
                              h5("Select a preprint", align = "left"),
                              fluidRow(
                                  column(3, id="box",
                                         radioButtons("preprint",
                                                     "",
                                                     choices=c(#"All",
                                                               unique(as.character(df$title))),
                                                     selected = NULL)
                                         
                                        ),
                                  column(9, 
                                         fluidRow(id="box", h5("Retweet network", align = "center"),
                                                  uiOutput("netviz"))
                                  ) 
                              ),
                              fluidRow(
                                  h5("Selected preprint", align = "center"),
                                  # column(12, htmlOutput("myImage")),
                                  column(12, id="box",DTOutput("viewData"))
                              ),
                              fluidRow(
                                  column(12,
                                         fluidRow(
                                             column(4, id="box",
                                                    fluidRow(h5("Top tweets", align = "left"),
                                                        DTOutput("viewTweeters","100%", 600))
                                                    
                                                    ),
                                             column(8,id="box",
                                                    fluidRow(h5("Tweets over time", align = "left"),
                                                             plotOutput("histogram","100%", 600)
                                                    )

                                             )
                                         )
                                  )
                              ),
                              # fluidRow(
                              #     h5("Top hashtags", align = "center"),
                              #     column(12, id="box", plotOutput("wordcloud"))
                              # ),
                              hr() 
                    )
                 ),
                 tabPanel("About", 
                          fluidPage(
                              h2("How Covid-19 preprints spread on Twitter"),
                              p("This Shiny app is a behind the scenes look at a selection of the preprint studies we wrote about in our May 14, 2020 piece in New York Times Opinion, linked below."),
                              tags$a(href="https://www.nytimes.com/2020/05/14/opinion/coronavirus-research-misinformation.html", "A Study Said Covid Wasn’t That Deadly. The Right Seized It."),
                              p(""),
                              p(""),
                              h4("Methods"),
                              p("Our analysis of 882 preprints published on medRxiv.org and shared on Twitter revealed two broad sharing patterns: In the first model, a few voices take a study and broadcast it to an army of retweeters. This one-to-many model, seen with the 'Indoor transmission of SARS-CoV-2' or the Santa Clara seroprevalence preprints, conforms most closely to traditional broadcast media, even as it bypasses traditional forms of vetting such as peer review or simple fact checking." ),
                              p("The other model, seen with the 'Chloroquine diphosphate in two different dosages' preprint for instance, is equally interesting, and conforms more closely to a many-to-many model of information spread. In this scenario, the papers are usually taken up by researchers and academics debating its merits in real time, spreading it via Twitter in the process as they broadcast it to colleagues for discussion."),
                              h4("Tools"),
                              p("This analysis was performed in RStudio using the packages 'tidyverse', 'rtweet' and 'twinetverse'. There may be gaps in the Twitter data, given the limitations with Twitter's free API tier. It should be noted that medRxiv URLs aren't very popular and we crossreferenced our data with software like 'twint' and 'hydrator' to spot-check for completeness."),
                              p("Feedback? Contact Aleszu Bajak or Jeff Howe."),
                              p("")
                          ) 
                          
                 )

)



server <- function(input, output, session) {
    
    shinyjs::addClass(id = "menus", class = "navbar-right")
    
    selectedData <- reactive({
        df %>%
            filter(title == input$preprint)
    })
    
    output$viewData <- DT::renderDataTable({
        outputtable <- selectedData() %>% 
            select(title, publish.date, query, author, total.retweets) %>%
            mutate(title = paste0("<a href='", query,"' target='_blank'>", title,"</a>")) %>%
            distinct() %>%
            select(title, publish.date, author, total.retweets)
        outputtable
    }, 
    escape=FALSE)
    
    # Top retweets
    
    
    
    output$viewTweeters <- DT::renderDataTable({
        
        outputtable <- selectedData() %>% 
            select(retweet_name, retweet_status_id, retweet_screen_name, retweet_retweet_count) %>%
            arrange(desc(retweet_retweet_count)) %>%
            mutate(retweet_name = paste0("<a href='https://twitter.com/", retweet_screen_name,"'/status/'", retweet_status_id,"' target='_blank'>", retweet_name,"</a>")) %>%
            distinct() %>%
            select(retweet_name, retweet_retweet_count)
        outputtable
    }, 
    escape=FALSE)
    
    # Top hashtags 
    
    output$wordcloud <- renderPlot({
        
        set.seed(123)
        
        wordcloud <- selectedData() %>% 
            select(hashtags) %>%
            add_count(hashtags) %>%
            filter(hashtags != "NA") %>%
            arrange(desc(n)) %>%
            distinct() %>% 
            glimpse()
        
        wordcloud2 <- ggplot(head(wordcloud, n=50), aes(label = hashtags, size=n)) +
            geom_text_wordcloud(area_corr = TRUE) +
            #scale_size_area(max_size = 30) +
            theme_minimal()
        wordcloud2
        
    })
    
    # HTML of netviz
    output$netviz <- renderUI({
        
        netvizdf <- selectedData() 
        
        tags$iframe(
            src = paste0("https://storybench.org/preprints/", netvizdf$netviz),
            style='width:900px;height:500px;', frameborder="0"
        )
    })
    
    # Histogram
    
    output$histogram <- renderPlot({
    
        histplotdf <- selectedData()
        histplotdf$created_at <- ymd_hms(histplotdf$created_at)
        
        p1 <- ggplot(histplotdf, aes(created_at)) +
            geom_histogram(bins = 300) +
            theme_minimal() +
            xlab("") +
            ylab("tweet volume")
        p1
    })
    
}


shinyApp(ui = ui, server = server)

