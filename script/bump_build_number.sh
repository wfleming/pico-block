#!/bin/sh
#
# This script sets the build number / CFBundleVersion in an app's Info.plist
# to an integer build number calculated as the number of git commits on the
# current branch.
#
# This script is intended to be used as an automatic part of XCode builds: to
# use it, create a new "Run Script Phase", and make the content of the script:
#
# ${PROJECT_DIR}/scripts/bump_build_number.sh "${BUILT_PRODUCTS_DIR}/[YOURAPPNAME].app/Info.plist"
#
# The advantage of this way of calculating the build number is that no file
# needs to be checked in with extra build number info, and a given revision
# will always have the same build number when compiled. Disadvantage is
# that two different branches could actually have the same build number
# (though this problem also exists in other versioning methods).


if [ $# -ne 1 ]; then
  echo usage: $0 plist-file
  exit 1
fi

plist="$1"

if [ ! -f $plist ]; then
  echo "$plist does not exist"
  exit 1
fi

# determine version
shortbuildnum=$(/usr/libexec/Plistbuddy -c "Print CFBundleShortVersionString" "$plist")
if [ -z "$shortbuildnum" ]; then
  echo "No build number in $plist"
  exit 2
fi

# this approximates "number of builds" by counting git revisions: Apple's
# TestFlight requires buildnumbers to be increasing integers, so this is
# necessary for all builds
buildnum=$(git rev-list HEAD --count)

# set the version in specified plist
/usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "$plist"

echo "Set build number to $buildnum"
