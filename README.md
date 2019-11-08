# 🐳 Docker Compose for Laravel 🐘
A Docker Compose setup for Laravel projects, inspired by [this repo](https://github.com/aschmelyun/docker-compose-laravel).

## Table of contents
* [Docker Compose for Laravel](#-docker-compose-for-laravel-)
* [Table of contents](#table-of-contents)
* [Setup](#setup)
  * [Prerequisites](#prerequisites)
  * [New Project](#new-project)
  * [Existing Project](#existing-project)
    * [Update an Existing Project](#update-an-existing-project)
* [Usage](#usage)
  * [Composer](#composer)
  * [Yarn](#yarn)
* [Configuration](#configuration)
  * [Services](#services)
    * [.env](#.env)
    * [app](#app)
    * [database](#database)
    * [webserver](#webserver)
  * [Building](#building)
* [Reference](#reference)
  * [Ports](#ports)
* [Changelog](#changelog)

## Setup
Setup is fairly straight forward, there are no installation steps for the project itself, just ensure that the prerequisites are met and you are off to the races!

### Prerequisites
Ensure that [Docker is installed](https://docs.docker.com/docker-for-mac/install/) and up to date on your system. Once installed, configure with your required preferences and ensure it is running. Make sure you are logged in to Docker Hub via the app so that it can download the container images.

### New Project
Create a new repo on GitHub, or your git host of choice. Once created, grab and save the remote for later. This will be my example, created the remote and ready to use.

```
New remote: git@github.com:othyn/new-docker-laravel-project.git
```

If it is a new project, clone this repo to a desired directory, making sure that the directory aligns with the new repo name (not essential, but good practice):

```bash
$ git clone git@github.com:othyn/docker-compose-laravel.git ~/git/new-docker-laravel-project
```

Once cloned, time to alter the remote to point at your new project and set the new upstream branch. We will now need that remote you saved to one side earlier:

```bash
$ cd ~/git/new-docker-laravel-project
$ git remote set-url origin git@github.com:othyn/new-docker-laravel-project.git
$ git push -u origin master
```

Awesome, so we now have a new working project directory, you can use the [Laravel installation tool](https://laravel.com/docs/master/installation#installing-laravel) and follow the [Laravel configuration steps](https://laravel.com/docs/master/installation#configuration) to create a new project in the `src` directory:

```bash
$ cd ~/git/new-docker-laravel-project
$ laravel new src --force
```

Now you can get to building that Laravel app you've always wanted to.

That's it! Magic. 🎉

### Existing Project
For existing projects, its as complicated as adding a git submodule and runnnig an installation script. Let's begin! Firstly, add this git repo as a submodule to the existing project:

```bash
$ cd ~/git/existing-docker-laravel-project
$ git submodule add git@github.com:othyn/docker-compose-laravel.git docker
```

Excellent! That has now added the repo as a submodule, although be sure to commit the addition. You can now view that submodule it in the project's root directory as with any other directory. Now, let's run that installation script:

```bash
$ docker/install.existing.sh
```

The installation script does one of two things. First, it creates a working copy of that `.env` file for you.

That's it! Magic. 🎉

#### Update an Existing Project

To update the submodule in future, use the following command:

```bash
$ cd ~/git/existing-docker-laravel-project
$ git submodule update --remote --merge
$ docker/install.existing.sh
```

That will download and merge the latest version of the submodule repo, then run the installation script to ensure that the module has all of the update steps run.

That's it! Magic. 🎉

## Usage
Once the project has been [Setup](#setup), it's very simple to use. Lauch docker composer from within the root directory of the project if it is a **new project**. If it is an **existing project**, first `cd` into the `docker` directory, the directory containing the submodule contents. As long as you are in the directory containing the `docker-compose.yml` file in it, away you go! The first time it is run, docker will build the containers, so it may take a little while longer.

```bash
$ docker-compose up
```

If you wish to run them in the background, in `detached` mode so that they don't remain as open processes within your terminal window, add the `-d` flag to the end of the command `$ docker-compose up -d`.

If you wish to detach from an already running `$ docker-compose up`, use `CTRL` + `Z`, that will suspend the process into the background. When in the background it becomes part of the `jobs` queue. You can view them and their `[id]` using the following command:

```bash
$ jobs
> [1]  + suspended  docker-compose up
#  ^ That is the ID of the process.
```

Then to get back to a background job, use its ID prefixed with a percent sign in the following command, it will return the process to the foreground:

```bash
$ fg %1
#     ^ That is the ID of the process.
```

To instead kill a background task, run the following, using that process ID that we had from before:

```bash
$ kill -KILL %1
#             ^ That is the ID of the process.
```

To re-attach to the docker logs whilst the process is suspended or `detached` (the output that `$ docker-compose up` would usually sit you at), run the following:

```bash
$ docker-compose logs -f -t
```

That will attach you back to the logs. To do this for a specific container, add the container name to the end of the command:

```bash
$ docker-compose logs -f -t <container>
# <container> can be any running container. e.g. webserver, database or app
```

To run a command in a running the container:

```bash
$ docker-compose exec <container> <command>
# <container> can be any running container. e.g. webserver, database or app
# <command> can be any command. e.g. 'top' or 'sh' (Alpine) / 'bash' (Ubuntu) to enter an interactive shell
```

To stop the containers, if they are attached simply press `CTRL` + `C` which is the escape sequence for any CLI application. That should gracefully stop them, if it aborts or the containers are running in `detached` mode, do the following:

```bash
$ docker-compose down
```

You can use `stop` instead of `down` to just stop the running container. The above command, `down`, will both stop and remove the container and its associated networks. You can also specify `--volumes` as an additional flag to remove any associated volumes, and the `--rmi <all|local>` flag to remove associated images.

### Composer
There is a composer image also built into the Docker Compose stack, allowing composer to automatically run on your project when the `$ docker-compose up` command is run. Although, if you wish to run a `$ composer install` at any point manually, you can just run:

```bash
$ docker-compose run --rm composer
```

This is because we haven't provided a command to run, so `$ docker-compose run` will `run` the `command` that is listed against the `composer` `service` defined in `docker-compose.yml`. The `--rm` flag will simply clean up the container that it has used to run the command after its been executed. If you wish to run any other composer commands with this, go ahead and do so, some examples:

```bash
$ docker-compose run --rm composer composer update                      # to update composer dependencies
$ docker-compose run --rm composer composer install <new dependency>    # to install new composer dependencies
$ docker-compose run --rm composer composer remove <old dependency>     # to remove old composer dependencies
```

### Yarn
There is a node image also built into the Docker Compose stack, allowing yarn to automatically run on your project when the `$ docker-compose up` command is run. Although, if you wish to run a `$ yarn install` at any point manually, you can just run:

```bash
$ docker-compose run --rm node
```

This is because we haven't provided a command to run, so `$ docker-compose run` will `run` the `command` that is listed against the `node` `service` defined in `docker-compose.yml`. The `--rm` flag will simply clean up the container that it has used to run the command after its been executed. If you wish to run any other yarn commands with this, go ahead and do so, some examples:

```bash
$ docker-compose run --rm node yarn upgrade                     # to update yarn dependencies
$ docker-compose run --rm node yarn install <new dependency>    # to install new yarn dependencies
$ docker-compose run --rm node yarn remove <old dependency>     # to remove old yarn dependencies
$ docker-compose run --rm node yarn <scripts>                   # run any package.json scripts, e.g. dev, watch, hot, build, prod|production, etc.
```

## Configuration
There are elements of this docker project that you can configure for you project if you require extra functionality. Obviously, at the end of the day this is just a bog standard Docker project, so you can go to town with any changes you wish. But these are the main areas that are easy adaptable.

### Services
This is the configuration for all of the core services that are configured; `app`, `composer`, `database`, `node` and `webserver`. All the services configuration is, as usual, located in their declaration within the `docker-compose.yml` in the project root, and if necessary, accompanied also by a directory with the service name in the `docker` directory, within the root directory.

### .env
There is a `.env` file that is currently optional for the project to run on [New Projects](#new-project), but essential to run on [Existing Projects](#existing-project) (see installation steps).

By default, for new installations, the `.env` file won't exist, as at the moment all variables contained within it aren't required for new installations and it saves unnecessary setup steps. Although can be used if you do a quick:

```bash
$ cd ~/git/existing-docker-laravel-project/docker
$ cp .env.example .env
```

Although, this is already done during the setup of an [Existing Project](#existing-project) and again, is not required unless you need to change one of the following values:

`APP_PATH`
```env
### ### ### ### ### ### ### ### ###
# Point to the path of your Laravel
# application code on the host.
#
#        New app: <blank>
#   Existing app: ../
#
APP_PATH=../
### ### ### ### ### ### ### ### ###
```

As the `.env` file won't exist for new installations, it defaults in the `docker-compose.yml` to use the `./src` directory. So, due to this behaviour, it makes sense to save a step for setup on existing projects to default the `.env` file to have the `APP_PATH` defined as the required parent directory as it will only exist on [Existing Project](#existing-project) installations. Saving you a step!

#### app
The `dockerfile` for the `app` contains all provisioning steps within the build process for the container, so add anything you wish to be built into it in there, as per the Docker docs.

The `entrypoint.sh` script is copied in and executed when the container is brought `up`, so this runs things like `artisan` commands (migrations, seeders, etc.) and such to get Laravel in a ready state. Add anything in to this file that you need running every time the container is upped, not built.

The `php.ini` file is any PHP ini configuration you wish to set, this overwrites the system default `php.ini`.

#### database
The `persist` directory is volume mapped to the MySQL directory on the docker container, so that the containers DB is persisted across container instances.

The `base.sql` patch file is run by the MySQL Docker container when its upped, so place any SQL statements in there that you wish to be run. E.g. creating databases.

The `mysql.conf` file is any MySQL configuration you wish to set, this overwrites the system default `mysql.conf`.

#### webserver
The `nginx.conf` file is any NGINX configuration you wish to set, this overwrites the system default `nginx.conf`.

### Building
Should you change parts of the docker container, make sure to re-build the containers!

```bash
$ docker-compose build
```

## Reference
This will just have things of reference for the project and a brief explanation on why things exist should it be necessary.

### Ports
Here are the exposed port maps for the containers:

| Service   | Host Port | Container Port |
|-----------|-----------|----------------|
| webserver | 8080      | 80             |
| database  | 3306      | 3306           |
| app       | 9000      | 9000           |

## Changelog
[View the repo's releases to see the change history](https://github.com/othyn/docker-compose-laravel/releases).
