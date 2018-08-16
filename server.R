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
library(scales)
library(magrittr)
library(shinyjs)
library(grid)
library(gridExtra)
library(data.table)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  cbPalette <-
    c(
      "#999999",
      "#E69F00",
      "#56B4E9",
      "#009E73",
      "#F0E442",
      "#0072B2",
      "#D55E00",
      "#CC79A7"
    )

  loaded_collections <- list()

  collection <- reactive({
    if (is.null(loaded_collections[[input$dataset]])) {
      filename <- paste(input$dataset, "-dt", ".Rdata", sep = "")
      filename <- paste("data", filename, sep = "/")
      load(filename)
      query_table <-
        dplyr::rename(
          query_table,
          visual = `Search Bar Lookup Value`,
          value = `Gene Coverage Lookup Value`,
          label = `Search Bar Visual`,
          psi_value = `PSI Table Lookup Value`
        )
      loaded_collections[[input$dataset]] <- list(
        psi = psi,
        gene_coverage = gene_coverage,
        query_table = query_table,
        categories = categories
      )
    }
    loaded_collections[[input$dataset]]
  })

  observe({
    cell_groups <- unique(collection()$categories$cell_group)
    updateCheckboxGroupInput(session,
                             "cell_groups",
                             choices = cell_groups,
                             selected = cell_groups)
  })

  observe({
    updateSelectizeInput(
      session,
      "gene",
      choices = collection()$query_table,
      selected = collection()$query_table[1][, value],
      server = TRUE
    )
  })

  plot_data <-
    eventReactive(
      c(input$gene, input$cell_groups, input$colorblind_mode),
      {
        if (input$gene == "") {
          return()
        }

        coverage <-
          collection()$gene_coverage[gene_id == input$gene,-(gene_id:gene_description)] %>%
          melt(
            measure.vars = patterns(".*"),
            variable.name = "cell_type",
            value.name = "gene_expression",
            variable.factor = FALSE
          )
        coverage <-
          coverage[collection()$categories,
                   on = "cell_type", nomatch = 0][cell_group %in% input$cell_groups]

        p1 <-
          ggplot(coverage, aes(x = cell_type, y = gene_expression)) +
          geom_bar(stat = "identity",
                   mapping = aes(fill = cell_group)) +
          theme_minimal() +
          scale_x_discrete("Cell Type",
                           expand = c(0, 0),
                           limits = coverage$cell_type) +
          scale_y_continuous("Gene Expression (RPKM)", expand = c(0, 0)) +
          theme(axis.text.x = element_text(
            angle = 90,
            hjust = 1,
            vjust = 0.5
          ))

        if (input$colorblind_mode) {
          p1 <- p1 + scale_fill_manual("Cell Groups", values = cbPalette)
        } else {
          p1 <- p1 + scale_fill_brewer("Cell Groups", palette = "Set2")
        }

        symbol <-
          collection()$query_table[value == input$gene][1, psi_value]
        gene_psi <-
          collection()$psi[gene_symbol == symbol, -(gene_symbol:MUTEX)] %>%
          melt(
            id.vars = c("exon_id"),
            variable.name = "cell_type",
            value.name = "PSI"
          )
        gene_psi <-
          gene_psi[collection()$categories, on = "cell_type", nomatch = 0][cell_group %in% input$cell_groups]
        if (nrow(gene_psi) == 0) {
          p2 <- NULL
        } else {
          group_labels <- unique(gene_psi$cell_group)
          padding_width <-
            sort(nchar(group_labels), decreasing = TRUE)[1]
          scale_labels <-
            stringr::str_pad(seq(0, 100, by = 25), width = padding_width, side = "right")
          p2 <- ggplot(gene_psi, aes(x = cell_type, y = exon_id)) +
            geom_tile(aes(fill = PSI), color = "white") +
            theme_minimal() +
            xlab("Cell Types") +
            ylab("Exon ID") +
            scale_x_discrete(expand = c(0, 0),
                             limits = unique(gene_psi$cell_type)) +
            theme(axis.text.x = element_text(
              angle = 90,
              hjust = 1,
              vjust = 0.5
            ))
          if (input$colorblind_mode) {
            p2 <-
              p2 + scale_fill_distiller(
                palette = "PuBuGn",
                limits = c(0, 100),
                labels = scale_labels
              )
          } else {
            p2 <-
              p2 + scale_fill_distiller(
                palette = "Spectral",
                limits = c(0, 100),
                labels = scale_labels
              )
          }
        }

        if (!is.null(p2)) {
          p1 <-
            p1 + scale_x_discrete(NULL,
                                  expand = c(0, 0),
                                  limits = unique(gene_psi$cell_type)) +
            theme(axis.text.x = element_blank())
        }
        list(p1 = p1,
             p2 = p2,
             size = if (is.null(p2))
               500
             else
               800)
      },
      ignoreInit = TRUE,
      ignoreNULL = TRUE
    )

  observeEvent(plot_data(), {
    output$plot <- renderPlot({
      if (is.null(plot_data()$p2)) {
        plot_data()$p1
      } else {
        gA <- ggplot_gtable(ggplot_build(plot_data()$p1))
        gB <- ggplot_gtable(ggplot_build(plot_data()$p2))
        maxWidth <- grid::unit.pmax(gA$widths, gB$widths)
        gA$widths <- as.list(maxWidth)
        gB$widths <- as.list(maxWidth)
        grid.newpage()
        grid.arrange(arrangeGrob(gA, gB, nrow = 2, heights = c(.2, .3)))
      }
    }, height = plot_data()$size)
  }, ignoreInit = TRUE)
})
