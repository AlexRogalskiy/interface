#!/usr/bin/env bash
set -exo pipefail

TEST_VERSION="0.1.0-test"
sbt \
  +test \
  +evictionCheck \
  +compatibilityCheck \
  'set version in ThisBuild := "'"$TEST_VERSION"'"' \
  publishLocal

# test that things work from JDK 11
# not actually building things from it, running into weird proguard issues…

CS_VERSION="2.0.0-RC6-21"

DIR="$HOME/.cache/coursier/launchers/$CS_VERSION"

CS="$DIR/cs"
if [ ! -x "$CS" ]; then
  DIR="$(dirname "$CS")"
  rm -rf "$DIR" # remove any former launcher
  mkdir -p "$DIR"
  curl -Lo "$CS" "https://github.com/coursier/coursier/releases/download/v$CS_VERSION/cs-x86_64-pc-linux"
  chmod +x "$CS"
fi

TEST_JDK="adopt:1.11.0-7"
eval "$("$CS" java --jvm "$TEST_JDK" --env)"

java -Xmx32m -version

export TEST_VERSION
sbt test
