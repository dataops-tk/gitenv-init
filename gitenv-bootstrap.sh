#!/bin/bash

# Generic bootstrap script for docker.
# To nest another boostrap script, set BASE_BOOTSTRAP and/or BASE_COMMAND

set -e  # abort on error

echo "Working directory is '$(pwd)'."

/gitenv-init.sh   # Clone repo and initialize git credentials

if [[ ! -z "$GIT_REPO" ]]; then
  cd "$(basename $GIT_REPO)";
  echo "Changed working directory to cloned repo root: $(pwd)";
  if [[ ! -z "$GIT_WORKDIR" ]]; then
    echo "Changing working directory (GIT_WORKDIR=$GIT_WORKDIR)...";
    cd $GIT_WORKDIR
  fi
fi

# In case we are wrapping another docker image, call
# the relevant bootstrap and/or command from the base
# image. Otherwise execute any provided arg(s) directly
# as commands.

if [[ ! -z "$@" ]]; then
  BASE_COMMAND=$@
fi
if [[ ! -z "$BASE_BOOTSTRAP" ]]; then
  echo "Calling base bootstrapper with '$BASE_BOOTSTRAP $@'..."
  $BASE_BOOTSTRAP $BASE_COMMAND
else
  echo "Calling '$BASE_COMMAND' from bootstrap script..."
  $@
fi
