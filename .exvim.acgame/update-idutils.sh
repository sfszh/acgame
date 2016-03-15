#!/bin/bash
export DEST="./.exvim.acgame"
export TOOLS="/home/vagrant/exvim//vimfiles/tools/"
export TMP="${DEST}/_ID"
export TARGET="${DEST}/ID"
sh ${TOOLS}/shell/bash/update-idutils.sh
