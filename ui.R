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
    theme = shinythemes::shinytheme("spacelab"),
    tags$head(tags$style(
      HTML(
        "
        @import url('https://fonts.googleapis.com/css?family=Open+Sans&display=swap');
        .muticol {
        height: 150px;
        -webkit-column-count: 2;
        -moz-column-count: 2;
        column-count: 2;
        -moz-column-fill: auto;
        -column-fill: auto;
        }"
        )
      ),
      #tags$link(rel="shortcut icon", href="https://www.google.com/favicon.ico")
      tags$link(rel="shortcut icon", href="https://raw.githubusercontent.com/jpling/ascot/master/imgs/favicon.ico")
    ),

    wellPanel(style = "
          background-color: #003082;
          box-shadow: 0 5px 5px -5px #333;
          padding: 0px 10px 6px;
          width: 1500px;
          ",
    fluidRow(  
      style = "padding: 10px 10px 10px;",
      column(4, style = "padding: 0px 0px 0px 20px;",
                img(src="logo-dark.png", style="float: left; padding: 10px 20px 0px 0px"),
                HTML("<div style=\"line-height:50%;\"><br/></div>"),
                HTML("<font size=\"3\"><span style=\"color: #ffffff;
                      font-family: 'Open Sans', sans-serif;\">Alternative Splicing &<br/>Gene Expression Summaries of<br/>
                      Public RNA-Seq Data</span></font>"),
                HTML("<div style=\"line-height:250%;\"><br/></div>"),
                HTML("<font size=\"3\"><span style=\"color: #ffffff;\">
                      <br/><br/>Built using <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                      href=\"http://snaptron.cs.jhu.edu/\" target=\"_blank\">Snaptron</a></span>&nbspand&nbsp<span><a 
                      style=\"color: #ffffff; text-decoration: underline;\"
                      href=\"https://jhubiostatistics.shinyapps.io/recount/\" target=\"_blank\">Recount2</a></span></span><br/></font>")
      ),
      column(4, style = "padding: 0px 0px 0px 65px;",
                HTML("<font size=\"5\"><span style=\"color: #ffc800; font-family: 'Open Sans', sans-serif;\">                    
                      <span><a style=\"color: #ffc800; text-decoration: underline;\" 
                      href=\"howtouse.html\" target=\"_blank\">How to use this website</a></span></br></span></font>"),
                HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: 'Open Sans', sans-serif;\">
                      • <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                      href=\"naucpsi.html\" target=\"_blank\">What do NAUC and PSI mean?</br></a></span></span></font>"),
                HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: 'Open Sans', sans-serif;\">
                      • <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                      href=\"/ds/ds_list.html\" 
                      target=\"_blank\">What publications did we use as data sources?</br></a></span></span></font>"),
                HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: 'Open Sans', sans-serif;\">
                      • <span><a style=\"color: #ffffff; text-decoration: underline;\"
                      href=\"ucsctracks.html\" target=\"_blank\">Visualize data on the UCSC Genome Browser</br></a></span>
                      </span></font>"),
                HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: 'Open Sans', sans-serif;\">                    
                      • <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                      href=\"http://snaptron.cs.jhu.edu/data/ascot\" target=\"_blank\">Download the raw data tables</br></a>
                      </span></span></font>"),
                HTML("<font size=\"3\"><span style=\"color: #ffffff; font-family: 'Open Sans', sans-serif;\">                    
                      • <span><a style=\"color: #ffffff; text-decoration: underline;\" 
                      href=\"https://github.com/jpling/ascot\" target=\"_blank\">GitHub repository</br></a></span></span></font>"),
                HTML("<font size=\"5\"><span style=\"color: #ffc800; font-family: 'Open Sans', sans-serif;\">Please cite:&nbsp<span>
                      <a style=\"color: #ffc800; text-decoration: underline;\" 
                      href=\"https://doi.org/10.1038/s41467-019-14020-5\" target=\"_blank\">Nature Commun. 2020</a>
                      </span></span></font>")
      ),
      column(4, align = "right", style="padding: 0px 20px 0px 0px", img(src="header160.png", style="float: right; padding: 10px 0px 0px"))
      )
    ),

    wellPanel(style = "margin-top:-10px; padding: 5px 20px 0px; width: 1500px;", fluidRow(
      column(3,
        selectInput(
          "dataset",
          tags$b("Select Dataset"),
          choices = c("Mouse Cells and Tissues (MESA)" = "mesa",
                      "Mouse Single Cell RNA-Seq (CellTower)" = "ctms",
                      "Human Tissues (GTEx)" = "gtex",
                      "HepG2 shRNA (ENCODE)" = "enchepg2",
                      "K562 shRNA (ENCODE)" = "enck562"
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
      column(2, checkboxInput("colorblind_mode", "Rainbow PSI"))
    )),

    plotOutput("plot", height = "auto") %>% withSpinner(),

    bsCollapsePanel(
        "Show/Hide Datasets",
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
                  HTML("<font size=\"3\"><span style=\"color: #4c4c4c; font-family: 'Open Sans', sans-serif;\">
                        <span><a style=\"color: #4c4c4c; text-decoration: underline;\" 
                        href=\"http://www.langmead-lab.org/\" target=\"_blank\">Ben Langmead Lab</a></span></br>
                        </span></font>"),
                  HTML("<font size=\"3\"><span style=\"color: #4c4c4c; font-family: 'Open Sans', sans-serif;\">                    
                        <span><a style=\"color: #4c4c4c; text-decoration: underline;\" 
                        href=\"http://neuroscience.jhu.edu/research/faculty/7\" target=\"_blank\">Seth Blackshaw Lab</a></span></br>
                        </span></font>")
        ),
        column(4, class = "text-center",
                  HTML("<font size=\"3\"><span style=\"color: #4c4c4c; font-family: 'Open Sans', sans-serif;\">                    
                        Website developed by <span><a style=\"color: #4c4c4c; text-decoration: underline;\" 
                        href=\"https://github.com/ch4rr0\" target=\"_blank\">Rone Charles</a></span>
                        </span></font>")
        ),
        column(4, class = "text-right",
                  HTML("<font size=\"3\"><span style=\"align:right; color: #4c4c4c; 
                        font-family: 'Open Sans', sans-serif\">Comments or Suggestions?<br/></span></font>"),
                  HTML("<font size=\"3\"><span style=\"color: #0645AD; font-family: 'Open Sans', sans-serif;\">                    
                        <span><a style=\"color: #0645AD; text-decoration: underline;\" 
                        href=\"ascotfeedback@gmail.com\">ascotfeedback@gmail.com</a></span></br>
                        </span></font>")
        )
      )
    )
  )
)
