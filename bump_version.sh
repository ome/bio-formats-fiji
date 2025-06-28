#!/bin/bash
# 
# This script bumps the version of the application and Bio-Formats
# Specify the release version as a parameter.
# If the boolean ZARR is set to true, the version will be bumped to the
# latest release of the OMEZarrReader
# The script assumes that Maven and git are installed.

set -e -u -x


# Variables
RELEASE=$1
ZARR=${ZARR:-"false"}
TAG=${TAG:-"false"}
message="Bump Bio-Formats version to $RELEASE"

mvn versions:set -DnewVersion=$RELEASE -DgenerateBackupPoms=false
mvn versions:set-property -Dproperty=bioformats.version -DnewVersion=$RELEASE -DgenerateBackupPoms=false

if [ "$ZARR" = true ]; then
	# Retrieve the latest release of the OMEZarrReader
	url="https://artifacts.openmicroscopy.org/artifactory/ome.releases/ome/OMEZarrReader/"
    zarr_version=`curl -s ${url}/maven-metadata.xml | grep latest | sed "s/.*<latest>\([^<]*\)<\/latest>.*/\1/"`
	mvn versions:set-property -Dproperty=omezarrreader.version -DnewVersion=$zarr_version -DgenerateBackupPoms=false
	message="$message and OMEZarrReader to $zarr_version"
fi
# commit the changes
git add -u
git commit -m "$message"
if [ "$TAG" = true ]; then
	git tag -s v$RELEASE -m "$message"
fi
