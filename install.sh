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
printf "[${BLUE}Docker Compose Laravel${RESET}: New project installation]\n"

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

    printf "> %-36s" "${PRINT_STRING}"
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

    Usage: $0 -r <new-remote-repo> -l <new-local-repo> [options]

    [required]
    -r      New, empty, remote repo to setup the new project against.
                E.g. git@github.com:othyn/new-docker-laravel-project.git
    -l      The new local directory this new project should reside in.
                E.g. ~/git/new-docker-laravel-project

    [options]
    -p      Use HTTPS clone method instead of SSH.
    -f      Force the local directory, if it exists, it will be removed.
    -h      Brings up this help screen.

EOF
exit 0
}

##
# Set default args.
##
REPO_DOCKER="git@github.com:othyn/docker-compose-laravel.git"
REPO_REMOTE=""
REPO_LOCAL=""
USE_FORCE=0

##
# Capture provided command args.
# https://stackoverflow.com/a/24868071/4494375
##
while getopts ":r:l:pfh" OPT
do
    case $OPT in
        r)
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
        h)
            logDone
            showHelp
            ;;
        \?)
            logError "Invalid option: ${OPTARG}" 1
            ;;
    esac
done

# Validate the remote repo option is provided
if [ -z "$REPO_REMOTE" ]; then
    logError "A remote repo is required." 1
fi

# Validate the local repo option is provided
if [ -z "$REPO_LOCAL" ]; then
    logError "A local repo is required." 1
fi

##
# Complete: Processing arguments.
##
logDone

##
# Check the supplied local directory.
#
# https://superuser.com/questions/363444/how-do-i-get-the-output-and-exit-value-of-a-subshell-when-using-bash-e
##
log "Checking local directory"
if [[ -d "${REPO_LOCAL}" ]] ; then
    if [[ "${USE_FORCE}" == "0" ]] ; then
        logError "There is already a local directory at '${REPO_LOCAL}' and the force option was not provided. Please provide the '-f' option or remove the directroy first and try again." 1
    else
        # https://superuser.com/a/363454/483484
        # https://stackoverflow.com/a/48734832/4494375
        if ! RESULT=$(rm -rf "${REPO_LOCAL}" 2>&1) ; then
            logError "${RESULT}" $?
        fi
    fi
fi
logDone

##
# Clone the repo.
##
log "Cloning remote to local"
if ! RESULT=$(git clone "${REPO_DOCKER}" "${REPO_LOCAL}" 2>&1) ; then
    logError "${RESULT}" $?
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
# Clean the project of git and a few unnecessary files.
##
log "Cleaning project"
if ! RESULT=$(rm -rf ".git" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(rm ".env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(rm "install.sh" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(rm "update.sh" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(rm "LICENSE" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(rm "README.md" 2>&1) ; then
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
# Checkout and track remote repo.
##
log "Checking out and tracking remote"
if ! RESULT=$(git checkout --track origin/master --force 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Commit the base docker project.
##
log "Committing base docker project"
if ! RESULT=$(git add . 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(git commit -m "[AUTO] Initial commit. Base docker project from ${REPO_DOCKER}." 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Create a new Laravel project.
##
log "Creating a new Laravel project"
if ! RESULT=$(laravel new "src" --force --quiet 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Configure new Laravel project.
##
log "Configure new Laravel project"
if ! RESULT=$(sed -i "" -e "/DB_HOST/s/.*/DB_HOST=database/" "src/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_HOST/s/.*/DB_HOST=database/" "src/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PORT/s/.*/DB_PORT=3306/" "src/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PORT/s/.*/DB_PORT=3306/" "src/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_DATABASE/s/.*/DB_DATABASE=homestead/" "src/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_DATABASE/s/.*/DB_DATABASE=homestead/" "src/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_USERNAME/s/.*/DB_USERNAME=homestead/" "src/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_USERNAME/s/.*/DB_USERNAME=homestead/" "src/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PASSWORD/s/.*/DB_PASSWORD=secret/" "src/.env.example" 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(sed -i "" -e "/DB_PASSWORD/s/.*/DB_PASSWORD=secret/" "src/.env" 2>&1) ; then
    logError "${RESULT}" $?
fi
logDone

##
# Commit the new Laravel project.
##
log "Committing new Laravel project"
if ! RESULT=$(git add . 2>&1) ; then
    logError "${RESULT}" $?
fi
if ! RESULT=$(git commit -m "[AUTO] Installed Laravel in './src'." 2>&1) ; then
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
