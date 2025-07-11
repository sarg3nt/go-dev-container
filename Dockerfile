# syntax=docker/dockerfile:1

# See: https://hub.docker.com/r/docker/dockerfile.  Syntax directive must be first line
# cspell:ignore

# Mise application list and versions are located in
# home/vscode/.config/mise/config.toml
# Add custom Mise tools and version to your projects root as .mise.toml  See: https://mise.jdx.dev/configuration.html

# https://hub.docker.com/r/jdxcode/mise/tags
# This is latest.
FROM jdxcode/mise@sha256:5a4eb0b7b6687f2f42ad24d37a50e605b6064d4cd051edb3286a30311539715c AS mise

# https://hub.docker.com/r/rockylinux/rockylinux/tags
FROM rockylinux/rockylinux:10-ubi@sha256:eca03145dd5e0b2a281eef164d391e4758b4a5962d29b688d15a72cef712fbb4 AS final

LABEL org.opencontainers.image.source=https://github.com/sarg3nt/go-dev-container

ENV TZ='America/Los_Angeles'

# Here for local builds, not used for main pipeline as the security tools gets snippy.
# ARG GITHUB_API_TOKEN
# ENV GITHUB_API_TOKEN=${GITHUB_API_TOKEN}

# What user will be created in the dev container and will we run under.
# Reccomend not changing this.
ENV USERNAME="vscode"

# Copy script libraries for use by internal scripts
COPY usr/bin/lib /usr/bin/lib

# Install packages using the dnf package manager
RUN --mount=type=bind,source=scripts/10_install_system_packages.sh,target=/10.sh,ro bash -c "/10.sh"

# Set current user to the vscode user, run all future commands as this user.
USER vscode

# Copy the mise binary from the mise container
COPY --from=mise /usr/local/bin/mise /usr/local/bin/mise

# Copy just files needed for mise from /home.
COPY --chown=vscode:vscode home/vscode/.config/mise /home/vscode/.config/mise

# These are only used in 30_install_mise_packages.sh so do not need to be ENV vars.
ARG MISE_VERBOSE=0
ARG RUST_BACKTRACE=0
RUN --mount=type=bind,source=scripts/20_install_mise_packages.sh,target=/20.sh,ro bash -c "/20.sh"
RUN --mount=type=bind,source=scripts/30_install_other_apps.sh,target=/30.sh,ro bash -c "/30.sh"

COPY --chown=vscode:vscode home /home/
COPY usr /usr

# VS Code by default overrides ENTRYPOINT and CMD with default values when executing `docker run`.
# Setting the ENTRYPOINT to docker_init.sh will configure non-root access to
# the Docker socket if "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/bin/docker_init.sh" ]
CMD [ "sleep", "infinity" ]

