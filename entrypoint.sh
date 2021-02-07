#!usr/bin/env bash

# get the release channel provided by the github action
channel=${INPUT_CHANNEL}
buildNumber=${INPUT_BUILDNUMBER}

# return on empty channel (should be covered by github action)
if [ -z "$channel" ]; then
  echo "A release channel is required to use this action"
  exit 1
fi
echo $channel
echo $buildNumber

getOperatingSystem() {
  case "$OSTYPE" in
  solaris*) var_executing_system="SOLARIS" ;;
  darwin*) var_executing_system="OSX" ;;
  linux*) var_executing_system="LINUX" ;;
  bsd*) var_executing_system="BSD" ;;
  msys*) var_executing_system="WINDOWS" ;;
  *) var_executing_system="unknown: $OSTYPE" ;;
  esac
}

# ** Get the current version from package.json ** #
packageVersion=$(cat package.json | grep version | tr -cd "[[:digit:].]") # get only the numbers from the package json version x.x.x
oldVersion=$(cat package.json | grep version)                             # "version": "x.x.x"
if [[ -z "$buildNumber" ]]; then
  newVersion="  \"version\": \"$packageVersion-$channel\"," # this outputs to --> "version": "x.x.x-channel"
else
  newVersion="  \"version\": \"$packageVersion-$channel.$buildNumber\"," # this outputs to -->  "version": "x.x.x-channel.buildNumber"
fi

getOperatingSystem

# ** replacement based on os runner ** #
if [ "${var_executing_system}" = "OSX" ]; then
  # Replace in package.json
  sed -i '' -e 's/'"$oldVersion"'/'"$newVersion"'/' package.json
else
  # Replace in package.json
  sed -i -e 's/'"$oldVersion"'/'"$newVersion"'/' package.json
fi

echo "::set-output name=version::$newVersion"
