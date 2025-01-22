#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  if [[ -z "${REGISTRY:-}" ]]; then
    echo "Error: REGISTRY is not set."
    exit 1
  fi

  if [[ -z "${REPOSITORY:-}" ]]; then
    echo "Error: REPOSITORY is not set."
    exit 1
  fi

  latest_version=$(gh api "/repos/${REPOSITORY}/releases/latest" | jq -r '.tag_name')
  echo "Latest Version from Releases: $latest_version"
  # Github runner does not print empty echos. :(
  echo "-"

  echo "Finding the latest tag version and setting major, minor, patch and new_patch."
  # This auto populates the special env var BASH_REMATCH with Bash magic.
  if [[ ! $latest_version =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Could not determine the latest tag version."
    exit 1
  fi 

  major=${BASH_REMATCH[1]}
  echo "Major: $major"
  minor=${BASH_REMATCH[2]}
  echo "Minor: $minor"
  patch=${BASH_REMATCH[3]}
  echo "Old Patch: $patch"
  new_patch=$((patch + 1))
  echo "New Patch: $new_patch"

  tag_major="${REGISTRY}/${REPOSITORY}:${major}"
  tag_minor="${REGISTRY}/${REPOSITORY}:${major}.${minor}"
  tag_patch="${REGISTRY}/${REPOSITORY}:${major}.${minor}.${new_patch}"
  tag_old="${REGISTRY}/${REPOSITORY}:${major}.${minor}.${patch}"
  tag_latest="${REGISTRY}/${REPOSITORY}:latest"

  echo "TAG_MAJOR: $tag_major"
  echo "TAG_MAJOR=$tag_major" >>"$GITHUB_ENV"
  echo "TAG_MINOR: $tag_minor"
  echo "TAG_MINOR=$tag_minor" >>"$GITHUB_ENV"
  echo "TAG_PATCH: $tag_patch"
  echo "TAG_PATCH=$tag_patch" >>"$GITHUB_ENV"
  echo "TAG_LATEST: $tag_latest"
  echo "TAG_LATEST=$tag_latest" >>"$GITHUB_ENV"
  echo "TAG_OLD: $tag_old"
  echo "TAG_OLD=$tag_old" >>"$GITHUB_ENV"

  new_version="v${major}.${minor}.${new_patch}"
  echo "New Version: $new_version"
  echo "VERSION=$new_version" >>"$GITHUB_ENV"

}

if ! (return 0 2>/dev/null); then
  (main "$@")
fi
