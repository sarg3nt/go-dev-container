# syntax=docker/dockerfile:1

# See: https://hub.docker.com/r/docker/dockerfile.  Syntax directive must be first line
# cspell:ignore FUMPT

# Mise application list and versions are located in
# home/vscode/.config/mise/config.toml
# Add custom Mise tools and version to your projects root as .mist.toml  See: https://mise.jdx.dev/configuration.html

FROM jdxcode/mise@sha256:f1e31ce5ef09b18e9766912fbbc401dbe9691f760a32972f284a089dced00d44 AS mise

FROM rockylinux:9@sha256:d7be1c094cc5845ee815d4632fe377514ee6ebcf8efaed6892889657e5ddaaa6 AS final

LABEL org.opencontainers.image.source=https://github.com/sarg3nt/go-dev-container

ENV TZ='America/Los_Angeles'

# What user will be created in the dev container and will we run under.
# Reccomend not changing this.
ENV USERNAME="vscode"

# Copy script libraries for use by internal scripts
COPY usr/bin/lib /usr/bin/lib

# COPY scripts directory
COPY scripts /scripts

# Install packages using the dnf package manager
RUN /scripts/10_install_system_packages.sh

# Install the devcontainers features common-utils scripts from https://github.com/devcontainers/features
# Installs common utilities and the USERNAME user as a non root user
RUN /scripts/20_install_microsoft_dev_container_features.sh

# Set current user to the vscode user, run all future commands as this user.
USER vscode

# Copy the mise binary from the mise container
COPY --from=mise /usr/local/bin/mise /usr/local/bin/mise

# Install applications that are scoped to the vscode user
RUN sudo chown vscode /scripts 

# Copy just files needed for mise from /home.
COPY --chown=vscode:vscode home/vscode/.config/mise /home/vscode/.config/mise

# These are only used in 30_install_mise.sh so do not need to be ENV vars.
ARG MISE_VERBOSE=0
ARG RUST_BACKTRACE=0
# https://github.com/jdx/mise/releases
RUN /scripts/30_install_mise_packages.sh

# https://github.com/go-delve/delve/releases
ARG GO_DELVE_DLV_VERSION="1.23.1"
# https://github.com/mvdan/gofumpt/releases
ARG GO_FUMPT_VERSION="0.7.0"
RUN /scripts/40_install_other_apps.sh

RUN sudo rm -rf /scripts

COPY --chown=vscode:vscode home /home/

COPY usr /usr

# VS Code by default overrides ENTRYPOINT and CMD with default values when executing `docker run`.
# Setting the ENTRYPOINT to docker_init.sh will configure non-root access to
# the Docker socket if "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/bin/docker_init.sh" ]
CMD [ "sleep", "infinity" ]

