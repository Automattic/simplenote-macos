#!/bin/bash

#
# Builds a new version of the Sparkle framework and copies the necessary files
#

set -e

# Create a temporary directory where to fetch and build Sparkle
basename=`basename $0`
WORKDIR=`mktemp -q -d ${TMPDIR}${basename}.XXXXXX`
if [ $? -ne 0 ]; then
  echo "$0: Can't create temp directory at $WORKDIR, exiting..."
  exit 1
fi

pushd $WORKDIR > /dev/null

# Clone Sparkle and checkout the 2.x branch
git clone git@github.com:sparkle-project/Sparkle
cd Sparkle
git fetch
# Use `git checkout <sha>` to go to a certain commit, e.g.:
# `git checkout 4767ef60ece7de7404f402c23177f0810bf72418` will checkout the
# commit used at the time of writing
git checkout --track origin/2.x
git submodule update --init

# The Sparkle Makefile uses $BUILDDIR as the folder where to create the
# framework. If the value is not set, it'll create a temp dir and use that.
# Setting it her to keep everything in the same place and being able to copy
# the files later.
BUILDDIR=$WORKDIR/Sparkle/DerivedData
mkdir -p $BUILDDIR
BUILDDIR=$BUILDDIR make release

popd > /dev/null

# Replace the existing framework and other required files with the newly
# generated ones.
FRAMEWORKDIR=$BUILDDIR/Build/Products/Release
DIR=`dirname $0`
PROJECTDIR=`cd "${DIR}" ; pwd -P`/..
SPARKLEDIR=$PROJECTDIR/External/Sparkle

rm -rf $SPARKLEDIR/Frameworks/Sparkle.framework
# ditto instead of cp to keep the symlinks instead of duplicating the files
ditto $FRAMEWORKDIR/Sparkle.framework $SPARKLEDIR/Frameworks/Sparkle.framework

BINDIR=$SPARKLEDIR/bin
cp -f $FRAMEWORKDIR/BinaryDelta $BINDIR
cp -f $FRAMEWORKDIR/generate_appcast $BINDIR
cp -f $FRAMEWORKDIR/generate_keys $BINDIR
cp -f $FRAMEWORKDIR/sign_update $BINDIR

XPCDIR=$SPARKLEDIR/XPCServices
rm -rf $XPCDIR/org.sparkle-project.InstallerConnection.xpc
cp -r $FRAMEWORKDIR/org.sparkle-project.InstallerConnection.xpc $XPCDIR/
rm -rf $XPCDIR/org.sparkle-project.InstallerStatus.xpc
cp -r $FRAMEWORKDIR/org.sparkle-project.InstallerStatus.xpc $XPCDIR
rm -rf $XPCDIR/org.sparkle-project.InstallerLauncher.xpc
cp -r $FRAMEWORKDIR/org.sparkle-project.InstallerLauncher.xpc $XPCDIR
