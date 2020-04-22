#!/bin/bash

# filename: install.sh
# author: othyn
# description: Installation script for the docker-compose-laravel repo.
# link: https://github.com/othyn/docker-compose-laravel

##
# Colours.
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
##
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RESET="\033[0m"

##
# Let's begin!
##
clear
printf "[${BLUE}Docker Compose Laravel${RESET}: Project installation]\n"

##
# Helper function for displaying hanging log lines.
##
log() {
    # OPTIONAL: This nicely formats numbers passed as the second param
    if [ "${2}" = "" ]; then
        PRINT_STRING="${1}..."
    else
        PRINT_NUMBER=$(echo "${2}" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')
        PRINT_STRING="${1}: ${PRINT_NUMBER}..."
    fi

    printf "> %-50s" "${PRINT_STRING}"
    #           ^^-- Needs to be set to the length of the longest log message, it's
    #                purely aesthetic, but it aligns all the log termination messages.
}

##
# Flag that the script is processing arguments.
##
log "Processing provided arguments"

##
# Helper functions for displaying termination log lines.
##
logDone() {
    printf "${GREEN}done!${RESET}\n"
}
logError() {
    printf "${RED}error!${RESET}\n"
    printf "${RED}[Error]${RESET} ${1}\n"
    exit $2
}

##
# Helper function for displaying usage instructions.
##
showHelp() {
cat << EOF

    Usage: $0 -l <new-local-repo> [options]

    [required]
    -l      The local directory of the project to Docker-ise.
                E.g. ~/git/new-docker-laravel-project

    [options]
    -r      New, empty, remote repo to setup a new project against.
                E.g. git@github.com:othyn/new-docker-laravel-project.git
    -p      Use HTTPS clone method instead of SSH.
    -f      Force the local directory, if it exists, it will be removed.
    -b      Git branch to checkout on a new installation, defaults to  origin/master.
    -c      Create the branch provided by -b before checking it out on a new installation.
    -h      Brings up this help screen.

EOF
exit 0
}

##
# Set default args.
##
REPO_DOCKER="git@github.com:othyn/docker-compose-laravel.git"
NEW_PROJECT=0
NEW_PROJECT_GIT_BRANCH="origin/master"
NEW_PROJECT_GIT_CREATE_BRANCH=0
REPO_REMOTE=""
REPO_LOCAL=""
USE_FORCE=0

##
# Capture provided command args.
# https://stackoverflow.com/a/24868071/4494375
##
while getopts ":r:l:pfbch" OPT
do
    case $OPT in
        r)
            NEW_PROJECT=1
            REPO_REMOTE="${OPTARG}"
            ;;
        l)
            REPO_LOCAL="${OPTARG}"
            ;;
        p)
            REPO_DOCKER="https://github.com/othyn/docker-compose-laravel.git"
            ;;
        f)
            USE_FORCE=1
            ;;
        b)
            NEW_PROJECT_GIT_BRANCH="${OPTARG}"
            ;;
        c)
            NEW_PROJECT_GIT_CREATE_BRANCH=1
            ;;
        h)
            logDone
            showHelp
            ;;
        \?)
            logError "Invalid option: ${OPTARG}" 1
            ;;
    esac
done

# Validate the local repo option is provided
if [ -z "$REPO_LOCAL" ]; then
    logError "A local repo is required." 1
fi

##
# Complete: Processing arguments.
##
logDone

##
# Check the supplied local directory for existence if a new project has been instructed to be setup.
# We don't want it to exist ideally, but we can handle it if the user has instructed us to do so.
#
# https://superuser.com/questions/363444/how-do-i-get-the-output-and-exit-value-of-a-subshell-when-using-bash-e
##
if [[ -d "${REPO_LOCAL}" ]] && [[ "${NEW_PROJECT}" == "1" ]] ; then
    log "Checking local directory"

    if [[ "${USE_FORCE}" == "0" ]] ; then
        logError "There is already a local directory at '${REPO_LOCAL}' and the force option was not provided. Please provide the '-f' option or remove the directroy first and try again." 1
    else
        # https://superuser.com/a/363454/483484
        # https://stackoverflow.com/a/48734832/4494375
        if ! RESULT=$(rm -rf "${REPO_LOCAL}" 2>&1) ; then
            logError "${RESULT}" $?
        fi
    fi

    logDone
fi

