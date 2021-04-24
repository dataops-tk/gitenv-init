#!/bin/bash

set -e  # abort on error

echo -e "\n\nRunning 'gitenv-init.sh' script to initialize Git environment and credentials...\n"

if [[ -z "$GIT_NO_PRECOMMIT" ]]; then
  echo "Installing pre-commit for git."
  echo "To skip this install in the future, set GIT_NO_PRECOMMIT to any non-zero value."
  python -m pip install pre-commit
else
  echo "Skipping installing pre-commit for git (GIT_NO_PRECOMMIT=$GIT_NO_PRECOMMIT)."
fi

if [[ -z "$GIT_REPO" ]]; then
  echo "Did not find GIT_REPO. Skipping git clone..."
else
  echo -e "Found: GIT_REPO=$GIT_REPO\nAttempting to clone..."
  if [[ ! -z "$GIT_USER" ]]; then
    export GIT_URL="https://$GIT_USER@$GIT_REPO.git"
  else
    export GIT_URL="https://$GIT_REPO"
  fi
  echo "Attempting to clone from GIT_URL: $GIT_URL"
  git clone $GIT_URL;
  cd "$(basename $GIT_REPO)";
  if [[ ! -z "$GIT_REF" ]]; then
    git checkout $GIT_REF;
  fi;
  if [[ ! -z "$GIT_EMAIL" ]]; then
    echo "Setting git email to '$GIT_EMAIL'..."
    git config --global user.email $GIT_EMAIL
  else
    echo "WARNING: no value detected for GIT_EMAIL environment variable."
  fi
  if [[ ! -z "$GIT_ACCESS_TOKEN" ]]; then
    echo "Found GIT_ACCESS_TOKEN. Initializing as git password."
    git config --global credential.helper '!f() { echo "password=$GIT_ACCESS_TOKEN"; }; f'
  else
    echo "WARNING: no access token or private key file detected."
  fi
fi;
