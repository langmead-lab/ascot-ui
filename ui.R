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

wellPanel(fluidRow(
  column(
    4,
    selectInput(
      "dataset",
      tags$b("Select Dataset"),
      choices = c("Super Mouse" = "supermouse", "Allen Brain" = "allenbrain"),
      selected = "supermouse"
    )
  ),
  column(
    8,
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
    wellPanel(checkboxInput(
      "colorblind_mode", "Enable Colorblind Mode"
    )),
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
    wellPanel(uiOutput("exon_filter_widget")),
    wellPanel(uiOutput("save_widget"))
  )
)
)
)