##
# Check the supplied local directory for existence if an existing project integration has been instructed to be setup.
# We need the directory to exist to proceed.
#
# https://superuser.com/questions/363444/how-do-i-get-the-output-and-exit-value-of-a-subshell-when-using-bash-e
##
if [[ ! -d "${REPO_LOCAL}" ]] && [[ "${NEW_PROJECT}" == "0" ]] ; then
    log "Checking local directory"

    logError "The local directory was not found at '${REPO_LOCAL}', the installation cannot proceed." 1

    logDone
fi

##
# Clone the repo.
##
log "Cloning remote to local"
if [[ "${NEW_PROJECT}" == "1" ]] ; then
    if ! RESULT=$(git clone "${REPO_DOCKER}" "${REPO_LOCAL}" 2>&1) ; then
        logError "${RESULT}" $?
    fi
else
    # As we are working with an existing project, we need to stick it somewhere temporarily
    REPO_LOCAL_TEMP="${REPO_LOCAL}_temp"

    if ! RESULT=$(git clone "${REPO_DOCKER}" "${REPO_LOCAL_TEMP}" 2>&1) ; then
        logError "${RESULT}" $?
    fi

    # Copy the docker folder to the actual location from the temp clone
    if [[ -d "${REPO_LOCAL}/docker" ]] ; then
        if ! RESULT=$(rm -rf "${REPO_LOCAL}/docker" 2>&1) ; then
            logError "${RESULT}" $?
        fi
    fi

    if ! RESULT=$(cp -R "${REPO_LOCAL_TEMP}/docker" "${REPO_LOCAL}/docker" 2>&1) ; then
        logError "${RESULT}" $?
    fi

    # Copy the default env file to the actual location from the temp clone
    if [[ -d "${REPO_LOCAL}/default.env" ]] ; then
        if ! RESULT=$(rm -rf "${REPO_LOCAL}/default.env" 2>&1) ; then
            logError "${RESULT}" $?
        fi
    fi

    if ! RESULT=$(cp -R "${REPO_LOCAL_TEMP}/default.env" "${REPO_LOCAL}/default.env" 2>&1) ; then
        logError "${RESULT}" $?
    fi

    # Copy the docker compose file to the actual location from the temp clone
    if [[ -d "${REPO_LOCAL}/docker-compose.yml" ]] ; then
        if ! RESULT=$(rm -rf "${REPO_LOCAL}/docker-compose.yml" 2>&1) ; then
            logError "${RESULT}" $?
        fi
    fi

    if ! RESULT=$(cp -R "${REPO_LOCAL_TEMP}/docker-compose.yml" "${REPO_LOCAL}/docker-compose.yml" 2>&1) ; then
        logError "${RESULT}" $?
    fi

    # Clean up the temp clone
    if ! RESULT=$(rm -rf "${REPO_LOCAL_TEMP}" 2>&1) ; then
        logError "${RESULT}" $?
    fi

    REPO_LOCAL_TEMP=""
fi
logDone

##
# Enter the repo.
##
log "Entering local repo"
if [[ -d "${REPO_LOCAL}" ]] ; then
    cd "${REPO_LOCAL}"
else
    logError "Local directory '${REPO_LOCAL}' does not exist, the clone must have failed. Please try again." 1
fi
logDone

##
# The following steps are new project initialisation, so only need to occur during
# new project setup.
##
if [[ "${NEW_PROJECT}" == "1" ]] ; then
    ##
    # Clean the project of git and a few unnecessary files.
    ##
    log "Cleaning project"
    if ! RESULT=$(rm -rf "${REPO_LOCAL}/.git" 2>&1) ; then
        logError "${RESULT}" $?
    fi
    if ! RESULT=$(rm "${REPO_LOCAL}/install.sh" 2>&1) ; then
        logError "${RESULT}" $?
    fi
    if ! RESULT=$(rm "${REPO_LOCAL}/LICENSE" 2>&1) ; then
        logError "${RESULT}" $?
    fi
    if ! RESULT=$(rm "${REPO_LOCAL}/README.md" 2>&1) ; then
        logError "${RESULT}" $?
    fi
    logDone

    ##
    # Init a new repo.
    ##
    log "Creating a new local repo"
    if ! RESULT=$(git init 2>&1) ; then
        logError "${RESULT}" $?
    fi
    logDone

    ##
    # Set the remote.
    ##
    log "Setting remote"
    if ! RESULT=$(git remote add origin "${REPO_REMOTE}" 2>&1) ; then
        logError "${RESULT}" $?
    fi
    logDone

    ##
    # Fetch remote repos.
    ##
    log "Fetching remote branches"
    if ! RESULT=$(git fetch 2>&1) ; then
        logError "${RESULT}" $?
    fi
    logDone

    ##
    # Create a new branch if required.
    ##
    if [[ "${NEW_PROJECT_GIT_CREATE_BRANCH}" == "1" ]] ; then
        log "Creating new branch '${NEW_PROJECT_GIT_BRANCH}'"
        if ! RESULT=$(git branch ${NEW_PROJECT_GIT_BRANCH} 2>&1) ; then
            logError "${RESULT}" $?
        fi
        logDone
    fi

    ##
    # Checkout and track the required branch.
    ##
    log "Checking out and tracking branch '${NEW_PROJECT_GIT_BRANCH}'"
    if ! RESULT=$(git checkout --track ${NEW_PROJECT_GIT_BRANCH} --force 2>&1) ; then
        logError "${RESULT}" $?
    fi
    logDone
