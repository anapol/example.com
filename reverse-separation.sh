#!/bin/bash

# This script reverses the separation of site-specific configs and data from the main/shared codebase.
#
# The intended usage is to revert the separation commit, pull from upstream and separate again.
# Quick and dirty solution of our current needs...
#
#
# Usage: reverse-separation.sh ezpublish-legacy_checkout_dir
#
# ./reverse-separation.sh ./ezpublish-legacy/
#

function reverse_from_upstream () {
  SUBDIR="$1"
  SUBDIR_UPSTREAM="$SUBDIR".upstream
  if [ -L "$EZPCHECKOUT"/"$SUBDIR" ]; then
   echo Removing link "$EZPCHECKOUT"/"$SUBDIR"
   rm "$EZPCHECKOUT"/"$SUBDIR"
  else
   echo NOT removing link "$EZPCHECKOUT"/"$SUBDIR"
  fi

  if [ -d "$EZPCHECKOUT"/"$SUBDIR_UPSTREAM" -a ! -L "$EZPCHECKOUT"/"$SUBDIR_UPSTREAM" -a ! -e "$EZPCHECKOUT"/"$SUBDIR" ]; then
   echo Moving "$EZPCHECKOUT"/"$SUBDIR_UPSTREAM" to "$EZPCHECKOUT"/"$SUBDIR"
   mv "$EZPCHECKOUT"/"$SUBDIR_UPSTREAM" "$EZPCHECKOUT"/"$SUBDIR"
  else
   echo NOT moving "$EZPCHECKOUT"/"$SUBDIR_UPSTREAM" to "$EZPCHECKOUT"/"$SUBDIR"
  fi
}

EZPCHECKOUT=$1

if [ -z $1 ]; then
 echo "Usage: $0 ezpublish-legacy_checkout_dir"
 exit 1
fi


echo "### Reverting extension(s)"
reverse_from_upstream extension

echo "### Reverting var"
reverse_from_upstream "var"

echo "### Reverting share locale & translations"
reverse_from_upstream "share/locale"
reverse_from_upstream "share/translations"

echo "### Reverting settings"
reverse_from_upstream "settings/siteaccess"
reverse_from_upstream settings/override

echo "Done."

