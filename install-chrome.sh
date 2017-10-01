#!/bin/bash

set -e

echo_red() {
  printf "\033[0;31m%s\033[0m\n" "$@"
}
echo_green() {
  printf "\033[0;32m%s\033[0m\n" "$@"
}
echo_cyan() {
  printf "\033[0;36m%s\033[0m\n" "$@"
}

# Some helptext when things go awry.
usage() {
	echo_red "Usage: $0 install_prefix"
}

deps() {
  command -v jq >/dev/null 2>&1 || { echo_red >&2 "I need jq but it's not installed.  Aborting."; exit 1; }
  command -v curl >/dev/null 2>&1 || { echo_red >&2 "I need curl but it's not installed.  Aborting."; exit 1; }
  command -v unzip >/dev/null 2>&1 || { echo_red >&2 "I need unzip but it's not installed.  Aborting."; exit 1; }
}

handle_args() {
  # Handle wrong number of  args being passed.
  [ $# -ne 1 ] && { usage $@; exit 1;}

  # Find the directory we want no longer to be duppy.
  install_prefix=$(realpath $1)
  if [ ! -d $install_prefix ]; then
    echo_red "The target directory '${install_prefix}' was not found."
    usage
    exit 1
  fi

  # Find the latest revision and generate the URL to download.
  # There is a known good copy @ https://www.dropbox.com/s/xqv919485gpdrdi/chrome-linux.zip?dl=0
  LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"
  LATEST_REVISION=$(curl -s -S $LASTCHANGE_URL)
  TARGET_REVISION=505518
  CHROME_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$TARGET_REVISION%2Fchrome-linux.zip?alt=media"

  TEMP_DIRECTORY=/tmp
  CHROME_DOWNLOAD=$TEMP_DIRECTORY/chrome.zip
  CHROME_PATH=$install_prefix/chrome-linux/chrome
}

install(){
  echo_cyan "'${LATEST_REVISION}' is the latest available revision. Build '${TARGET_REVISION}' will be downloaded from: '${CHROME_URL}'..."
  #curl -L $CHROME_URL | jq .mediaLink | xargs curl -L -o $CHROME_DOWNLOAD
  curl -L -o $CHROME_DOWNLOAD $CHROME_URL
  echo_cyan "Done."

  echo_cyan "Unzipping '${CHROME_DOWNLOAD}'..."
  unzip -o -qq $CHROME_DOWNLOAD -d $TEMP_DIRECTORY
  echo_cyan "Done."

  echo_cyan "Install to ${install_prefix}..."
  mv $TEMP_DIRECTORY/chrome-linux $install_prefix/
  echo_cyan "Done."

  if [[ ! -f $CHROME_PATH ]]; then
    echo_red "Chrome was not where we thought it would be... Please make sure download URL is correct."
    exit 1
  else
    export CHROME_PATH=$CHROME_PATH
    echo_green "Chrome was installed at '${CHROME_PATH}'."
    echo_cyan "Removing downloaded file '${CHROME_DOWNLOAD}'..."
    rm $CHROME_DOWNLOAD
    echo_cyan "Done."
    exit 0
  fi
}

# Script entrypoint
main() {
  deps
  handle_args $@
  install
}

main "$@"
