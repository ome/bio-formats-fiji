#!/usr/bin/env bash
set -e

export WEBDAV_USER=${WEBDAV_USER:-"Bio-Formats"}
export UPDATE_SITE=${UPDATE_SITE:-"Bio-Formats"}

# Define update site variables
export URL=${URL:-"http://sites.imagej.net/$UPDATE_SITE/"}
export LOGIN=${LOGIN:-"webdav:$WEBDAV_USER:$WIKI_UPLOAD_PASS"}
export DIR=${DIR:-"."}

# IJ Installation variables
export IJ_PATH=${IJ_PATH:-"$HOME/Fiji.app"}
export IJ_PLATFORM=${IJ_PLATFORM:-"linux64"}
export IJ_LAUNCHER=${IJ_LAUNCHER:-"${IJ_PATH}/ImageJ-${IJ_PLATFORM}"}
export IJ_ZIP=${ZIP:-"fiji-${IJ_PLATFORM}.zip"}

# Install ImageJ
if [ ! -e "$IJ_PATH" ];
then
    mkdir -p "$IJ_PATH/"
    pushd $HOME/
    wget --no-check-certificate "https://downloads.imagej.net/fiji/latest/$IJ_ZIP"
    unzip "$IJ_ZIP"
    "$IJ_LAUNCHER" --update update-force-pristine
    popd
fi

# Install the package
mvn clean package -Dfiji.home="$IJ_PATH"

# Deploy the package
if [ -z ${SKIPDEPLOY+x} ];
then
    export PATH="$IJ_PATH:$PATH"
    "$IJ_LAUNCHER" --update edit-update-site "$UPDATE_SITE" "$URL" "$LOGIN" "$DIR"
    "$IJ_LAUNCHER" --update upload-complete-site --force-shadow "$UPDATE_SITE"
else
    echo "Skipping deploy..."
fi
