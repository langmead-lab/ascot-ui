#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyBS)
library(shinycssloaders)
library(shinydashboard)
library(magrittr)
library(ggplot2)


shinyUI(
  fluidPage(
    # fluidRow(headerPanel("Header")),
    theme = shinythemes::shinytheme("spacelab"),
    tags$head(tags$style(
      HTML(
        "
        .muticol {
        height: 150px;
        -webkit-column-count: 2;
        -moz-column-count: 2;
        column-count: 2;
        -moz-column-fill: auto;
        -column-fill: auto;
        }"
        )
      )),

wellPanel(style = "
          background-color: #003082;
          box-shadow: 0 5px 5px -5px #333;
          padding: 0px 10px 0px;
          ",
  fluidRow(style = "padding: 0px 10px 0px;",
    column(3, HTML("<font size=\"7\"><span style=\"color: #ffffff; 
                    font-family: Open Sans; font-weight: 500;\">ASCOT<br/></span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #ffffff; 
                    font-family: Open Sans;\">Alternative Splicing and Gene Expression<br/>
                    Summaries of Public RNA-Seq Data</span></font>"),
              HTML("<font size=\"2\"><span style=\"color: #ffffff;\">
                    <br/><br/>(powered by <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"http://snaptron.cs.jhu.edu/\">Snaptron</a></span>&nbspand&nbsp<span><a 
                    style=\"color: #ffffff; text-decoration: underline;\"
                    href=\"https://jhubiostatistics.shinyapps.io/recount/\">Recount2</a></span>)</span><br/></font>")
    ),
    column(5, style = "padding: 15px 0px 0px;",
              HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: Open Sans;\">                    
                    <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"https://google.com\">How to cite</br></a></span></span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: Open Sans;\">                    
                    <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"https://google.com\">Where did we find the data?</br></a></span></span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: Open Sans;\">                    
                    <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"https://google.com\">Visualize data on the UCSC Genome Browser</br></a></span>
                    </span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: Open Sans;\">                    
                    <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"https://google.com\">Download the raw data</br></a></span></span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: Open Sans;\">                    
                    <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"https://google.com\">GitHub repository</br></a></span></span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: Open Sans;\">                    
                    <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"https://google.com\">Placeholder</a></span></span></font>")
    ),
    column(4, style="padding: 5px 12px 5px;", align = "right", img(src="logos160.png"))
  )
),

wellPanel(style = "margin-top:-10px; padding: 5px 20px 0px;", fluidRow(
  column(3,
    selectInput(
      "dataset",
      tags$b("Select Dataset"),
      choices = c("MESA (Mouse Cell Types)" = "mesa",
                  "CellTower (Mouse Single Cell RNA-Seq)" = "ctms",
                  "GTEx (Human Tissues)" = "gtextissue",
                  "ENCODE HepG2 (shRNA-seq)" = "encodehepg2",
                  "ENCODE K562 (shRNA-seq)" = "encodek562"
                 ),
      selected = "mesa"
    )
  ),
  column(3,
    selectizeInput(
      "gene",
      tags$b("Select Gene"),
      choices = NULL,
      options = list(
        maxItems = "1",
        # plugins = list('restore_on_backspace')
                       onFocus = I('function () {
                                          var value = this.getValue();
                                          console.log(value);
                                          if (value.length > 0) {
                                            this.clear(true);
                                            this.setTextboxValue(value);
                                          }
                                   }'),
                      onItemAdd = I('function() { this.blur(); }')
      )
    )
  ),
  column(2,
    sliderInput("naucRange", "NAUC view range:",
			min = 0, max = 100,
			value = c(0,100),
			step = 1
		)
  ),
  column(2,
    sliderInput("psiRange", "PSI view range:",
			min = 0, max = 100,
			value = c(0,100),
			step = 5
		)
  ),
  column(2, checkboxInput("colorblind_mode", "Enable Colorblind Mode"))
)),

plotOutput("plot", height = "auto") %>% withSpinner(),

bsCollapsePanel(
    "Select/Deselect Datasets",
    style = "primary",
    wellPanel(tags$div(
      align = "left",
      class = "muticol",
      checkboxGroupInput(
        "cell_groups",
        label = NULL,
        choices = NULL,
        selected = NULL
      )
    ))
),

wellPanel(style = "
          background-color: #d8e7ff;
          box-shadow: 0 5px 5px -5px #333;
          padding: 0px 16px 10px;
          ",
	DT::dataTableOutput("exontable")
),

wellPanel(style = "
          background-color: #f2f2f2;
          box-shadow: 0 5px 5px -5px #333;
          padding: 0px 10px 0px;
          ",
  fluidRow(style = "padding: 6px 6px 10px;",
    column(4, class = "text-left",
              HTML("<font size=\"3\"><span style=\"color: #4c4c4c; font-family: Open Sans;\">
                    <span><a style=\"color: #4c4c4c; text-decoration: underline;\" 
                    href=\"http://www.langmead-lab.org/\">Ben Langmead Lab</a></span></br>
                    </span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #4c4c4c; font-family: Open Sans;\">                    
                    <span><a style=\"color: #4c4c4c; text-decoration: underline;\" 
                    href=\"http://neuroscience.jhu.edu/research/faculty/7\">Seth Blackshaw Lab</a></span></br>
                    </span></font>")
    ),
    column(4, class = "text-center",
              HTML("<font size=\"3\"><span style=\"color: #4c4c4c; font-family: Open Sans;\">                    
                    Website developed by <span><a style=\"color: #4c4c4c; text-decoration: underline;\" 
                    href=\"https://github.com/ch4rr0\">Rone Charles</a></span>
                    </span></font>")
    ),
    column(4, class = "text-right",
              HTML("<font size=\"3\"><span style=\"align:right; color: #4c4c4c; 
                    font-family: Open Sans\">Comments or Suggestions?<br/></span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #0645AD; font-family: Open Sans;\">                    
                    <span><a style=\"color: #0645AD; text-decoration: underline;\" 
                    href=\"ascotfeedback@gmail.com\">ascotfeedback@gmail.com</a></span></br>
                    </span></font>")
    )
  )
)

)
)
