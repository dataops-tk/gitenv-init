# Expected build ARGs:
# - base_image
# - base_bootstrap

ARG base_image

FROM ${base_image}

ARG base_bootstrap
ARG base_command

ENV BASE_BOOTSTRAP=${base_bootstrap}\
    BASE_COMMAND=${base_command}

# One or more of these may be overriden by settings in
# docker run or docker compose:
ENV GIT_REPO=\
    GIT_USER=\
    GIT_EMAIL=\
    GIT_ACCESS_TOKEN=\
    GIT_NO_PRECOMMIT=\
    GIT_WORKDIR=

# For debugging, print workdir of base image during build
RUN pwd

COPY ./bootstrap.sh /gitenv-bootstrap.sh
COPY ./gitenv-init.sh /gitenv-init.sh

RUN chmod +x /gitenv-bootstrap.sh
RUN chmod +x /gitenv-init.sh

ENTRYPOINT [ "/gitenv-bootstrap.sh" ]
