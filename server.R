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
  dfPalette <-
    c(
      "#006629", 
      "#d1561b",
      "#777474",
      "#d84b7e",
      "#33506d",
      "#707000",
      "#d39817",
      "#c13b20",
      "#849b14",
      "#c90c0c",
      "#12967b",
      "#832ba5",
      "#a0396e",
      "#6a54ff",
      "#108989",
      "#563434"
    )
  
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
      filename <- paste(input$dataset, ".Rdata", sep = "")
      filename <- paste("data", filename, sep = "/")
      load(filename)
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
  
  defaultGene <- 1234
  observe({
    defaultGene <- 4474    
    if (input$dataset %in% c("mesa", "ctms")) {
      defaultGene <- 6863
    }
    updateSelectizeInput(
      session,
      "gene",
      #Gene Coverage Lookup Value
      choices = setNames(collection()$query_table[["Search Bar Lookup Value"]],
                         collection()$query_table[["Search Bar Visual"]]),
      selected = collection()$query_table[["Search Bar Lookup Value"]][defaultGene],
      options = list(
        render = I('{
                  item: function(item, escape) {
                    return "<div>" + escape(item.value) + "</div>";
                  }
                }')
      ), server = TRUE
    )
  })

  observeEvent(input$gene, {
    if (input$gene != "") {
      naucMax <- max(collection()$gene_coverage[gene_symbol == input$gene,-c("gene_id", "gene_symbol")])
      if (naucMax >= 100) {
        naucMax <- ceiling(naucMax)
        naucStep <- 1
      } else if (naucMax >= 10 & naucMax < 100) {
        naucMax <- ceiling(naucMax)
        naucStep <- 0.5
      } else if (naucMax >= 1 & naucMax < 10) {
        naucStep <- 0.2
      } else if (naucMax >= 0 & naucMax < 1) {
        naucStep <- naucMax/100
      }
      updateSliderInput(session, "naucRange", value = c(0, naucMax), min = 0, max = naucMax, step = naucStep)            
    }
  })

  plot_data <- eventReactive(c(input$cell_groups, input$colorblind_mode, input$naucRange, input$psiRange), {
    if (input$gene == "") {
      return()
    }
    # Adjust height based on compilation
    if (input$dataset == 'mesa') {
      base_height <- 430
      base_width <- 130
      col_width <- 16
      excn <- c("Exon ID", "CA", "AG", "LK", "ME", "ST", "Exon Location (mm10)", "Exon Boundary (mm10)")
    } else if (input$dataset == 'ctms') {
      base_height <- 430
      base_width <- 130
      col_width <- 18
      excn <- c("Exon ID", "CA", "AG", "LK", "ME", "ST", "Exon Location (mm10)", "Exon Boundary (mm10)")
    } else if (input$dataset == 'gtex') {
      base_height <- 430
      base_width <- 130
      col_width <- 18
      excn <- c("Exon ID", "CA", "AG", "LK", "ME", "ST", "Exon Location (hg38)", "Exon Boundary (hg38)")
    } else if (input$dataset == 'enchepg2') {
      base_height <- 430
      base_width <- 130
      col_width <- 18
      excn <- c("Exon ID", "CA", "AG", "LK", "ME", "ST", "Exon Location (hg38)", "Exon Boundary (hg38)")
    } else if (input$dataset == 'enck562') {
      base_height <- 430
      base_width <- 130
      col_width <- 18
      excn <- c("Exon ID", "CA", "AG", "LK", "ME", "ST", "Exon Location (hg38)", "Exon Boundary (hg38)")
    }
          
    print(input$gene)
    subtitle_id <- collection()$gene_coverage[gene_symbol == input$gene]$gene_id
    coverage <-
      collection()$gene_coverage[gene_symbol == input$gene,-c("gene_id")] %>%
      melt(
        variable.name = "cell_type",
        value.name = "gene_expression",
        variable.factor = FALSE
      )
    
        coverage <-
      coverage[collection()$categories,
               on = "cell_type", nomatch = 0][cell_group %in% input$cell_groups]
    
    p1shift <- -40
    if (input$dataset == "ctms") {
      p1shift <- p1shift + 50
    } 
    
    p1 <-
      ggplot(coverage, aes(x = cell_type, y = gene_expression)) +
      ggtitle(input$gene, 
              subtitle = paste("(", subtitle_id, ")", sep="")
             ) +
      geom_bar(stat = "identity",
               mapping = aes(fill = cell_group)) +
      theme_minimal() +
      scale_x_discrete("",
                       expand = c(0, 0),
                       limits = coverage$cell_type) +
      scale_y_continuous("Gene Expression\n(NAUC)\n", limits = c(input$naucRange[1], input$naucRange[2]),
                                                oob = rescale_none, expand = c(0, 0)) +
          theme(text = element_text(size=16),
            plot.title = element_text(hjust = 0.5, size = 30),
            plot.subtitle = element_text(hjust = 0.5),
            legend.box.margin = unit(c(p1shift,0,0,0), "pt"),
            axis.text.x = element_text(
            angle = 90,
            hjust = 1,
            vjust = 0.4
          ))
    
    if (input$colorblind_mode) {
      #p1 <- p1 + scale_fill_manual("Cell Groups", values = cbPalette)
      #p1 <- p1 + scale_fill_brewer("Cell Groups", palette = "Dark2")
      p1 <- p1 + scale_fill_manual("Cell Groups", values = dfPalette)
    } else {
      p1 <- p1 + scale_fill_manual("Cell Groups", values = dfPalette)
    }
    
    gene_psi <- collection()$psi[gene_symbol == input$gene,-(cassette_exon:exon_boundary)] %>%
      melt(
        id.vars = c("exon_id"),
        variable.name = "cell_type",
        value.name = "PSI"
      )
    gene_psi <-
      gene_psi[collection()$categories, on = "cell_type", nomatch = 0][cell_group %in% input$cell_groups]

      exdt <- collection()$psi[gene_symbol == input$gene, c(1:6,11,12)]
        output$exontable <- DT::renderDataTable(DT::datatable(head(exdt,200),
          caption = htmltools::tags$caption(
                htmltools::tags$span(
                    style = "vertical-align: middle; font-size:125%; color:black",
                    "Alternative Exon Metadata "
                ),
                htmltools::tags$span(
                    style = "vertical-align: middle; font-size:100%; color:black",
                    "— (CA = Cassette, AG = Alternative Splice Site Group, LK= Linked Exons, ME = Mutually Exclusive, ST = Strand)"
                )
          ),
            rownames = FALSE,
            colnames=excn,
            options = list(dom = 't', order = list(list(0, 'desc'))))
      )
    
    if (nrow(gene_psi) == 0) {
      p2 <- NULL
    } else {
      group_labels <- unique(gene_psi$cell_group)
      padding_width <- sort(nchar(group_labels), decreasing = TRUE)[1]
      psiMin <- input$psiRange[1]
      psiMax <- input$psiRange[2]
      scale_labels <- stringr::str_pad(seq(psiMin, psiMax, by = round((psiMax - psiMin)/4, digits=0)), width = padding_width, side = "right")
      break_numbers <- c(seq(psiMin, psiMax, by = round((psiMax - psiMin)/4, digits=0)))
      
      p2left = 0
      if (nrow(gene_psi)/nrow(coverage) == 1) {
        p2up <- 70
      } else if (nrow(gene_psi)/nrow(coverage) == 2) {
        p2up <- 40
      } else {
        p2up <- 0
      }
      if (input$dataset == "mesa") {
        p2up <- p2up + 60
      } else if (input$dataset == "ctms") {
        p2up <- p2up + 118
        p2left <- -23
      }

      p2 <- ggplot(gene_psi, aes(x = cell_type, y = exon_id)) +
        geom_tile(aes(fill = PSI), color = "white") +
        theme_minimal() +
        xlab("") +
        ylab("Exon\n(PSI)\n") +
        scale_x_discrete(expand = c(0, 0), limits = unique(gene_psi$cell_type)) +
        theme(text = element_text(size=16),
          plot.margin = unit(c(-5,0,0,0), "pt"),
          legend.box.margin = unit(c(p2up,0,0,p2left-nrow(coverage)/4.6666), "pt"),
          axis.text.x = element_text(
          angle = 90,
          hjust = 1,
          vjust = 0.4
        ))
      if (input$colorblind_mode) {
        p2 <-
          p2 + scale_fill_distiller(
            palette = "Spectral",
            limits = c(input$psiRange[1], input$psiRange[2]),
            labels = scale_labels,
            breaks = break_numbers,
            oob = squish
          )
      } else {
        p2 <-
          p2 + scale_fill_distiller(
            palette = "Blues",
            direction = 1,
            limits = c(input$psiRange[1], input$psiRange[2]),
            labels = scale_labels,
            breaks = break_numbers,
            oob = squish
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
            height_px = if (is.null(p2))
              base_height
            else
              base_height + 30*nrow(gene_psi)/nrow(coverage),
            width_px = if (is.null(p2))
              base_width + col_width*nrow(coverage)
            else
              base_width + col_width*nrow(coverage))
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
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
        grid.arrange(arrangeGrob(gA, gB, nrow = 2, heights = c(105/plot_data()$height_px, 0.3)))
      }
    }, height = plot_data()$height_px, width = plot_data()$width_px)
  }, ignoreInit = TRUE)
})
