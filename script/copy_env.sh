#!/bin/sh
#
# This script copies the appropriate plist to AppEnv.plist for the project
# being built.

if [ $# -ne 1 ]; then
  echo usage: $0 target-dir
  exit 1
fi

cp "${PROJECT_DIR}/env/${CONFIGURATION}.plist" "$1/AppEnv.plist"
