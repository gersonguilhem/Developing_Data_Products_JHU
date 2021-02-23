#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(caret)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    dataset <- reactive({
        
        if(is.null(input$DemoOptions))
            return(NULL)
        
        if(input$DemoOptions == "Preset") {
            get(input$preset_data)
        } else if(!is.null(input$file1)) {
            read.csv(input$file1$datapath)
        } else {
            return(NULL)
        }
        
    })
    
    observeEvent(input$DemoOptions, {
        
        if(is.null(input$DemoOptions)) {
            updateSelectInput(session, inputId = "x_column",
                              choices = "",
                              selected = NULL)
            updateSelectInput(session, inputId = "y_column",
                              choices = "",
                              selected = NULL)  
        }
        
        if(input$DemoOptions == "Preset") {
            show(id = "presets_menu", anim = F)
            hide(id = "input_menu", anim = F)
            show(id = "columns_menu", anim = F)
            show(id = "DatasetHeaderLabel", anim = TRUE)
            
            isNumeric <- vapply(get(input$preset_data), is.numeric, logical(1))
            numericCols <- names(isNumeric)[isNumeric]
            updateSelectInput(session, inputId = "y_column",
                              choices = numericCols,
                              selected = NULL)
            updateSelectInput(session, inputId = "x_column",
                              choices = numericCols,
                              selected = NULL)
            
        } else {
            
            hide(id = "presets_menu", anim = F)
            show(id = "input_menu", anim = F)
            show(id = "columns_menu", anim = F)
            show(id = "DatasetHeaderLabel", anim = TRUE)
            
            if(is.null(input$file1)) {
                updateSelectInput(session, inputId = "x_column",
                                  choices = "",
                                  selected = NULL) 
                updateSelectInput(session, inputId = "y_column",
                                  choices = "",
                                  selected = NULL)    
            } else {
                
                data <- read.csv(input$file1$datapath, header = TRUE)
                isNumeric <- vapply(data, is.numeric, logical(1))
                numericCols <- names(isNumeric)[isNumeric]
                updateSelectInput(session, inputId = "y_column",
                                  choices = numericCols,
                                  selected = NULL)
                updateSelectInput(session, inputId = "x_column",
                                  choices = numericCols,
                                  selected = NULL)    
            }
            
              
        }
    })
    
    observeEvent(input$preset_data, {
        
        if(input$preset_data == "")
            return(NULL)
        
        isNumeric <- vapply(get(input$preset_data), is.numeric, logical(1))
        numericCols <- names(isNumeric)[isNumeric]
        updateSelectInput(session, inputId = "y_column",
                          choices = numericCols,
                          selected = NULL)
        updateSelectInput(session, inputId = "x_column",
                          choices = numericCols,
                          selected = NULL)
    })
    
    observeEvent(input$file1, {
        
        inFile <- input$file1
        
        if (is.null(inFile)) {
            
            return(NULL)
            
        } else {
            
            data <- read.csv(inFile$datapath, header = TRUE)
            isNumeric <- vapply(data, is.numeric, logical(1))
            numericCols <- names(isNumeric)[isNumeric]
            updateSelectInput(session, inputId = "y_column",
                              choices = numericCols,
                              selected = NULL)
            updateSelectInput(session, inputId = "x_column",
                              choices = numericCols,
                              selected = NULL)
            
        }
    })
    
    output$columns <- renderText({
        paste0("Column names of the dataset obejct: ", names(dataset()))
    })
    
    output$columns.df <- renderDataTable({
        
        if(is.null(input$DemoOptions))
            return(NULL)
        
        if(input$DemoOptions == "Preset") {
            get(input$preset_data)
        } else if(!is.null(input$file1)) {
            read.csv(input$file1$datapath)
        } else {
            return(NULL)
        }
    })
    
    output$plot <- renderPlot({
        
        if(is.null(dataset()))
            return(NULL)
        
        plot <- ggplot(dataset(), aes_(x = as.name(input$x_column), y = as.name(input$y_column))) + 
            geom_point()
        
        if (input$showLinearModel)
            plot <- plot + stat_smooth(method = "lm", formula = y~x, color = "blue", se = input$showSE)
        
        if (input$showQuadraticModel)
            plot <- plot + stat_smooth(method = "lm", formula = y~poly(x, 2), color = "red", se = input$showSE)
        
        if (input$showCubicModel)
            plot <- plot + stat_smooth(method = "lm", formula = y~poly(x, 3), color = "orange", se = input$showSE)
            
        plot <- plot + theme_bw() +
            xlab(input$x_column) + ylab(input$y_column)
            
            plot
    })
    
    output$model_results <- renderTable({
        
        if(is.null(input$DemoOptions))
            return(NULL)
        
        simple_linear_model <- lm(dataset()[, input$y_column] ~ dataset()[, input$x_column], data = dataset())
        simple_linear_model_performance_df <- data.frame(Model = "Simple Linear Model",
                                                         RMSE = RMSE(predict(simple_linear_model), dataset()[, input$y_column]),
                                                         R2 = R2(predict(simple_linear_model), dataset()[, input$y_column]))
        
        quadratic_model <- lm(dataset()[, input$y_column] ~ poly(dataset()[, input$x_column], 2, raw = TRUE), data = dataset())
        quadratic_model_performance_df <- data.frame(Model = "Quadratic Model",
                                                     RMSE = RMSE(predict(quadratic_model), dataset()[, input$y_column]),
                                                     R2 = R2(predict(quadratic_model), dataset()[, input$y_column]))
        
        cubic_model <- lm(dataset()[, input$y_column] ~ poly(dataset()[, input$x_column], 3, raw = TRUE), data = dataset())
        cubic_model_performance_df <- data.frame(Model = "Cubic Model",
                                                 RMSE = RMSE(predict(cubic_model), dataset()[, input$y_column]),
                                                 R2 = R2(predict(cubic_model), dataset()[, input$y_column]))
        
        rbind(simple_linear_model_performance_df, quadratic_model_performance_df, cubic_model_performance_df)
        
    })

})
