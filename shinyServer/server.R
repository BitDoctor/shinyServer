#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#rm(list = ls())
#available.packages()
#packrat::snapshot(infer.dependencies = F)
#packrat::init()
#packrat::snapshot()
#packrat::set_opts(external.packages = c('reticulate'))

#packrat::snapshot()
#.libPaths("C:/Users/antutlan/Microsoft/DSSInsightsAA - PFH-DEV2/CPENew/CPENew/CPE-Shiny/ShinyGithub2/SimilarityText/packrat/lib/x86_64-w64-mingw32/3.4.0")


library(shiny)
library(reticulate)
py_install(c('numpy','pandas','nltk','gensim'))
nltkdown <- import('nltk')
nltkdown$download('all')
source_python('TextSimilarity-Production.py')


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  # Define a reactive expression for the document term matrix
  
  
  
  clusterData <- reactive({
    
    input$update
    isolate({
      
      req(input$file1)
      df <- read.csv(input$file1$datapath,
                     header = TRUE,
                     sep = ",",
                     quote = '"',stringsAsFactors = FALSE)
      #xxx <- calcSent(fileR=df)
      xx <- iconv(df$Text,to="utf8")
      xx <- gsub("[^\x01-\x7F]","" , xx ,ignore.case = TRUE,perl = TRUE)
      
      df$Text <- xx
      data_to_export <- Similarity_Criteria(data1=df,criteria=input$criteria,MAX_CAT=input$max,Max_Iter=input$max1)
      
      
      return(data_to_export)
      
    })
  })
  
  
  output$heading1 <- renderPrint({
    
    input$update
    isolate({
      req(input$file1)
      df <- read.csv(input$file1$datapath,
                     header = TRUE,
                     sep = ",",
                     quote = '"',stringsAsFactors = FALSE)$text
      
      vv<-clusterData()
      return(cat("1.Original % Distribution, 2.Refined % Distribution"))
      
      
    })
    
  })
  
  
  output$table1 <- renderTable({
    
    input$update
    isolate({
      data_to_export <- clusterData()  
    })
    
    return(data_to_export)
  })
  
  
  
  output$table2<-renderTable({
    input$update
    isolate({
      withProgress(message = "Creating Cluster % distribution table...",value = 0,{
        
        vv <- clusterData()
        #ggplot(v,aes(tf,tfidf,label=TopWords)) + geom_point() + geom_text(aes(label=TopWords),hjust=-0.1,vjust=-0.1) + facet_grid(Cluster~.)
        ffff <-data.frame(table(vv$Category))
        colnames(ffff)<-c('Category','PercentCount')
        ffff$PercentCount <- round((ffff$PercentCount/sum(ffff$PercentCount))*100)
        ffff <- ffff[order(-ffff$PercentCount),]
        return(ffff)
        
      })
    })
    
  })
  
  output$table3<-renderTable({
    input$update
    isolate({
      req(input$file1)
      df <- read.csv(input$file1$datapath,
                     header = TRUE,
                     sep = ",",
                     quote = '"',stringsAsFactors = FALSE)
      
      #ggplot(v,aes(tf,tfidf,label=TopWords)) + geom_point() + geom_text(aes(label=TopWords),hjust=-0.1,vjust=-0.1) + facet_grid(Cluster~.)
      ffff <-data.frame(table(df$Category))
      colnames(ffff)<-c('Category','PercentCount')
      ffff$PercentCount <- round((ffff$PercentCount/sum(ffff$PercentCount))*100)
      ffff <- ffff[order(-ffff$PercentCount),]
      return(ffff)
      
    })
  })
  
  
  output$download <- downloadHandler(
    
    filename = function(){paste0("Data_with_refined_Categories",Sys.Date(),".csv")},
    
    #filename = function(){
    # paste(clusterData(),".csv",sep="")
    #"SentimentScore_ANd_Cluster.csv"
    #},
    content = function(filename){
      write.csv(clusterData(),filename,row.names = FALSE)
    }
  )})

