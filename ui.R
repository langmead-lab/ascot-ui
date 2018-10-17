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
    column(6, HTML("<font size=\"7\"><span style=\"color: #ffffff; 
                    font-family: Open Sans; font-weight: 500;\">ASCOT<br/></span></font>"),
              HTML("<font size=\"3\"><span style=\"color: #ffffff; 
                    font-family: Open Sans;\">Alternative Splicing and Gene Expression<br/>
                    Summaries of Public RNA-Seq Data</span></font>"),
              HTML("<font size=\"2\"><span style=\"color: #ffffff;\">
                    <br/><br/>(powered by <span style=\"text-decoration: underline;\">
                    <a style=\"color: #ffffff; text-decoration: underline;\" 
                    href=\"http://snaptron.cs.jhu.edu/\">Snaptron</a></span>&nbspand&nbsp<span 
                    style=\"text-decoration: underline;\">
                    <a style=\"color: #ffffff; text-decoration: underline;\"
                    href=\"https://jhubiostatistics.shinyapps.io/recount/\">Recount2</a></span>)</span></font>"),
              HTML("<font size=\"2\"><br/>&nbsp</font>")
    ),
    column(6, align = "right", img(src="header_logos.png", height="160pt"))
  )
),

wellPanel(style = "margin-top:-10px; padding: 5px 20px 0px;", fluidRow(
  column(
    2,
    selectInput(
      "dataset",
      tags$b("Select Dataset"),
      choices = c("MESA (Mouse Cell Types)" = "mesa",
                  "GTEx (Human Tissues)" = "gtex",
                  "ENCODE HepG2 (shRNA-seq)" = "encodehepg2",
                  "ENCODE K562 (shRNA-seq)" = "encodek562"),
      selected = "mesa"
    )
  ),
  column(
    2,
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
  column(
    2,
    sliderInput("range", "NAUC view range:",
                    min = 0, max = 1000,
                    value = c(200,500))
  ),
  column(
    2,
    sliderInput("range", "PSI view range:",
                    min = 0, max = 100,
                    value = c(0,30))
  )
)),

plotOutput("plot", height = "500px") %>% withSpinner(),
# plotOutput("heatmap", height = "500px"),
absolutePanel(
  id = "controls",
  fixed = TRUE,
  draggable = FALSE,
  top = "auto",
  left = 10,
  right = "auto",
  bottom = 0,
  width = 330,
  height = "auto",
  bsCollapsePanel(
    "Plot Options",
    style = "primary",
    wellPanel(tags$div(
      align = "left",
      class = "muticol",
      checkboxGroupInput(
        "cell_groups",
        "Filter Cell Groups",
        choices = NULL,
        selected = NULL
      )
    )),
    checkboxInput(
      "colorblind_mode", "Enable Colorblind Mode"
    ),
    wellPanel(uiOutput("exon_filter_widget")),
    wellPanel(uiOutput("save_widget"))
  )
)
)
)