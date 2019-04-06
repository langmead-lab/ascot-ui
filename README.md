### Docker image

The `Dockerfile` and accompanying `*.sh` scripts enable building and running a Docker image encapsulating Shiny, the Ascot UI and their dependencies.

* `build.sh` -- builds the image, based on the [`rocker/shiny`](https://hub.docker.com/r/rocker/shiny/).
* `run.sh` -- runs a container in daemon mode, mapping port 3838 on localhost to 3838 on the Shiny appliance.  It also uses `open` to open a web browser and point it at the app.  (Works on my Mac at least.)
* `kill.sh` -- kills the container if it's running.
* `cat_shiny_logs.sh` -- if the container is running, prints all the Shiny logs, including logs for the Ascot UI.  Useful for debugging.

The datasets are currently baked into the image (added via the `COPY data /srv/shiny-server/ascot-ui/data` command in the `Dockerfile`), but an alternate design is to keep them in directory on the host and then mount that host directory to some known path within the container.   Then they wouldn't bloat the image.

### Elastic Beanstalk

In Beanstalk, the highest level of organization is an Application.
The next level is called an Environment.
The steps below walk through creating an application and environment.

#### Prerequisites

Some prerequisites for using [Elastic Beanstalk (EB)](https://aws.amazon.com/elasticbeanstalk/).  These only need to be handled once per account or per user.  These steps should not need to be repeated for each new application or environment.

* Make sure all the AZs have default subnets
    * `aws --profile jhu-langmead ec2 create-default-subnet --availability-zone us-east-2c`
* Allow the user to pass appropriate roles to EB service
    * I called the policy `AllowPassEbRole`

Here's the policy JSON:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::159168350739:role/aws-elasticbeanstalk-ec2-role",
                "arn:aws:iam::159168350739:role/aws-elasticbeanstalk-service-role"
            ]
        }
    ]
}
```

I attached the policy to the `eb` group, and then added `langmead` to that group.

#### Create the application

```
./eb_create_app.sh
```

#### Create the `test` environment

```
./eb_create_env.sh
```

#### Browse to the deployed app

```
eb open
```

A typical Beanstalk application will have more than one environment.  E.g. one for development, one for testing, and one for production.  Here we've just made one called `test` but we might want many.
