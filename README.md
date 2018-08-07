### Docker image

The `Dockerfile` and accompanying `*.sh` scripts enable building and running a Docker image encapsulating Shiny, the Ascot UI and their dependencies.

* `build.sh` -- builds the image, based on the [`rocker/shiny`](https://hub.docker.com/r/rocker/shiny/).
* `run.sh` -- runs a container in daemon mode, mapping port 3838 on localhost to 3838 on the Shiny appliance.  It also uses `open` to open a web browser and point it at the app.  (Works on my Mac at least.)
* `kill.sh` -- kills the container if it's running.
* `cat_shiny_logs.sh` -- if the container is running, prints all the Shiny logs, including logs for the Ascot UI.  Useful for debugging.

The datasets are currently baked into the image (added via the `COPY data /srv/shiny-server/ascot-ui/data` command in the `Dockerfile`), but an alternate design is to keep them in directory on the host and then mount that host directory to some known path within the container.   Then they wouldn't bloat the image.