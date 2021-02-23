#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    useShinyjs(),
    
    # Application title
    titlePanel("Testing Linear Models App"),
    
    h4("Inspect the Linear Relationship Between two Numeric Variables"),
    
    tags$hr(),

    sidebarLayout(
        sidebarPanel(
            radioButtons(inputId = "DemoOptions", label = "Do you want to use a preset data or your own dataset?", selected = character(0),
                         choices = c("Preset", "My own CSV file")),
            tags$hr(),
            shinyjs::hidden(tags$div(
                class = "header",
                id = "presets_menu",
                selectInput(inputId = "preset_data", label = "Please, select one of the preset R datasets", choices = c("mtcars", "USArrests")),
            tags$hr()
            )),
            shinyjs::hidden(tags$div(
                class = "header",
                id = "input_menu",
                fileInput("file1", "Choose CSV File",
                          accept = c(
                              "text/csv",
                              "text/comma-separated-values,text/plain",
                              ".csv")
            ),
            tags$hr()
            )),
            
            shinyjs::hidden(tags$div(
                class = "header",
                id = "columns_menu",
                #varSelectInput(inputId = "x_column", label = "Please, select the column that will serve as the Y Variable", data = tableOutput("columns.df")),
                selectInput(inputId = "y_column", label = "Please, select the column that will serve as the Y Variable",
                            choices = ""),
                selectInput(inputId = "x_column", label = "Please, select the column that will serve as the X Variable",
                            choices = "")
            ))
        ),
        
        
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Help", 
                                 h3("What is this app?"),
                                 p("The goal of this application is to compare the linear relationship between two numeric values.
                                    You can upload your own csv file and select which columns you want to compare.
                                    If you have no dataset to upload at the moment, don't worry. You can select one of the two preset datasets to
                                    see how the app works."),
                                 h3("How does it work?"),
                                 p("After informing the two columns that you want to compare, the app will fit three linear models:"),
                                 tags$ul(
                                     tags$li("A simple linear model"),
                                     tags$li("A quadratic model (i.e. the squared version of the selected x variable will be added the model"),
                                     tags$li("A cubic model (i.e. the cubic version of the selected x variable will be added to the model")
                                 ),
                                 p("You can see a glimpse of your dataset in the Glimpse of the Data tab, inspect the three models visually in the Plot of X and Y tab and check each model performance in the Model Evaluations tab."),
                                 p("The model with smaller RMSE and the highest R2 is the model that best fits your data."),
                                 h3("How do I start?"),
                                 p("To start, please, select either an example dataset or upload your own csv file in order to select the variables for inspection")),
                        tabPanel("Glimpse of the Data", 
                                 shinyjs::hidden(tags$div(
                                     class = "header",
                                     id = "DatasetHeaderLabel",
                                     h3("Glimpse of the selected dataset"),
                                     dataTableOutput("columns.df")
                        ))),
                        tabPanel("Plot of X and Y", 
                                 checkboxInput(inputId = "showSE", label = "Show Standard Errors", value = FALSE),
                                 checkboxInput(inputId = "showLinearModel", label = "Show Simple Linear Model", value = TRUE),
                                 checkboxInput(inputId = "showQuadraticModel", label = "Show Quadratic Model", value = TRUE),
                                 checkboxInput(inputId = "showCubicModel", label = "Show Cubic Model", value = TRUE),
                                 plotOutput("plot")),
                        tabPanel("Model Evaluations",
                                 tableOutput("model_results"))
                        )
        )
    )
))
