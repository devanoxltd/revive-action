#!/bin/sh

set -e

echo "Running: revive" $*

revive --version
revive $*
