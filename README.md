# `gitenv-init`

A simple script to initialize git using provided environment variables.
Designed and optimized for dockerized scenarios.

- [gitenv-init.sh](gitenv-init.sh)

## Other tools used here

- `Dockerfile` - Wraps another docker image without changing the original image.
- `bootstrap.sh` - Works with the provided Dockerfile, or as a starting point to copy into your own Docker images.
- `pre-commit` - The widely loved [`pre-commit`](https://pre-commit.com/) tool is automatically
  installed unless you specify `GIT_NO_PRECOMMIT`. This means that if your repo has a
  `.pre-commit-config.yaml` file, it will be applied automatically.

## Example usage

These examples use [Meltano](meltano.com) as the base image.

### Test locally

```bash
export GIT_REPO=gitlab.com/meltano/singerhub
export GIT_REF=meltano-project
export GIT_WORKDIR=meltano

export GIT_USER=myname
export GIT_EMAIL=myname@example.com

# Only one of these is required:
export GIT_ACCESS_TOKEN=<token-secret>
export GIT_SSH_PRIVATE_KEY="$(cat /path/to/keyfile)"  # SSH not yet supported

# Build and run the image:
docker build --build-arg base_image=meltano/meltano:latest --build-arg base_bootstrap=meltano --build-arg base_command=ui -t mymelt .
docker run -it --rm -p 5000:5000 -e GIT_REPO -e GIT_REF -e GIT_USER -e GIT_EMAIL -e GIT_WORKDIR -e GIT_ACCESS_TOKEN --name meltui mymelt
```

### Committing changes back to git

Many UIs are not yet git aware. This means changes applied within the UI
cannot be directly committed and pushed back to git unless the user logs into a terminal.

Here is code to do this when running the docker image locally. This expects that
meltano was launched via the docker instruction above and is still running:

```bash
docker exec -i meltui bash
```

After connecting to the container:

```bash
cd /project/*
pwd

# Show what has changed:
git status
git diff --cached

# Optionally make a small test change:
echo "\n" >> README.md

### TODO: The part to add to Meltano UI
# Stage anything changed:
git add -A
# Test ability to commit:
git commit -m "meltano-ui changes, '$(date -Iseconds)'"
# Test ability to push:
git push
```

### Create an SSH keypair for your containers

- [ ] TODO: Note that SSH keypair support is not yet enabled automatically by the script. That said, you can probably get it working if you already know what you are doing. (Same rules apply as other environments.)

To generate an SSH key, run this locally:

```bash
export SSH_KEYNAME=meltano-containers
# Generates key files in user's profile folder (~/.ssh):
#   '~/.ssh/meltano-containers-ssh'
#   '~/.ssh/meltano-containers-ssh.pub'
ssh-keygen -t rsa -b 4096 -f ~/.ssh/$SSH_KEYNAME-ssh -C "SSH Key for $SSH_KEYNAME" -q -N ""
```

## Wrap in your own Dockerfile

If you are building a new image, you can wrap these tools as in the following example:

`Dockerfile`

```Dockerfile
FROM meltano/meltano

WORKDIR /

# Install the latest 'gitenv-init' scripts
ENV GITENV_FILE_ROOT=https://raw.githubusercontent.com/dataops-tk/gitenv-init/main
RUN wget ${GITENV_FILE_ROOT}/gitenv-init.sh
RUN wget ${GITENV_FILE_ROOT}/gitenv-bootstrap.sh
RUN chmod +x /gitenv-bootstrap.sh
RUN chmod +x /gitenv-init.sh
ENTRYPOINT [ "/gitenv-bootstrap.sh" ]

# Meltano-specific steps here:

# Install the Meltano boostrap script
COPY ./bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh

WORKDIR /project

# Set our bootstrap script to run within gitenv-bootstrap.sh
ENV BASE_BOOTSTRAP=/bootstrap.sh
CMD ["ui"]
```

Note that the `gitenv-bootstrap.sh` script will call any provided custom
bootstrap script via the `BASE_BOOTSTRAP` environment variable.
