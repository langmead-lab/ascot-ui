FROM rocker/shiny

RUN Rscript -e "install.packages(c('ggplot2', 'gridExtra'), repos='https://cran.rstudio.com/')"
RUN Rscript -e "install.packages(c('shinyBS', 'shinycssloaders', 'shinydashboard', \
                                   'shinythemes', 'shinyjs', 'DT'), repos='https://cran.rstudio.com/')"
RUN Rscript -e "install.packages(c('data.table'), repos='https://cran.rstudio.com/')"
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN mkdir -p /srv/shiny-server/ascot-ui
COPY www /srv/shiny-server/ascot-ui/www
COPY data /srv/shiny-server/ascot-ui/data
COPY *.R /srv/shiny-server/ascot-ui/

RUN wget -i /srv/shiny-server/ascot-ui/data/rdata.txt -P /srv/shiny-server/ascot-ui/data

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
