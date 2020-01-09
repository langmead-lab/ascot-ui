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

RUN wget https://doc-0o-6s-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/tfdj0l90kogdfopqc8p4umjg5df7lcid/1578549600000/02723178961533344843/*/1vbtzhW0m1uLxHq19aTFEWXdRSS-6ziq4?e=download -O /srv/shiny-server/ascot-ui/data/mesa.Rdata
RUN wget https://doc-10-6s-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/po7h0ll9c1g9rb88aoqnevsgv7hic5mq/1578549600000/02723178961533344843/*/1GkMTOOIbRE-Aj1A1k3gwgQYN3hovz6ZV?e=download -O /srv/shiny-server/ascot-ui/data/ctms.Rdata
RUN wget https://doc-0k-6s-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/085vcj904cb9iq7krcmasb9bt5ha5i6o/1578549600000/02723178961533344843/*/1riAi9IZpj1MWtg2buUj2DO4rT9Ioq5km?e=download -O /srv/shiny-server/ascot-ui/data/enchepg2.Rdata
RUN wget https://doc-0c-6s-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/iul62s2jrhh7bs6ckfl1rmmk07q343p5/1578549600000/02723178961533344843/*/10UVtCFhWUriwnVW9Vjy7VlOl-73_nJyT?e=download -O /srv/shiny-server/ascot-ui/data/enck562.Rdata
RUN wget https://doc-14-6s-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/2aprraofq23afpujlponv1g2ofimese7/1578549600000/02723178961533344843/*/1lVg2ZE7ItjkRp5536Dtr5HMwnKwYwh6l?e=download -O /srv/shiny-server/ascot-ui/data/gtex.Rdata

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
