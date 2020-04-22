# 🐳 Docker Compose for Laravel 🐘

A Docker Compose setup for Laravel projects, inspired by [this repo](https://github.com/aschmelyun/docker-compose-laravel).

## Table of contents

- [Docker Compose for Laravel](#-docker-compose-for-laravel-)
- [Table of contents](#table-of-contents)
- [Setup](#setup)
  - [Prerequisites](#prerequisites)
  - [New Project](#new-project)
  - [Existing Project](#existing-project)
    - [Update an Existing Project](#update-an-existing-project)
- [Usage](#usage)
  - [Viewing container logs in detached mode](#viewing-container-logs-in-detached-mode)
  - [Running attached](#running-attached)
  - [Composer](#composer)
  - [Yarn](#yarn)
- [Configuration](#configuration)
  - [Services](#services)
    - [.env](#env)
    - [app](#app)
    - [database](#database)
      - [Common Issues](#common-issues)
    - [webserver](#webserver)
  - [Building](#building)
- [Reference](#reference)
  - [Ports](#ports)
  - [Database Access](#database-access)
- [Recommended Packages](#recommended-packages)
- [Changelog](#changelog)

## Setup

Setup is fairly straight forward, there are no installation steps for the project itself, just ensure that the prerequisites are met and you are off to the races!

Use the scripts in this repo at your own risk. Please read through the code first and be familiar with what it is doing and make a judgment call. I accept no liability.

### Prerequisites

Ensure that [Docker is installed](https://docs.docker.com/docker-for-mac/install/) and up to date on your system. Once installed, configure with your required preferences and ensure it is running.

### New Project

Create a new **empty** repo on GitHub, or your git host of choice. The git repo will be initialised and a master branch created and pushed during setup.

Once created, grab and save the SSH link to the new remote for later. You can use HTTPS too, provide the link to it as you would with SSH, but then instruct the script that you are using HTTPS by passing the `-p` flag.

Below is my example. I've created the remote and its ready to use:

```plaintext
New remote: git@github.com:othyn/new-docker-laravel-project.git
```

Next, run this handy installation script [`install.sh`](install.sh), that does all the hard work for you! Just pass in that new remote you setup above and where you'd like it to exist locally on your machine at it will do the rest:

**\*Before running!** Please ensure you've read and understood what the script does. Sure, you may learn something from it, but you should never run arbitrary code on your machine without first checking the source. A good habit to get into if you aren't already in it!\*

```sh
$ curl https://raw.githubusercontent.com/othyn/docker-compose-laravel/master/install.sh | \
  bash -s -- \
  -r git@github.com:othyn/new-docker-laravel-project.git \
  -l ~/git/new-docker-laravel-project
```

The back slashes are just for readability, you can one-line the command if you wish. Below is an excerpt of the [`install.sh`](install.sh) help contents, displayed by passing the `-h` flag, just for reference:

```sh
#    Usage: $0 -l <new-local-repo> [options]
#
#    [required]
#    -l      The local directory of the project to Docker-ise.
#                E.g. ~/git/new-docker-laravel-project
#
#    [options]
#    -r      New, empty, remote repo to setup a new project against.
#                E.g. git@github.com:othyn/new-docker-laravel-project.git
#    -p      Use HTTPS clone method instead of SSH.
#    -f      Force the local directory, if it exists, it will be removed.
#    -b      Git branch to checkout on installation, defaults to origin/master.
#    -h      Brings up this help screen.
```

Now to continue on your new project adventure, begin with the [Laravel configuration steps](https://laravel.com/docs/master/installation#configuration) and have some fun.

That's it! Magic. 🎉

### Existing Project

It's as simple as running a script. Let's begin!

**\*Before running!** Please ensure you've read and understood what the script does. Sure, you may learn something from it, but you should never run arbitrary code on your machine without first checking the source. A good habit to get into if you aren't already in it!\*

**\*THIS IS A DESTRUCTIVE OPERATION!** The installation script will delete the `/docker`, `default.env` and `docker-compose.yml` files in the provided local directory (the directory value provided for the `-l` flag). This is as it copies the ones from this project in. You have been warned.

The installation script is the same as a new project installation, however it omits the git repo as it assumes you already have one configured. This under the assumption that its an existing project and you won't want to overwrite your git history. Just make sure you have the project on the branch you want the changes to be made on prior to running the script, as it commits a few times throughout the process.

```sh
$ curl https://raw.githubusercontent.com/othyn/docker-compose-laravel/master/install.sh | \
  bash -s -- \
  -l ~/git/existing-docker-laravel-project
```

This will install the `/docker` directory into the provided local `-l` directory along with the `docker-compose.yml` file too, along with configuring your existing Laravel project's `.env` and `.env.example`, giving you access to Docker!

That's it! Magic. 🎉

#### Update an Existing Project

To update in future, just run through the [Existing Project](#existing-project) installation, as the steps will be the same. It will overwrite the files in future with the latest versions in this repo.

That's it! Magic. 🎉

## Usage

Once the project has been [Setup](#setup), it's very simple to use. Launch docker composer from within the root directory of the project. As long as you are in the directory containing the `docker-compose.yml` file in it, away you go!

```sh
$ docker-compose up -d
```

The above command, specifically the `-d` flag, will tell Docker to run the containers in the background, this is `detached` mode. This is so that they don't remain as open processes within your terminal/terminal window and it can be reused for other commands without starting a new session and the Docker container process is not bound to the terminal session process.

Once the containers have been downloaded and built, in which Docker will do this automatically on first up or via running `$ docker-compose build`, beneath a heap of terminal output showing the logs and progress of said downloading and building, you should see a nice set of `Creating xyz ... done` statements before the terminal is automatically detached and handed back to you. The download and build status will only be shown the first time that you run the project or update the containers, and subsequent times will only show the `Creating xyz ... done` statements, as the containers are ready to go.

```sh
... <lots of terminal output with download and build status from Docker that will only appear on first build> ...
Creating database  ... done
Creating composer  ... done
Creating node      ... done
Creating app       ... done
Creating webserver ... done
```

Great! The containers are up and running. Time to verify everything is working by visiting that nice new fresh Laravel installation screen in your browser at [`http://localhost:8080/`](http://localhost:8080/).

That's it! Magic. 🎉 Now get to building something beautiful.

### Viewing container logs in detached mode

If you wish to quickly view the logs of the detached containers without re-attaching the output to the terminal, run `$ docker-compose logs` which will spit out a one off log of the current log output of all of the containers as if you were attached.

### Running attached

If you wish to have the standard `attached` mode, omit the `-d` flag. This is helpful when you wish to debug containers, as you will be attached to the log output of the containers in whichever terminal you fired off the up command into.

To quit all containers in this view, use the standard unix abort key sequence `CTRL` + `C`. Pressing this key combo once will gracefully halt the containers into a `down` state. Pressing it again during the graceful stop will forcibly halt the containers.

To detach from an already running `$ docker-compose up`, use `CTRL` + `Z`, that will suspend the process into the background. When in the background it becomes part of the `jobs` queue. You can view them and their `[id]` using the following command:

```sh
$ jobs
> [1]  + suspended  docker-compose up
#  ^ That is the ID of the process.
```

Then to get back to a background job, use its ID prefixed with a percent sign in the following command, it will return the process to the foreground:

```sh
$ fg %1
#     ^ That is the ID of the process.
```

To instead kill a background task, run the following, using that process ID that we had from before:

```sh
$ kill -KILL %1
#             ^ That is the ID of the process.
```

To re-attach to the docker logs whilst the process is suspended or `detached` (the output that `$ docker-compose up` would usually sit you at), run the following:

```sh
$ docker-compose logs -f -t
```

That will attach you back to the logs. To do this for a specific container, add the container name to the end of the command:

```sh
$ docker-compose logs -f -t <container>
# <container> can be any running container. e.g. webserver, database or app
```

To run a command in a running the container:

```sh
$ docker-compose exec <container> <command>
# <container> can be any running container. e.g. webserver, database or app
# <command> can be any command. e.g. 'top' or 'sh' (Alpine) / 'bash' (Ubuntu) to enter an interactive shell
```

To stop the containers, if they are attached simply press `CTRL` + `C` which is the escape sequence for any CLI application. That should gracefully stop them, if it aborts or the containers are running in `detached` mode, do the following:

```sh
$ docker-compose down
```

You can use `stop` instead of `down` to just stop the running container. The above command, `down`, will both stop and remove the container and its associated networks. You can also specify `--volumes` as an additional flag to remove any associated volumes, and the `--rmi <all|local>` flag to remove associated images.

### Composer

There is a composer image also built into the Docker Compose stack, allowing composer to automatically run on your project when the `$ docker-compose up` command is run. Although, if you wish to run a `$ composer install` at any point manually, you can just run:

```sh
$ docker-compose run --rm composer
```

This is because we haven't provided a command to run, so `$ docker-compose run` will `run` the `command` that is listed against the `composer` `service` defined in `docker-compose.yml`. The `--rm` flag will simply clean up the container that it has used to run the command after its been executed. If you wish to run any other composer commands with this, go ahead and do so, some examples:

```sh
$ docker-compose run --rm composer composer update                      # to update composer dependencies
$ docker-compose run --rm composer composer install <new dependency>    # to install new composer dependencies
$ docker-compose run --rm composer composer remove <old dependency>     # to remove old composer dependencies
```

### Yarn

There is a node image also built into the Docker Compose stack, allowing yarn to automatically run on your project when the `$ docker-compose up` command is run. Although, if you wish to run a `$ yarn install` at any point manually, you can just run:

```sh
$ docker-compose run --rm node
```

This is because we haven't provided a command to run, so `$ docker-compose run` will `run` the `command` that is listed against the `node` `service` defined in `docker-compose.yml`. The `--rm` flag will simply clean up the container that it has used to run the command after its been executed. If you wish to run any other yarn commands with this, go ahead and do so, some examples:

```sh
$ docker-compose run --rm node yarn upgrade                     # to update yarn dependencies
$ docker-compose run --rm node yarn install <new dependency>    # to install new yarn dependencies
$ docker-compose run --rm node yarn remove <old dependency>     # to remove old yarn dependencies
$ docker-compose run --rm node yarn <scripts>                   # run any package.json scripts, e.g. dev, watch, hot, build, prod|production, etc.
```

## Configuration

There are elements of this docker project that you can configure if you require extra functionality. Obviously, at the end of the day this is just a bog standard Docker project, so you can go to town with any changes you wish. But these are the main areas that are easy adaptable.

### Services

This is the configuration for all of the core services that are configured; `app`, `composer`, `database`, `node` and `webserver`. All the services configuration is, as usual, located in their declaration within the `docker-compose.yml` in the project root, and if necessary, accompanied also by a directory with the service name in the `docker` directory, within the root directory.

#### .env

The docker compose file runs using the `.env` config for the project, to ensure all hosts, ports, etc. align between Laravel and the containers that it uses. Meaning, if you edit your `.env` and cycle your Docker environment, down and up again, they should automatically re-align.

#### app

The `dockerfile` for the `app` contains all provisioning steps within the build process for the container, so add anything you wish to be built into it in there, as per the Docker docs.

The `entrypoint.sh` script is copied in and executed when the container is brought `up`, so this runs things like `artisan` commands (migrations, seeders, etc.) and such to get Laravel in a ready state. Add anything in to this file that you need running every time the container is upped, not built.

The `php.ini` file is any PHP ini configuration you wish to set, this merges into the system default `php.ini`, as defined in the [documentation for the docker image](https://hub.docker.com/_/php), under 'Configuration'. (Documentation page doesn't support URL fragments, no ID's!)

#### database

The MySQL container is volume mapped within Docker, so that the containers database is persisted across container instances. If you don't want the data to persist, when you bring the container down, use the `-v` flag to also remove attached volumes `$ docker-compose down -v`.

The `base.sql` patch file is run by the MySQL Docker container when its upped, so place any SQL statements in there that you wish to be run. E.g. creating databases.

##### Common Issues

**As per the MySQL docs**, this is only run when the containers volume to `/var/lib/mysql` is empty - same with `env` variables. If you are having issues connecting to the database, down all the containers and remove their volumes and try again.

#### webserver

The `nginx.conf` file is any NGINX configuration you wish to set, this merges into the system default `nginx.conf`, as defined in the [documentation for the docker image](https://hub.docker.com/_/nginx), under 'Complex configuration'. (Documentation page doesn't support URL fragments, no ID's!)

### Building

Should you change parts of the docker container, make sure to re-build the containers!

```sh
$ docker-compose build
```

## Reference

This will just have things of reference for the project and a brief explanation on why things exist should it be necessary.

### Ports

Ports are now read out from your `.env` file and will mirror the values defined there. Initially, they will default inline with the contents of `default.env`, until you change them. Below is the relevant excerpt from `default.env` for reference:

```sh
# |-----------|
# | Webserver |
# |-----------|

# 'Docker network' access:
# - Other containers will access via this as it will be on the virtual network.
WEBSERVER_PORT=80

# Localhost/external access:
# - Development machines and any device coming in outside of the virtual network.
WEBSERVER_EXT_PORT=8080
```

### Database Access

Database configuration is now read out from your `.env` file and will mirror the values defined there. Initially, they will default inline with the contents of `default.env`, until you change them. Below is the relevant excerpt from `default.env` for reference:

```sh
# |----------|
# | Database |
# |----------|

# Enforce the connection type so that the MySQL container will
# be used. This is default in Laravel, but worth enforcing.
DB_CONNECTION=mysql

# The host is crucial as it is used to identify the container
# on the local network, Docker exposes this by hostname.
# Doing this ensures the container name and addressable location
# can be kept in sync.
DB_HOST=database

# 'Docker network' access:
# - Other containers will access via this as it will be on the virtual network.
DB_PORT=3306

# Localhost/external access:
# - Development machines and any device coming in outside of the virtual network.
DB_EXT_PORT=3306

# As for the database information, lets keep it the same as Homestead
# to keep things recognisable and easier to work with.
DB_DATABASE=homestead
DB_USERNAME=homestead
DB_PASSWORD=secret
```

## Recommended Packages

Here are a few packages that I highly recommend to take your Laravel project to the next level.

Of course, if you want to take your self to the next level, learn anything new or even top up your skills, there is nothing better than [Laracasts](https://laracasts.com). Its a fantastic resource that is one of the best places on the web to continually learn and keep up with this industry and expand your knowledge.

- [laravel-initializer](https://github.com/mad-web/laravel-initializer)
  - An excellent Laravel plugin that allows you to automate aspects of your Laravel environment, be it setting up a local environment from scratch or deploying to remote production environments.
- [laravel-ide-helper](https://github.com/barryvdh/laravel-ide-helper)
  - This is an excellent tool if using Laravel within an IDE (or VSCode with PHP extensions, [like this one](https://github.com/bmewburn/vscode-intelephense)). It generates class maps for the application and instructs the IDE on how to analyse and traverse your Laravel application.
- [laravel-enum](https://github.com/BenSampo/laravel-enum)
  - A brilliant plugin that does exactly what it says, adds 'enums' to Laravel. Very handy!
- [laravel-package](https://github.com/Jhnbrn90/LaravelPackage.com)
  - Okay, so not a package per-say, but it is an incredible resource on creating them.
- [phpunit-pretty-print](https://github.com/sempro/phpunit-pretty-print)
  - Not Laravel, but a PHPUnit beautifier. Makes it much easier to work with the output.
- [symfony](https://symfony.com/)
  - Again, not Laravel, technically. For those that don't know, Laravel is built on top of the Symfony framework, sharing a lot of its core. It's components are excellent and well documented, would highly recommend seeing if they have a utility class before you create one, they usually do! Saves re-inventing the wheel and keeps things maintainable.
- [laravel-cross-database-subqueries](https://github.com/hoyvoy/laravel-cross-database-subqueries)
  - A mouth full, but does what it says. Laravel has a bug, I think its a bug, where it ignores the models connection definition when using subqueries when its perfectly capable of doing so and I think, is what is expected behavior.
- [laravel-cors](https://github.com/fruitcake/laravel-cors) or [laravel-cors](https://github.com/spatie/laravel-cors)
  - Both have similar implementations, but handle the same thing. Easy management of CORS within your Laravel app, personally I think Laravel should have better handling of this built in.
- [laravel-compass](https://github.com/davidhsianturi/laravel-compass)
  - A superb sub-application that allows for an API consumption client right in as part of your application. This is a fantastic tool that I always install alongside API apps.
- [laravel-airlock](https://github.com/laravel/airlock) or [laravel-passport](https://github.com/laravel/passport)
  - Both authentication layers for your application, for SPA's or just ways to easily integrate OAuth. Either way, well documented first-party plugins that are staple for these use cases.
- [laravel-deployer](https://github.com/lorisleiva/laravel-deployer)
  - A wrapper around [deployer.org](https://github.com/deployphp/deployer) for Laravel, it allows easy access and customisation through Laravel's tool chain. It maps the relevant commands to artisan and places the deployer config within Laravel's for tidiness and scoping. Very handy for semi-autonomous and non-CI/CD deployments!

## Changelog

[View the repo's releases to see the change history](https://github.com/othyn/docker-compose-laravel/releases).
