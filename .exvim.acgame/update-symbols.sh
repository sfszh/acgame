#!/bin/bash
export DEST="./.exvim.acgame"
export TOOLS="/home/vagrant/exvim//vimfiles/tools/"
export TMP="${DEST}/_symbols"
export TARGET="${DEST}/symbols"
sh ${TOOLS}/shell/bash/update-symbols.sh