fi

##
# Commit the base docker project.
##
log "Committing base docker project"
if ! RESULT=$(git add . 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(git commit -m "[AUTO] Implement base docker project from ${REPO_DOCKER}." 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Laravel installation steps only required on a new installation.
##
if [[ "${NEW_PROJECT}" == "1" ]] ; then
    ##
    # Create a new Laravel project.
    ##
    log "Creating a new Laravel project"
    if ! RESULT=$(laravel new ${REPO_LOCAL} --force --quiet 2>&1) ; then
        logError "${RESULT}" $?
    fi
    logDone


    ##
    # Commit the the new Laravel project.
    ##
    log "Committing the new Laravel project"
    if ! RESULT=$(git add . 2>&1) ; then
        logError "${RESULT}" $?
    fi
    if ! RESULT=$(git commit -m "[AUTO] Created a new Laravel installation." 2>&1) ; then
        logError "${RESULT}" $?
    fi
    logDone
fi

##
# Get a hold of the default.env values to be merged into the local installation
# .env and env.example files.
#
# https://gist.github.com/judy2k/7656bfe3b322d669ef75364a46327836
##
export $(egrep -v '^#' ${REPO_LOCAL}/default.env | xargs)

##
# Configure the Laravel project.
##
log "Configure the Laravel project"
if ! RESULT=$(sed -i "" -e "/DB_HOST/s/.*/DB_HOST=${DB_HOST}/" "${REPO_LOCAL}/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_HOST/s/.*/DB_HOST=${DB_HOST}/" "${REPO_LOCAL}/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PORT/s/.*/DB_PORT=${DB_PORT}/" "${REPO_LOCAL}/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PORT/s/.*/DB_PORT=${DB_PORT}/" "${REPO_LOCAL}/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_DATABASE/s/.*/DB_DATABASE=${DB_DATABASE}/" "${REPO_LOCAL}/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_DATABASE/s/.*/DB_DATABASE=${DB_DATABASE}/" "${REPO_LOCAL}/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_USERNAME/s/.*/DB_USERNAME=${DB_USERNAME}/" "${REPO_LOCAL}/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_USERNAME/s/.*/DB_USERNAME=${DB_USERNAME}/" "${REPO_LOCAL}/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PASSWORD/s/.*/DB_PASSWORD=${DB_PASSWORD}/" "${REPO_LOCAL}/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PASSWORD/s/.*/DB_PASSWORD=${DB_PASSWORD}/" "${REPO_LOCAL}/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(echo "\n# Docker webserver config\nWEBSERVER_PORT=${WEBSERVER_PORT}\nWEBSERVER_EXT_PORT=${WEBSERVER_EXT_PORT}" >> "${REPO_LOCAL}/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(echo "\n# Docker webserver config\nWEBSERVER_PORT=${WEBSERVER_PORT}\nWEBSERVER_EXT_PORT=${WEBSERVER_EXT_PORT}" >> "${REPO_LOCAL}/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Clean up the temporary default.env file.
##
log "Clean up the temporary default.env file"
if ! RESULT=$(rm "${REPO_LOCAL}/default.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Commit the the Laravel project.
##
log "Committing the Laravel project"
if ! RESULT=$(git add . 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(git commit -m "[AUTO] Configured Laravel installation after installing docker configuration." 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Git push.
##
log "Pushing to remote"
if ! RESULT=$(git push 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# That's it! Magic. 🎉
##
printf "${GREEN}[Installation complete!]${RESET}\n"
